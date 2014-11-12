package canoe.util
{
	import flash.utils.Dictionary;

	public class HashSet
	{
		private var _dict : Dictionary;
		
		public function HashSet(weakKeys:Boolean = true)
		{
			_dict = new Dictionary(weakKeys);
		}
		
		public function add(element : *) : void
		{
			if(!contains(element))
			{
				_dict[element] = null;
			}
		}
		
		public function remove(element : *) : void
		{
			if(contains(element))
			{
				delete _dict[element];
			}
		}
		
		public function contains(element : *) : Boolean
		{
			return (typeof _dict[element] != "undefined");
		}
		
		public function get length() : uint
		{
			return toArray().length;
		}
		
		public function toArray() : Array
		{
			var arr : Array = [];
			for(var element : * in _dict)
			{
				arr.push(element);
			}
			
			return arr;
		}
		
		public static function fromArray(array : Array) : HashSet
		{
			if(!array)
			{
				return null;
			}

			var hashSet : HashSet = new HashSet();
			for(var i : uint = 0, length : uint = array.length; i < length; i ++)
			{
				hashSet.add(array[i]);
			}
			
			return hashSet;
		}
	}
}