package canoe.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import canoe.core.IContainer;
	import canoe.core.IElement;
	import canoe.core.ILayout;
	import canoe.core.IScrollable;
	import canoe.core.UIElement;
	import canoe.layout.BasicLayout;
	import canoe.util.ArrayUtil;
	import canoe.util.MathUtil;

	[Event(name="scroll", type="flash.events.Event")]
	public class Container extends UIElement implements IContainer, IScrollable
	{
			
		private var _backgroundColor : int;
		
        private var _backgroundAlpha : Number = 0;
			
		private var _borderWidth : Number = 0;
			
		private var _borderRadius : Number = 0;
			
		private var _borderColor : int;
				
		private var _borderAlpha : Number = 1;
			
		private var backgroundChanged : Boolean;
		
		private var _clipAndScroll : Boolean;
		
		/**
		 *  显示时是否将超出大小的部分裁掉 
		 * @return 
		 * 
		 */		
		public function get clipAndScroll():Boolean
		{
			return _clipAndScroll;
		}

		public function set clipAndScroll(value:Boolean):void
		{
			if(clipAndScroll != value)
			{
				_clipAndScroll = value;
				scrollingChanged = true;
				invalidate();
			}
		}

		/**
		 * 	设置或获取背景颜色值，改变背景颜色值时，backgroundChanged为true.
		 * @param v 只支持十六进制颜色值。不支持具有指定名称的颜色（例如 blue）。颜色以下面的格式写入：#FF0000。 
		 * 
		 */		
		public function set backgroundColor(v : int) : void
		{
			if(_backgroundColor != v)
			{
				_backgroundColor = v;
                backgroundChanged = true;
                invalidate();
			}
		}
			
		public function get backgroundColor() : int
		{
			return _backgroundColor;
		}
		/**
		 * 	设置或获取背景的Alpha
		 * @param v Alpha值。 Numnber类型数据
		 * 
		 */		
		public function set backgroundAlpha(v : Number) : void
		{
			if(_backgroundAlpha != v)
			{
				_backgroundAlpha = v;
				backgroundChanged = true;
				invalidate();
			}
		}
       
		public function get backgroundAlpha() : Number
		{
			return _backgroundAlpha;
		}
		/**
		 *	获取或设置边框圆角半径 
		 * @param v Numnber类型数据
		 * 
		 */		
		public function set borderRadius(v : Number) : void
		{
			if(_borderRadius != v)
			{
				_borderRadius = v;
                backgroundChanged = true;
                invalidate();
			}
		}		
		public function get borderRadius() : Number
		{
			return _borderRadius;
		}
		/**
		 *	设置或获取边框宽度 
		 * @param v 边框宽度，Number类型数据
		 * 
		 */		
		public function set borderWidth(v : Number) : void
		{
			if(_borderWidth != v)
			{
				_borderWidth = v;
                backgroundChanged = true;
                invalidate();
			}
		}	
		public function get borderWidth() : Number
		{
			return _borderWidth;
		}
		/**
		 *	设置或获取变宽的颜色值。 
		 * @param v 十六进制颜色值，如：#FF0000
		 * 
		 */		
		public function set borderColor(v : int) : void
		{
			if(_borderColor != v)
			{
				_borderColor = v;
				backgroundChanged = true;
				invalidate();
			}
		}		
		public function get borderColor() : int
		{
			return _borderColor;
		}
		/**
		 *	设置或获取边框Alpha 
		 * @param v Number数据类型
		 * 
		 */		
		public function set borderAlpha(v : Number) : void
		{
			if(_borderAlpha != v)
			{
				_borderAlpha = v;
                backgroundChanged = true;
				invalidate();
			}
		}
	
		public function get borderAlpha() : Number
		{
			return _borderAlpha;
		}
		
        private var _scrollLeft : Number = 0;
	
		private var _scrollTop : Number = 0;
	
        private var scrollingChanged : Boolean;
		
		/**
		 * 	获取最大离注册点往左的像素值。
		 * @return Number数据类型
		 * 
		 */		
		public function get maxScrollLeft():Number
		{
			return contentWidth > width ? contentWidth - width : 0;
		}
		/**
		 * 	获取最大离注册点往上的像素值。
		 * @return  Number数据类型
		 * 
		 */        
		public function get maxScrollTop():Number
		{
			return contentHeight > height ? contentHeight - height : 0;
		}
		/**
		 * 	获取水平滚动页面的大小
		 * @return 
		 * 
		 */		
		public function get scrollPageSizeH() : Number{
			return width;
		}
		/**
		 *获取竖直滚动页面大小 
		 * @return 
		 * 
		 */		
		public function get scrollPageSizeV() : Number
		{
			return height;
		}
        
		/**
		 *	获取或设置当前的 在容器中 水平位置
		 * 
		 */		
		public function get scrollLeft():Number
		{
            return _scrollLeft;
		}
        
		public function set scrollLeft(value:Number):void
		{
            if(_scrollLeft != value)
			{
                _scrollLeft = value;
				scrollingChanged = true;
				invalidate();
			}
		}
		/**
		 *	获取或设置当前的 在容器中垂直位置
		 * @return 
		 * 
		 */        
		public function get scrollTop():Number
		{
			return _scrollTop;
		}

		public function set scrollTop(value:Number):void
		{
			value = Math.max(0, value);
			if(_scrollTop != value)
			{
				_scrollTop = value;
				scrollingChanged = true; 
				invalidate();	
			}
		}
		
		private var _layout : ILayout;
		private var layoutChanged : Boolean;
		private var defaultLayout : ILayout;
		
		private var _contentWidth : Number = 0;
		private var _contentHeight : Number = 0;

		/**
		 *	获取或设置content的宽度 
		 * @param v
		 * 
		 */		
		public function set contentWidth(v : Number) : void
		{
            if(contentWidth != v)
			{
				_contentWidth = v;
				invalidateWidth();
			}
		}

		override public function get contentWidth() : Number
		{
			return _contentWidth;
		}
		/**
		 *	获取或设置content的高度 
		 * @param v
		 * 
		 */	
		public function set contentHeight(v : Number) : void
		{
            if(contentHeight != v)
			{
				_contentHeight = v;
				invalidateHeight();
			}
		}

		override public function get contentHeight() : Number
		{
			return _contentHeight;	
		}
		/**
		 *	获取或设置布局 
		 * @return 
		 * 
		 */		
		public function get layout():ILayout
		{
			return _layout;
		}

		public function set layout(value:ILayout):void
		{
			if(_layout != value)
			{
				if(_layout != null)
				{
					_layout.container = null;
				}

				_layout = value;
                if(_layout)
				{
					_layout.container = this;
				}

				invalidateLayout();
			}
		}
		
        private var oldContentWidth : Number,
			oldContentHeight : Number,
			oldWidth : Number,
			oldHeight : Number,
			oldScrollLeft : Number,
			oldScrollTop : Number;
		
		override public function validate():void
		{
			super.validate();
            
			if(!layout)
			{
				layout = new BasicLayout();
			}
			
			if(layeringIsDirty)
			{
				var layeringChildren : Array = children.concat();
				layeringChildren.sort(sortHandler);

				for(var i : uint = 0; i < layeringChildren.length; i ++)
				{
					$setChildIndex(layeringChildren[i], i);
				}
				
				layeringIsDirty = false;
			}
            
			if(layoutChanged)
			{
				layout.updateLayout();
				layoutChanged = false;
			}
			
            var resized : Boolean;
            if(oldWidth != width || oldHeight != height)
			{
                oldWidth = width;
				oldHeight = height;
				invalidateLayout();
				resized = true;
			}
			
			if(clipAndScroll && (oldContentWidth != contentWidth || oldContentHeight != contentHeight || resized || scrollingChanged))
			{
				oldContentWidth = contentWidth;
				oldContentHeight = contentHeight;
				
                scrollLeft = Math.max(0, Math.min(scrollLeft, maxScrollLeft));
                scrollTop = Math.max(0, Math.min(scrollTop, maxScrollTop));
                
				if(contentWidth > width || contentHeight > height)
				{
					scrollRect = new Rectangle(scrollLeft, scrollTop, width, height);
				}
				else
				{
					scrollRect = null;
				}
				
				scrollingChanged = false;
                dispatchEvent(new Event(Event.SCROLL));
			}
            
            if(backgroundChanged || resized)
			{
				graphics.clear();

                if(borderWidth != 0)
				{
					graphics.lineStyle(borderWidth, borderColor, borderAlpha);
				}

                if(backgroundAlpha != 0)
				{
					graphics.beginFill(backgroundColor, backgroundAlpha);
				}
				graphics.drawRoundRect(0, 0, width, height, borderRadius, borderRadius);
				
				if(backgroundAlpha != 0)
				{
					graphics.endFill();
				}

				backgroundChanged = false;
				resized = false;
			}
		}
		
		private function sortHandler(display1 : DisplayObject, display2 : DisplayObject) : int
		{
			var depth1 : int = (display1 is IElement) ? IElement(display1).depth : 0;
			var depth2 : int = (display2 is IElement) ? IElement(display2).depth : 0;
			
			return MathUtil.getSign((depth1 - depth2) || (getChildIndex(display1) - getChildIndex(display2)));
		}
		
		private var children : Array = [];
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			var oldParent : Container = child.parent as Container;
			if(oldParent)
			{
				oldParent.removeChild(child);
			}

			$addChild(child);
			
			if(children.indexOf(child) < 0)
			{
				children.push(child);
				invalidateLayering();
				invalidateLayout();
			}
			return child;
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			var oldParent : Container = child.parent as Container;
			if(oldParent)
			{
				oldParent.removeChild(child);
			}

			$addChild(child);

			ArrayUtil.addElementAt(children, child, index);

			invalidateLayering();
			invalidateLayout();			
			return child;
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			$removeChild(child);
			ArrayUtil.removeElements(children, child);
			invalidateLayout();
			return child;
		}
        
		override public function removeChildAt(index:int):DisplayObject
		{
			var child : DisplayObject = children[index];
			$removeChild(child);
			ArrayUtil.removeElementAt(children, index);
			invalidateLayout();
			return child;
		}
		
		public function removeAll() : void
		{
			while(numChildren)
			{
				removeChildAt(0);
			}
		}
		
		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
		{
			swapChildrenAt(children.indexOf(child1), children.indexOf(child2));
		}
		
		override public function swapChildrenAt(index1:int, index2:int):void
		{
			ArrayUtil.swapElementAt(children, index1, index2);
			
			invalidateLayering();
			invalidateLayout();
		}
		
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			ArrayUtil.setElementIndex(children, child, index);
			
			invalidateLayering();
			invalidateLayout();
		}

		override public function getChildIndex(child:DisplayObject):int
		{
			return children.indexOf(child);
		}
		
		override public function getChildAt(index:int):DisplayObject
		{
			return children[index];
		}
		
		override public function get numChildren():int
		{
			return children.length;
		}

		private function $addChild(child : DisplayObject) : DisplayObject
		{
			return super.addChild(child);
		}
		
		private function $removeChild(child : DisplayObject) : DisplayObject
		{
			return super.removeChild(child);
		}
		
		private function $setChildIndex(child : DisplayObject, index : int) : void
		{
			super.setChildIndex(child, index);
		}
		
		private function $getChildIndex(child : DisplayObject) : int
		{
			return super.getChildIndex(child);
		}
		
		public function invalidateLayout() : void
		{
			if(!layout || !layout.updating)
			{
				layoutChanged = true;
				invalidate();
			}
		}
		
		private var layeringIsDirty : Boolean;
		public function invalidateLayering() : void
		{
			layeringIsDirty = true;
			invalidate();
		}
	}
}