package canoe.cxml
{
	import canoe.core.IElement;
	import canoe.state.State;

	public interface IAtProcessor
	{
		function call(obj : *, prop : String, arguments : Array, state : State, document : IElement) : void;
	}
}