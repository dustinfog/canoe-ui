package canoe.components
{
	import canoe.components.support.ScrollBarBase;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class HScrollBar extends ScrollBarBase
	{
		private var stageMouseX : Number;
		private var initialValue : Number;
        private var thumbX : Number;

		override protected function thumb_mouseDownHandler(event : MouseEvent) : void
		{
			super.thumb_mouseDownHandler(event);
            
			stageMouseX = stage.mouseX;
			initialValue = value;
			thumbX = thumb.x;
		}
        
		override protected function updateByScrollable(event : Event = null) : void
		{
			width = scrollable.width;
			minimum = 0;
			maximum = scrollable.maxScrollLeft;
            pageSize = scrollable.scrollPageSizeH;
			value = scrollable.scrollLeft;
		}
        
		override public function set value(v : Number) : void
		{
			if(super.value != v)
			{
				if(scrollable)
				{
					scrollable.scrollLeft = v;
				}
                
				super.value = v;
			}
		}
		
		override protected function stage_mouseMoveHandler(event : MouseEvent) : void
		{
			super.stage_mouseMoveHandler(event);
			
			value = initialValue + (stage.mouseX - stageMouseX) * (maximum - minimum)/ (track.width - thumb.width);
		}
		
		override protected function getTrackContinousInterval(event:MouseEvent):Number
		{
			if(track.mouseX + track.x > thumb.x)
			{
				return pageSize;
			}
			else
			{
				return - pageSize;
			}
		}
		
        override protected function resetThumbSize():void
		{
            super.resetThumbSize();
            
			thumb.width = pageSize * track.width / (maximum - minimum + pageSize);
		}
        
		override protected function resetThumbPos():void
		{
            super.resetThumbPos();
            
			thumb.x = track.x + (track.width - thumb.width) * value / (maximum - minimum);
		}
	}
}