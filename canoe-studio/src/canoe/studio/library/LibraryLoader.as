package canoe.studio.library
{
	import canoe.studio.util.FileUtil;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.utils.ByteArray;
	
	import nochump.util.zip.ZipFile;

	[Event(name="complete", type="flash.events.Event")]
	public class LibraryLoader extends EventDispatcher
	{
		private static const STATUS_INIT : int = 1;
		private static const STATUS_LOADING : int = 2;
		private static const STATUS_COMPLETE : int = 3;
		
		private var swcFile : File;
		private var loader : Loader;
		private var status : uint = STATUS_INIT;
		private var _catalog : LibraryCatalog;

		public function LibraryLoader(swcFile : File)
		{
			this.swcFile = swcFile;
		}

		public function get catalog():LibraryCatalog
		{
			return _catalog;
		}

		public function load() : void
		{
			if(status != STATUS_INIT) return;

			var bytes : ByteArray = FileUtil.readFileBytes(swcFile);
			var zipFile : ZipFile = new ZipFile(bytes);
			
			bytes = zipFile.getInput(zipFile.getEntry("catalog.xml"));
			var xml : XML = new XML(new String(bytes));
			
			_catalog = new LibraryCatalog(xml);
			System.disposeXML(xml);

			bytes = zipFile.getInput(zipFile.getEntry("library.swf"));
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			
			var loaderContext : LoaderContext = new LoaderContext();
			loaderContext.allowCodeImport = true;
			loaderContext.applicationDomain = ApplicationDomain.currentDomain;
			loader.loadBytes(bytes, loaderContext);
			
			status = STATUS_LOADING;
		}
		
		private function loader_completeHandler(event:Event):void
		{
			status = STATUS_COMPLETE;
			dispatchEvent(event);
		}
		
		private function getZipEntryBytes(zipFile : ZipFile, entryName : String) : ByteArray
		{
			return zipFile.getInput(zipFile.getEntry(entryName));
		}
	}
}