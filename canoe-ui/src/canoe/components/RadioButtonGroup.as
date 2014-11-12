package canoe.components
{
	import flash.events.Event;
	
	import canoe.events.CanoeEvent;
	
	[Event(name="valueCommit", type="canoe.events.CanoeEvent")]
	
	public class RadioButtonGroup extends Container
	{
		private var radioButtons : Array;
		private var selectedRadioButton : RadioButton;
		private var _value : Object;
		private var valueChanged : Boolean;

		/**
		 *	构造函数 
		 * 
		 */		
		public function RadioButtonGroup()
		{
			super();
			
			radioButtons = [];
			addEventListener(Event.ADDED_TO_STAGE, detectRadioButton, true);
		}
		/**
		 *	获取或设置radioButtonGroup的值
		 * @return 
		 * 
		 */		
		public function get value() : Object
		{
			return _value;
		}
		
		public function set value(v : Object) : void
		{
			if(value != v)
			{
				_value = v;
				valueChanged = true;
				invalidate();
			}
		}
		/**
		 * 	获取radioButtonGroup 包含RadioButton数组的长度 
		 * @return 
		 * 
		 */		
		public function get length() : int
		{
			return radioButtons.length;
		}
		
		override public function validate():void
		{
			super.validate();
			
			if(valueChanged)
			{
				for each(var radioButton : RadioButton in radioButtons)
				{
					if(radioButton.value == value)
					{
						switchRadioButton(radioButton);
						break;
					}
				}
				
				dispatchEvent(new Event(CanoeEvent.VALUE_COMMIT));
				valueChanged = false;
			}
		}
		
		private function detectRadioButton(event:Event):void
		{
			if(event.target is RadioButtonGroup)
			{
				throw new Error("RadioButtonGroup can't be nested");
			}

			if(event.target is RadioButton)
			{
				var radioButton : RadioButton = RadioButton(event.target);
				radioButtons.push(radioButton);
				radioButtonAdded(radioButton);
			}
		}
		
		private function radioButtonAdded(radioButton : RadioButton) : void
		{
			radioButton.addEventListener(Event.ADDED_TO_STAGE, judgeRadioButton);
			radioButton.addEventListener(Event.REMOVED_FROM_STAGE, radioButtonRemoved);
			radioButton.addEventListener(Event.CHANGE, judgeRadioButton);
		}
		
		private function radioButtonRemoved(event : Event) : void
		{
			var radioButton : RadioButton = RadioButton(event.currentTarget);
			
			if(selectedRadioButton == radioButton) selectedRadioButton = null;
			
			radioButton.removeEventListener(Event.REMOVED_FROM_STAGE, radioButtonRemoved);
			radioButton.removeEventListener(Event.ADDED_TO_STAGE, judgeRadioButton);
			radioButton.removeEventListener(Event.CHANGE, judgeRadioButton);
		}
		
		private function judgeRadioButton(event:Event):void
		{
			var radioButton : RadioButton = RadioButton(event.currentTarget);
			
			if(radioButton.selected)
			{
				switchRadioButton(radioButton);
			}
		}
		
		private function switchRadioButton(radioButton : RadioButton) : void
		{
			if(radioButton == selectedRadioButton) return;
			
			if(selectedRadioButton)
			{
				selectedRadioButton.selected = false;
				value = null;
			}
			
			if(!radioButton.selected)
			{
				radioButton.selected = true;
			}
			
			value = radioButton.value;
			selectedRadioButton = radioButton;
		}
	}
}