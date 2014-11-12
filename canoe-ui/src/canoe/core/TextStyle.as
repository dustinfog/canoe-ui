package canoe.core
{
	import canoe.util.reflect.ClassReflector;
	import canoe.util.reflect.Member;
	import canoe.util.reflect.Variable;

	public dynamic class TextStyle
	{
		public static function inheritFrom(parentStyle : Object) : TextStyle
		{
			var textStyle : TextStyle = new TextStyle();
			textStyle.inherits(parentStyle);
			
			return textStyle;
		}
		
		private static var _propDict : Object;
		private static function get propDict() : Object
		{
			if(!_propDict)
			{
				_propDict = {};
				var reflector : ClassReflector = ClassReflector.reflect(TextStyle);
				for each(var member : Member in reflector.members)
				{
					if(member is Variable)
					{
						var propName : String = member.name;
						_propDict[propName] = transformProp(propName);
					}
				}
			}
			
			return _propDict;
		}

		/**
		 * 从已知的样式对象中继承样式
		 * @param textStyle 已知的样式表
		 * @return 即this本身
		 * 
		 */		
		public function inherits(textStyle : Object) : TextStyle
		{
			if(textStyle != null)
			{
				
				for(var prop : String in propDict)
				{
					var inheritsValue : Object = textStyle[prop];
					if((typeof inheritsValue != "undefined") && inheritsValue !== null)
					{
						this[prop] = inheritsValue;
					}
				}
			}
			
			return this;
		}
		
		public function toString() : String
		{
			return null;
//			var str : String = "{\n";
//			for each(var prop : String in propDict)
//			{
//				str += "\t" + prop + ": "
//			}
		}
		
		private static function transformProp(prop : String) : String
		{
			var cssProp : String = "";
			for(var i : uint = 0; i < prop.length; i ++)
			{
				var charCode : int = prop.charCodeAt(i);
				if(charCode >= 65 && charCode <= 90)
				{
					cssProp += String.fromCharCode(45, charCode + 32);
				}
				else
				{
					cssProp += String.fromCharCode(charCode);
				}
			}
			
			return cssProp;
		}
		/**
		 * 只支持十六进制颜色值。不支持具有指定名称的颜色（例如 blue）。颜色以下面的格式写入：#FF0000。
		 **/
		public var color : Object;
		/**
		 * 受支持的值为 inline、block 和 none。
		 **/
		public var display	: Object;
		/**
		 * font-family
		 * 用逗号分隔的供使用字体的列表，根据需要按降序排列。可以使用任何字体系列名称。如果您指定通用字体名称，它将转换为相应的设备字体。支持以下字体转换：mono 转换为 _typewriter，sans-serif 转换为 _sans，serif 转换为 _serif。
		 **/
		public var fontFamily : Object;
		/**
		 * font-size
		 * 只使用该值的数字部分。不分析单位（px、pt）；像素和点是等价的。
		 **/
		public var fontSize	: Object; 
		/**
		 * font-style
		 * 可识别的值为 normal 和 italic。
		 **/
		public var fontStyle : Object;
		/**
		 * font-weight
		 * 可识别的值为 normal 和 bold。
		 **/
		public var fontWeight : Object;
		/**
		 * 可识别的值为 true 和 false。仅嵌入字体支持字距调整。某些字体（如 Courier New）不支持字距调整。只有 Windows 中创建的 SWF 文件支持 kerning 属性，而 Macintosh 中创建的 SWF 文件不支持该属性。但是，这些 SWF 文件可以在 Flash Player 的非 Windows 版本中播放，并且仍可以应用字距调整。
		 **/
		public var kerning : Object;
		/**
		 * 两行之间统一分布的距离。该值指定在每行之后添加的像素数。负值将压缩两行之间的距离。只使用该值的数字部分。不分析单位（px、pt）；像素和点是等价的。
		 **/
		public var leading : Object;	
		/**
		 * letter-spaceing
		 * 两个字符之间统一分布的距离。该值指定在每个字符之后添加的像素数。负值将压缩两个字符之间的距离。只使用该值的数字部分。不分析单位（px、pt）；像素和点是等价的。
		 **/
		public var letterSpacing : Object;
		/**
		 * margin-left
		 * 只使用该值的数字部分。不分析单位（px、pt）；像素和点是等价的。
		 **/
		public var marginLeft : Object;
		/**
		 * margin-right
		 * 只使用该值的数字部分。不分析单位（px、pt）；像素和点是等价的。
		 **/
		public var marginRight : Object;
		/**
		 * margin-align
		 * 可识别的值为 left、center、right 和 justify。
		 **/
		public var textAlign : Object;
		/**
		 * text-decoration
		 * 可识别的值为 none 和 underline。
		 **/
		public var textDecoration : Object;
		/**
		 * text-indent
		 * 只使用该值的数字部分。不分析单位（px、pt）；像素和点是等价的。
		 **/
		public var textIndent : Object;		
	}
}