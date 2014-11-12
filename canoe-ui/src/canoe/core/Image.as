package canoe.core
{
	import canoe.events.CanoeEvent;
	import canoe.events.StateEvent;
	import canoe.managers.StateManager;
	import canoe.state.State;
	import canoe.util.ArrayUtil;
	import canoe.util.NumberUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	[Event(name="resize", type="flash.events.Event")]
	[Event(name="move", type="canoe.events.CanoeEvent")]
	[Event(name="creationComplete", type="canoe.events.CanoeEvent")]
	[Event(name="stateChange", type="canoe.events.StateEvent")]
	[Event(name="show", type="canoe.events.CanoeEvent")]
	[Event(name="hide", type="canoe.events.CanoeEvent")]
	[Event(name="dataChanged", type="canoe.events.CanoeEvent")]
	[Event(name="change", type="flash.events.Event")]
	public class Image extends Bitmap implements IElement
	{
		/**
		 *  构造函数 
		 * @param bitmapData 位图
		 * @param pixelSnapping 像素
		 * @param smoothing 平滑
		 * 
		 */		
		public function Image(bitmapData:BitmapData=null, pixelSnapping:String="auto", smoothing:Boolean=false)
		{
			super(null, pixelSnapping, smoothing);
			delegate = new ElementDelegate(this);
			
			this.bitmapData = bitmapData;
			addEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}

		private function addedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			create();
			if(currentState == null && states && states.length > 0)
			{
				currentState = State(states[0]).name;
			}
			dispatchEvent(new CanoeEvent(CanoeEvent.CREATION_COMPLETE));
		}
		
		private function removeFromStageHandler(event:Event):void
		{
			measuredWidth = NaN;
			measuredHeight = NaN;
			
			if($bitmapData)
			{
				dispose$();
				bitmapDataChanged = true;
				invalidate();
			}
		}
		
		protected function create() : void
		{
			
		}
		
        private var _clipRect : Rectangle;
        private var clipRectChanged : Boolean;
		private var _scale9Grid : Rectangle;
        private var scale9GridChanged : Boolean;
		private var _bitmapData : BitmapData;
		private var $bitmapData : BitmapData;
        private var bitmapDataChanged : Boolean;
		
		
		public function get clipRect():Rectangle
		{
			return _clipRect;
		}
		
		public function set clipRect(value:Rectangle):void
		{
            _clipRect = value;
			clipRectChanged = true;
			measureContentSize();
			invalidate();
		}
		
		override public function set scale9Grid(v:Rectangle):void
		{
			_scale9Grid = v; 
			scale9GridChanged = true;
			invalidate();
		}
        
		override public function get scale9Grid() : Rectangle
		{
			return _scale9Grid;
		}
		
		override public function set bitmapData(value:BitmapData):void
		{
			_bitmapData = value;
            bitmapDataChanged = true;
			measureContentSize();
			invalidate();
		}
		
		override public function get bitmapData() : BitmapData
		{
			return _bitmapData;
		}
		
		public function validate() : void
		{
			if(bindingsExpired)
			{
				applyBindings(this);
				bindingsExpired = false;
			}
			
			if(origX != x || origY != y)
			{
				dispatchEvent(new CanoeEvent(CanoeEvent.MOVE));
				origX = x;
				origY = y;
			}
			
            var resized : Boolean = false;
			if(origWidth != width || origHeight != height)
			{
               	dispatchEvent(new Event(Event.RESIZE));
				origWidth = width;
				origHeight = height;
				resized = true;
			}

			if(bitmapDataChanged || clipRectChanged || scale9GridChanged || resized)
			{
				if(bitmapData == null)
				{
					dispose$();
				}
				else if(!clipRect && !scale9Grid && width == contentWidth && height == contentHeight)
				{
					dispose$();
					super.bitmapData = bitmapData;
				}
				else
				{
					renderBitmapData();
				}
                
				clipRectChanged = false;
				scale9GridChanged = false;
			}
		}

		private function renderBitmapData() : void
		{
			if(int(width) == 0 || int(height) == 0) return;
			
            clear$(width, height);
			
			var sourceX : int, sourceY : int, sourceWidth : int, sourceHeight : int;
			
			if(clipRect)
			{
				sourceX = clipRect.x;
				sourceY = clipRect.y;
				sourceWidth = clipRect.width;
				sourceHeight = clipRect.height;
			}
			else
			{
				sourceX = 0;
				sourceY = 0;
				sourceWidth = bitmapData.width;
				sourceHeight = bitmapData.height;
			}
			
			if(scale9Grid)
			{
				var rightColWidth : Number = sourceWidth - scale9Grid.right;
				var bottomRowHeight : Number = sourceHeight - scale9Grid.bottom;
				
				var innerWidth : Number = width - scale9Grid.left - rightColWidth;
				var innerHeight : Number = height - scale9Grid.top - bottomRowHeight;
				var innerScaleX : Number = innerWidth / scale9Grid.width;
				var innerScaleY : Number = innerHeight / scale9Grid.height;
				
	            var tX1 : Number = innerWidth - sourceX - scale9Grid.width;
				var tY1 : Number = innerHeight - sourceY - scale9Grid.height;
				var tX2 : Number = scale9Grid.x - scale9Grid.x * innerScaleX - sourceX * innerScaleX;
				var tY2 : Number = scale9Grid.y - scale9Grid.y * innerScaleY - sourceY * innerScaleY;
				var tX3 : Number = scale9Grid.x + innerWidth;
				var tY3 : Number = scale9Grid.y + innerHeight;
	            
				// Draw Top-Left
				$bitmapData.copyPixels(bitmapData,
					newRectangle(sourceX, sourceY, scale9Grid.x, scale9Grid.y),
					newPoint());
	            
				// Draw Top-Right
				$bitmapData.copyPixels(bitmapData,
					newRectangle(sourceX + scale9Grid.right, sourceY, rightColWidth, scale9Grid.y),
					newPoint(tX3));
				
				// Draw Bottom-Left
				$bitmapData.copyPixels(bitmapData,
					newRectangle(sourceX, sourceY + scale9Grid.bottom, scale9Grid.x, bottomRowHeight),
					newPoint(0, tY3));
	
				// Draw Bottom-Right
				$bitmapData.copyPixels(bitmapData,
					newRectangle(sourceX + scale9Grid.right, sourceY + scale9Grid.bottom, rightColWidth, bottomRowHeight),
					newPoint(tX3, tY3));
				
				// Draw Top-Center
				$bitmapData.draw(bitmapData,
					newMatrix(innerScaleX, 0, 0, 1, tX2, -sourceY),
					null, null,
					newRectangle(scale9Grid.x, 0, innerWidth, scale9Grid.y));
	            
				// Draw Middle-Left
				$bitmapData.draw(bitmapData,
					newMatrix(1, 0, 0, innerScaleY, -sourceX, tY2),
					null, null,
					newRectangle(0, scale9Grid.y, scale9Grid.x, innerHeight));
	            
				// Draw Middle-Right
				$bitmapData.draw(bitmapData,
					newMatrix(1, 0, 0, innerScaleY, tX1, tY2),
					null, null,
					newRectangle(tX3, scale9Grid.y, rightColWidth, innerHeight));
	            
				// Draw Bottom-Center
				$bitmapData.draw(bitmapData,
					newMatrix(innerScaleX, 0, 0, 1, tX2, tY1),
					null, null,
					newRectangle(scale9Grid.x, tY3, innerWidth, bottomRowHeight));
	            
				// Draw Middle-Center
				$bitmapData.draw(bitmapData,
					newMatrix(innerScaleX, 0, 0, innerScaleY, tX2, tY2),
					null, null,
					newRectangle(scale9Grid.x, scale9Grid.y, innerWidth, innerHeight));
			}
			else
			{
				var scaleX : Number = width / contentWidth;
				var scaleY : Number = height / contentHeight;
				
				$bitmapData.draw(bitmapData,
					newMatrix(scaleX, 0, 0, scaleY, - sourceX * scaleX, - sourceY * scaleY),
					null, null,
					newRectangle(0, 0, width, height));
			}
		}
        
		private function clear$(width : int, height : int) : void
		{
			if($bitmapData && $bitmapData.width == width && $bitmapData.height == height)
			{
				$bitmapData.fillRect(newRectangle(0, 0, width, height), 0);
			}
			else
			{
				dispose$();
				$bitmapData = new BitmapData(width, height, true, 0);
				super.bitmapData = $bitmapData;
			}
		}
		
		private function dispose$() : void
		{
			if($bitmapData)
			{
				$bitmapData.dispose();
				$bitmapData = null;
				super.bitmapData = null;
			}
		}
        
        private var tmpRect : Rectangle = new Rectangle();
		private function newRectangle(x : Number, y : Number, width : Number, height : Number) : Rectangle
		{
			tmpRect.x = x;
			tmpRect.y = y;
			tmpRect.width = width;
			tmpRect.height = height;
			
			return tmpRect;
		}
        
		private var tmpMatrix : Matrix = new Matrix();
        private function newMatrix(a : Number, b : Number, c : Number, d : Number, tx : Number, ty : Number) : Matrix
		{
			tmpMatrix.a = a;
			tmpMatrix.b = b;
			tmpMatrix.c = c;
			tmpMatrix.d = d;
			tmpMatrix.tx = tx;
			tmpMatrix.ty = ty;
            
			return tmpMatrix;
		}
        
		private var tmpPoint : Point = new Point();
		private function newPoint(x : Number = 0, y : Number = 0) : Point
		{
			tmpPoint.x = x;
			tmpPoint.y = y;
			
			return tmpPoint;
		}
		
		private var _contentWidth : Number = 0;
		private var _contentHeight : Number = 0;
		private var oldContentWidth : Number;
		private var oldContentHeight : Number;

		public function get contentWidth() : Number
		{
			return _contentWidth;
		}
		
		public function get contentHeight() : Number
		{
			return _contentHeight;
		}

		protected function measureContentSize() : void
		{
			if(clipRect)
			{
				_contentWidth = clipRect.width;
				_contentHeight = clipRect.height;
			}
			else if(bitmapData)
			{
				_contentWidth = bitmapData.width;
				_contentHeight = bitmapData.height;
			}
			else
			{
				_contentWidth = 0;
				_contentHeight = 0;
			}
			
			if(oldContentWidth != contentWidth)
			{
				invalidateWidth();
				oldContentWidth = contentWidth;
			}
			
			if(oldContentHeight != contentHeight)
			{
				invalidateHeight();
				oldContentHeight = contentHeight;
			}
		}
		
		// implements IElement
		protected var delegate : ElementDelegate;
		
		private var origX : Number = 0;
		private var origY : Number = 0;
		private var origWidth : Number = 0;
		private var origHeight : Number = 0;
		
		private var _left : Number;
		private var _right : Number;
		private var _top : Number;
		private var _bottom : Number;
		
		private var _hCenter : Number;
		private var _vCenter : Number;
		
		private var _depth : int;
		private var _owner : IContainer;
		private var _document : Object;
		private var _id : String;
		private var _states : Array;
		private var _currentState : String;
		
		public function get states():Array
		{
			return _states;
		}
		
		public function set states(value:Array):void
		{
			_states = value;
		}
		
		public function get currentState():String
		{
			return _currentState;
		}
		
		public function set currentState(value:String):void
		{
			if(_currentState != value)
			{
				StateManager.switchState(this, value);
				_currentState = value;
				dispatchEvent(new StateEvent(StateEvent.STATE_CHANGE));
			}
		}
		
		public function get owner():IContainer
		{
			return _owner || (parent as IContainer);
		}
		
		public function set owner(value:IContainer):void
		{
			_owner = value;
		}
		
		public function get document() : Object
		{
			return _document;
		}
		
		public function set document(v : Object) : void
		{
			_document = v;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function set id(value:String):void
		{
			if(_id != value)
			{
				_id = value;
			}
		}
		
		public function get depth():int
		{
			return _depth;
		}
		
		public function set depth(value:int):void
		{
			if(depth != value)
			{
				_depth = value;
				invalidateParentLayering()
			}
		}
		
		public function get vCenter():Number
		{
			return _vCenter;
		}
		
		public function set vCenter(value:Number):void
		{
			if(vCenter != value)
			{
				_vCenter = value;
				invalidateParentLayout();
			}
		}
		
		public function get hCenter():Number
		{
			return _hCenter;
		}
		
		public function set hCenter(value:Number):void
		{
			if(hCenter != value)
			{
				_hCenter = value;
				invalidateParentLayout();
			}
		}
		
		public function get autoLeft() : Boolean
		{
			return isNaN(_left);
		}
		
		public function get autoTop() : Boolean
		{
			return isNaN(_top);
		}
		
		public function get autoRight() : Boolean
		{
			return isNaN(_right);
		}
		
		public function get autoBottom() : Boolean
		{
			return isNaN(_bottom);
		}
		
		public function get bottom():Number
		{
			return (autoBottom && parent) ? (parent.height - top - height) : _bottom;
		}
		
		public function set bottom(value:Number):void
		{
			if(_bottom != value)
			{
				_bottom = value;
				invalidateParentLayout();
			}
		}
		
		public function get top():Number
		{
			return autoTop ? y : _top;
		}
		
		public function set top(value:Number):void
		{
			if(_top != value)
			{
				_top = value;
				invalidateParentLayout();
			}
		}
		
		public function get right():Number
		{
			return (autoRight && parent) ? (parent.width - left - width) : _right;
		}
		
		public function set right(value:Number):void
		{
			if(_right != value)
			{
				_right = value;
				invalidateParentLayout();
			}
		}
		
		public function get left():Number
		{
			return autoLeft ? x : _left;
		}
		
		public function set left(value:Number):void
		{
			if(_left != value)
			{
				_left = value;
				invalidateParentLayout();
			}
		}
		
		override public function set x(v : Number) : void
		{
			if(x != v)
			{
				super.x = v;
				invalidate();
				invalidateParentLayout();
			}
		}
		
		override public function set y(v : Number) : void
		{
			if(y != v)
			{
				super.y = v;
				invalidate();
				invalidateParentLayout();
			}
		}
		
		override public function set visible(value:Boolean):void
		{
			if(super.visible != value)
			{
				super.visible = value;
				if(value)
				{
					dispatchEvent(new CanoeEvent(CanoeEvent.SHOW));
				}
				else
				{
					dispatchEvent(new CanoeEvent(CanoeEvent.HIDE));
				}
				invalidateParentLayout();
			}
		}

		
		private var _data : Object;
		
		public function get data():*
		{
			return _data;
		}
		
		public function set data(value:*):void
		{
			_data = value;
			dispatchEvent(new CanoeEvent(CanoeEvent.DATA_CHANGED));
			invalidateBindings();
		}
		
		private var bindings : Array = [];
		public function registerBinding(binding:IBinding):void
		{
			bindings.push(binding);
		}
		
		public function unregisterBinding(binding:IBinding):void
		{
			ArrayUtil.removeElements(bindings, binding);
		}
		
		private function applyBindings(document:Object):void
		{
			for each(var binding : IBinding in bindings)
			{
				binding.apply();
			}
		}
		
		private var _width : Number;
		private var _measuredWidth : Number;
		private var _minWidth : Number;
		private var _maxWidth : Number;
		private var explicitWidth : Number;
		private var widthIsDirty : Boolean = true;
		
		override public function set width(v : Number) : void
		{
			if(explicitWidth != v)
			{
				explicitWidth = v;
				invalidateWidth();
			}
		}
		
		override public function get width():Number
		{
			if(widthIsDirty)
			{
				if(!isNaN(explicitWidth))
				{
					_width = explicitWidth;
				}
				else if(!isNaN(_measuredWidth))
				{
					_width = _measuredWidth;
				}
				else
				{
					_width = contentWidth;
				}
				
				_width = NumberUtil.restrict(_width, minWidth, maxWidth);
				widthIsDirty = false;
			}
			
			return _width;
		}
		
		public function get measuredWidth():Number
		{
			return width * scaleX;
		}
		
		public function set measuredWidth(value:Number):void
		{
			if(measuredWidth != value)
			{
				_measuredWidth = value / scaleX;
				invalidateWidth();
			}
		}
		
		public function get minWidth():Number
		{
			return isNaN(_minWidth) ? 0 : _minWidth;
		}
		
		public function set minWidth(value:Number):void
		{
			if(minWidth != value)
			{
				_minWidth = value;
				invalidateWidth();
			}
		}
		
		public function get maxWidth():Number
		{
			return isNaN(_maxWidth) ? CanoeGlobals.ELEMENT_DEFAULT_MAX_WIDTH : _maxWidth;
		}
		
		public function set maxWidth(value:Number):void
		{
			if(maxWidth != value)
			{
				_maxWidth = value;
				invalidateWidth();
			}
		}
		
		override public function set scaleX(v : Number) : void
		{
			if(super.scaleX != v)
			{
				super.scaleX = v;
				invalidateParentLayout();
			}
		}
		
		protected function invalidateWidth() : void
		{
			widthIsDirty = true;
			invalidate();
			invalidateParentLayout();
		}
		
		private var _height : Number;
		private var _measuredHeight : Number;
		private var _minHeight : Number;
		private var _maxHeight : Number;
		private var explicitHeight : Number;
		private var heightIsDirty : Boolean = true;
		
		override public function set height(v : Number) : void
		{
			if(explicitHeight != v)
			{
				explicitHeight = v;
				invalidateHeight();
			}
		}
		
		override public function get height():Number
		{
			if(heightIsDirty)
			{
				if(!isNaN(explicitHeight))
				{
					_height = explicitHeight;
				}
				else if(!isNaN(_measuredHeight))
				{
					_height = _measuredHeight;
				}
				else
				{
					_height = contentHeight;
				}
				
				_height = NumberUtil.restrict(_height, minHeight, maxHeight);
				heightIsDirty = false;
			}
			
			return _height;
		}
		
		public function get measuredHeight():Number
		{
			return height * scaleX;
		}
		
		public function set measuredHeight(value:Number):void
		{
			if(measuredHeight != value)
			{
				_measuredHeight = value / scaleX;
				invalidateHeight();
			}
		}
		
		public function get minHeight():Number
		{
			return isNaN(_minHeight) ? 0 : _minHeight;
		}
		
		public function set minHeight(value:Number):void
		{
			if(minHeight != value)
			{
				_minHeight = value;
				invalidateHeight();
			}
		}
		
		public function get maxHeight():Number
		{
			return isNaN(_maxHeight) ? CanoeGlobals.ELEMENT_DEFAULT_MAX_WIDTH : _maxHeight;
		}
		
		public function set maxHeight(value:Number):void
		{
			if(maxHeight != value)
			{
				_maxHeight = value;
				invalidateHeight();
			}
		}
		
		override public function set scaleY(v : Number) : void
		{
			if(super.scaleY != v)
			{
				super.scaleY = v;
				invalidateParentLayout();
			}
		}
		
		protected function invalidateHeight() : void
		{
			heightIsDirty = true;
			invalidate();
			invalidateParentLayout();
		}
		
		public function invalidate() : void
		{
			delegate.invalidate();
		}
		
		public function invalidateParentLayout() : void
		{
			var container : IContainer = parent as IContainer;
			if(container) container.invalidateLayout();
		}
		
		public function invalidateParentLayering() : void
		{
			var container : IContainer = parent as IContainer;
			if(container) container.invalidateLayering();
		}
		
		private var bindingsExpired : Boolean = true;
		protected function invalidateBindings() : void
		{
			bindingsExpired = true;
			invalidate();
		}
	}
}