package canoe.studio.util
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class FileUtil
	{
		public static function readFileBytes(file : File) : ByteArray
		{
			var scream : FileStream = new FileStream();
			scream.open(file, FileMode.READ);
			
			var bytes : ByteArray = new ByteArray();
			scream.readBytes(bytes);
			scream.close();
			
			return bytes;
		}
		
		public static function readFileContent(file : File) : String
		{
			return new String(readFileBytes(file));
		}
		
		public static function writeFileBytes(file : File, bytes : ByteArray) : void
		{
			var scream : FileStream = new FileStream();
			scream.open(file, FileMode.WRITE);
			scream.writeBytes(bytes);
			scream.close();
		}
		
		public static function writeFileContent(file : File, content : String) : void
		{
			var scream : FileStream = new FileStream();
			scream.open(file, FileMode.WRITE);
			scream.writeMultiByte(content, "utf-8");
			scream.close();
		}
	}
}