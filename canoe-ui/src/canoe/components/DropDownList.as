package canoe.components
{
	import canoe.components.support.ListBase;
	import canoe.events.CanoeEvent;
	import canoe.util.EventUtil;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	public class DropDownList extends ListBase
	{
		/**
		 *	构造函数 
		 * 
		 */		
		public function DropDownList()
		{
			super();

			addEventListener(CanoeEvent.INDEX_CHANGED, indexChangedHandler);
		}
		/**
		 *	Buttton类型按钮 
		 */		
		[Part]
		public var button : Button;

		private function indexChangedHandler(event:Event):void
		{
			setButtonLabel();
		}
		
		override protected function partAdded(instance:Object):void
		{
			super.partAdded(instance);
			
			if(instance == button)
			{
				setButtonLabel();
				button.addEventListener(MouseEvent.MOUSE_DOWN, switchStatus);
			}
			else if(dataGroup == instance)
			{
				dataGroup.addEventListener(MouseEvent.MOUSE_DOWN, EventUtil.stopPropagation);
				dataGroup.addEventListener(MouseEvent.CLICK, hide);
			}
			else if(vScrollBar == instance)
			{
				vScrollBar.addEventListener(MouseEvent.CLICK, EventUtil.stopPropagation);
				vScrollBar.addEventListener(MouseEvent.MOUSE_DOWN, EventUtil.stopPropagation);
			}
			else if(hScrollBar == instance)
			{
				hScrollBar.addEventListener(MouseEvent.CLICK, EventUtil.stopPropagation);
				hScrollBar.addEventListener(MouseEvent.MOUSE_DOWN, EventUtil.stopPropagation);
			}
		}
		
		override protected function partRemoved(instance:Object):void
		{
			super.partRemoved(instance);
			if(instance == button)
			{
				button.removeEventListener(MouseEvent.MOUSE_DOWN, switchStatus);
			}
			else if(dataGroup == instance)
			{
				dataGroup.removeEventListener(MouseEvent.MOUSE_DOWN, EventUtil.stopPropagation);
				dataGroup.removeEventListener(MouseEvent.CLICK, hide);
			}
			else if(vScrollBar == instance)
			{
				vScrollBar.removeEventListener(MouseEvent.CLICK, EventUtil.stopPropagation);
				vScrollBar.removeEventListener(MouseEvent.MOUSE_DOWN, EventUtil.stopPropagation);
			}
			else if(hScrollBar == instance)
			{
				hScrollBar.removeEventListener(MouseEvent.CLICK, EventUtil.stopPropagation);
				hScrollBar.removeEventListener(MouseEvent.MOUSE_DOWN, EventUtil.stopPropagation);
			}

		}
		
		private function setButtonLabel() : void
		{
			if(button)
			{
				if(selectedItem)
				{
					button.label = selectedItem.toString();
				}
				else
				{
					button.label = "";
				}
			}
		}
		
		private var _open : Boolean;
		
		private function get open():Boolean
		{
			return _open;
		}
		
		private function set open(value:Boolean):void
		{
			_open = value;
			invalidateSkinState();
		}
		
		private function switchStatus(event:Event):void
		{
			event.stopPropagation();

			if(!open)
			{
				open = true;
				stage.addEventListener(MouseEvent.MOUSE_DOWN, hide);
			}
			else
			{
				hide(event);
			}
		}
		
		private function hide(event:Event):void
		{
			open = false;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
		}
		
		override protected function get currentSkinState():String
		{
			if(!enabled)
				return "disabled";
			if(open)
				return "open";
			return "normal";
		}
		
		private var keyboardString : String = "";
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ENTER)
			{
				switchStatus(event);
			}
			else if(event.keyCode >= 48 && event.keyCode <= 57 || event.keyCode >= 65 && event.keyCode <= 90)
			{
				keyboardString += String.fromCharCode(event.charCode);
				invalidate();
			}
			else
			{
				super.keyDownHandler(event);
			}
		}
		
		override public function validate():void
		{
			super.validate();
			
			if(dataProvider && dataProvider.length > 0)
			{
				if(selectedIndex == -1)
				{
					selectedIndex = 0;
				}
				
				if(keyboardString.length != 0)
				{
					for( var i : uint = 0; i < dataProvider.length; i ++)
					{
						if(String(dataProvider[i]).indexOf(keyboardString) == 0)
						{
							selectedIndex = i;
							break;
						}
					}
					
					keyboardString = "";
				}
			}
		}
	}
}