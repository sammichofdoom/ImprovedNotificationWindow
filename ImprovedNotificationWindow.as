/**
 * meant to replace the AnimaWheelLink window.
 * @author Sammiches
 */
import com.GameInterface.DistributedValue;
import com.GameInterface.Log;
import com.sammichofdoom.ImprovedNotificationWindow.NotificationIcon;
import gfx.core.UIComponent;

class com.sammichofdoom.ImprovedNotificationWindow.ImprovedNotificationWindow extends UIComponent
{
	//statics
	private static var S_ANIMA_WINDOW:String 		= "anima_wheel_gui";
	private static var S_CHARACTER_WINDOW:String 	= "character_points_gui";
	private static var S_CHARACTER_SHEET:String 	= "character_sheet";
	private static var S_ACHIEVEMENT_WINDOW:String  = "achievement_lore_window";
	private static var S_PETITION_WINDOW:String 	= "petition_browser";
	private static var S_PETITION_UPDATE:String 	= "HasUpdatedPetition";
	private static var S_CLAIM_WINDOW:String 		= "claim_window";
	
	//pseudo enum corresponds to frame of background
	public static var eInvalid:Number 		= -1;
	public static var eAnima:Number 		= 0;
	public static var eSkill:Number			= 1;
	public static var eLore:Number			= 2;
	public static var eAchievement:Number	= 3;
	public static var eBreaking:Number		= 4;
	public static var eBroken:Number		= 5;
	public static var eTutorial:Number		= 6;
	public static var ePetition:Number		= 7;
	public static var eClaim:Number			= 8;	
	
	
	//stage vars
	
	private var m_dv_wheelMonitor:DistributedValue;
	private var m_dv_skillMonitor:DistributedValue;
	private var m_dv_achievementMonitor:DistributedValue;
	private var m_dv_petitionWindowMonitor:DistributedValue;
	private var m_dv_petitionUpdateMonitor:DistributedValue;
	private var m_dv_claimMonitor:DistributedValue;
	
	private var m_usedNotifications:Array;
	private var m_unusedNotifications:Array;
	
	public function ImprovedNotificationWindow() 
	{
		super();	
		Log.Print(3, "ImprovedNotificationWindow", "Constructor");
		
		m_usedNotifications = new Array;
		m_unusedNotifications = new Array;
	}
	
	public function onLoad():Void
	{
		super.onLoad();
		
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
	}
	
	public function configUI():Void
	{
		super.configUI();
	}
	
	/****************************************************************************************
	 * Icon Factory																			*
	****************************************************************************************/
	
	private function CreateNotificationIcon():NotificationIcon
	{
		var retVal:NotificationIcon = NotificationIcon(createInstance(this, "NotificationIcon", 
														"NotificationIcon_" + m_usedNotifications.length++, 
														 this.getNextHighestDepth()));
		retVal._visible = false;
		return retVal;
	}
	
	private function ShowNotificationIcon(type:Number, count:Number):Void
	{
		var icon:NotificationIcon = undefined;
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
		icon.label = String(count);
		
		icon._visible = true;
		m_usedNotifications.push(icon);
	}
	
	private function HideNotificationIcon(type:Number):Void 
	{
		for (var i:Number = 0; i < m_usedNotifications.length; i++)
		{
			var icon:NotificationIcon = NotificationIcon(m_usedNotifications[i]);
			
			if (icon.type == type)
			{
				icon._visible = false;
				m_unusedNotifications.push(icon);
				m_usedNotifications.splice(i, 1);
				break;
			}
		}
	}
	
	/****************************************************************************************
	 * Click Behavior																		*
	****************************************************************************************/
	
	private function NotificationPressed(e:Object):Void
	{
		var icon:NotificationIcon = NotificationIcon(e.target);
		
		if (e.buttonIdx == Mouse["LEFT"])
		{
			switch(icon.type)
			{
			case eSkill:
				DistributedValue.SetDValue(S_CHARACTER_WINDOW, 	!DistributedValue.GetDValue(S_CHARACTER_WINDOW));
				//intentional fall through
			case eAnima:
				DistributedValue.SetDValue(S_ANIMA_WINDOW, 		!DistributedValue.GetDValue(S_ANIMA_WINDOW));
				break;
			case eLore:
			case eAchievement: 
			case eTutorial:
				//open lore
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
		
		HideNotificationIcon(icon.type);
	}
	
	/****************************************************************************************
	 * Signal Handlers																		*
	****************************************************************************************/
	private function signalHandlerWheel():Void
	{
		
	}
	
	private function signalHandlerSkill():Void
	{
		
	}
	
	private function signalHandlerAchievement():Void
	{
		
	}
	
	private function signalHandlerPetition():Void
	{
		
	}
	
	private function signalHandlerPetitionUpdate():Void
	{
		
	}
	
	private function signalHandlerClaim():Void
	{
		
	}
}