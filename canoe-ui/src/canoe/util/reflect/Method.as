package canoe.util.reflect
{
	public class Method extends Member implements IFunction
	{
		private var _declaredBy : Class;
		private var _returnType : Class;
		private var _parameters : Array = [];
		
		public function get parameters():Array
		{
			return _parameters;
		}
		
		public function set parameters(value:Array):void
		{
			_parameters = value;
		}
		
		public function get returnType():Class
		{
			return _returnType;
		}

		public function set returnType(value:Class):void
		{
			_returnType = value;
		}

		public function get declaredBy():Class
		{
			return _declaredBy;
		}

		public function set declaredBy(value:Class):void
		{
			_declaredBy = value;
		}
		
		public function invoke(object : Object, ... args : *) : *
		{
			return (object[name] as Function).apply(object, args);
		}
	}
}