package canoe.util
{
	import flash.display.DisplayObject;
	import flash.filters.BitmapFilter;
	import flash.filters.ColorMatrixFilter;

	public class FilterUtil
	{
		public static const grayFilter : ColorMatrixFilter = new ColorMatrixFilter([0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0, 0, 0, 1, 0])
		
		public static function addFilters(target : DisplayObject, ...newFilters) : void
		{
			var filters:Array = target.filters;
			
			for each(var newFilter : BitmapFilter in newFilters)
			{
				for(var itr : Iterator = new Iterator(filters); itr.hasNext();)
				{
					var filter : BitmapFilter = itr.next();
					
					if(filter["constructor"] == newFilter["constructor"])
					{
						itr.remove();
					}
				}
				
				filters.push(newFilter);
			}
			
			target.filters = filters;
		}
		
		public static function removeFilters(target : DisplayObject, ...overdueFilters) : void
		{
			var filters:Array = target.filters;
			
			for each(var newFilter : BitmapFilter in overdueFilters)
			{
				for(var itr : Iterator = new Iterator(filters); itr.hasNext();)
				{
					var filter : BitmapFilter = itr.next();
					
					if(filter["constructor"] == newFilter["constructor"])
					{
						itr.remove();
					}
				}
			}

			target.filters = filters;
		}
	}
}