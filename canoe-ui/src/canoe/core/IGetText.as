package canoe.core
{
	public interface IGetText
	{
		/**
		 *  改变项目的语言 
		 * @param str
		 * @param locale
		 * @return 
		 * 
		 */		
		function traslate(str : String, locale : String) : String;
	}
}