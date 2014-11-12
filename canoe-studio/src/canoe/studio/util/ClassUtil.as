package canoe.studio.util
{
	public class ClassUtil
	{
		public static function getNamespace(className : String) : String
		{
			var lastIndexDot : int = className.lastIndexOf(".");
			return className.substr(0, lastIndexDot);
		}
		
		public static function getLocalName(className : String) : String
		{
			var lastIndexDot : int = className.lastIndexOf(".");
			return className.substr(lastIndexDot + 1);
		}
	}
}