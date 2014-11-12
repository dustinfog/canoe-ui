package canoe.util.reflect
{
	public class Metadata
	{
        private var _name : String;
        private var _args : Object = {};

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get args():Object
		{
			return _args;
		}

	}
}