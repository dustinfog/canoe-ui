package canoe.studio.util
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class BitmapDataUtil
	{
		public static function scale(src : BitmapData, scaleX : Number, scaleY : Number) : BitmapData {
			var dist : BitmapData = new BitmapData(scaleX * src.width, scaleY * src.height, src.transparent, 0);
			dist.draw(src,
				new Matrix(scaleX, 0, 0, scaleY),
				null, null,
				new Rectangle(0, 0, dist.width, dist.height));
			return dist;
		}
		
		public static function getColorBounds(src : BitmapData) : Rectangle
		{
			var width : int  = src.width;
			var height : int = src.height;
			
			var rgbArray : Vector.<uint> = src.getVector(new Rectangle(0, 0, width, height));
			
			var minX : int = width - 1, minY : int = height - 1, maxX : int  = 0, maxY : int = 0;
			
			var found : Boolean = false;
			for(var x : int = 0; x < width; x ++)
			{
				for(var y : int = 0; y < height; y ++)
				{
					var color : uint = rgbArray[width * y + x];
					var alpha : uint = color >> 24;
					var rgb : uint = color & 0x00ffffff;
					
					if(alpha != 0 && rgb != 0)
					{
						minX = Math.min(minX, x);
						maxX = Math.max(maxX, x);
						minY = Math.min(minY, y);
						maxY = Math.max(maxY, y);
						
						found = true;
					}
				}
			}
			
			if(found)
			{
				return new Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1);
			}
			else
			{
				return new Rectangle(0, 0, 1, 1);
			}
		}
		
		public static function getSubBitmapData(src : BitmapData, rect : Rectangle) : BitmapData
		{
			var bitmapData : BitmapData = new BitmapData(rect.width, rect.height, src.transparent, 0);
			bitmapData.copyPixels(src, rect, new Point(0, 0));
			
			return bitmapData;
		}
	}
}