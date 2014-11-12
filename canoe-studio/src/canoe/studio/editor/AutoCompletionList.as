package canoe.studio.editor
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.List;
	
	import flashx.textLayout.container.ScrollPolicy;
	
	public class AutoCompletionList extends UIComponent
	{
		private var list : List;
		private var dataProviver : ArrayCollection;
		private var _prefix : String;
		
		public function AutoCompletionList()
		{
			super();
			
			maxHeight = 200;
			width = 200;
			
			dataProviver = new ArrayCollection();
			dataProviver.filterFunction = filterAutoCompletion;
			
			list = new List();
			
			list.addEventListener(ResizeEvent.RESIZE, list_resizeHandler);
			list.height = 200;
			list.width = 200;
			list.setStyle("contentBackgroundColor",0xffffff);
			list.setStyle("verticalScrollPolicy", ScrollPolicy.AUTO);
			list.dataProvider = dataProviver;

			list.addEventListener(FlexEvent.VALUE_COMMIT, list_valueCommitHandler);
			addChild(list);
			
			addEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
		}
		
		protected function removeFromStageHandler(event:Event):void
		{
			prefix = null;
		}
		
		protected function list_resizeHandler(event:ResizeEvent):void
		{
			width = list.width;
			height = list.height;
		}
		
		public function get prefix():String
		{
			return _prefix;
		}

		public function set prefix(value:String):void
		{
			if(_prefix != value)
			{
				_prefix = value;
				dataProviver.refresh();
			}
		}

		public function set source(v : Array) : void
		{
			dataProviver.source = v;
			dataProviver.refresh();
		}
		
		public function get source() : Array
		{
			return dataProviver.source;
		}
		
		public function get length() : int
		{
			return dataProviver.length;
		}
		
		public function get selectedIndex() : int
		{
			return list.selectedIndex;
		}
		
		public function set selectedIndex(v : int) : void
		{
			list.selectedIndex = v;
		}
		
		public function get selectedItem() : *
		{
			return list.selectedItem;
		}
		
		public function isItemRendererClicked(event : MouseEvent) : Boolean
		{
			return list.dataGroup.contains(DisplayObject(event.target));
		}
		
		private function filterAutoCompletion(item : String) : Boolean
		{
			return !prefix || item.match(new RegExp("^" + prefix, "i"));
		}
		
		private function list_valueCommitHandler(event:FlexEvent):void
		{
			try
			{
				list.ensureIndexIsVisible(selectedIndex);
			}
			catch(e : Error)
			{
			}
		}
	}
}