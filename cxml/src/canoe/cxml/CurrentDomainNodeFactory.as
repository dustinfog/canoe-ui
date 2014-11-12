package canoe.cxml
{
	import flash.utils.getDefinitionByName;

	public class CurrentDomainNodeFactory implements INodeFactory
	{
		public function create(nodeName:String):*
		{
			var clazz : Class = getDefinitionByName(nodeName) as Class;
			
			return new clazz();
		}
	}
}