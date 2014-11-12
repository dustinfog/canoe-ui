package canoe.studio.extensions
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	import canoe.core.IFactory;
	import canoe.cxml.CXMLTranslator;
	import canoe.studio.entity.Project;
	import canoe.studio.util.ClassUtil;
	import canoe.studio.util.FileUtil;
	
	public class CXMLClass implements IFactory
	{
		private var _className : String;
		private var xml : XML;
		
		private var classFile : File;
		private var lastModified : Number = 0;
		private var instanceIdDict : Dictionary = new Dictionary(true);
		private var tmpIdDict : Object;
		
		public function get className():String
		{
			return _className;
		}
		
		public function newInstance():*
		{
			if(lastModified < classFile.modificationDate.time)
			{
				xml = XML(FileUtil.readFileContent(classFile));
				lastModified = classFile.modificationDate.time;
			}

			tmpIdDict = {};
			var instance : * = CXMLTranslator.createWithXML(xml, null, callback);
			instanceIdDict[instance] = tmpIdDict;
			tmpIdDict = null;

			return instance;
		}
		
		private function callback(xml : XML, instance : Object) : void
		{
			var id : String = xml.@id;
			if(id)
			{
				tmpIdDict[id] = instance;
			}
		}

		public function getProperty(instance : *, prop : String) : *
		{
			if(instance.hasOwnProperty(prop))
			{
				return instance[prop];
			}
			
			var idDict : Object = instanceIdDict[instance];
			if(idDict)
			{
				return idDict[prop];
			}
			
			return null;
		}
		
		public static function forName(className : String) : CXMLClass
		{
			var classFile : File = classNameToFile(className);
			if(classFile.exists)
			{
				var clazz : CXMLClass = new CXMLClass();
				clazz._className = className;
				clazz.classFile = classFile;

				return clazz;
			}
			
			return null;
		}
		
		public static function classNameToFile(className : String) : File
		{
			return new File(Project.currProject.cxmlPath + File.separator + className.replace(/\./g, File.separator) + ".cxml");
		}
		
		public static function dirToPackageName(file : File) : String
		{
			return new File(Project.currProject.cxmlPath).getRelativePath(file).replace(/\//g, ".");
		}
		
		public static function fileToClassName(file : File) : String
		{
			return dirToPackageName(file.parent) + "." + ClassUtil.getNamespace(file.name);
		}
	}
}