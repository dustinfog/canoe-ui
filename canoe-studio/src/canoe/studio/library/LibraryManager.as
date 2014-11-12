package canoe.studio.library
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.system.System;
	
	import canoe.studio.util.FileUtil;
	
	[Event(name="complete", type="flash.events.Event")]
	public class LibraryManager extends EventDispatcher
	{
		public static const instance : LibraryManager = new LibraryManager();
		
		private var loaderQueue : Array = [];
		private var catalogs : Array;
		private var currLoader : LibraryLoader;
		
		public function LibraryManager()
		{
			var xml : XML = XML(FileUtil.readFileContent(File.applicationDirectory.resolvePath("playerglobal.xml")));
			var playerglobalCatalog : LibraryCatalog = new LibraryCatalog(xml);
			System.disposeXML(xml);
			
			catalogs = [playerglobalCatalog];
		}
		
		public function loadLibrary(swcFile : File) : void
		{
			var loader : LibraryLoader = new LibraryLoader(swcFile);
			loaderQueue.push(loader);
			
			load();
		}
		
		public function getClassNames(ns : String) : Array
		{
			var classNames : Array = [];
			for each(var catalog : LibraryCatalog in catalogs)
			{
				var subClassNames : Array = catalog.getClassNames(ns);
				if(subClassNames)
				{
					classNames = classNames.concat(subClassNames);
				}
			}
			
			return classNames;
		}
		
		private function load() : void
		{
			if(currLoader == null)
			{
				currLoader = loaderQueue.shift();	
				currLoader.addEventListener(Event.COMPLETE, currLoader_completeHandler);
				currLoader.load();
			}
		}
		
		private function currLoader_completeHandler(event:Event):void
		{
			catalogs.push(currLoader.catalog);
			currLoader = null;
			if(loaderQueue.length)
			{
				load();
			}
			else
			{
				dispatchEvent(event);
			}
		}
	}
}