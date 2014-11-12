package canoe.components
{
	import canoe.components.support.TrackBase;
	
	import flash.events.MouseEvent;
	
	public class HSlider extends TrackBase
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
		
		override protected function getTrackContinousInterval(event:MouseEvent):Number
		{
			if(track.mouseX + track.x > thumb.x)
			{
				return stepSize;
			}
			else
			{
				return - stepSize;
			}
		}
		
		override protected function stage_mouseMoveHandler(event : MouseEvent) : void
		{
			super.stage_mouseMoveHandler(event);
			
			value = initialValue + (stage.mouseX - stageMouseX) * (maximum - minimum) / track.width;
		}
		
		override protected function resetThumbPos():void
		{
			super.resetThumbPos();
			
			thumb.x = track.x + (track.width - thumb.width) * (value - minimum) / (maximum - minimum);
		}
	}
}