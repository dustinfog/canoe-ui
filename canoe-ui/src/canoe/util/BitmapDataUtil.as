package canoe.util
{
	import flash.display.BitmapData;

	public class BitmapDataUtil
	{
		private static var _blank : BitmapData = new BitmapData(1, 1, true, 0);	
		
		public static function get blank() : BitmapData
		{
			return _blank;
		}
	}
}