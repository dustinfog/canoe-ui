package canoe.studio.editor
{
	import flash.events.Event;
	
	public class EditorEvent extends Event
	{
		public static const UPDATE : String = "update";
		public function EditorEvent(type:String)
		{
			super(type, true, false);
		}
	}
}