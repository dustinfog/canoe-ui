package canoe.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import canoe.core.IFactory;
	import canoe.core.IItemRenderer;
	import canoe.events.ItemRendererEvent;
	import canoe.util.ObjectPool;
	
	[Event(name="itemRendererAdded", type="canoe.events.ItemRendererEvent")]
	[Event(name="itemRendererRemoved", type="canoe.events.ItemRendererEvent")]
	public class DataGroup extends Container
	{
		/**
		 * 构造函数 
		 * 
		 */		
		public function DataGroup()
		{
			super();
			
			addEventListener(Event.REMOVED_FROM_STAGE, removeFrameStageHandler);
		}
		
		protected function removeFrameStageHandler(event:Event):void
		{
			clear();
			invalidate();
		}
		
		private var _dataProvider : Array;
		private var dataProviderChanged : Boolean;
		private var _itemRenderer : *;
		private var itemRendererChanged : Boolean;
		
		/**
		 * 获取或设置绑定数据 
		 * @return 
		 * 
		 */		
		public function get dataProvider():Array
		{
			return _dataProvider;
		}
		
		[Editable]
		public function set dataProvider(value:Array):void
		{
			_dataProvider = value;
			dataProviderChanged = true;
			invalidate();
		}
		
		/**
		 * 获取或设置 itemRenderer 
		 * @return 
		 * 
		 */		
		public function get itemRenderer():*
		{
			return _itemRenderer;
		}
		
		[Editable]
		public function set itemRenderer(value:*):void
		{
			if(_itemRenderer != value)
			{
				_itemRenderer = value;
				itemRendererChanged = true;
				invalidate();
			}
		}
		/**
		 *强制刷新数据 
		 * 
		 */		
		public function refresh() : void
		{
			dataProvider = dataProvider;
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if(!(child is IItemRenderer))
			{
				throw new Error("DataGroup must add a IItemRenderer instance as Child");
			}
			
			return super.addChild(child);
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if(!(child is IItemRenderer))
			{
				throw new Error("DataGroup must add a IItemRenderer instance as Child");
			}
			
			return super.addChildAt(child, index);
		}
		
		override public function validate():void
		{
			super.validate();
			
			if(itemRendererChanged || dataProviderChanged)
			{
				if(itemRendererChanged || dataProvider == null)
				{
					clear();
				}
				
				refreshItemRenderers();

				itemRendererChanged = false;
				dataProviderChanged = false;
			}
		}
		
		private function clear() : void
		{
			while(numChildren != 0)
			{
				removeItemRenderer(getChildAt(0) as IItemRenderer);
			}
			
			itemRendererChanged = true;
		}
		
		private function refreshItemRenderers() : void
		{
			if(itemRenderer == null || dataProvider == null) return;
			
			for(var i : uint = 0; i < dataProvider.length; i ++)
			{
				var renderer : IItemRenderer;
				if(numChildren > i)
				{
					renderer = getChildAt(i) as IItemRenderer;
				}
				else
				{
					renderer = createItemRenderer();
				}
				
				renderer.data = dataProvider[i];
			}
			
			while(numChildren > dataProvider.length)
			{
				removeItemRenderer(getChildAt(numChildren - 1) as IItemRenderer);
			}
		}

		private function createItemRenderer() : IItemRenderer
		{
			var renderer : IItemRenderer;
			if(itemRenderer is IFactory)
			{
				renderer = IFactory(itemRenderer).newInstance();
			}
			else
			{
				renderer = ObjectPool.create(itemRenderer);
			}
			addChild(renderer as DisplayObject);
			renderer.addEventListener(ItemRendererEvent.ITEM_RENDERER_SELECTED, renderer_selectedHandler);
			dispatchEvent(new ItemRendererEvent(ItemRendererEvent.ITEM_RENDERER_ADDED, renderer));
			
			return renderer;
		}
		
		private function removeItemRenderer(itemRenderer : IItemRenderer) : void
		{
			itemRenderer.data = null;
			itemRenderer.selected = false;
			removeChild(itemRenderer as DisplayObject);
			itemRenderer.removeEventListener(ItemRendererEvent.ITEM_RENDERER_SELECTED, renderer_selectedHandler);
			dispatchEvent(new ItemRendererEvent(ItemRendererEvent.ITEM_RENDERER_REMOVED, itemRenderer));
			if(!(itemRenderer is IFactory))
			{
				ObjectPool.collect(itemRenderer);
			}
		}
		
		private function renderer_selectedHandler(event : ItemRendererEvent):void
		{
			var renderer : IItemRenderer = event.itemRenderer;
			if(width < contentWidth)
			{
				scrollLeft = Math.min(renderer.x, Math.max(scrollLeft, renderer.x + renderer.width - width));
			}
			
			if(height < contentHeight)
			{
				scrollTop = Math.min(renderer.y, Math.max(scrollTop, renderer.y + renderer.height - height));
			}
		}
	}
}