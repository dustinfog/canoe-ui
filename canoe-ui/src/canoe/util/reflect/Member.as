package canoe.util.reflect
{
	public class Member
	{
		private var _name : String;
		private var _metadatas : Array = [];
		
		public function get metadatas():Array
		{
			return _metadatas;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
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
		
		public function toString() : String
		{
			return name;
		}
	}
}