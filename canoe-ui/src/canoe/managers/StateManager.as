package canoe.managers
{
	import canoe.core.IElement;
	import canoe.managers.impl.StateManagerImpl;
	import canoe.state.State;

	public class StateManager
	{
		private static const impl : IStateManager = new StateManagerImpl();
		
		public static function switchState(component : IElement, stateName : String) : void
		{
			impl.switchState(component, stateName);
		}
		public static function getState(component : IElement, name : String) : State
		{
			return impl.getState(component, name);
		}
	}
}