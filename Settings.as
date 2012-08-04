/**
 * ...
 * @author Sammiches
 */
import com.sammichofdoom.ImprovedNotificationWindow.ImprovedNotificationWindow;
import com.Utils.LDBFormat;
import gfx.controls.CheckBox;
import gfx.core.UIComponent;
import gfx.events.EventTypes;
 
class com.sammichofdoom.ImprovedNotificationWindow.Settings extends UIComponent
{
	private var eAnima:CheckBox;
	private var eSkill:CheckBox;
	private var eLore:CheckBox;
	private var eAchievement:CheckBox;
	private var eBreaking:CheckBox;
	private var eBroken:CheckBox;
	private var eTutorial:CheckBox;
	private var ePetition:CheckBox;
	private var eClaim:CheckBox;
	private var eCash:CheckBox;
	private var eMajorAnima:CheckBox;
	private var eMinorAnima:CheckBox;
	private var eSoloToken:CheckBox;
	private var eEgypToken:CheckBox;
	private var eTranToken:CheckBox;
	private var eHeroicToken:CheckBox;
	private var eShowBadge:CheckBox;
	
	private var m_CheckBoxs:Array;
	
	public function Settings() 
	{
		super();
		
		m_CheckBoxs = new Array(undefined, eAnima, eSkill, eLore, eAchievement,
			eBreaking, eBroken, eTutorial, ePetition, eClaim, eCash,
			eMajorAnima, eMinorAnima, eSoloToken, eEgypToken, eTranToken,
			eHeroicToken, eShowBadge);
	}
	
	public function onLoad():Void
	{
		super.onLoad();
	}
	
	public function configUI():Void
	{
		super.configUI();
		
		eAnima.label = LDBFormat.LDBGetText("GenericGUI", "AnimaWheelLink_AnimaPointsHeader");
		eSkill.label = LDBFormat.LDBGetText("GenericGUI", "AnimaWheelLink_SkillPointsHeader");
		eLore.label = LDBFormat.LDBGetText("GenericGUI", "Lore_AllCaps");
		eAchievement.label = LDBFormat.LDBGetText("GenericGUI", "Achievements_AllCaps");
		eBreaking.label = LDBFormat.LDBGetText("GenericGUI", "Notifications_BreakingItemsHeader");
		eBroken.label = LDBFormat.LDBGetText("GenericGUI", "Notifications_BrokenItemsHeader");
		eTutorial.label = LDBFormat.LDBGetText("GenericGUI", "Notifications_TutorialHeader");
		ePetition.label = LDBFormat.LDBGetText("GenericGUI", "Notifications_PetitionHeader");
		eClaim.label = LDBFormat.LDBGetText("GenericGUI", "Notifications_ClaimHeader");
		eCash.label = LDBFormat.LDBGetText("Tokens", "Token" + _global.Enums.Token.e_Cash);
		eMajorAnima.label = LDBFormat.LDBGetText("Tokens", "Token" + _global.Enums.Token.e_Major_Anima_Fragment);
		eMinorAnima.label = LDBFormat.LDBGetText("Tokens", "Token" + _global.Enums.Token.e_Minor_Anima_Fragment);
		eSoloToken.label = LDBFormat.LDBGetText("Tokens", "Token" + _global.Enums.Token.e_Solomon_Island_Token);
		eEgypToken.label = LDBFormat.LDBGetText("Tokens", "Token" + _global.Enums.Token.e_Egypt_Token);
		eTranToken.label = LDBFormat.LDBGetText("Tokens", "Token" + _global.Enums.Token.e_Transylvania_Token);
		eHeroicToken.label = LDBFormat.LDBGetText("Tokens", "Token" + _global.Enums.Token.e_Heroic_Token);
		eShowBadge.label = "Show Badge";
		
		Redraw()
	}
	
	public function Redraw():Void
	{
		for (var i:Number = 0; i < m_CheckBoxs.length; i++)
		{
			var rdio:CheckBox = CheckBox(m_CheckBoxs[i]);
			if (rdio != undefined)
			{
				if (rdio.hasEventListener(EventTypes.CLICK))
				{
					rdio.removeEventListener(EventTypes.CLICK);
				}
				
				rdio.addEventListener(EventTypes.CLICK, this, "CheckBoxClicked");
				rdio.selected = ImprovedNotificationWindow(_parent._parent).IsTypeActive(i);
				rdio["optionIndex"] = i;
			}
		}
	}
	
	private function CheckBoxClicked(e:Object):Void
	{
		var rdio:CheckBox = CheckBox(e.target);
		var optionIndex:Number = rdio["optionIndex"];
		ImprovedNotificationWindow(_parent._parent).SettingChanged(optionIndex, rdio.selected);
		
		Selection.setFocus(null);
	}
}