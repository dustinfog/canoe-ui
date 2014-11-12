package canoe.cxml
{
	import canoe.core.IElement;
	import canoe.state.CXMLSimpleOverride;
	import canoe.state.State;

	public class AtFalse implements IAtProcessor
	{
		public function call(obj:*, prop:String, arguments:Array, state : State, document : IElement):void
		{
			if(state == null)
			{
				obj[prop] = false;
			}
			else
			{
				state.overrides.push(new CXMLSimpleOverride(obj, prop, false));
			}
		}
	}
}