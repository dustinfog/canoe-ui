package canoe.util
{
	import flash.events.Event;

	public class EventUtil
	{
		public static function stopPropagation(event : Event) : void
		{
			event.stopPropagation();
		}
		
		public static function preventDefault(event : Event) : void
		{
			event.preventDefault();
		}
		
		public static function stopImmediatePropagation(event : Event) : void
		{
			event.stopImmediatePropagation();
		}
	}
}