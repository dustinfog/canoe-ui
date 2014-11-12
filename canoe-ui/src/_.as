package 
{
	import canoe.core.CanoeGlobals;
	import canoe.core.IGetText;
	import canoe.util.StringUtil;

	public function _(message : String, parameters : Object = null) : String
	{
        var text : String = message;
        var getText : IGetText = CanoeGlobals.getText;
		if(getText)
		{
			text =  getText.traslate(message, CanoeGlobals.locale);
		}
        
		if(parameters == null)
		{
			return text;
		}
		else
		{
			return StringUtil.substitute(text, parameters);
		}
	}
}