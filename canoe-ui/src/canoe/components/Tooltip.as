package canoe.components
{
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import canoe.managers.PopUpLayer;
	import canoe.managers.PopUpManager;

	public class Tooltip extends SkinnableContainer
	{
		private static const TIMEOUT : uint = 500;
		private var timer : int;
		private var deferring : Boolean;
		/**
		 *	构造函数 
		 * 
		 */		
		public function Tooltip()
		{
			super();
			
			mouseEnabled = false;
			addEventListener(Event.RESIZE, updatePosition);
		}
		
		override public function set data(value:*):void
		{
			super.data = value;
			if(value)
			{
				show();
			}
			else
			{
				hide();
			}
		}
		/**
		 *	显示tip
		 * 
		 */		
		public function show() : void
		{
			if(PopUpManager.isPopUp(this))
			{
				updatePosition();
			}
			else if(!deferring)
			{
				timer = setTimeout(doShow, TIMEOUT);
				deferring = true;
			}
		}
		/**
		 *	隐藏tip 
		 * 
		 */		
		public function hide() : void
		{
			stopDeferring();
			PopUpManager.removePopUp(this);
		}
		
		private function doShow() : void
		{
			stopDeferring();
			PopUpManager.addPopUp(this, PopUpLayer.LAYER_WIDGETS);
			updatePosition();
		}
		
		private function stopDeferring() : void
		{
			if(deferring)
			{
				deferring = false;
				clearTimeout(timer);
			}
		}
		
		private function updatePosition(event : Event = null) : void
		{
			if(!PopUpManager.isPopUp(this)) return;

			var refX : Number = stage.mouseX + 10;
			var refY : Number = stage.mouseY + 15;
			
			if(refX > stage.stageWidth - width)
			{
				refX = stage.mouseX - width - 5;
			}
			
			if(refY > stage.stageHeight - height)
			{
				refY = Math.max(stage.mouseY - height - 5, 0);
			}
			
			x = refX;
			y = refY;
		}
	}
}