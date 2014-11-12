package canoe.components
{
	import canoe.core.CanoeGlobals;
	import canoe.core.IElement;
	import canoe.core.UIElement;
	import canoe.managers.PopUpLayer;
	import canoe.managers.PopUpManager;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class PopUpAnchor extends UIElement
	{
		private var _popUp : DisplayObject;
		private var _displayPopUp : Boolean;

		/**
		 *	获取或设置是否弹出显示 
		 * @return 
		 * 
		 */		
		public function get displayPopUp():Boolean
		{
			return _displayPopUp;
		}

		public function set displayPopUp(value:Boolean):void
		{
			_displayPopUp = value;
			
			if(popUp)
			{
				popUpOrRemove();
			}
		}

		/**
		 *	获取或设置弹出显示的DisplayObject对象
		 * @return 
		 * 
		 */		
		public function get popUp():DisplayObject
		{
			return _popUp;
		}

		public function set popUp(value:DisplayObject):void
		{
			if(_popUp != value)
			{
				_popUp = value;
				
				if(value)
				{
					popUpOrRemove();
				}
			}
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			popUp = child;
			return child;
		}
		
		private function popUpOrRemove() : void
		{
			if(!displayPopUp)
			{
				PopUpManager.removePopUp(popUp);
				popUp.removeEventListener(Event.RESIZE, popUp_resizeHandler);
			}
			else
			{
				if(!popUp.stage)
				{
					PopUpManager.addPopUp(popUp, PopUpLayer.LAYER_WIDGETS);
					popUp.addEventListener(Event.RESIZE, popUp_resizeHandler);
				}
				
				calcPosition();
			}
		}
		
		private function popUp_resizeHandler(event:Event):void
		{
			calcPosition();
		}
		
		private function calcPosition() : void
		{
			var stage : Stage = CanoeGlobals.root.stage;
			var p : Point = localToGlobal(new Point());
            
			var refX : Number = p.x;
			var refY : Number = p.y + height;
			
			if(refX > stage.stageWidth - popUp.width)
			{
				refX = p.x + width - popUp.width;
			}
			
			if(refY > stage.stageHeight - popUp.height)
			{
				refY = Math.max(p.y - popUp.height, 0);
			}
			
			if(popUp is IElement)
			{
				IElement(popUp).minWidth = width;
			}
			popUp.x = refX;
			popUp.y = refY;
		}
	}
}