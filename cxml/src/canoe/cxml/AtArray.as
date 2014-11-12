package canoe.cxml
{
	import canoe.core.IElement;
	import canoe.state.CXMLSimpleOverride;
	import canoe.state.State;

	public class AtArray implements IAtProcessor
	{
		public function call(obj:*, prop:String, arguments:Array, state : State, document : IElement):void
		{
			var elements : Array = [];
			for each(var element : String in arguments)
			{
				elements.push(_(element));
			}
			
			if(state == null)
			{
	            obj[prop] = elements;
			}
			else
			{
				state.overrides.push(new CXMLSimpleOverride(obj, prop, elements));
			}
		}
	}
}