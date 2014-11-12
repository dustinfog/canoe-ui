package canoe.util
{
	public class StringUtil
	{
		public static function trim(str:String):String
		{
			if (str == null) return '';
			
			var startIndex:int = 0;
			while (isWhitespace(str.charAt(startIndex)))
				++startIndex;
			
			var endIndex:int = str.length - 1;
			while (isWhitespace(str.charAt(endIndex)))
				--endIndex;
			
			if (endIndex >= startIndex)
				return str.slice(startIndex, endIndex + 1);
			else
				return "";
		}

		public static function isWhitespace(character:String):Boolean
		{
			switch (character)
			{
				case " ":
				case "\t":
				case "\r":
				case "\n":
				case "\f":
					return true;
					
				default:
					return false;
			}
		}

		public static function substitute(str:String, parameters : Object):String
		{
			if (str == null) return '';
		
			for (var key : String in parameters)
			{
				str = str.replace(new RegExp("\\{"+key+"\\}", "g"), parameters[key]);
			}
			
			return str;
		}
		
		public static function getMnemonicIndex(label : String) : int
		{
            if(label == null) return -1;
			var indexOfBracket : int = label.indexOf("(");
			return indexOfBracket >= 0 ? indexOfBracket + 1 : -1; 
		}
	}
}