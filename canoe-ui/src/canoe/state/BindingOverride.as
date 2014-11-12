package canoe.state
{
	import canoe.core.IBinding;
	import canoe.core.IElement;

	public class BindingOverride implements IOverride
	{
		private var binding : IBinding;
		private var document : IElement;
		
		public function BindingOverride(binding : IBinding, document : IElement)
		{
			this.binding = binding;
			this.document = document;
		}

		public function apply():void
		{
			document.registerBinding( binding);
			binding.apply();
		}
		
		public function remove():void
		{
			binding.clear();
			document.unregisterBinding(binding);
		}
	}
}