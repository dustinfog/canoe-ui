package canoe.events
{
	import flash.events.Event;
	
	public class CanoeEvent extends Event
	{
		public static const MOVE : String = "move";
        public static const CREATION_COMPLETE : String = "creationComplete";
		public static const VALUE_COMMIT : String = "valueCommit";
		public static const INDEX_CHANGED : String = "indexChanged";
		public static const DATA_CHANGED : String = "dataChanged";
		public static const TEXT_STYLE_UPDATED : String = "textStyleUpdated";
		public static const SHOW : String = "show";
		public static const HIDE : String = "hide";
		
		public function CanoeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}