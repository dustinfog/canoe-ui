package canoe.cxml
{
	public class AtProcessorFactory
	{
		public static const instance : AtProcessorFactory = new AtProcessorFactory();
        
		private var _processorDict : Object;
        protected function get processorDict() : Object
		{
			return _processorDict;
		}
        
		public function AtProcessorFactory()
		{
			_processorDict = {};
         	_processorDict[""] = At;
			_processorDict["Array"] = AtArray;
			_processorDict["Asset"] = AtAsset;
			_processorDict["Class"] = AtClass;
			_processorDict["false"] = AtFalse;
			_processorDict["true"] = AtTrue;
		}
		
		public function getProcessor(name : String) : IAtProcessor
		{
            var processor : * = _processorDict[name];
            if(processor is Class)
			{
				processor = new processor();
			}
            
			return processor;
		}	
	}
}