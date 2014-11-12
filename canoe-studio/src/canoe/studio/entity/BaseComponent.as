package canoe.studio.entity
{
	[Bindable]
	public class BaseComponent
	{
		private var _name : String;
		private var _className : String;

		public function get className():String
		{
			return _className;
		}

		public function set className(value:String):void
		{
			_className = value;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function toString() : String
		{
			return name;
		}
	}
}