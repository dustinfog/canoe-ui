package canoe.state
{
	public class SimpleOverride implements IOverride
	{
		private var setter : Function;
		private var getter : Function;
		private var value : Object;
		private var oldValue : Object;

		public function SimpleOverride(setter : Function, getter : Function, value : Object)
		{
			this.setter = setter;
			this.getter = getter;
			this.value = value;
		}
		
		public function apply():void
		{
			oldValue = getter();
			setter(value);
		}
		
		public function remove():void
		{
			setter(oldValue);
		}
	}
}