/**
 * meant to replace the AnimaWheelLink window.
 * @author Sammiches
 */
import com.GameInterface.Claim;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Inventory;
import com.GameInterface.Lore;
import com.GameInterface.Utils;
import com.sammichofdoom.ImprovedNotificationWindow.NotificationIcon;
import com.Utils.ID32;
import gfx.core.UIComponent;
import mx.data.encoders.Num;

class com.sammichofdoom.ImprovedNotificationWindow.ImprovedNotificationWindow extends UIComponent
{
	//statics
	private static var S_ANIMA_WINDOW:String 		= "anima_wheel_gui";
	private static var S_SKILL_HIVE:String 			= "skillhive_window"
	private static var S_CHARACTER_WINDOW:String 	= "character_points_gui";
	private static var S_CHARACTER_SHEET:String 	= "character_sheet";
	private static var S_ACHIEVEMENT_WINDOW:String  = "achievement_lore_window";
	private static var S_PETITION_WINDOW:String 	= "petition_browser";
	private static var S_PETITION_UPDATE:String 	= "HasUpdatedPetition";
	private static var S_CLAIM_WINDOW:String 		= "claim_window";
	
	//pseudo enum corresponds to frame of background
	public static var eInvalid:Number 		= 0;
	public static var eAnima:Number 		= 1;
	public static var eSkill:Number			= 2;
	public static var eLore:Number			= 3;
	public static var eAchievement:Number	= 4;
	public static var eBreaking:Number		= 5;
	public static var eBroken:Number		= 6;
	public static var eTutorial:Number		= 7;
	public static var ePetition:Number		= 8;
	public static var eClaim:Number			= 9;	
	
	public var m_dv_wheelMonitor:DistributedValue;
	public var m_dv_skillMonitor:DistributedValue;
	public var m_dv_achievementMonitor:DistributedValue;
	public var m_dv_petitionWindowMonitor:DistributedValue;
	public var m_dv_petitionUpdateMonitor:DistributedValue;
	public var m_dv_claimMonitor:DistributedValue;
	
	private var m_usedNotifications:Array;
	private var m_unusedNotifications:Array;
	
	//funtimes
	private var m_Character:Character;
	private var m_EquipInventory:Inventory;
	
	private var m_nBrokenItems;
	private var m_nBreakingItems;
	
	public function ImprovedNotificationWindow() 
	{
		super();	
		trace("[ImprovedNotificationWindow][INFO]: Constructor");
		
		m_usedNotifications = new Array();
		m_unusedNotifications = new Array();
		
		m_nBrokenItems = 0;
		m_nBreakingItems = 0;
	}
	
	public function onLoad():Void
	{
		super.onLoad();
		trace("[ImprovedNotificationWindow][INFO]: onLoad");
		
		m_dv_wheelMonitor = DistributedValue.Create(S_ANIMA_WINDOW);
		m_dv_wheelMonitor.SignalChanged.Connect(signalHandlerWheel, this);
		
		m_dv_skillMonitor = DistributedValue.Create(S_CHARACTER_WINDOW);
		m_dv_skillMonitor.SignalChanged.Connect(signalHandlerSkill, this);
		
		m_dv_achievementMonitor = DistributedValue.Create(S_ACHIEVEMENT_WINDOW);
		m_dv_achievementMonitor.SignalChanged.Connect(signalHandlerAchievement, this);
		
		m_dv_petitionWindowMonitor = DistributedValue.Create(S_PETITION_WINDOW);
		m_dv_petitionWindowMonitor.SignalChanged.Connect(signalHandlerPetition, this);
		
		m_dv_petitionUpdateMonitor = DistributedValue.Create(S_PETITION_UPDATE);
		m_dv_petitionUpdateMonitor.SignalChanged.Connect(signalHandlerPetitionUpdate, this);
		
		m_dv_claimMonitor = DistributedValue.Create(S_CLAIM_WINDOW);
		m_dv_claimMonitor.SignalChanged.Connect(signalHandlerClaim, this);
		
		Character.SignalClientCharacterAlive.Connect(signalHandlerCharacterAlive, this);
		Claim.SignalClaimsUpdated.Connect(signalHandlerClaimUpdated, this);
		
		//explicit onLoad calls
		signalHandlerCharacterAlive();
		signalHandlerClaimUpdated();
		signalHandlerPetitionUpdate();
	}
	
	public function configUI():Void
	{
		super.configUI();
		trace("[ImprovedNotificationWindow][INFO]: configUI");
	}
	
	private function draw():Void
	{
		super.draw();
		trace("[ImprovedNotificationWindow][INFO]: draw");
		
		var yPos:Number = 0;
		for (var i:Number = 0; i < m_usedNotifications.length; i++)
		{
			var icon:NotificationIcon = NotificationIcon(m_usedNotifications[i]);
			icon._y = yPos;
			icon._x = -10;
			icon._visible = true;
			yPos -= icon._height + 10; //pad it a bit
		}
	}
	
	//copy pasta from animawheellink.as
	private function UpdateDurability():Void
	{
		trace("[ImprovedNotificationWindow][INFO]: UpdateDurability");
		m_nBrokenItems = 0;
		m_nBreakingItems = 0;
		
		for (var i:Number = 0; i < m_EquipInventory.GetMaxItems(); i++)
		{
			if (m_EquipInventory.GetItemAt(i) != undefined)
			{
				if (m_EquipInventory.GetItemAt(i).IsBroken())
				{
					m_nBrokenItems++;
				}
				else if (m_EquipInventory.GetItemAt(i).IsBreaking())
				{
					m_nBreakingItems++;
				}
			}
		}
		
		UpdateDurabilityNotifications();
	}
	
	function UpdateDurabilityNotifications():Void
	{
		trace("[ImprovedNotificationWindow][INFO]: UpdateDurabilityNotifications");
		var headline:String = "";
		var bodyText:String = "";
		
		if (m_nBreakingItems > 0)
		{
			ShowNotificationIcon(eBreaking, String(m_nBreakingItems), -1);
		}
		else if (m_nBreakingItems == 0)
		{
			HideNotificationIcon(eBreaking);
		}
		
		if (m_nBrokenItems > 0)
		{
			ShowNotificationIcon(eBroken, String(m_nBrokenItems), -1);
		}
		else if (m_nBrokenItems == 0)
		{
			HideNotificationIcon(eBroken);
		}
	}
	
	/****************************************************************************************
	 * Icon Factory																			*
	****************************************************************************************/
	
	private function CreateNotificationIcon():NotificationIcon
	{
		trace("[ImprovedNotificationWindow][INFO]: CreateNotificationIcon #" + m_usedNotifications.length);
		var retVal:NotificationIcon = NotificationIcon(this.attachMovie("NotificationIcon", "NotificationIcon_" + m_usedNotifications.length, this.getNextHighestDepth()));
		retVal._visible = false;
		return retVal;
	}
	
	private function ShowNotificationIcon(type:Number, count:String, id:Number):Void
	{
		trace("[ImprovedNotificationWindow][INFO]: ShowNotificationIcon");
		
		var icon:NotificationIcon = GetNotificationIcon(type);
		if (icon != undefined)
		{		
			//we've already got this icon showing, just update it.
			icon.label = count;
		}
		else
		{
			if (m_unusedNotifications.length > 0)
			{
				icon = NotificationIcon(m_unusedNotifications.pop());
			}
			else
			{
				icon = CreateNotificationIcon();
				icon.addEventListener("press", this, "NotificationPressed");
			}
			
			icon.type = type;
			icon.label = count;
			icon.tagId = id;
			m_usedNotifications.push(icon);
			invalidate();
		}
	}
	
	private function HideNotificationIcon(type:Number):Void 
	{
		trace("[ImprovedNotificationWindow][INFO]: HideNotificationIcon");
		for (var i:Number = 0; i < m_usedNotifications.length; i++)
		{
			var icon:NotificationIcon = NotificationIcon(m_usedNotifications[i]);
			
			if (icon.type == type)
			{
				icon._visible = false;
				Selection.setFocus(null);
				m_unusedNotifications.push(icon);
				m_usedNotifications.splice(i, 1);
				invalidate();
				break;
			}
		}
	}
	
	private function GetNotificationIcon(type:Number):NotificationIcon
	{
		trace("[ImprovedNotificationWindow][INFO]: GetNotificationIcon");
		for (var i:Number = 0; i < m_usedNotifications.length; i++)
		{
			var icon:NotificationIcon = NotificationIcon(m_usedNotifications[i]);
			
			if (icon.type == type)
			{
				return icon;
			}
		}
		
		return undefined;
	}
	
	/****************************************************************************************
	 * Click Behavior																		*
	****************************************************************************************/
	
	private function NotificationPressed(e:Object):Void
	{
		trace("[ImprovedNotificationWindow][INFO]: NotificationPressed");
		var icon:NotificationIcon = NotificationIcon(e.target);

		if (e.buttonIdx == 0)
		{
			switch(icon.type)
			{
			case eSkill:
				DistributedValue.SetDValue(S_CHARACTER_WINDOW, 	!DistributedValue.GetDValue(S_CHARACTER_WINDOW));
				DistributedValue.SetDValue(S_SKILL_HIVE, 		!DistributedValue.GetDValue(S_SKILL_HIVE));
				break;
			case eAnima:
				DistributedValue.SetDValue(S_SKILL_HIVE, 		!DistributedValue.GetDValue(S_SKILL_HIVE));
				break;
			case eLore:
			case eAchievement: 
			case eTutorial:
				Lore.OpenTag(icon.tagId);
				break;
			case eBroken:
			case eBreaking:
				DistributedValue.SetDValue(S_CHARACTER_SHEET, true);
				break;
			case ePetition:
				DistributedValue.SetDValue(S_PETITION_WINDOW, true);
				break;
			case eClaim:
				DistributedValue.SetDValue(S_CLAIM_WINDOW, true);
				break
			case eInvalid:
			default:
				trace("[ImprovedNotificationWindow][Error]: Clicked notification did not have a valid type");
			}
		}

		if (m_Character != undefined) 
		{ 
			m_Character.AddEffectPackage( "sound_fxpackage_GUI_click_tiny.xml" ); 
		}
		
		HideNotificationIcon(icon.type);
	}
	
	/****************************************************************************************
	 * Signal Handlers																		*
	****************************************************************************************/
	private function signalHandlerWheel():Void
	{
		trace("[ImprovedNotificationWindow][INFO]: signalHandlerWheel");
		HideNotificationIcon(eAnima);
	}
	
	private function signalHandlerSkill():Void
	{
		trace("[ImprovedNotificationWindow][INFO]: signalHandlerSkill");
		HideNotificationIcon(eSkill);
	}
	
	private function signalHandlerAchievement():Void
	{
		//more complex due to multiple types in Achievement Window
	}
	
	private function signalHandlerPetition():Void
	{
		trace("[ImprovedNotificationWindow][INFO]: signalHandlerPetition");
		HideNotificationIcon(ePetition);
	}
	
	private function signalHandlerPetitionUpdate():Void
	{
		trace("[ImprovedNotificationWindow][INFO]: signalHandlerPetitionUpdated");
		var visible:Boolean = DistributedValue.GetDValue(S_PETITION_UPDATE);
		
		if (visible)
		{
			ShowNotificationIcon(ePetition, "");
		}
		else
		{
			HideNotificationIcon(ePetition);
		}
	}
	
	private function signalHandlerClaim():Void
	{
		trace("[ImprovedNotificationWindow][INFO]: signalHandlerClaim");
		HideNotificationIcon(eClaim);
	}
	
	private function signalHandlerClaimUpdated():Void
	{
		trace("[ImprovedNotificationWindow][INFO]: signalHandlerClaimUpdated");
		var claimCount = Claim.m_Claims.length;
		var character:Character = Character.GetClientCharacter();
		var canRecieveClaims:Boolean = character.CanReceiveItems();
		
		if (claimCount && canRecieveClaims)
		{
			ShowNotificationIcon(eClaim, String(claimCount), -1);
		}
		else
		{
			HideNotificationIcon(eClaim);
		}
	}
	
	//pretty much copy pasta from AnimaWheelLink.as
	private function signalHandlerCharacterAlive():Void
	{
		trace("[ImprovedNotificationWindow][INFO]: signalHandlerCharacterAlive");
		m_Character = Character.GetClientCharacter();
		
		if (m_Character != undefined)
		{
			m_Character.SignalTokenAmountChanged.Connect(signalHandlerCharacterTokenChanged, this);
			
			signalHandlerCharacterTokenChanged(_global.Enums.Token.e_Anima_Point, m_Character.GetTokens(_global.Enums.Token.e_Anima_Point), 0);
			signalHandlerCharacterTokenChanged(_global.Enums.Token.e_Skill_Point, m_Character.GetTokens(_global.Enums.Token.e_Skill_Point), 0);
			
			Lore.SignalGetAnimationComplete.Connect(signalHandlerLoreAnimComplete, this);
			
			if (m_EquipInventory != undefined)
			{
				m_EquipInventory.SignalItemAdded.Disconnect(signalHandlerItemAdded, this);
				m_EquipInventory.SignalItemLoaded.Disconnect(signalHandlerItemAdded, this);
				m_EquipInventory.SignalItemRemoved.Disconnect(signalHandlerItemAdded, this);
				m_EquipInventory.SignalItemStatChanged.Disconnect(signalHandlerItemChanged, this);
			}
        
			m_EquipInventory = new Inventory(new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, m_Character.GetID().GetInstance()));
			
			if (m_EquipInventory != undefined)
			{
				m_EquipInventory.SignalItemAdded.Connect(signalHandlerItemAdded, this);
				m_EquipInventory.SignalItemLoaded.Connect(signalHandlerItemAdded, this);
				m_EquipInventory.SignalItemRemoved.Connect(signalHandlerItemAdded, this);
				m_EquipInventory.SignalItemStatChanged.Connect(signalHandlerItemChanged, this);
				
				UpdateDurability();
			}
		}
	}
	
	private function signalHandlerCharacterTokenChanged(id:Number, newValue:Number, oldValue:Number):Void
	{
		trace("[ImprovedNotificationWindow][INFO]: signalHandlerCharacterTokenChanged");
		var type:Number = ((id == _global.Enums.Token.e_Anima_Point) ? eAnima : (id == _global.Enums.Token.e_Skill_Point) ? eSkill : 0);
		var total:Number = ((m_Character != undefined) ? m_Character.GetTokens(id) : 0);
		var show:Boolean = ((total > 0) && (oldValue < newValue));
		
		if (show)
		{
			ShowNotificationIcon(type, String(total), -1);
		}
		else
		{
			HideNotificationIcon(type);
		}
	}

	private function signalHandlerLoreAnimComplete(tagId:Number):Void
	{
		trace("[ImprovedNotificationWindow][INFO]: signalHandlerLoreAnimComplete");
		if (tagId == undefined) { return; }
		
		var dataType:Number = Lore.GetTagCategory(tagId);
		
		switch(dataType)
		{
		case _global.Enums.LoreNodeType.e_Achievement:
			{
				if (!Lore.ShouldShowGetAnimation(tagId)) { return; }
				
				ShowNotificationIcon(eAchievement, "", tagId);
			}
			break;
		case _global.Enums.LoreNodeType.e_Lore:
			{
				if (!Lore.ShouldShowGetAnimation(tagId)) { return; }
				
				ShowNotificationIcon(eLore, "", tagId);
			}
			break;
		case _global.Enums.LoreNodeType.e_Tutorial:
			{
				if (!Lore.ShouldShowGetAnimation(tagId) || !Lore.IsVisible(tagId))
				{
					HideNotificationIcon(eTutorial);
					return;
				}
				
				ShowNotificationIcon(eTutorial, "", tagId);
			}
			break;
		case _global.Enums.LoreNodeType.e_Tutorial:
		default:
			//we do nothing
		}
	}
	
	private function signalHandlerItemAdded(inventoryId:ID32, itemPos:Number):Void
	{
		trace("[ImprovedNotificationWindow][INFO]: signalHandlerItemAdded");
		UpdateDurability();
	}
	
	private function signalHandlerItemChanged(inventoryId:ID32, itemPos:Number, stat:Number, newValue:Number):Void
	{
		trace("[ImprovedNotificationWindow][INFO]: signalHandlerItemChanged");
		if (stat == _global.Enums.Stat.e_Durability || stat == _global.Enums.Stat.e_MaxDurability)
		{
			UpdateDurability();
		}
	}
}