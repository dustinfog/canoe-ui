package canoe.binding
{
	import canoe.util.StringUtil;

	public class TextTemplate implements IBindingExpression
	{
		public function TextTemplate(text : String, propertyChainses : Array)
		{
			this.text = text;
			this.propertyChainses = propertyChainses;
		}
		
		private var _text : String;
		private var _propertyChainses : Array;
		
		public function get text():String
		{
			return _text;
		}

		public function set text(value:String):void
		{
			_text = value;
		}
		
		public function get propertyChainses():Array
		{
			return _propertyChainses;
		}
		
		public function set propertyChainses(value:Array):void
		{
			_propertyChainses = value;
		}

		public function getValue() : Object
		{
			var parameters : Array = [];
			for each(var chains : PropertyChains in propertyChainses)
			{
				parameters.push(chains.getValue());
			}
			
			return StringUtil.substitute(text, parameters);
		}
	}
}