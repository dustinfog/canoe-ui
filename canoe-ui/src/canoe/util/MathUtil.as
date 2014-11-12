package canoe.util
{
	import flash.geom.Point;

	public class MathUtil
	{
		public static function hypot(x : Number, y : Number) : Number
		{
			return Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
		}

		public static function getSign(v : Number) : int
		{
			if(v > 0)
			{
				return 1;
			}
			else if(v == 0)
			{
				return 0;
			}
			else
			{
				return -1;
			}
		}
		
		
		/**
		 * 将角度转化为弧度
		 * @param angle 角度
		 * @return 弧度
		 */
		public static function angleToRadian(angle:Number) : Number
		{
			return angle * Math.PI / 180;
		}
		
		/**
		 * 将弧度转化为角度
		 * @param radian 弧度
		 * @return 角度
		 */
		public static function radianToAngle(radian:Number) : Number
		{
			return radian * 180 / Math.PI;
		}
        
		public static function getRoundPoint(radius : Number, radian : Number, centerX : Number = 0, centerY : Number = 0) : Point
		{
			var x : Number = centerX + Math.cos(radian) * radius;
			var y : Number = centerY + Math.sin(radian) * radius;
            
			return new Point(x, y);
		}
	}
}