package canoe.compiler;

import java.io.File;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import canoe.as.ASMethod;
import canoe.as.Modifiers;
import canoe.utils.FileUtils;
import canoe.utils.StringUtils;
import canoe.utils.XMLUtils;

public class Project {
	public static final Project instance = new Project();

	private Project() {
	}

	private String sourcePath;
	private String cxmlPath;
	private String swapPath;
	private String assetPath;
	private String binaryPath;
	private String projectPath;
	private String locale;
	private boolean inited;

	public String getSourcePath() {
		return sourcePath;
	}

	public String getCxmlPath() {
		return cxmlPath;
	}

	public String getAssetPath() {
		return assetPath;
	}

	public String getBinaryPath() {
		return binaryPath;
	}

	public String getProjectPath() {
		return projectPath;
	}

	public String getSwapPath() {
		return swapPath;
	}
	
	public String getLocale() {
		return locale;
	}

	public boolean isInited() {
		return inited;
	}

	private File projFile;
	private Document doc;

	public void compilePreset() {
		String name = "_preset";
		File asFile = new File(swapPath + File.separator + name + ".as");
		if (asFile.lastModified() > projFile.lastModified())
			return;

		ASMethod presetMethod = new ASMethod("", "_preset", "void")
				.depends("canoe.managers.SkinManager").modify(Modifiers.INTERNAL);
		StringBuilder bodyBuilder = new StringBuilder();
		if(!StringUtils.isEmpty(locale))
		{
			presetMethod.depends("canoe.core.CanoeGlobals");
			bodyBuilder.append("CanoeGlobals.locale = \"" + locale + "\";\n");
		}

		Element docElement = doc.getDocumentElement();
		NodeList skinElements = docElement.getElementsByTagName("skin");

		for (int i = 0, length = skinElements.getLength(); i < length; i++) {
			Element skinElement = (Element) skinElements.item(i);
			if ("true".equals(skinElement.getAttribute("default"))) {
				String comp = skinElement.getAttribute("for");
				String skin = skinElement.getAttribute("class");

				presetMethod.depends(comp).depends(skin);
				bodyBuilder
						.append("canoe.managers.SkinManager.registerDefaultSkinClass(")
						.append(comp).append(", ").append(skin).append(");\n");
			}
		}

		presetMethod.setBody(bodyBuilder.toString());
		FileUtils.writeFileContent(asFile, presetMethod.toString());
	}

	public void load(File projFile) {
		this.projFile = projFile;
		doc = XMLUtils.load(projFile);

		Element docElement = doc.getDocumentElement();
		NodeList nodes = docElement.getElementsByTagName("path").item(0)
				.getChildNodes();

		projectPath = projFile.getParentFile().getAbsolutePath();
		for (int i = 0, length = nodes.getLength(); i < length; i++) {
			Element element;
			try {
				element = (Element) nodes.item(i);
			} catch (Exception e) {
				continue;
			}

			String tagName = element.getTagName();
			String value = projectPath + File.separator
					+ element.getAttribute("value");
			if (tagName.equals("sourcePath")) {
				sourcePath = value;
			} else if (tagName.equals("cxmlPath")) {
				cxmlPath = value;
			} else if (tagName.equals("swapPath")) {
				swapPath = value;
			} else if (tagName.equals("assetPath")) {
				assetPath = value;
			} else if (tagName.equals("binaryPath")) {
				binaryPath = value;
			} else if (tagName.equals("locale")) {
				locale = element.getAttribute("value");
			}
		}
		
		inited = true;
	}
}
