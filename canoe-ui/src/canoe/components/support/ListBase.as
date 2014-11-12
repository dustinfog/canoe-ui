package canoe.components.support
{
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import canoe.components.DataGroup;
	import canoe.components.HScrollBar;
	import canoe.components.SkinnableComponent;
	import canoe.components.VScrollBar;
	import canoe.core.IItemRenderer;
	import canoe.core.ILayout;
	import canoe.events.CanoeEvent;
	import canoe.events.ItemRendererEvent;
	import canoe.util.ObjectUtil;

    [Event(name="indexChanged", type="canoe.events.CanoeEvent")]
	public class ListBase extends SkinnableComponent
	{
		/**
		 *构造函数 
		 * 
		 */		
		public function ListBase()
		{
			super();
			addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		private var dataGroupProperties : Object = {};
		/**
		 * 列表，包括呈示器和数据。
		 */		
		[Part]
		public var dataGroup : DataGroup;
		/**
		 *纵向滚动条 
		 */		
		[Part]
		public var vScrollBar : VScrollBar;
		/**
		 * 横向滚动条
		 */		
		[Part]
		public var hScrollBar : HScrollBar;

		/**
		 *获取或设置 itemRenderer
		 * @param v
		 * 
		 */		
		[Editable]
		public function set itemRenderer(v : *) : void
		{
			if(dataGroup)
			{
				dataGroup.itemRenderer = v;
			}
			else
			{
				dataGroupProperties.itemRenderer = v;
			}
		}
		
		public function get itemRenderer() : *
		{
			if(dataGroup)
			{
				return dataGroup.itemRenderer;
			}
			else
			{
				return dataGroupProperties.itemRenderer;
			}
		}
		/**
		 *获取或设置绑定数据 
		 * @param v
		 * 
		 */		
		[Editable]
		public function set dataProvider(v : Array) : void
		{
			if(dataGroup)
			{
				dataGroup.dataProvider = v;
			}
			dataGroupProperties.dataProvider = v;
			selectedIndex = -1;
		}
		
		public function get dataProvider() : Array
		{
			if(dataGroup)
			{
				return dataGroup.dataProvider;
			}
			else
			{
				return dataGroupProperties.dataProvider;
			}
		}
		/**
		 *重置。 
		 * 
		 */		
		public function refresh() : void
		{
			if(dataGroup)
			{
				dataGroup.refresh();
			}
		}
		/**
		 *获取或设置布局 
		 * @return 
		 * 
		 */		
		public function get layout():ILayout
		{
			if(dataGroup)
			{
				return dataGroup.layout;
			}
			else
			{
				return dataGroupProperties.layout;
			}
		}
		
		public function set layout(value:ILayout):void
		{
			if(dataGroup)
			{
				dataGroup.layout = value;
			}
			dataGroupProperties.layout = value;
		}
		
		private var _selectedIndex : int = - 1;
		private var oldSelectedIndex : int = -1;

		override protected function partAdded(instance:Object):void
		{
			if(dataGroup == instance)
			{
				ObjectUtil.overrideProperties(dataGroup, dataGroupProperties);
				dataGroup.addEventListener(ItemRendererEvent.ITEM_RENDERER_ADDED, itemRendererAddedHandler);
				dataGroup.addEventListener(ItemRendererEvent.ITEM_RENDERER_REMOVED, itemRendererRemovedHandler);
			}
			else
			{
				super.partAdded(instance);
			}
			
			if(dataGroup)
			{
				if(vScrollBar)
				{
					vScrollBar.scrollable = dataGroup;
				}
				
				if(hScrollBar)
				{
					hScrollBar.scrollable = dataGroup;
				}
			}
		}
		
		override protected function partRemoved(instance:Object):void
		{
			if(dataGroup == instance)
			{
				dataGroup.dataProvider = null;
				dataGroup.itemRenderer = null;
				dataGroup.removeEventListener(ItemRendererEvent.ITEM_RENDERER_ADDED, itemRendererAddedHandler);
				dataGroup.removeEventListener(ItemRendererEvent.ITEM_RENDERER_REMOVED, itemRendererRemovedHandler);
			}
			else if(instance == vScrollBar)
			{
				vScrollBar.scrollable = null;
			}
			else if(instance == hScrollBar)
			{
				hScrollBar.scrollable = null;
			}
			else
			{
				super.partRemoved(instance);
			}
		}
		
		private function itemRendererRemovedHandler(event:ItemRendererEvent):void
		{
			var itemRenderer : IItemRenderer = event.itemRenderer;
			itemRenderer.selected = false;
			itemRenderer.removeEventListener(MouseEvent.CLICK, itemRenderer_clickHandler);
		}
		
		private function itemRendererAddedHandler(event:ItemRendererEvent):void
		{
			var itemRenderer : IItemRenderer = event.itemRenderer;
			if(selectedIndex == dataGroup.getChildIndex(itemRenderer as DisplayObject))
			{
				itemRenderer.selected = true;
			}

			itemRenderer.addEventListener(MouseEvent.CLICK, itemRenderer_clickHandler);
		}
		/**
		 *获取或设置选中的item 
		 * @return 
		 * 
		 */		
		public function get selectedItem():Object
		{
			if(selectedIndex == -1)
			{
				return null;
			}
			else
			{
				return dataProvider[selectedIndex];
			}
		}

		public function set selectedItem(value:Object):void
		{
			if(dataProvider != null)
			{
				selectedIndex = dataProvider.indexOf(value);
			}
		}
		/**
		 *获取或设置 选中的索引
		 * @return 
		 * 
		 */
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}

		public function set selectedIndex(value:int):void
		{
            if(_selectedIndex != value && dataProvider && value < dataProvider.length)
			{
				_selectedIndex = value;
				invalidate();
			}
		}
		
        override public function validate():void
		{
			super.validate();
			
			switchSelected();
		}
		
		protected function switchSelected() : void
		{
			if(oldSelectedIndex != selectedIndex)
			{
				var itemRenderer : IItemRenderer = dataGroup.getChildAt(oldSelectedIndex) as IItemRenderer;
				if(itemRenderer != null)
				{
					itemRenderer.selected = false;
				}

				itemRenderer = dataGroup.getChildAt(selectedIndex) as IItemRenderer;
				if(itemRenderer)
				{
					itemRenderer.selected = true;
				}

				oldSelectedIndex = selectedIndex;				
				dispatchEvent(new CanoeEvent(CanoeEvent.INDEX_CHANGED));
			}
		}
		
		protected function itemRenderer_clickHandler(event : MouseEvent):void
		{
			selectedItem = IItemRenderer(event.currentTarget).data;
			
		}
		
		protected function keyDownHandler(event:KeyboardEvent):void
		{
			if(!dataProvider) return;
			if(event.keyCode == Keyboard.DOWN)
			{
				if(selectedIndex < dataProvider.length -1)
				{
					selectedIndex ++;
				}
				else
				{
					selectedIndex = 0;
				}
			}
			else if(event.keyCode == Keyboard.UP)
			{
				if(selectedIndex > 0)
				{
					selectedIndex --;
				}
				else
				{
					selectedIndex = dataProvider.length - 1;
				}
			}
		}
	}
}