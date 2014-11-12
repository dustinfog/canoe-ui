package canoe.events
{
	import flash.events.Event;
	
	public class StateEvent extends Event
	{
        public static const STATE_CHANGE : String = "stateChange";
		
		public function StateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}