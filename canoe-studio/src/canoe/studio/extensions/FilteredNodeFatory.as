package canoe.studio.extensions
{
	import flash.utils.getDefinitionByName;
	
	import canoe.cxml.INodeFactory;
	
	public class FilteredNodeFatory implements INodeFactory
	{
		public function create(nodeName:String):*
		{
			var className : String = nodeName.replace("::", ".");
			try
			{
				var clazz : Class = getDefinitionByName(className) as Class;
				return new clazz();	
			}
			catch(e : Error)
			{
				var cxmlClass : CXMLClass = CXMLClass.forName(className);
				return cxmlClass ? cxmlClass.newInstance() : null;
			}
		}
	}
}