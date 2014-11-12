package canoe.compiler;

import java.io.File;

import canoe.utils.FileUtils;


public class CXMLCompiler {
	public static boolean compile()
	{
		File cxmlPath = new File(Project.instance.getCxmlPath());
		return treeCompile(cxmlPath, "");
	}
	
	private static boolean treeCompile(File path, String namespace)
	{
		boolean ret = false;
		File[] subFiles = path.listFiles();
		
		for(File subFile : subFiles)
		{
			String fileName = subFile.getName();
			if(fileName.startsWith(".")) continue;
			if(subFile.isDirectory())
			{
				ret = treeCompile(subFile, namespace == "" ? fileName : (namespace + "." + fileName)) || ret;
			}
			else if(subFile.getName().endsWith(".cxml"))
			{
				CXMLClass clazz = new CXMLClass(namespace, FileUtils.getBaseName(subFile));
				ret = clazz.compile() || ret;
			}
			else
			{
				File distFile = new File(Project.instance.getBinaryPath() + File.separator + namespace.replace('.', File.separatorChar) + File.separator + fileName);
				if(subFile.lastModified() > distFile.lastModified())
				{
					FileUtils.copy(subFile, distFile);
					System.out.println("拷贝文件" + fileName);
				}
			}
		}
		
		return ret;
	}
}
