package canoe.cxml
{
	import canoe.core.IElement;
	import canoe.state.CXMLSimpleOverride;
	import canoe.state.State;
	
	import flash.utils.getDefinitionByName;

	public class AtClass implements IAtProcessor
	{
		public function call(obj:*, prop:String, arguments:Array, state : State, document : IElement):void
		{
			var clazz : Class = Class(getDefinitionByName(arguments.shift()));
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