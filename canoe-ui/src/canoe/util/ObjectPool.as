package canoe.util
{
	import flash.utils.Dictionary;

	public class ObjectPool
	{
		private static var idleObjectDict : Dictionary = new Dictionary();
		
		public static function create(klass : Class, initHandler : Function = null) : *
		{
			var idleObjects : Array = idleObjectDict[klass];
			
			var instance : *;
			if(idleObjects && idleObjects.length > 0)
			{
				instance = idleObjects.shift();
			}
			else
			{
				instance = new klass();
				if(initHandler != null)
				{
					initHandler(instance);
				}
			}
			
			return instance;
		}
		
		public static function collect(object : *) : void
		{
            var clazz : Class = object["constructor"];
			var idleObjects : Array = idleObjectDict[clazz];
			
			if(!idleObjects)
			{
				idleObjects = [];
				idleObjectDict[clazz] = idleObjects;
			}
			
			idleObjects.push(object);
		}
	}
}