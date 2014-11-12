package canoe.as;

import java.io.File;

import canoe.utils.FileUtils;


public class ASGenerator {
	private String srcDir;

	public void setSrcDir(String srcDir) {
		this.srcDir = srcDir;
	}

	public File locateClassFile(ASClass clazz)
	{
		return new File(srcDir + File.separator
				+ clazz.getPackageName().replaceAll(".", File.separator) + File.separator + clazz.getClassName() + ".as");
	}
	
	public void generate(ASClass clazz) throws Exception {
		if (srcDir == null) {
			throw new Exception("please set the srcDir");
		}

		File clazzFile = locateClassFile(clazz);

		File folder = clazzFile.getParentFile();
		folder.mkdirs();

		FileUtils.writeFileContent(clazzFile, clazzFile.toString());
	}
}
