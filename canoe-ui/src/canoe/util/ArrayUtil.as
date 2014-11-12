package canoe.util
{
	public class ArrayUtil
	{
		public static function removeElements(array : Array, ...elements) : Array
		{
			if(array == null)return null;

			for(var itr : Iterator = new Iterator(array); itr.hasNext();)
			{
				if(elements.indexOf(itr.next()) >= 0)
				{
					itr.remove();
				}
			}

			return array;
		}
		
		public static function clear(array : Array, onElementRemoved : Function = null) : Array
		{
			while(array.length != 0)
			{
				var element : * = array.shift();
				if(onElementRemoved != null)
				{
					onElementRemoved(element);
				}
			}
			
			return array;
		}
        
		public static function trimAll(array : Array) : Array
		{
			for(var i : int = 0; i < array.length; i ++)
			{
				array[i] = StringUtil.trim(array[i]);
			}
            
			return array;
		}
		
		public static function addElementAt(array : Array, element : *, index : int) : Array
		{
			if(array.length > index)
			{
				ArrayUtil.removeElements(array, element);
				array.splice(index, 0, element);
				
				return array;
			}
			else
			{
				throw new RangeError();
			}
		}
		
		public static function removeElementAt(array : Array, index : int) : *
		{
			if(index >= 0 && index < array.length)
			{
				var element : * = array[index];
				array.splice(index, 1);
				
				return element;
			}
			else
			{
				throw new RangeError();
			}
		}
		
		public static function setElementIndex(array : Array, element : *, index : uint) : Array
		{
			var oldIndex : int = array.indexOf(element);
			if(oldIndex != -1 && index < array.length && oldIndex != index)
			{
				var i : int;
				if(oldIndex < index)
				{
					for(i = oldIndex + 1; i <= index; i ++)
					{
						array[i - 1] = array[i];
					}
				}
				else
				{
					for(i = index; i < oldIndex; i ++)
					{
						array[i + 1] = array[i];
					}
				}

				array[index] = element;
			}
			
			return array;
		}
		
		public static function swapElementAt(array : Array, index1 : int, index2 : int) : Array
		{
			var element1 : * = array[index1];
			var element2 : * = array[index2];
			
			array[index1] = element2;
			array[index2] = element1;
			
			return array;
		}

		public static function equals(array1 : Array, array2 : Array) : Boolean
		{
			if(array1.length != array2.length) 
				return false;
			for(var i : uint = 0; i < array1.length; i ++)
			{
				if(array1[i] != array2[i])
				{
					return false;
				}
			}
			
			return true;
		}
	}
}