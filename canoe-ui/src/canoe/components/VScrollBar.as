package canoe.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import canoe.components.support.ScrollBarBase;
	import canoe.core.IScrollable;
	
	public class VScrollBar extends ScrollBarBase
	{
		private var stageMouseY : Number;
		private var initialValue : Number;
        private var thumbY : Number;

		override protected function thumb_mouseDownHandler(event : MouseEvent) : void
		{
			super.thumb_mouseDownHandler(event);
            
			stageMouseY = stage.mouseY;
			initialValue = value;
			thumbY = thumb.y;
		}
        
		override protected function updateByScrollable(event : Event = null) : void
		{
			height = scrollable.height;
			minimum = 0;
			maximum = scrollable.maxScrollTop;
            pageSize = scrollable.scrollPageSizeV;
           
			value = scrollable.scrollTop;
		}
        
		override public function set value(v : Number) : void
		{
			if(super.value != v)
			{
				if(scrollable)
				{
					scrollable.scrollTop = v;
				}
                
				super.value = v;
			}
		}
		
		override protected function stage_mouseMoveHandler(event : MouseEvent) : void
		{
			super.stage_mouseMoveHandler(event);
			
			value = initialValue + (stage.mouseY - stageMouseY) * (maximum - minimum)/ (track.height - thumb.height);
		}
		
		override protected function getTrackContinousInterval(event:MouseEvent):Number
		{
			if(track.mouseY + track.y > thumb.y)
			{
				return pageSize;
			}
			else
			{
				return - pageSize;
			}
		}
		
		override protected function changeScrollable(oldScrollable:IScrollable, newScrollable:IScrollable):void
		{
			if(oldScrollable)
				oldScrollable.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			
			if(newScrollable)
				newScrollable.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
		}
		
        override protected function resetThumbSize():void
		{
            super.resetThumbSize();
            
			thumb.height = pageSize * track.height / (maximum - minimum + pageSize);
		}
        
		override protected function resetThumbPos():void
		{
            super.resetThumbPos();
            
			thumb.y = track.y + (track.height - thumb.height) * value / (maximum - minimum);
		}
	}
}