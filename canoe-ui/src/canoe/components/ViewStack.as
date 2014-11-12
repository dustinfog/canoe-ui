package canoe.components
{
	import canoe.events.CanoeEvent;
	
	import flash.display.DisplayObject;

	[Event(name="indexChanged", type="canoe.events.CanoeEvent")]
	public class ViewStack extends Container
	{
		private var _selectedIndex : int;
		private var oldSelectedView : DisplayObject;

		/**
		 *	获取或设置当前选中索引 
		 * @return 
		 * 
		 */		
		public function get selectedIndex():int
		{
			return _selectedIndex; 
		}

		public function set selectedIndex(value:int):void
		{
			if(selectedIndex != value)
			{
				_selectedIndex = value;	
				invalidate();
			}
		}
		
		/**
		 *	获取或设置当前选中的view对象 
		 * @param value
		 * 
		 */		
		public function set selectedView(value : DisplayObject) : void
		{
			if(selectedView != value)
			{
				if(value == null)
				{
					selectedIndex = -1;
				}
				else if(value.parent != this)
				{
					addChild(value);
					selectedIndex = numChildren - 1;
				}
				else
				{
					selectedIndex = getChildIndex(value);
				}
			}
		}

		public function get selectedView() : DisplayObject
		{
			return selectedIndex == -1 ? null : getChildAt(selectedIndex);
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			child.visible = false;
			return super.addChild(child);
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			child.visible = false;
			return super.addChildAt(child, index);
		}
		
		override public function validate():void
		{
			super.validate();
			
			if(selectedIndex >= numChildren)
			{
				selectedIndex = 0;
			}
			
			if(oldSelectedView != selectedView)
			{	
				if(oldSelectedView && oldSelectedView.parent == this)
				{
					oldSelectedView.visible = false;
				}
				
				if(selectedView)
				{
					selectedView.visible = true;
				}

				dispatchEvent(new CanoeEvent(CanoeEvent.INDEX_CHANGED));
				oldSelectedView = selectedView;
			}
		}
	}
}