package canoe.studio.extensions
{
	import canoe.core.IElement;
	import canoe.cxml.IAtProcessor;
	import canoe.state.CXMLSimpleOverride;
	import canoe.state.State;
	
	import flash.utils.getDefinitionByName;

	public class AtClass implements IAtProcessor
	{
		public function call(obj:*, prop:String, arguments:Array, state : State, document : IElement):void
		{
			var className : String = arguments.shift();
			var clazz : * = CXMLClass.forName(className);
			if(clazz == null)
			{
				clazz = Class(getDefinitionByName(className));
			}
			
			if(state == null)
			{
				obj[prop] = clazz;
			}
			else
			{
				state.overrides.push(new CXMLSimpleOverride(obj, prop, clazz));
			}
		}
	}
}