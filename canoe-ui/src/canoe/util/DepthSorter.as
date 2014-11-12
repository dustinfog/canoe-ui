package canoe.util
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	public class DepthSorter
	{
		public static function sort(container : DisplayObjectContainer) : void
		{
			var displays : Array = [];
			
			for(var i : uint = 0; i < container.numChildren; i ++)
			{
				displays.push(container.getChildAt(i));
			}
			
			displays.sort(displaySortHandler);
			
			for(i = 0; i < displays.length; i ++)
			{
				var child : DisplayObject = displays[i];
				var index : int = container.getChildIndex(child);

				if(index != i)
				{
					container.setChildIndex(child, i);
				}
			}
		}
		
		private static function displaySortHandler(display1 : DisplayObject, display2 : DisplayObject) : int
		{
			var container : DisplayObjectContainer = display1.parent;
			return MathUtil.getSign(display1.y - display2.y || container.getChildIndex(display1) - container.getChildIndex(display2));
		}
	}
}