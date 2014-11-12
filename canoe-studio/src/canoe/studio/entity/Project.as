package canoe.studio.entity
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.utils.IDataInput;
	import flash.utils.getDefinitionByName;
	
	import canoe.managers.SkinManager;
	import canoe.managers.TextStyleManager;
	import canoe.studio.extensions.CXMLClass;
	import canoe.studio.library.LibraryManager;
	import canoe.studio.panel.Console;
	import canoe.studio.util.FileUtil;

	public class Project extends EventDispatcher
	{
		private var _sourcePath : String;
		private var _cxmlPath : String;
		private var _assetPath : String;
		private var _binaryPath : String;
		private var _projectPath : String;
		private var _libPath : String;
		private var projFile : File;
		private var projXML : XML;
		private var _locale : String;
		
		public function set locale(value:String):void
		{
			_locale = value;
		}

		public function get locale():String
		{
			return _locale;
		}


		public function get libPath():String
		{
			return _libPath;
		}

		public function set libPath(value:String):void
		{
			_libPath = value;
		}

		public function get projectPath():String
		{
			return _projectPath;
		}

		public function get binaryPath():String
		{
			return _binaryPath;
		}

		public function set binaryPath(value:String):void
		{
			_binaryPath = value;
		}

		public function get assetPath():String
		{
			return _assetPath;
		}

		public function set assetPath(value:String):void
		{
			_assetPath = value;
		}

		public function get cxmlPath():String
		{
			return _cxmlPath;
		}

		public function set cxmlPath(value:String):void
		{
			_cxmlPath = value;
		}

		public function get sourcePath():String
		{
			return _sourcePath;
		}

		public function set sourcePath(value:String):void
		{
			_sourcePath = value;
		}

		private static var _currProject : Project;
		public static function get currProject() : Project
		{
			return _currProject;
		}
		
		public static function load(projFile : File) : void
		{
			var proj : Project = new Project();
			proj.projFile = projFile;
			proj.projXML = XML(FileUtil.readFileContent(projFile));
			proj._projectPath = projFile.parent.nativePath;
			for each(var subXML : XML in proj.projXML.path.*)
			{
				if(subXML.nodeKind() != "element") continue;
				var tagName : String = subXML.name();
				var value : String = proj.projectPath + File.separator + subXML.@value;
				if(tagName == "sourcePath")
				{
					proj.sourcePath = value;
				}
				else if(tagName == "cxmlPath")
				{
					proj.cxmlPath = value;
				}
				else if(tagName == "assetPath")
				{
					proj.assetPath = value;
				}
				else if(tagName == "binaryPath")
				{
					proj.binaryPath = value;
				}
				else if(tagName == "libPath")
				{
					proj.libPath = value;
				}
				else if(tagName == "locale")
				{
					proj.locale = subXML.@value;
				}
			}
			
			proj.loadLibrarys();
			_currProject = proj;
		}
		
		public function compileCXML() : void
		{
			compile("cxmlc");
		}
		
		public function compileAssets() : void
		{
			compile("assetc");
		}
		
		public function clean() : void
		{
			compile("clean");
		}
		
		private function loadLibrarys() : void
		{
			var libDir : File = new File(libPath);
			var libFiles : Array = libDir.getDirectoryListing();
			
			var libraryManager : LibraryManager = LibraryManager.instance;
			libraryManager.addEventListener(Event.COMPLETE, libraryManager_completeHandler);
			for each(var libFile : File in libFiles)
			{
				if(libFile.extension == "swc")
				{
					libraryManager.loadLibrary(libFile);
				}
			}
		}
		
		private function loadStyleSheets() : void
		{
			for each(var subXML : XML in projXML.styleSheets.styleSheet)
			{
				TextStyleManager.instance.load(new URLRequest(this.cxmlPath + File.separator + subXML["@file"]));
			}
		}
		
		private function registerSkins() : void
		{
			for each(var subXML : XML in projXML.skins.skin)
			{
				var compClass : * = getDefinitionByName(subXML["@for"]);
				var skinClass : * = CXMLClass.forName(subXML["@class"]);
				SkinManager.registerDefaultSkinClass(compClass, skinClass);
			}
		}
		
		private function libraryManager_completeHandler(event:Event):void
		{
			registerSkins();
			loadStyleSheets();
		}
		
		private function compile(cmd : String) : void
		{
			var javaPath : String = Config.javaHome + File.separator + "bin" + File.separator;
			var java : File = new File(javaPath + "java.exe");
			if(!java.exists)
			{
				java = new File(javaPath + "java");
			}
			var process : NativeProcess = new NativeProcess();
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, compilerOutputHandler);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, compilerErrorHandler);
			process.addEventListener(NativeProcessExitEvent.EXIT, compilerExitHandler);

			var startupInfo : NativeProcessStartupInfo = new NativeProcessStartupInfo();
			startupInfo.executable = java;
			var arguments : Vector.<String> = new Vector.<String>();
			arguments.push("-jar");
			arguments.push(File.applicationDirectory.resolvePath("libs/compiler.jar").nativePath);
			arguments.push(projFile.nativePath);
			arguments.push(cmd);
			startupInfo.arguments = arguments;
			process.start(startupInfo);
		}
		
		protected function compilerExitHandler(event:NativeProcessExitEvent):void
		{
			var process : NativeProcess = event.currentTarget as NativeProcess;
			process.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, compilerOutputHandler);
			process.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, compilerErrorHandler);
		}
		
		protected function compilerErrorHandler(event:ProgressEvent):void
		{
			var process : NativeProcess = event.currentTarget as NativeProcess;
			var error : IDataInput = process.standardError;
			Console.instance.error(error.readMultiByte(error.bytesAvailable, "UFT-8"));
		}
		
		protected function compilerOutputHandler(event:ProgressEvent):void
		{
			var process : NativeProcess = event.currentTarget as NativeProcess;
			var output : IDataInput = process.standardOutput;
			Console.instance.output(output.readMultiByte(output.bytesAvailable, "UFT-8"));
		}		
		
	}
}