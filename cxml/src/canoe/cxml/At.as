package canoe.cxml
{
	import canoe.binding.BindingUtil;
	import canoe.binding.CXMLSimpleBinding;
	import canoe.binding.IBindingExpression;
	import canoe.core.IBinding;
	import canoe.core.IElement;
	import canoe.state.BindingOverride;
	import canoe.state.CXMLSimpleOverride;
	import canoe.state.State;

	public class At implements IAtProcessor
	{
		public function call(obj : *, prop : String, arguments : Array, state : State, document : IElement) : void
		{
			var string : String = arguments.shift();
			var binding : IBinding = null;
			
			var bindingExpr : IBindingExpression = BindingUtil.parseExpression(string, document, true);
			if(bindingExpr)
			{
				binding = new CXMLSimpleBinding(obj, prop, bindingExpr);
			}
			
            if(state == null)
			{
				if(binding)
				{
					document.registerBinding(binding);
				}
				else
				{
					obj[prop] = _(string);
				}
			}
			else
			{
				if(binding)
				{
					state.overrides.push(new BindingOverride(binding, document));
				}
				else
				{
					state.overrides.push(new CXMLSimpleOverride(obj, prop, string));
				}
			}
		}
	}
}