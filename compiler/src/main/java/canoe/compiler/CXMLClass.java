package canoe.compiler;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import canoe.as.ASClass;
import canoe.as.ASField;
import canoe.as.ASMethod;
import canoe.as.ASVar;
import canoe.as.Modifiers;
import canoe.compiler.at.At;
import canoe.compiler.at.AtArray;
import canoe.compiler.at.AtAsset;
import canoe.compiler.at.AtClass;
import canoe.compiler.at.AtFalse;
import canoe.compiler.at.AtProcessor;
import canoe.compiler.at.AtTrue;
import canoe.utils.FileUtils;
import canoe.utils.StringUtils;
import canoe.utils.XMLUtils;

public class CXMLClass {
	public static final String INTERFACE_DOCUMENT = "canoe.core.IDocument";
	private ASClass baseClass;
	private String namespace;
	private String name;
	private int creationId;

	public CXMLClass(String namespace, String name) {
		this.namespace = namespace;
		this.name = name;
	}

	public CXMLClass(String name) {
		this("", name);
	}

	public ASClass getBaseClass() {
		return baseClass;
	}

	public boolean compile() {
		String relativeDir = File.separator
				+ namespace.replace('.', File.separatorChar) + File.separator;
		String relativePath = relativeDir + name;
		String baseClassName = "_" + name;

		File cxmlFile = new File(Project.instance.getCxmlPath() + relativePath
				+ ".cxml");
		File baseAsFile = new File(Project.instance.getSwapPath() + relativeDir
				+ baseClassName + ".as");

		if (baseAsFile.lastModified() >= cxmlFile.lastModified())
			return false;

		baseClass = new ASClass(namespace, baseClassName)
				.modify(Modifiers.INTERNAL);
		System.out.println("编译[" + namespace + "." + name + "]");

		Document doc = XMLUtils.load(cxmlFile);
		Element root = doc.getDocumentElement();

		String baseQName = getQName(root);

		baseClass.depends(baseQName);
		baseClass.inherits(baseQName);

		StringBuilder creationBuilder = new StringBuilder(
				"super.create();\nvar self:").append(baseClassName).append(
				" = this; \n");
		updateElement(root, creationBuilder, "self", false);

		baseClass.addMethod(
				new ASMethod("create", "void").modify(Modifiers.PROTECTED)
						.setOverride(true).setBody(creationBuilder.toString()))
				.addMethod(
						new ASMethod("$", "*").addArg(new ASVar("value", "*"))
								.modify(Modifiers.PRIVATE)
								.setBody(" return value;"));

		if (!baseAsFile.exists()) {
			baseAsFile.getParentFile().mkdirs();
		}

		FileUtils.writeFileContent(baseAsFile, baseClass.toString());

		File classFile = new File(Project.instance.getSourcePath()
				+ relativePath + ".as");
		if (!classFile.exists()) {
			ASClass clazz = new ASClass(namespace, name);
			clazz.inherits(baseClassName).addMethod(
					new ASMethod("create", "void").modify(Modifiers.PROTECTED)
							.setOverride(true).setBody("super.create();\n"));

			classFile.getParentFile().mkdirs();
			FileUtils.writeFileContent(classFile, clazz.toString());
		}

		return true;
	}

	private String createElement(Element element, boolean uiElement) {
		String qName = getQName(element);
		baseClass.depends(qName);

		String varName = element.getAttribute("id");
		StringBuilder creationBuilder;
		if (varName.length() != 0) {
			baseClass.addField(new ASField(varName, qName)
					.modify(Modifiers.PUBLIC));
			creationBuilder = new StringBuilder(varName);
		} else {
			varName = "tmp";
			creationBuilder = new StringBuilder("var ").append(varName)
					.append(" :").append(qName);
		}

		creationBuilder.append(" = new ").append(qName).append("();\n");
		updateElement(element, creationBuilder, varName, "Array".equals(qName));
		if (uiElement) {
			baseClass.depends("canoe.core.IElement");
			creationBuilder.append("if(").append(varName)
					.append(" is canoe.core.IElement) canoe.core.IElement(")
					.append(varName).append(").document = this;\n");
		}

		creationBuilder.append("return ").append(varName).append(";");

		String methodName = "create" + (++creationId);
		baseClass.addMethod(new ASMethod(methodName, qName).modify(
				Modifiers.PRIVATE).setBody(creationBuilder.toString()));

		return methodName + "()";
	}

	private void updateElement(Element element, StringBuilder creationBuilder,
			String varName, boolean isArray) {
		List<Element> childElements = null, attrElements = null;
		Element statesElement = null;

		// 初始化childElements, attrElements, statesElement
		NodeList childNodes = element.getChildNodes();
		for (int i = 0, length = childNodes.getLength(); i < length; i++) {
			Node childNode = childNodes.item(i);
			if (!(childNode instanceof Element))
				continue;
			Element childElement = (Element) childNode;
			String localName = childElement.getLocalName();
			if ("states".equals(localName)) {
				statesElement = childElement;
			} else {
				char firstChar = localName.charAt(0);
				if (firstChar >= 65 && firstChar <= 90) {
					if (childElements == null) {
						childElements = new ArrayList<Element>();
					}
					childElements.add(childElement);
				} else {
					if (attrElements == null) {
						attrElements = new ArrayList<Element>();
					}
					attrElements.add(childElement);
				}
			}
		}

		if (statesElement != null) {
			compileStates(statesElement, varName, creationBuilder);
		}

		NamedNodeMap attributes = element.getAttributes();

		for (int i = 0, length = attributes.getLength(); i < length; i++) {
			Node node = attributes.item(i);

			if ((node.getPrefix() == null && "xmlns".equals(node.getLocalName())) || "xmlns".equals(node.getPrefix()))
				continue;
			compileAttrNode(node, varName, creationBuilder);
		}

		if (attrElements != null) {
			for (Element attrElement : attrElements) {
				compileAttrElement(attrElement, varName, creationBuilder);
			}
		}

		if (childElements != null) {
			for (Element childElement : childElements) {
				compileChildElement(childElement, varName, creationBuilder,
						isArray);
			}
		}
	}

	private void compileStates(Element statesElement, String varName,
			StringBuilder creationBuilder) {
		creationBuilder.append(varName).append(".states = [");
		NodeList stateNodes = statesElement.getChildNodes();
		for (int i = 0, length = stateNodes.getLength(); i < length; i++) {
			Node node = stateNodes.item(i);
			if (!(node instanceof Element))
				continue;

			Element stateElement = (Element) node;
			if (!"State".equals(stateElement.getLocalName())) {
				System.err.println("state属性只能以canoe.state.State列表为值");
				continue;
			}

			baseClass.depends("canoe.state.State");
			creationBuilder
					.append("new canoe.state.State(")
					.append(StringUtils.toAsLiteral(stateElement
							.getAttribute("name"))).append("),");
		}
		StringUtils.removeLastComma(creationBuilder).append("];\n");
	}

	private void compileAttrNode(Node node, String varName,
			StringBuilder creationBuilder) {
		String attrName = node.getNodeName();
		String[] propAndState = parsePropAndState(attrName);

		attrName = propAndState[0];
		String state = propAndState[1];
		String value = node.getNodeValue();

		boolean atProcessed = false;
		if (value.charAt(0) == '@') {
			int indexl = value.indexOf("(");
			String atName = null;
			String[] params = null;
			if (indexl < 0) {
				atName = value.substring(1);
			} else {
				int indexr = value.indexOf(")");

				if (indexr > 0) {
					atName = value.substring(1, indexl).trim();
					params = StringUtils.trimAll(value.substring(indexl + 1,
							indexr).split(","));
				}
			}

			if (atName != null) {
				Class<? extends AtProcessor> atClass = getAtProcesserClass(atName);

				if (atClass != null) {
					try {
						AtProcessor at = atClass.newInstance();
						at.call(varName, attrName, params, state, this,
								creationBuilder);
						atProcessed = true;
					} catch (Exception e) {
						e.printStackTrace(System.err);
					}
				}
			}
		}

		if (!atProcessed) {
			String binding = null;
			String expr = Util.parseExpression(value, baseClass);
			if (expr != null) {
				binding = Util.createHandlerBinding(varName, attrName, expr,
						baseClass);
			}

			if (state == null) {
				if (binding == null) {
					creationBuilder.append(Util
							.assign(varName, attrName, value));
				} else {
					creationBuilder.append(Util.registerBinding(binding));
				}
			} else {
				if (binding == null) {
					creationBuilder
							.append(Util.pushOverride(state, Util
									.createSimpleOverride(varName, attrName,
											StringUtils.toAsLiteral(value),
											baseClass)));
				} else {
					creationBuilder.append(Util.pushOverride(state,
							Util.createBindingOverride(binding, baseClass)));
				}
			}
		}
	}

	private void compileAttrElement(Element attrElement, String varName,
			StringBuilder creationBuilder) {
		NodeList subChildNodes = attrElement.getChildNodes();
		for (int j = 0, subLength = subChildNodes.getLength(); j < subLength; j++) {
			Node subChildNode = subChildNodes.item(j);
			if (subChildNode instanceof Element) {
				String attrName = attrElement.getLocalName();
				String[] propAndState = parsePropAndState(attrName);

				attrName = propAndState[0];
				String state = propAndState[1];
				String value = createElement((Element) subChildNode, false);

				if (state == null) {
					creationBuilder.append(varName).append(".")
							.append(attrName).append(" = ").append(value)
							.append(";\n");
				} else {
					creationBuilder.append(Util.pushOverride(state, Util
							.createSimpleOverride(varName, attrName, value,
									baseClass)));
				}
				break;
			}
		}
	}

	private void compileChildElement(Element childElement, String varName,
			StringBuilder creationBuilder, boolean isArray) {
		creationBuilder.append(varName).append(".")
				.append(isArray ? "push" : "addChild").append("(")
				.append(createElement(childElement, true)).append(");\n");
	}

	private Class<? extends AtProcessor> getAtProcesserClass(String atName) {
		Class<? extends AtProcessor> atClass = null;
		if ("".equals(atName)) {
			atClass = At.class;
		} else if ("Array".equals(atName)) {
			atClass = AtArray.class;
		} else if ("Asset".equals(atName)) {
			atClass = AtAsset.class;
		} else if ("Class".equals(atName)) {
			atClass = AtClass.class;
		} else if ("false".equals(atName)) {
			atClass = AtFalse.class;
		} else if ("true".equals(atName)) {
			atClass = AtTrue.class;
		}

		return atClass;
	}

	private String getQName(Element element) {
		String namespaceURI = element.getNamespaceURI();
		String localName = element.getLocalName();
		if (namespaceURI == null) {
			return localName;
		} else {
			return namespaceURI + "." + localName;
		}
	}

	private String[] parsePropAndState(String attrName) {
		int index = attrName.indexOf(".");
		String[] ret = new String[2];
		if (index < 0) {
			ret[0] = attrName;
		} else {
			ret[0] = attrName.substring(0, index);
			baseClass.depends("canoe.managers.StateManager");
			ret[1] = "canoe.managers.StateManager.getState(this, "
					+ StringUtils.toAsLiteral(attrName.substring(index + 1))
					+ ")";
		}

		return ret;
	}

	public static void main(String[] args) {
		File configFile = new File(
				"E:\\Documents\\canoe\\canoe-sample\\project.canoe");
		Project.instance.load(configFile);
		new CXMLClass("canoe.sample.view", "MainView").compile();
	}
}
