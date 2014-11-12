package canoe.studio.entity
{
	import flash.filesystem.File;

	[Bindable]
	public class AssetPack
	{
		private var _dir : File;
		private var _name : String;
		
		public function get dir():File
		{
			return _dir;
		}

		public function set dir(value:File):void
		{
			_dir = value;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}

		public function toString() : String
		{
			return name;
		}
	}
}