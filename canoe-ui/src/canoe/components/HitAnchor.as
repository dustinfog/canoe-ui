package canoe.components
{
	import canoe.core.UIElement;
	import canoe.util.BitmapDataUtil;
	
	import flash.events.Event;

	public class HitAnchor extends UIElement
	{
		/**
		 *	构造函数 
		 * 
		 */		
		public function HitAnchor()
		{
			super();
			
			addEventListener(Event.RESIZE, resizeHandler);
		}
		
		protected function resizeHandler(event:Event):void
		{
			graphics.clear();
			graphics.beginBitmapFill(BitmapDataUtil.blank);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
		}
	}
}