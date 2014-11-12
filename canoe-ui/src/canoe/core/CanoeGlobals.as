package canoe.core
{
	import canoe.components.Application;
	
	import flash.display.Sprite;

	/**
	 *  构造函数 
	 * @author Administrator
	 * 
	 */	
	public class CanoeGlobals
	{
		/**
		 *  Application类型的静态变量 
		 */		
		public static var application : Application;
		/**
		 *   Sprite类型的静态变量
		 */		
        public static var root : Sprite;
		/**
		 *  通过设置这个静态变量来改变语言。 
		 */		
        public static var getText : IGetText;
		/**
		 * 字符串类型的静态变量 
		 */		
		public static var locale : String;
		public static const ELEMENT_DEFAULT_MAX_WIDTH : Number = 10000;
		public static const ELEMENT_DEFAULT_MAX_HEIGHT : Number = 10000;   
	}
}