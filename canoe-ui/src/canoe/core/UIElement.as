package canoe.core
{
	import canoe.events.CanoeEvent;
	import canoe.events.StateEvent;
	import canoe.managers.StateManager;
	import canoe.managers.TooltipManager;
	import canoe.state.State;
	import canoe.util.ArrayUtil;
	import canoe.util.NumberUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	[Event(name="resize", type="flash.events.Event")]
	[Event(name="move", type="canoe.events.CanoeEvent")]
	[Event(name="creationComplete", type="canoe.events.CanoeEvent")]
	[Event(name="ready", type="canoe.events.CanoeEvent")]
	[Event(name="show", type="canoe.events.CanoeEvent")]
	[Event(name="hide", type="canoe.events.CanoeEvent")]
    [Event(name="stateChange", type="canoe.events.StateEvent")]
	[Event(name="dataChanged", type="canoe.events.CanoeEvent")]
	public class UIElement extends Sprite implements IElement
	{
		private var _tooltipData : Object;
		private var _tooltipClass : *;
		/**
		 *  构造函数 
		 * 
		 */		
        public function UIElement()
		{
			super();
			
			delegate = new ElementDelegate(this);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
		}
		
		protected function removeFromStageHandler(event:Event):void
		{
			measuredWidth = NaN;
			measuredHeight = NaN;
		}
		
		private var _enabled : Boolean = true;

		/**
		 *  获取或设置提示的Class
		 * @return 
		 * 
		 */		
		public function get tooltipClass():*
		{
			return _tooltipClass || TooltipManager.getTooltipClass(tooltipData["constructor"]);
		}

		public function set tooltipClass(value:*):void
		{
			_tooltipClass = value;
		}

		/**
		 *   获取或设置提示的数据
		 * @return 
		 * 
		 */		
		public function get tooltipData():Object
		{
			return _tooltipData;
		}

		public function set tooltipData(value:Object):void
		{
			_tooltipData = value;
			
			if(_tooltipData)
			{
				TooltipManager.listenTooltip(this);
			}
			else
			{
				TooltipManager.ignoreTooltip(this);
			}
		}

		/**
		 *  获取或设置是否能点击
		 * @return 
		 * 
		 */		
		public function get enabled():Boolean
		{
			return _enabled;
		}

		public function set enabled(value:Boolean):void
		{
            if(_enabled != value)
			{
				_enabled = value;
                mouseChildren = value;
			}
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
		
		protected function create() : void
		{
			
		}
		
		override public function startDrag(lockCenter:Boolean=false, bounds:Rectangle=null):void
		{
			super.startDrag(lockCenter, bounds);
			
            addEventListener(Event.ENTER_FRAME, trackCoord);
		}
		
		override public function stopDrag():void
		{
			super.stopDrag();
            
			trackCoord();
			removeEventListener(Event.ENTER_FRAME, trackCoord);
		}
		
		private function trackCoord(event:Event = null):void
		{
			invalidate();
			invalidateParentLayout();
		}
        
		public function validate() : void
		{
			if(bindingsExpired)
			{
				applyBindings(this);
				bindingsExpired = false;
			}
			
			if(origWidth != width || origHeight != height)
			{
				dispatchEvent(new Event(Event.RESIZE));
				
				origWidth = width;
				origHeight = height;
			}
			
			if(origX != x || origY != y)
			{
				dispatchEvent(new CanoeEvent(CanoeEvent.MOVE));
				
				origX = x;
				origY = y;
			}
		}

		public function get contentWidth() : Number
		{
			return 0;
		}

		public function get contentHeight() : Number
		{
			return 0;
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
				invalidateParentLayering();
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