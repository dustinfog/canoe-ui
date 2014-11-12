package canoe.util
{
	import flash.utils.Dictionary;

	public class PropertyProxy
	{
		private static const instancesDict : Dictionary = new Dictionary(true);
		
		public static function getInstance(host : Object, prop : String) : PropertyProxy
		{
			var instances : Object = instancesDict[host];
			if(!instances)
			{
				instances = {};
			}
			
			var instance : PropertyProxy = instances[prop];
			if(!instance)
			{
				instance = new PropertyProxy(host, prop);
				instances[prop] = instance;
			}
			
			return instance;
		}
		
		private var host : Object;
		private var prop : String;
		public function PropertyProxy(host : Object, prop : String)
		{
			this.host = host;
			this.prop = prop;
		}

		public function setter(v : *) : void
		{
			host[prop] = v;
		}
		
		public function getter() : *
		{
			return host[prop];
		}
	}
}