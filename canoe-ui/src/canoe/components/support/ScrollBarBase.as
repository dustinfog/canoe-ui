package canoe.components.support
{
	import flash.events.Event;
	
	import canoe.core.IScrollable;

	public class ScrollBarBase extends TrackBase
	{
		private var _pageSize : int;
		private var pageSizeChanged : Boolean;
		private var limitChanged : Boolean;
        private var _scrollable : IScrollable;
        private var oldScrollable : IScrollable;

		/**
		 *  获取或设置是否滚动
		 * @return 
		 * 
		 */		
		public function get scrollable():IScrollable
		{
			return _scrollable;
		}

		public function set scrollable(value:IScrollable):void
		{
			if(_scrollable != value)
			{
				_scrollable = value;
				invalidate();
			}
		}

		/**
		 *  设置或获取页面大小 
		 * @return 
		 * 
		 */		
		public function get pageSize():int
		{
			return _pageSize;
		}

		public function set pageSize(value:int):void
		{
			if(_pageSize != value)
			{
				_pageSize = value;
                pageSizeChanged = true;
                invalidate();
			}
		}
		
		override public function set maximum(value:Number):void
		{
			if(super.maximum != value)
			{
				super.maximum = value;
				limitChanged = true;
				invalidate();
			}
		}
		
		override public function set minimum(value:Number):void
		{
			if(super.minimum != value)
			{
				super.minimum = value;
				limitChanged = true;
				invalidate();
			}
		}
		
		override protected function track_resizeHandler(event:Event):void
		{
			resetThumbSize();
		}
		
		protected function updateByScrollable(event : Event = null) : void
		{
			
		}
		
		protected function changeScrollable(oldScrollable : IScrollable, newScrollable : IScrollable) : void
		{
			
		}
		
		override public function validate():void
		{
			super.validate();
            
			if(oldScrollable != scrollable)
			{
				if(oldScrollable)
				{
					oldScrollable.removeEventListener(Event.RESIZE, updateByScrollable);
                    oldScrollable.removeEventListener(Event.SCROLL, updateByScrollable);
				}
                
				if(scrollable)
				{
					scrollable.addEventListener(Event.RESIZE, updateByScrollable);
					scrollable.addEventListener(Event.SCROLL, updateByScrollable);
					updateByScrollable();
				}
                
				changeScrollable(oldScrollable, scrollable);
				oldScrollable = scrollable;
			}
			
			if(pageSizeChanged || limitChanged)
			{
                if(maximum <= minimum)
				{
					thumb.visible = false;
                    enabled = false;
				}
				else
				{
					enabled = true;
					thumb.visible = true;
					resetThumbSize();
				}
				pageSizeChanged = false;
				limitChanged = false;
			}
		}
		
		protected function resetThumbSize():void
		{
			
		}
	}
}