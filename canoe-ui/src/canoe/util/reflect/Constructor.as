package canoe.util.reflect
{
	public class Constructor implements IFunction
	{
		private var _parameters : Array = [];

		public function get parameters():Array
		{
			return _parameters;
		}

		public function set parameters(value:Array):void
		{
			_parameters = value;
		}
	}
}