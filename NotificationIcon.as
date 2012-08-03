/**
 * represents a single notification badge
 * @author Sammiches
 */
import com.sammichofdoom.ImprovedNotificationWindow.ImprovedNotificationWindow;
import gfx.controls.Button;

class com.sammichofdoom.ImprovedNotificationWindow.NotificationIcon extends Button
{
	private var m_mc_background:MovieClip;
	private var m_type:Number;
	private var m_tagId:Number;
	
	public function NotificationIcon() 
	{
		super();
	}
	
	public function configUI():Void
	{
		super.configUI();
		
		//compiler doesn't like this.onPressAux D:
		this["onPressAux"] = handleMousePress;
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
	
	public function set tagId(tagId:Number):Void 
	{
		m_tagId = tagId;
	}
	
	public function get tagId():Number 
	{
		return m_tagId;
	}
	
	private function draw():Void
	{
		super.draw();
		
		if (type == ImprovedNotificationWindow.eBreaking)
		{
			LoadIcon("rdb:1000624:7363472");
		}
		else if (type == ImprovedNotificationWindow.eBroken)
		{
			LoadIcon("rdb:1000624:7363471");
		}
		else
		{
			m_mc_background["container"].removeMovieClip();
		}
		
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
	
		
	//used for breaking and broken icons
	private function LoadIcon(icon:String)
	{
		var clip:MovieClip = m_mc_background.createEmptyMovieClip("container", m_mc_background.getNextHighestDepth());
		
		var imageLoader:MovieClipLoader = new MovieClipLoader();
		var imageLoaderListener:Object = new Object;
		
		imageLoaderListener.onLoadInit = function(target:MovieClip)
		{
			target._x = 0;
			target._y = 0;
			target._xscale = 48;
			target._yscale = 48;
		}
		
		imageLoader.addListener(imageLoaderListener);
		
		imageLoader.loadClip(icon, clip);   
	}
}