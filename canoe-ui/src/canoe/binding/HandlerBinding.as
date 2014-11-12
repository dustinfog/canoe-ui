package canoe.binding
{
	import canoe.core.IBinding;

	public class HandlerBinding implements IBinding
	{
		private var applyHandler : Function;
		private var clearHandler : Function;
		public function HandlerBinding(applyHandler : Function, clearHandler : Function = null)
		{
			this.applyHandler = applyHandler;
			this.clearHandler = clearHandler;
		}
		
		public function apply():void
		{
			applyHandler();
		}
		
		public function clear() : void
		{
			if(clearHandler != null)
			{
				clearHandler();
			}
		}
	}
}