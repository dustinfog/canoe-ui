package canoe.binding
{
	import canoe.core.IBinding;

	public class CXMLSimpleBinding implements IBinding
	{
		public function CXMLSimpleBinding(host : Object, property : String, expression : IBindingExpression)
		{
			this.host = host;
			this.property = property;
			this.expression = expression;
		}
		
		private var host : Object;
		private var property : String;
		private var expression : IBindingExpression;

		public function apply() : void
		{
			try
			{
				host[property] = expression.getValue();
			}
			catch(e : Error)
			{
				trace(e.getStackTrace());
			}
		}
		
		public function clear() : void
		{
			
		}
	}
}