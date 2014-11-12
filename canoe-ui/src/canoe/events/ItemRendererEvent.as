package canoe.events
{
	import canoe.core.IItemRenderer;
	
	import flash.events.Event;
	
	public class ItemRendererEvent extends Event
	{
		public static const ITEM_RENDERER_ADDED : String = "itemRendererAdded";
		public static const ITEM_RENDERER_REMOVED : String = "itemRendererRemoved";
		public static const ITEM_RENDERER_SELECTED : String = "itemRendererSelected";
		
		private var _itemRenderer : IItemRenderer;
		
		public function ItemRendererEvent(type:String, itemRenderer : IItemRenderer)
		{
			super(type);
			
			_itemRenderer = itemRenderer;
		}

		public function get itemRenderer():IItemRenderer
		{
			return _itemRenderer;
		}
	}
}