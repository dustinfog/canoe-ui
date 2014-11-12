package canoe.studio.entity
{
	import canoe.studio.util.FileUtil;
	
	import flash.filesystem.File;

	public class Config
	{
		private static var _javaHome : String;
		
		private static var loaded : Boolean;

		public static function get javaHome() : String
		{
			return _javaHome;
		}

		public static function load() : void
		{
			var xml : XML = XML(FileUtil.readFileContent(File.applicationDirectory.resolvePath("config.xml")));
			_javaHome = xml..javaHome;
		}
	}
}