package canoe.cxml
{
	import avmplus.getQualifiedClassName;
	
	import canoe.binding.BindingUtil;
	import canoe.binding.CXMLSimpleBinding;
	import canoe.binding.IBindingExpression;
	import canoe.core.IElement;
	import canoe.managers.StateManager;
	import canoe.state.CXMLSimpleOverride;
	import canoe.state.State;
	import canoe.util.ArrayUtil;
	import canoe.util.StringUtil;

	public class CXMLTranslator
	{
        public static var childProcesssorFactory : ChildProcessorFactory = ChildProcessorFactory.instance;
        public static var atProcessorFactory : AtProcessorFactory = AtProcessorFactory.instance;
		public static var nodeFatory : INodeFactory = new CurrentDomainNodeFactory();
		
		public static function createWithXML(xml : XML, document : Object = null, creationCallback : Function = null) : * 
		{
            if(xml.nodeKind() == "text") return xml.toString();
			
			var className : String = xml.name();
			var instance : Object = nodeFatory.create(className);
			
			if(instance)
			{
				if(creationCallback != null)
				{
					creationCallback(xml, instance);
				}
	
				updateWithXML(instance, xml, document || instance, creationCallback);
			}

			return instance;
		}
        
		public static function updateWithXML(instance : Object, xml : XML, document : Object = null, creationCallback : Function = null) : void
		{
			if(instance is IElement)
			{
				if(document != null)
				{
					IElement(instance).document = document;
				}
				
				var stateNodes : XMLList = xml.states.*;
                if(stateNodes.length() > 0)
				{
                    var states : Array = [];
					for each(var stateNode : XML in stateNodes)
					{
						states.push(createWithXML(stateNode));
					}
					IElement(instance).states = states;
				}
			}
			
            var attrs : XMLList = xml.attributes();
			for each(var attr : XML in  attrs)
			{
                var attrName : String = attr.localName();
				var value : String = attr.toString();
                
				var propAndState : Array = parsePropAndState(attrName, document);
                var prop : String = propAndState.shift();
				var state : State = null;
				if(propAndState.length)
				{
					state = propAndState.shift();
				}
				
				var atProcessed : Boolean = false;
				if(value.charAt(0) == "@")
				{
					var indexl : int = value.indexOf("(");
					var atName : String = null;
					var params : Array = null;
					if(indexl < 0)
					{
						atName = StringUtil.trim(value.substring(1));
					}
					else
					{
						var indexr : int = value.indexOf(")");
						
						if(indexr > 0)
						{
							atName = StringUtil.trim(value.substring(1, indexl));
							params = ArrayUtil.trimAll(value.substring(indexl + 1, indexr).split(","));
						}
					}
					
					if(atName != null)
					{
						var atPsr : IAtProcessor = atProcessorFactory.getProcessor(atName);
						atPsr.call(instance, prop, params, state, document as IElement);
						atProcessed = true;
					}
				}
				
				if(!atProcessed)
				{
                    if(state == null)
					{
						var expression : IBindingExpression = BindingUtil.parseExpression(value, document);
						if(expression)
						{
							(document as IElement).registerBinding(new CXMLSimpleBinding(IElement(instance), prop, expression));
						}
						else
						{
							instance[prop] = value;
						}
					}
					else
					{
						state.overrides.push(new CXMLSimpleOverride(instance, prop, value));
					}
				}
			}
			            
			var children : XMLList = xml.elements();
			for each(var child : XML in children)
			{
				var basename : String = child.localName();
                if(basename == "states") continue;
				
				var firstChar : int = basename.charCodeAt(0);
				
				if(firstChar >= 65 && firstChar <= 90)
				{
					var childProcessor : IChildProcessor = childProcesssorFactory.getProcessor(instance);
					
					if(childProcessor == null)
					{
						throw new Error("can not find the child processor for class[" + getQualifiedClassName(instance) + "]");
					}
					
					var childInst : * = createWithXML(child, document, creationCallback);
					if(childInst)
					{
						childProcessor.appendChild(instance, childInst);
					}
				}
				else
				{
					var subChildren : XMLList = child.elements();
					if(subChildren.length() == 1)
					{
						propAndState = parsePropAndState(basename, document);
						prop = propAndState.shift();
						state = null;
                        
						if(propAndState.length)
						{
							state = propAndState.shift();
						}
                        
						var valueObj : Object = createWithXML(subChildren[0]);
                        if(state == null)
						{
							instance[prop] = valueObj;
						}
						else
						{
							state.overrides.push(new CXMLSimpleOverride(instance, prop, valueObj));
						}
					}
					else
					{
						throw new Error("invalid attribute for [" + getQualifiedClassName(instance) + "]");
					}
				}
			}
		}
		
		private static function parsePropAndState(fullPropName : String, document : Object) : Array
		{
			var index : int = fullPropName.indexOf(".");
			if(index < 0)
			{
				return [fullPropName];
			}
			else
			{
                var arry : Array = [fullPropName.substr(0, index)];
				if(document != null)
				{
					var stateName : String = fullPropName.substr(index + 1);
					arry.push(StateManager.getState(IElement(document), stateName));
				}
                
				return arry;
			}
		}
	}
}