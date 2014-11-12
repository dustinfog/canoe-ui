package canoe.util.reflect
{
	import flash.system.ApplicationDomain;
	import flash.system.System;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;

	public class ClassReflector
	{
		private static const reflectorDict : Dictionary = new Dictionary();
        private static var staticFlag : Boolean = false;

		public static function reflect(object : Object, cached : Boolean = false, applicationDomain : ApplicationDomain = null) : ClassReflector
		{
			var clazz : Class;
			if(object is Class)
			{
				clazz = Class(object);
			}
			else
			{
				clazz = object["constructor"];
			}

			var reflector : ClassReflector = reflectorDict[clazz];
			
			if(!reflector)
			{
				staticFlag = true;
				reflector = new ClassReflector(clazz, applicationDomain);
				if(cached)
				{
					reflectorDict[clazz] = reflector;
				}

				staticFlag = false;
			}
            
			return reflector;
		}
        
		private var _clazz : Class;
		private var _extendsClasses : Array;
        private var _metadatas : Array;
		private var _implementsInterfaces : Array;
		private var _members : Array;
		private var _staticMembers : Array;
		private var _isDynamic : Boolean;
		private var _constructor : Constructor;
		private var _applicationDomain : ApplicationDomain;

		public function ClassReflector(clazz : Class, applicationDomain : ApplicationDomain = null)
		{
            if(!staticFlag)
			{
				throw new Error("please use ClassReflector.reflect() instantiate");
			}
			
			_clazz = clazz;
			_extendsClasses = [];
			_implementsInterfaces = [];
			_members = [];
			_staticMembers = [];
			_metadatas = [];
            
			var description : XML = describeType(clazz);
			_isDynamic = (description.@isDynamic == "true");
			
			var subNodes : XMLList = description.*;
			
			for each(var subNode : XML in subNodes)
			{
				var subNodeName : String = subNode.name();
				
				var member : Member;
				
				if(subNodeName == "factory")
				{
					var factoryNodes : XMLList = subNode.*;
					
					for each(var factoryNode : XML in factoryNodes)
					{
						var factoryNodeName : String = factoryNode.name();
						if(factoryNodeName == "extendsClass")
						{
							_extendsClasses.push(parseType(factoryNode.@type));
						}
						else if(factoryNodeName == "implementsInterface")
						{
							_implementsInterfaces.push(parseType(factoryNode.@type));
						}
						else if(factoryNodeName == "metadata")
						{
							metadatas.push(parseMetadata(factoryNode));
						}
						else if(factoryNodeName == "constructor")
						{
							_constructor = new Constructor();
							parseParams(factoryNode, _constructor);
						}
						else if((member = parseMember(factoryNode)) != null)
						{
							members.push(member);
						}
					}
				}
				else if((member = parseMember(subNode)) != null)
				{
					staticMembers.push(member);
				}
			}

			System.disposeXML(description);
		}
		
		public function get applicationDomain() : ApplicationDomain
		{
			return _applicationDomain;
		}
		
		public function get constructor() : Constructor
		{
			return _constructor;
		}
		
		public function get isDynamic():Boolean
		{
			return _isDynamic;
		}
		
		public function get isInterface() : Boolean
		{
			return extendsClasses.length == 0;
		}
		
		public function get clazz() : Class
		{
			return _clazz;
		}
		
		public function get members():Array
		{
			return _members;
		}
		
		public function get staticMembers() : Array
		{
			return _staticMembers;
		}

		public function get metadatas():Array
		{
			return _metadatas;
		}
		
		public function get extendsClasses():Array
		{
			return _extendsClasses;
		}
		
		public function get implementsInterfaces():Array
		{
			return _implementsInterfaces;
		}
        		
		private function parseMember(memberNode : XML) : Member
		{
			var nodeName : String = memberNode.name();
			var member : Member;

			if(nodeName == "accessor")
			{
				var accessor : Accessor = new Accessor();
				accessor.type = parseType(memberNode.@type); 
				accessor.declaredBy = parseType(memberNode.@declaredBy);
				accessor.access = memberNode.@access;

				member = accessor;
			}
			else if(nodeName == "constant")
			{
				var constant : Constant = new Constant();
				constant.type = parseType(memberNode.@type);
				
				member = constant;
			}
			else if(nodeName == "variable")
			{
				var variable : Variable = new Variable();
				variable.type = parseType(memberNode.@type);
				
				member = variable;
			}
			else if(nodeName == "method")
			{
				var method : Method = new Method();
				method.returnType = parseType(memberNode.@returnType);
				method.declaredBy = parseType(memberNode.@declaredBy);

				parseParams(memberNode, method);
				
				member = method;
			}
			
			if(member)
			{
				member.name = memberNode.@name;
				var metadataNodes : XMLList = memberNode.metadata;
				for each(var metadataNode : XML in metadataNodes)
				{
					member.metadatas.push(parseMetadata(metadataNode));
				}

				return member;
			}

			return null;
		}
		
		public function getMetadatasByName(name : String) : Array
		{
			var ret : Array = [];
			for each(var metadata : Metadata in metadatas)
			{
				if(metadata.name == name)
				{
					ret.push(metadata);
				}
			}
			
			return ret;
		}
		
		private function parseMetadata(metaNode : XML) : Metadata
		{
			var metadata : Metadata = new Metadata;
			metadata.name = metaNode.@name;

			var args : XMLList = metaNode.arg;
			var argIndex : int = 0;
			
			for(var j : uint = 0, len : uint = args.length(); j < len; j ++)
			{
				var arg : XML = args[j];
				
				metadata.args[arg.@key.toString() || (argIndex ++ )] = arg.@value.toString();
                metadata.args.length = argIndex;
			}
            
			return metadata;
		}
		
		private function parseParams(funcNode : XML, func : IFunction) : void
		{
			var paramNodes : XMLList = funcNode.parameter;
			for each(var paramNode : XML in paramNodes)
			{
				var param : Parameter = new Parameter();
				param.type = parseType(paramNode.@type);
				param.optional = (paramNode.@optional == "true");
				
				func.parameters.push(param);
			}
		}
		
		private function parseType(typeName : String) : Class
		{
			if(typeName == "void" || !typeName)
				return null;
			else if(typeName == "*")
				return Object;
			else
			{
				try
				{
					return Class(getDefinitionByName(typeName));
				}
				catch(e : Error)
				{
					if(applicationDomain && applicationDomain.hasDefinition(typeName))
					{
						return applicationDomain.getDefinition(typeName) as Class;
					}
				}
			}
			
			return Object;
		}
	}
}