/**
 * represents a single notification badge
 * @author Sammiches
 */
import gfx.controls.Button;

class com.sammichofdoom.ImprovedNotificationWindow.NotificationIcon extends Button
{
	private var m_mc_background:MovieClip;
	private var m_type:Number;
	
	public function NotificationIcon() 
	{
		super();
	}
	
	public function configUI():Void
	{
		super.configUI();
		
		this["onPressAux"] = handleMousePress;
		
		label = "";
	}
	
	public function set type(type:Number):Void 
	{ 
		m_type = type; 
		invalidate();
	}
	
	public function get type():Number 
	{ 
		return m_type; 
	}
	
	private function draw():Void
	{
		super.draw();
		
		m_mc_background.gotoAndStop(m_type);
	}
	
	//replaced original to handle potential right clicks.
	private function handleMousePress(mouseIdx:Number, keyboardOrMouse:Number, buttonIdx:Number):Void 
	{
		if (_disabled) { return; }
		if (!_disableFocus) { Selection.setFocus(this); }
		setState("down"); // Focus changes in the setState will override those in the changeFocus (above)
		
		dispatchEvent( { 	
			type:"press", 
			mouseIndex:mouseIdx, 
			button:keyboardOrMouse, 
			buttonIdx: ((buttonIdx == undefined) ? Mouse["LEFT"] : buttonIdx)
		});		
		
		if (autoRepeat) 
		{
			buttonRepeatInterval = setInterval(this, "beginButtonRepeat", buttonRepeatDelay, mouseIdx, keyboardOrMouse);
		}
	}
}