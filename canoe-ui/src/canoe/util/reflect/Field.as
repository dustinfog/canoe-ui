package canoe.util.reflect
{
	public class Field extends Member
	{
		private var _type : Class;	
		
		public function get type():Class
		{
			return _type;
		}
		
		public function set type(value:Class):void
		{
			_type = value;
		}
		
		public function getValue(object : Object) : Object
		{
			return object[name];
		}
	}
}