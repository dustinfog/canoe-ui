package canoe.util.reflect
{
	public class Accessor extends Variable
	{
		private var _declaredBy : Class;
		private var _access : String;

		public function get declaredBy():Class
		{
			return _declaredBy;
		}

		public function set declaredBy(value:Class):void
		{
			_declaredBy = value;
		}

		public function get access():String
		{
			return _access;
		}

		public function set access(value:String):void
		{
			_access = value;
		}
	}
}