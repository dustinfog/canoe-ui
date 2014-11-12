package canoe.components
{
	public class RadioButton extends ToggleButton
	{
		private var _value : Object;
		/**
		 *	获取或设置radioButton的值 
		 * @return 
		 * 
		 */		
		public function get value():Object
		{
			return _value;
		}
		
		[Editable]
		public function set value(value:Object):void
		{
			_value = value;
		}
		
		override protected function onMouseReleased():void
		{
			if(!selected)
			{
				selected = true;
			}
		}
	}
}