package canoe.cxml
{
	import flash.display.DisplayObjectContainer;

	public class DisplayObjectChildProcessor implements IChildProcessor
	{
		public function appendChild(parentObj:*, subObj:*):void
		{
			DisplayObjectContainer(parentObj).addChild(subObj);
		}
	}
}