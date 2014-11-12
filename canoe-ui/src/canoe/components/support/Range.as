package canoe.components.support
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import canoe.components.Button;
	import canoe.components.SkinnableComponent;
	import canoe.components.TextInput;
	import canoe.core.IElement;
	import canoe.events.CanoeEvent;
	import canoe.util.CanoeTimer;
	import canoe.util.Closure;
	import canoe.util.NumberUtil;
	import canoe.util.ObjectUtil;
	
	[Event(name="valueCommit", type="canoe.events.CanoeEvent")]
	public class Range extends SkinnableComponent
	{
		
		private static const CONTINOUS_BUFFER_TIME : uint = 500;
		private static const CONTINOUS_DELAY : uint  = 50;
		
		
		/**
		 *  构造函数 
		 * 
		 */		
        public function Range()
		{
			timer = new CanoeTimer(CONTINOUS_DELAY);
			continuousChangeClosure = new Closure(doContinuousChange);
		}
		/**
		 *	下一页Button按钮 
		 */
		[Part]
		public var increaseButton : Button;
		/**
		 *	上一页Button按钮 
		 */		
		[Part]
		public var decreaseButton : Button;
		/**
		 *	末页Button按钮 
		 */		
		[Part]
		public var maximizeButton : Button;
		/**
		 *	首页Button 
		 */		
		[Part]
		public var minimizeButton : Button;
		/**
		 *	确定Button按钮 
		 */		
		[Part]
		public var confirmButton : Button;
		/**
		 *	输入页数 的文本
		 */
		[Part]
		public var valueInput : TextInput;

		private var _minimum : Number = 0;
		private var _maximum : Number = 0;
		private var _value : Number = 0;
		private var oldValue : Number = 0;
		private var valueChanged : Boolean;
		private var _snapInterval : Number = 1;
        private var _stepSize : int = 1;
        private var _continuousEnabled : Boolean = true;
		
		private var continuousOrigValue : Number = 0;
		private var continuousInterval : Number = 0;
        private var waitTimer : uint;
        private var timer : CanoeTimer;
		private var continuousChangeClosure : Closure;
		
		public function get continuousEnabled():Boolean
		{
			return _continuousEnabled;
		}

		public function set continuousEnabled(value:Boolean):void
		{
			_continuousEnabled = value;
		}
		/**
		 * 
		 *  获取或设置，更改的value数量。除非 snapInterval 为 0，否则它必须是 snapInterval 的倍数。如果 stepSize 不是倍数，则会将它近似到大于或等于 snapInterval 的最近的倍数。默认值为 1。
		 * @return 
		 * 
		 */
		public function get stepSize():int
		{
			return _stepSize;
		}

		public function set stepSize(value:int):void
		{
			_stepSize = value;
		}

		/**
		 *  获取设置snapInterval属性，snapInterval属性控制 value 属性的有效值。 如果为非零，则有效值为 minimum 与此属性的整数倍数之和，且小于或等于 maximum。例如，如果 minimum 为 10，maximum 为 20，而此属性为 3，则可能的有效值为 10、13、16、19 和 20。
		 * @return 
		 * 
		 */		
		public function get snapInterval():Number
		{
			return _snapInterval;
		}

		public function set snapInterval(value:Number):void
		{
			_snapInterval = value;
		}
		/**
		 *	获取或设置minimum和maximum之间有效的当前值。 
		 * @return 
		 * 
		 */
		public function get value():Number
		{
			return _value;
		}
		
		[Editable]
		public function set value(value:Number):void
		{
			if(_value != value)
			{
				_value = value;
				valueChanged = true;
				invalidate();
			}
		}
		/**
		 *	获取或设置有效的最大值
		 * @return 
		 * 
		 */		
		[Editable]
		public function get maximum():Number
		{
			return _maximum;
		}

		public function set maximum(value:Number):void
		{
			if(_maximum != value)
			{
				_maximum = value;
				valueChanged = true;
				invalidate();
			}
		}
		/**
		 *	获取或设置有效的最小值 
		 * @return 
		 * 
		 */		
		[Editable]
		public function get minimum():Number
		{
			return _minimum;
		}

		public function set minimum(value:Number):void
		{
			if(_minimum != value)
			{
				_minimum = value;
				valueChanged = true;
				invalidate();
			}
		}
		
		override protected function partAdded(instance:Object):void
		{
			if(instance == maximizeButton)
			{
				maximizeButton.addEventListener(MouseEvent.CLICK, maximizeButton_clickHandler);
			}
			else if(instance == minimizeButton)
			{
				minimizeButton.addEventListener(MouseEvent.CLICK, minimumButton_clickHandler);
			}
			else if(instance == increaseButton)
			{
				increaseButton.addEventListener(MouseEvent.MOUSE_DOWN, increaseButton_mouseDownHandler);
			}
			else if(instance == decreaseButton)
			{
				decreaseButton.addEventListener(MouseEvent.MOUSE_DOWN, decreaseButton_mouseDownHandler);
			}else if(instance == valueInput)
			{
				valueInput.text = String(value);
				valueInput.addEventListener(Event.COMPLETE, setValueByTextInput);
				valueInput.addEventListener(FocusEvent.FOCUS_OUT, valueInput_focusOutHandler);
			}
			else if(instance == confirmButton)
			{
				confirmButton.addEventListener(MouseEvent.CLICK, setValueByTextInput);
			}
		}
		
		override protected function partRemoved(instance:Object):void
		{
			if(instance == maximizeButton)
			{
				maximizeButton.removeEventListener(MouseEvent.CLICK, maximizeButton_clickHandler);
			}
			else if(instance == minimizeButton)
			{
				minimizeButton.removeEventListener(MouseEvent.CLICK, minimumButton_clickHandler);
			}
			else if(instance == increaseButton)
			{
				increaseButton.removeEventListener(MouseEvent.MOUSE_DOWN, increaseButton_mouseDownHandler);
			}
			else if(instance == decreaseButton)
			{
				decreaseButton.removeEventListener(MouseEvent.MOUSE_DOWN, decreaseButton_mouseDownHandler);
			}
			else if(instance == valueInput)
			{
				valueInput.removeEventListener(Event.COMPLETE, setValueByTextInput);
				valueInput.removeEventListener(FocusEvent.FOCUS_OUT, valueInput_focusOutHandler);
			}
			else if(instance == confirmButton)
			{
				confirmButton.removeEventListener(MouseEvent.CLICK, setValueByTextInput);
			}
		}
		
		private function valueInput_focusOutHandler(event : FocusEvent):void
		{
			if(!confirmButton) setValueByTextInput(event);
		}
		
		private function increaseButton_mouseDownHandler(event:MouseEvent):void
		{
			continuousChange(event, snapInterval * stepSize);
		}
        
		private var continuousActivator : IElement;
		
		protected function continuousChange(event : MouseEvent, continuousInterval : Number) : void
		{
			continuousOrigValue = value;
			
			this.continuousInterval = continuousInterval;
			
			if(continuousInterval != 0)
			{
				value += continuousInterval;
				
				if(!continuousEnabled) return;
				
				clearTimeout(waitTimer);
				waitTimer = setTimeout(timer.run, CONTINOUS_BUFFER_TIME, continuousChangeClosure);
			}
			
			continuousActivator = IElement(event.currentTarget);
			continuousActivator.addEventListener(MouseEvent.MOUSE_UP, stopContinuousChanging);
			continuousActivator.addEventListener(MouseEvent.MOUSE_OUT, stopContinuousChanging);
		}
        
		private function stopContinuousChanging(event : MouseEvent = null) : void
		{
			continuousInterval = 0;
			clearTimeout(waitTimer);
			timer.stop();
			
			continuousActivator.removeEventListener(MouseEvent.MOUSE_UP, stopContinuousChanging);
			continuousActivator.removeEventListener(MouseEvent.MOUSE_OUT, stopContinuousChanging);
			continuousActivator = null;
		}
		
		private function decreaseButton_mouseDownHandler(event:MouseEvent):void
		{
            continuousChange(event, - snapInterval * stepSize);;
		}
		
		private function maximizeButton_clickHandler(event:MouseEvent) : void
		{
			value = maximum;
		}
		
		private function minimumButton_clickHandler(event:MouseEvent) : void
		{
			value = minimum;
		}
        
		private function doContinuousChange(timer : CanoeTimer, tally : int) : Boolean
		{
            if(value != maximum && value != minimum)
			{
				value += continuousInterval;
				return true;
			}
			else
			{
				stopContinuousChanging();
				return false;
			}
		}
		
		protected function setValueByTextInput(event:Event):void
		{
			var newValue : Number = parseFloat(valueInput.text);
			if(isNaN(newValue))
			{
				newValue = 0;
			}
			
			var currentValue : Number = value; 
			value = NumberUtil.restrict(newValue, minimum, maximum);
			
			if(currentValue == value)
			{
				valueInput.text = String(newValue);
			}
		}	
		
		override public function validate():void
		{
			super.validate();
			
			if(valueChanged)
			{
				_value = NumberUtil.restrict(_value, minimum, maximum);

				if(_value != maximum && _value != minimum)
				{
					_value -= (_value - minimum) % snapInterval;
				}
				
				if(_value == maximum)
				{
					if(increaseButton)increaseButton.enabled = false;
					if(maximizeButton)maximizeButton.enabled = false;
				}
				else
				{
					if(increaseButton)increaseButton.enabled = true;
					if(maximizeButton)maximizeButton.enabled = true;
				}
				
				if(_value == minimum)
				{
					if(decreaseButton)decreaseButton.enabled = false;
					if(minimizeButton)minimizeButton.enabled = false;
				}
				else
				{	
					if(decreaseButton)decreaseButton.enabled = true;
					if(minimizeButton)minimizeButton.enabled = true;
				}
				
				if(oldValue != value)
				{
					if(valueInput)
					{
						valueInput.text = String(value);
					}
					
					dispatchEvent(new CanoeEvent(CanoeEvent.VALUE_COMMIT));
					oldValue = value;
				}
				
				var params : Object = {
					value : value,
					minimum : minimum,
					maximum : maximum
				};
				
				if(skinData)
				{
					ObjectUtil.overrideProperties(skinData, params);
					skinData = skinData;
				}
				else
				{
					skinData = params;
				}
				
				valueChanged = false;
			}
		}
	}
}