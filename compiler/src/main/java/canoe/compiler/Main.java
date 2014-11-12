package canoe.compiler;

import java.io.File;

import canoe.utils.FileUtils;

public class Main {
	public static void main(String[] args) throws Exception{
		if(args.length < 2)
		{
			printHelp();
			return;
		}
		
		Project.instance.load(new File(args[0]));
		String cmd = args[1];

		if("clean".equals(cmd))
		{
			FileUtils.remove(new File(Project.instance.getSwapPath()));
		}
		
		if("cxmlc".equals(cmd) || "clean".equals(cmd))
		{
			Project.instance.compilePreset();
			CXMLCompiler.compile();
		}
		else if("assetc".equals(cmd) || "clean".equals(cmd))
		{
			AssetCompiler.compile();
		}
		else
		{
			printHelp();
		}
		
		System.out.println("Finish!");
	}
	
	public static void printHelp()
	{
		System.out.println("compiler [project file] [cmd]\n" +
				"cmd:\n" +
				"	clean 清理并编译cxml\n" +
				"	cxmlc 编译cxml文件\n" +
				"	assetc 打包素材\n");
	}
}