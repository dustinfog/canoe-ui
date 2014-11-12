package canoe.managers
{
	import flash.utils.Dictionary;
	
	import canoe.components.Skin;
	import canoe.components.SkinnableComponent;
	import canoe.core.IFactory;
	import canoe.util.reflect.Accessor;
	import canoe.util.reflect.ClassReflector;
	import canoe.util.reflect.Member;
	import canoe.util.reflect.Variable;

	public class SkinManager
	{
        private static var classSkinDict : Dictionary = new Dictionary();
		private static var partsDict : Dictionary = new Dictionary();
        
        public static function registerDefaultSkinClass(componentClass : *, skinClass : *) : void
		{
			classSkinDict[componentClass] = skinClass;
		}
        
		public static function getSkinClass(component : SkinnableComponent) : * 
		{
			var compClass : * = component["constructor"];
			var skinClass : * = classSkinDict[compClass];
			if(!skinClass)	
			{
				var reflector : ClassReflector = ClassReflector.reflect(compClass, true);
				var minIndex : int = int.MAX_VALUE;
				for(var tmpClass : * in classSkinDict)
				{   
					var index : int = reflector.extendsClasses.indexOf(tmpClass);
                    if(index >= 0 && index < minIndex)
					{
                        minIndex = index;
						skinClass = classSkinDict[tmpClass];
					}
				}
			}
            
			return skinClass;
		}
		
		public static function createSkin(component : SkinnableComponent) : Skin
		{
			var skinClass : * = component.skinClass;
			if(skinClass == null)
			{
				throw new Error("there is no skinClass for" + component);
			}
			
			if(skinClass is IFactory)
			{
				return IFactory(skinClass).newInstance();
			}
			else
			{
				return new skinClass();
			}
		}
		
		public static function getParts(component : SkinnableComponent) : Array
		{
			var compClass : * = component["constructor"];
			var parts : Array = partsDict[compClass];
			if(parts == null)
			{
				parts = [];
				partsDict[compClass] = parts;
				
				var reflector : ClassReflector = ClassReflector.reflect(compClass);
				for each(var member : Member in reflector.members)
				{
					var metadatas : Array;
					if((member is Accessor || member is Variable) && (metadatas = member.getMetadatasByName("Part")).length > 0)
					{
						parts.push(member.name);
					}
				}
			}
			
			return parts;
		}
	}
}