package canoe.studio.util
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class TextHistoryManager extends EventDispatcher
	{
		private var historys : Array = [];
		private var historyIndex : int;

		private var waiting : Boolean = false;
		private var timer : int;
		private var lastText : String;
		
		public function get redoEnabled() : Boolean
		{
			return !waiting && historyIndex < historys.length;
		}
		
		public function get undoEnabled() : Boolean
		{
			return !waiting && historyIndex > 1;
		}
		
		public function forward() : String
		{
			if(redoEnabled)
			{
				var text : String = historys[historyIndex ++];
				commitChanged();
				return text;
			}
			
			return null;
		}
		
		public function backward() : String
		{
			if(undoEnabled)
			{
				historyIndex --;
				var text : String =  historys[historyIndex - 1];
				commitChanged();
				return text;
			}
			
			return null;
		}

		public function clear() : void
		{
			historys = [];
			historyIndex = 0;
			clearTimeout(timer);
		}
		
		public function record(text : String):void
		{
			lastText = text;
			if(!waiting)
			{
				waiting = true;
				timer = setTimeout(doRecord, 1000);			
				commitChanged();
			}
		}
		
		private function doRecord() : void
		{
			if(historyIndex == historys.length)
				historys.push(lastText);
			else
				historys.splice(historyIndex, historys.length - 1, lastText);
			
			historyIndex ++;
			waiting = false;
			commitChanged();
		}
		
		private function commitChanged() : void
		{
			dispatchEvent(new Event("historyChanged", true, false));
		}
	}
}