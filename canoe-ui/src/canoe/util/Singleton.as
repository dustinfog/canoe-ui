package canoe.util
{
	import canoe.util.reflect.ClassReflector;
	
	import flash.utils.Dictionary;

	public class Singleton
	{
		private static var instanceDict :Dictionary = new Dictionary();
		
		public static function getInstance(classIdentifier : Class, createIfNo : Boolean = true) : *
		{
			if(!instanceDict[classIdentifier] && createIfNo)
			{
				instanceDict[classIdentifier] = new classIdentifier();
			}
			
			return instanceDict[classIdentifier];
		}
		
		public static function hasInstance(classIdentifier : Class) : Boolean
		{
			return (instanceDict[classIdentifier] != null);
		}
		
		public static function registerInterface(classInterface : Class, instance : Object) : void
		{
			var reflector : ClassReflector = ClassReflector.reflect(classInterface);
			if(!reflector.isInterface)
			{
				throw new Error("class [" + classInterface + "] is not a interface");
			}
			
			if(!(instance is classInterface))
			{
				throw new Error("object [" + instance + "] is not a instance of [" + classInterface + "]");
			}
			
			instanceDict[classInterface] = instance;
		}
	}
}