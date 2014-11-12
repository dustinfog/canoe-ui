package canoe.components
{
	import flash.events.MouseEvent;
	
	import canoe.core.IItemRenderer;
	import canoe.events.ItemRendererEvent;
	import canoe.state.State;
	
	[Event(name="itemRendererSelected", type="canoe.events.ItemRendererEvent")]
	public class ItemRenderer extends Container implements IItemRenderer
	{
		/**
		 *	构造函数 
		 * 
		 */		
        public function ItemRenderer()
		{
			super();
			
			states = [
				new State("normal"),
				new State("hover"),
				new State("selected")
			];
			
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
		}
		
		private function mouseOutHandler(event:MouseEvent):void
		{
			hovered = false;
			if(!selected)
			{
				currentState = "normal";
			}
		}
		
		private function mouseOverHandler(event:MouseEvent):void
		{
			hovered = true;
			if(!selected)
			{
				currentState = "hover";
			}
		}

        private var _selected : Boolean;
        private var oldSelected : Boolean;
		private var _data : Object;
		private var oldData : Object;
        private var hovered : Boolean;

		/**
		 *	获取或设置是否选中 
		 * @return 
		 * 
		 */		
		public function get selected():Boolean
		{
			return _selected;
		}

		public function set selected(value:Boolean):void
		{
            if(_selected != value)
			{
				_selected = value;
				invalidate();
			}
		}
		
		override public function validate():void
		{
			super.validate();
            
            if(oldSelected != selected)
			{
				if(selected)
				{
					currentState = "selected";
					dispatchEvent(new ItemRendererEvent(ItemRendererEvent.ITEM_RENDERER_SELECTED, this));
				}
				else if(hovered)
				{
					currentState = "hover";
				}
				else
				{
					currentState = "normal";
				}
                
				oldSelected = selected;
			}
		}
	}
}