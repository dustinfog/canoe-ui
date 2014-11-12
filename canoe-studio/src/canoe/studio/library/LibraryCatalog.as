package canoe.studio.library
{
	public class LibraryCatalog
	{
		private var definitionDict : Object = {};
		
		public function LibraryCatalog(xml : XML)
		{
			var ns1:Namespace = new Namespace("http://www.adobe.com/flash/swccatalog/9"); 
			default xml namespace = ns1;
			
			for each(var def : XML in xml..def)
			{
				var defId : String = def.@id;
				var colonIndex : int = defId.indexOf(":");
				
				var ns : String = defId.substring(0, colonIndex);
				var className : String = defId.substring(colonIndex + 1);
				
				var definitions : Array = definitionDict[ns];
				if(!definitions)
				{
					definitionDict[ns] = [className];
				}
				else
				{
					definitions.push(className);
				}
			}

			default xml namespace = "";
		}
		
		public function getClassNames(ns : String) : Array
		{
			return definitionDict[ns];
		}

		public function hasDefinition(name : String) : Boolean
		{
			var colonIndex : int = name.indexOf(":");
			var ns : String = name.substring(0, colonIndex);
			var className : String = name.substring(colonIndex + 1);
			
			var definitions : Array = definitionDict[ns];
			return definitions && definitions.indexOf(className) >= 0;
		}
	}
}