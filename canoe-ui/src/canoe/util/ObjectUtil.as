package canoe.util
{
	public class ObjectUtil
	{
		public static function or(... objects) : *{
			for(var obj : * in objects)
			{
				if(obj)
					return obj;
			}
			
			return null;
		}
		
		public static function createSetter(obj : Object, ... propChains) : Function
		{
			return function(value : *) : void
			{
				setPropertyRecursive(obj, value, propChains);
			};
		}
		
		public static function createGetter(obj : Object, ... propChains) : Function
		{
			return function() : *
			{
				return getPropertyRecursive(obj, propChains);
			};
		}
		
		public static function overrideProperties(obj : Object, properties : Object) : void
		{
			for(var prop: String in properties)
			{
				obj[prop] = properties[prop];
			}
		}
		
	    public static function setPropertyRecursive(obj : Object, value : *, propertieChains : Array) : void
		{
            for(var i : uint = 0; i < propertieChains.length; i ++)
			{
				var property : String = propertieChains[i];
                
				if(i == propertieChains.length - 1)
				{
					obj[property] = value;
				}
				else
				{
					var subObj : Object = obj[property];
					if(!subObj)
					{
						subObj = {};
						obj[property] = subObj;
					}
					
					obj = subObj;
				}
			}
		}
		
		public static function getPropertyRecursive(obj : Object, propertieChains : Array) : * 
		{
			var value : * = obj;
			for each (var key : String in propertieChains)
			{
                try
				{
    				value = value[key];
				}
				catch(e : Error)
				{
					value = undefined;
				}

				if(!value) {
					break;
				}
			}
			
			return value;
		}
	}
}