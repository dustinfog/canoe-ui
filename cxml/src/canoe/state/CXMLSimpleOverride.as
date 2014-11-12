package canoe.state
{
	public class CXMLSimpleOverride implements IOverride
	{
		private var target : Object;
		private var prop : String;
		private var value : Object;
		private var oldValue : Object;

		public function CXMLSimpleOverride(target : Object, prop : String, value : Object)
		{
			this.target = target;
			this.prop = prop;
			this.value = value;
		}
		
		public function apply() : void
		{
			oldValue = target[prop];
			target[prop] = value;
		}
		
		public function remove() : void
		{
			target[prop] = oldValue;
		}
	}
}