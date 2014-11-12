package canoe.components.support
{
	import canoe.components.Button;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class TrackBase extends Range
	{
		
		/**
		 *  滚动条上的拖拽的Button按钮 
		 */		
		[Part]
		public var thumb : Button;
		/**
		 *  上下Button按钮 
		 */		
		[Part]
		public var track : Button;
        
        private var valueChanged : Boolean;

		/**
		 * 构造函数 
		 * 
		 */		
		public function TrackBase()
		{
			super();
			
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
		}
		
		override public function set value(v : Number) : void
		{
			if(super.value != v)
			{
				super.value = v;
				valueChanged = true;
				invalidate();
			}
		}
		
		protected function resetThumbPos():void
		{
		}
		
		protected function mouseWheelHandler(event:MouseEvent):void
		{
			value -= event.delta * stepSize * snapInterval;
            event.stopPropagation();
		}
		
		override protected function partAdded(instance:Object):void
		{
			if(instance == thumb)
			{
				thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
				thumb.addEventListener(Event.RESIZE, thumb_resizeHandler);
			}
			else if(instance == track)
			{
				track.addEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler);
				track.addEventListener(Event.RESIZE, track_resizeHandler);
			}
			else
			{
				super.partAdded(instance);
			}
		}
		
		override protected function partRemoved(instance:Object):void
		{
			if(instance == thumb)
			{
				thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
				thumb.removeEventListener(Event.RESIZE, thumb_resizeHandler);
			}
			else if(instance == track)
			{
				track.removeEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler);
				track.addEventListener(Event.RESIZE, track_resizeHandler);
			}
			else
			{
				super.partRemoved(instance);
			}
		}
		
		protected function track_resizeHandler(event:Event):void
		{
			resetThumbPos();
		}
		
		private function thumb_resizeHandler(event:Event):void
		{
			resetThumbPos();
		}
		
		protected function thumb_mouseDownHandler(event : MouseEvent) : void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseReleaseHandler);
		}
		
		protected function stage_mouseMoveHandler(event : MouseEvent) : void
		{
			
		}
		
		protected function getTrackContinousInterval(event:MouseEvent):Number
		{
			return 0;
		}
		
		private function track_mouseDownHandler(event : MouseEvent) : void
		{
			continuousChange(event, getTrackContinousInterval(event));
		}
		
		private function stage_mouseReleaseHandler(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseReleaseHandler);
		}
        
		override public function validate():void
		{
            super.validate();

			if(valueChanged)
			{
				resetThumbPos();
				valueChanged = false;
			}
		}
	}
}