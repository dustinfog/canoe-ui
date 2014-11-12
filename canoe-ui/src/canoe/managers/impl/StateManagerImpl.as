package canoe.managers.impl
{
	import canoe.core.IElement;
	import canoe.managers.IStateManager;
	import canoe.state.State;

	public class StateManagerImpl implements IStateManager
	{
		public function switchState(component : IElement, stateName : String) : void
		{
			var currState : State = null;
			var nextState : State = null;
			for each(var state : State in component.states)
			{
				if(state.name == component.currentState)
				{
					currState = state;
				}
				
				if(state.name == stateName)
				{
					nextState = state;
				}
			}
			
			if(nextState != null)
			{
				if(currState != null)
				{
					currState.remove();
				}
				
				nextState.apply();
			}
			else if(stateName != null)
			{
				throw new Error("can't find state [" + stateName + "]");
			}
		}
		
		public function getState(component : IElement, name : String) : State
		{
			for each(var state : State in component.states)
			{
				if(state.name == name)
				{
					return state;
				}
			}
			
			return null;
		}
	}
}