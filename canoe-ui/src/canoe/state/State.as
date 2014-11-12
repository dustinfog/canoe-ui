package canoe.state
{
	public class State
	{
		private var _overrides : Array = [];
		
        public function State(name : String = null, overrides : Array = null)
		{
			this.name = name;
			this.overrides = overrides;
		}
		
		private var _name : String;	

		public function get overrides():Array
		{
			return _overrides;
		}

		public function set overrides(value:Array):void
		{
			if(value != null)
			{
				_overrides = value;
			}
		}
		
		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function apply() : void
		{
			if(overrides == null) return;
			for each(var or : IOverride in overrides)
			{
				or.apply();
			}
		}
		
		public function remove() : void
		{
			if(overrides == null) return;
			for each(var or : IOverride in overrides)
			{
				or.remove();
			}
		}
	}
}