package canoe.components
{
	import flash.events.MouseEvent;
	
	import canoe.components.support.ListBase;
	import canoe.core.IItemRenderer;
	import canoe.events.CanoeEvent;
	import canoe.util.ArrayUtil;
	import canoe.util.Iterator;
	
	/**
	 *	构造函数 
	 * @author Administrator
	 * 
	 */	
	public class List extends ListBase
	{
        private var _multiple : Boolean;
		private var _selectedIndexes : Array;
		private var _selectedItems : Array;
		private var selectedItemsChanged : Boolean;
        private var selectedIndexChanged : Boolean;
		
		/**
		 *	获取或设置  多选内容 Array 
		 * @return 
		 * 
		 */		
		public function get selectedItems():Array
		{
            if(!multiple || selectedIndexes == null || dataProvider == null) return null;
            
			if(selectedItemsChanged)
			{
				_selectedItems = [];
				for each(var index : int in selectedIndexes)
				{
					_selectedItems.push(dataProvider[index]);
				}
				
				selectedItemsChanged = false;
			}
            
			return _selectedItems;
		}

		
		public function set selectedItems(value:Array):void
		{
            if(!multiple || value == null || dataProvider == null)
			{
				selectedIndexes = null;
			}
			else
			{
				var indexes : Array = [];
                for each(var data : Object in value)
				{
					var index : int = dataProvider.indexOf(data);
                    if(index > 0)
					{
						indexes.push(index);
					}
					
					selectedIndexes = indexes;
				}
			}
		}
		/**
		 *	获取或设置选择索引 Array 
		 * @return 
		 * 
		 */		
		public function get selectedIndexes():Array
		{
			return _selectedIndexes;
		}

		public function set selectedIndexes(value:Array):void
		{
            if(!multiple || dataProvider == null || (_selectedIndexes == null && value == null)) return;

			_selectedIndexes = value;
            if(value != null)
			{
				for(var itr : Iterator = new Iterator(value); itr.hasNext();)
				{
                    if(dataProvider.length <= itr.next())
					{
						itr.remove();
					}
				}
			}

			selectedIndexChanged = true;
			selectedItemsChanged = true;
            invalidate();
		}

		override public function get selectedIndex():int
		{
            if(!multiple)
			{
				return super.selectedIndex;
			}
			else if(selectedIndexes && selectedIndexes.length > 0)
			{
				return selectedIndexes[selectedIndexes.length - 1];
			}
			else
			{
				return -1;
			}
		}

		override public function set selectedIndex(value:int):void
		{
            if(dataProvider != null && dataProvider.length > value)
			{
                if(multiple)
				{
					if(value < 0)
					{
						selectedIndexes = null;
					}
					else
					{
						selectedIndexes = [value];
					}
				}
				else if(selectedIndex != value)
				{
					super.selectedIndex = value;
				}
			}
		}

		/**
		 *	获取或设置是否多行 显示
		 * @return 
		 * 
		 */		
		public function get multiple():Boolean
		{
			return _multiple;
		}

		public function set multiple(value:Boolean):void
		{
			_multiple = value;
		}
		
		override protected function itemRenderer_clickHandler(event : MouseEvent):void
		{
			if(multiple)
			{
				var index : int = dataProvider.indexOf(IItemRenderer(event.currentTarget).data);
				var indexes : Array = selectedIndexes;
				
				if(indexes == null)
				{
					indexes = [index];
				}
				else if(indexes.indexOf(index) >= 0)
				{
					ArrayUtil.removeElements(indexes, index);
				}
				else
				{
					indexes.push(index);
				}
				
				selectedIndexes = indexes;
			}
			else
			{
				super.itemRenderer_clickHandler(event);
			}
		}

		override protected function switchSelected():void
		{
			if(multiple && selectedIndexChanged)
			{
				for(var i : uint = 0, length : uint = dataProvider.length; i < length; i ++)
				{
					var itemRenderer : IItemRenderer = dataGroup.getChildAt(i) as IItemRenderer;
					if(!itemRenderer)
						continue;
					if(selectedIndexes && selectedIndexes.indexOf(i) >= 0)
					{
						itemRenderer.selected = true;
					}
					else
					{
						itemRenderer.selected = false;
					}
				}
				
				dispatchEvent(new CanoeEvent(CanoeEvent.INDEX_CHANGED));
				selectedIndexChanged = false;
			}
			else
			{
				super.switchSelected();
			}
		}
	}
}