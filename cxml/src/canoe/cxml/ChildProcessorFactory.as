package canoe.cxml
{
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;

	public class ChildProcessorFactory
	{
		public static var instance : ChildProcessorFactory = new ChildProcessorFactory();
		
		private var _processorDict : Dictionary;
		
        protected function get processorDict() : Dictionary
		{
			return _processorDict;
		}
		
		public function ChildProcessorFactory()
		{
			_processorDict = new Dictionary();
            _processorDict[Array]= ArrayChildProcessor;
			_processorDict[DisplayObjectContainer] = DisplayObjectChildProcessor;
		}
		
		public function getProcessor(obj : Object) : IChildProcessor
		{
			for(var key : * in processorDict)
			{
				var objClass : Class = Class(key);
				
				if(obj is objClass)
				{
	                var value : * = processorDict[key];
                    if(value is Class)
					{
						processorDict[key] = new value();
					}
					
					return processorDict[key];
				}
			}
            
			return null;
		}
	}
}