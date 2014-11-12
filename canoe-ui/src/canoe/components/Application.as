package canoe.components
{
	import canoe.core.CanoeGlobals;
	import canoe.core.UIElement;
	import canoe.managers.PopUpManager;
	import canoe.util.NumberUtil;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Application extends Container
	{
		
		override protected function create():void
		{
            super.create();
            
			if(!CanoeGlobals.root)
			{
				var newRoot : Sprite = new Sprite();
				CanoeGlobals.root = newRoot;
				stage.addChild(newRoot);
				CanoeGlobals.root.addChild(this);
				PopUpManager.initialize(newRoot);
			}
            
			if(!CanoeGlobals.application)
			{
				CanoeGlobals.application = this;
			}
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			resetSize();
			stage.addEventListener(Event.RESIZE, resetSize);
			stage.addEventListener(MouseEvent.CLICK, stopDisabledMouseEvents, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stopDisabledMouseEvents, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDisabledMouseEvents, true);
		}
		
		private function stopDisabledMouseEvents(event:MouseEvent):void
		{
            if(event.target is UIElement && !UIElement(event.target).enabled) 
			{
				event.preventDefault();
				event.stopImmediatePropagation();
                
				stage.dispatchEvent(event);
			}
		}
		
		private function resetSize(event:Event = null):void
		{
			width = NumberUtil.restrict(stage.stageWidth, minWidth, maxWidth);
			height = NumberUtil.restrict(stage.stageHeight, minHeight, maxHeight);
			
			x = (stage.stageWidth - width) / 2;
			y = (stage.stageHeight - height) / 2;
		}
	}
}