package canoe.studio.util
{
	public class XMLUtil
	{
		public static function setNamespace(xml : XML, uri : String,  refXML : XML = null) : void
		{
			var actualNamespace : Namespace;
			
			refXML ||= xml;
			
			var nss : Array = refXML.inScopeNamespaces();
			var prefixes : Array = [];
			for each(var ns : Namespace in nss)
			{
				if(ns.uri == uri)
				{
					actualNamespace = ns;
				}
				else
				{
					prefixes.push(ns.prefix);
				}
			}

			if(!actualNamespace)
			{
				var bestPrefix : String;
				var lastIndexDot : int = uri.lastIndexOf(".");
				if(lastIndexDot < 0)
				{
					bestPrefix = uri;
				}
				else
				{
					bestPrefix = uri.substr(lastIndexDot + 1);
				}
				
				var prefix : String = bestPrefix;
				var i : int = 1;
				while(prefixes.indexOf(prefix) >= 0)
				{
					prefix = bestPrefix + (i ++);
				}
				
				actualNamespace = new Namespace(prefix, uri);
				refXML.addNamespace(ns);
			}
			
			xml.setNamespace(actualNamespace);
		}
		
		public static function getRoot(xml : XML) : XML
		{
			var parentXML : XML = xml.parent();
			while(parentXML)
			{
				xml = parentXML;
				parentXML = xml.parent();
			}
			
			return xml;
		}
	}
}