package canoe.asset
{
	public class AssetURI
	{
		/**
		 *  获取对象通信路径、包名、元件名 
		 * @param uri 字符串类型
		 * @return 
		 * 
		 */		
		public static function parse(uri : String) : AssetURI
		{
			var channelName : String, packName : String, symbolName : String;
			
			var tmp : String;
			for(var i : uint = 0; i < uri.length; i ++)
			{
				var char : String = uri.charAt(i);
				if(char == ":")
				{
					channelName = tmp;
					tmp = null;
				}
				else if(char == "#")
				{
					packName = tmp;
					tmp = null;
				}
				else if(tmp == null)
				{
					tmp = char;
				}
				else
				{
					tmp += char;
				}
				
				symbolName = tmp;
			}
			
			return new AssetURI(packName, symbolName, channelName);
		}
		/**
		 *  构造函数 
		 * @param packName 包名
		 * @param symbolName 元件名
		 * @param channelName 通信路径
		 * 
		 */		
		public function AssetURI(packName : String, symbolName : String, channelName : String = null)
		{
			this.packName = packName;
			this.symbolName = symbolName;
			this.channelName = channelName;
		}
		
		private var _channelName : String;
		private var _packName : String;
		private var _symbolName : String;
		/**
		 *  获取或设置通信路径 
		 * @return 
		 * 
		 */
		public function get channelName():String
		{
			return _channelName;
		}

		public function set channelName(value:String):void
		{
			_channelName = value;
		}
		/**
		 *  获取或设置包名 
		 * @return 
		 * 
		 */
		public function get packName():String
		{
			return _packName;
		}

		public function set packName(value:String):void
		{
			_packName = value;
		}
		/**
		 *  获取或设置元件名 
		 * @return 
		 * 
		 */
		public function get symbolName():String
		{
			return _symbolName;
		}

		public function set symbolName(value:String):void
		{
			_symbolName = value;
		}
		/**
		 *   判断前后两次是否一样
		 * @param other
		 * @return 
		 * 
		 */		
		public function equals(other : AssetURI) : Boolean
		{
			return other != null && packName == other.packName
				&& symbolName == other.symbolName;
		}
		/**
		 * 返回对象的路径，比如image的路径是skin#button
		 * @return 
		 * 
		 */		
		public function toString() : String
		{
			return (packName ? (packName + ":") : "") + packName + "#" + symbolName;
		}
	}
}