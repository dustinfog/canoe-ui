package canoe.layout.support
{
	import canoe.components.Container;
	import canoe.core.IElement;
	import canoe.core.ILayout;

	public class LayoutBase implements ILayout
	{
        private static var count : int = 0;
		private var _container : Container;
		private var _updating : Boolean;
		private var _layoutElements : Array;

		public function get updating():Boolean
		{
			return _updating;
		}

		public function set container(value : Container) : void
		{
			if(container != value)
			{
				_container = value;
			}
		}

		public function get container() : Container
		{
			return _container;
		}
		
		protected function get layoutElements() : Array
		{
			return _layoutElements;
		}
        
		protected function doUpdateLayout() : void
		{
			
		}
        
		protected function measureSize() : void
		{
			
		}
		
		protected function invalidate() : void
		{
			if(container)
			{
				container.invalidateLayout();
			}
		}
		
		public function updateLayout() : void
		{
			_updating = true;
			_layoutElements = [];
			preprocess();
			measureSize();
			doUpdateLayout();
			_layoutElements = null;
			_updating = false;
		}
		
		private function preprocess() : void
		{
			var children : Array = [];
			for(var i : uint = 0; i < container.numChildren; i ++)
			{
				var child : IElement = container.getChildAt(i) as IElement;
				if(child && child.visible)
				{
					children.push(child);
					layoutElements.push(child);
				}
			}
		}
	}
}