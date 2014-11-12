package canoe.studio.extensions
{
	import canoe.cxml.AtProcessorFactory;
	
	public class FilteredAtProcessorFactory extends AtProcessorFactory
	{
		public static const instance : FilteredAtProcessorFactory = new FilteredAtProcessorFactory();
		public function FilteredAtProcessorFactory()
		{
			super();
			
			processorDict["Class"] = AtClass;
		}
	}
}