package canoe.core
{
	import flash.display.Stage;
	import flash.events.Event;

	internal class ElementDelegate
	{
		private var target : IElement;

		/**
		 * 构造函数 
		 * @param target
		 * 
		 */		
		public function ElementDelegate(target : IElement)
		{
			this.target = target;
		}
		/**
		 * 组件的属性失效 
		 * 
		 */
		public function invalidate() : void
		{
			target.addEventListener(Event.RENDER, renderHandler, false, int.MAX_VALUE, true);
			
			var stage : Stage = target.stage;
			if(stage)
			{
				target.addEventListener(Event.ENTER_FRAME, renderHandler, false, int.MAX_VALUE, true);
				stage.invalidate();
			}
		}
		
		private function renderHandler(event : Event) : void
		{
			target.removeEventListener(Event.ENTER_FRAME, renderHandler);
            if(!target.stage) return;
			target.removeEventListener(Event.RENDER, renderHandler);
			target.validate();
		}
	}
}