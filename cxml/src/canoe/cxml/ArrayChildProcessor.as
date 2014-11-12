package canoe.cxml
{
	public class ArrayChildProcessor implements IChildProcessor
	{
		public function appendChild(parentObj:*, subObj:*):void
		{
			(parentObj as Array).push(subObj);
		}
	}
}