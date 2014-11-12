package canoe.managers
{
	import canoe.core.IElement;
	import canoe.state.State;

	public interface IStateManager
	{
		function switchState(component : IElement, stateName : String) : void;
		function getState(component : IElement, name : String) : State;
	}
}