package canoe.compiler;

import java.io.File;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import canoe.utils.FileUtils;

public class CXMLTask extends Task {
	private boolean clean;

	public boolean isClean() {
		return clean;
	}

	public void setClean(boolean clean) {
		this.clean = clean;
	}
	
	private File projFile;

	public File getProjFile() {
		return projFile;
	}

	public void setProjFile(File projFile) {
		this.projFile = projFile;
	}
	
	@Override
	public void execute() throws BuildException {
		if(!Project.instance.isInited())
		{
			Project.instance.load(projFile);
		}
		
		if(clean)
		{
			FileUtils.remove(new File(Project.instance.getSwapPath()));
		}

		Project.instance.compilePreset();
		log("准备编译cxml");
		CXMLCompiler.compile();
		log("准备编译素材");
		AssetCompiler.compile();
	}
}
