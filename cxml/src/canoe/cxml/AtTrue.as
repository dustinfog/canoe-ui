package canoe.cxml
{
	import canoe.core.IElement;
	import canoe.state.CXMLSimpleOverride;
	import canoe.state.State;

	public class AtTrue implements IAtProcessor
	{
		public function call(obj:*, prop:String, arguments:Array, state : State, document : IElement):void
		{
			if(state == null)
			{
				obj[prop] = true;
			}
			else
			{
				state.overrides.push(new CXMLSimpleOverride(obj, prop, true));
			}
		}
	}
}