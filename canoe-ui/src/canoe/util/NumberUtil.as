package canoe.util
{
	public class NumberUtil
	{
		public static function getByPrecision(num : Number, precision : uint) : Number
		{
			var multi : uint = Math.pow(10, precision);
			return Math.round(num * multi) / multi;
		}
		
		public static function equals(num1 : Number, num2 : Number) : Boolean
		{
			return (isNaN(num1) && isNaN(num2)) || num1 == num2;
		}
		
		public static function restrict(num : Number, minimum : Number, maximum : Number) : Number
		{
			return Math.min(maximum, Math.max(minimum, num));
		}
	}
}