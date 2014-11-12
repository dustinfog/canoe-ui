package canoe.util.reflect
{
	public class Parameter
	{
		private var _type : Class;
		private var _optional : Boolean;

		public function get type():Class
		{
			return _type;
		}

		public function set type(value:Class):void
		{
			_type = value;
		}

		public function get optional():Boolean
		{
			return _optional;
		}

		public function set optional(value:Boolean):void
		{
			_optional = value;
		}
	}
}