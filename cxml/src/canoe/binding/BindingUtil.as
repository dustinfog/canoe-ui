package canoe.binding
{
	import canoe.util.StringUtil;

	public class BindingUtil
	{
		public static function parseExpression(str : String, document : Object, i18n : Boolean = false) : IBindingExpression
		{
			var expression : IBindingExpression = parsePropertyChains(str, document);
			if(!expression)
				expression = parseTextTemplate(str, document, i18n);
			return expression;
		}
		
		public static function parsePropertyChains(str : String, document : Object) : PropertyChains
		{
			str = StringUtil.trim(str);
			if(str.indexOf("{") != 0 || str.indexOf("}", 1) != str.length - 1) return null;
			
			var substrs : Array = str.substr(1, str.length - 2).split(".");
			
			var chains : Array = [];
			for each(var substr : String in substrs)
			{
				chains.push(StringUtil.trim(substr));
			}
			
			return new PropertyChains(chains, document);
		}
		
		
		public static function parseTextTemplate(str : String, document : Object, i18n : Boolean) : TextTemplate
		{
			const pattern : RegExp = /\{[^\}]+\}/g;
			if(str.search(pattern) == -1) return null;	
			
			var matches : Array = str.match(pattern);
			var chainses : Array = [];
			for each(var match : String in matches)
			{
				var chains : PropertyChains = parsePropertyChains(match, document);
				
				var chainsIndex : int = -1;
				for(var i : uint = 0; i < chainses.length; i ++)
				{
					var rchains : PropertyChains = chainses[i];
					if(rchains.equals(chains))
					{
						chainsIndex = i;
						break;
					}
				}
				
				if(chainsIndex == -1)
				{
					chainses.push(chains);
					chainsIndex = chainses.length - 1;
				}
				
				str = str.replace(match, "{" + chainsIndex + "}");
			}
			
			if(i18n)
			{
				str = _(str);
			}
			
			var template : TextTemplate = new TextTemplate(str, chainses);
			return template;
		}
	}
}