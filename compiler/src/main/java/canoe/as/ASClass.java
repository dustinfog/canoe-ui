package canoe.as;

import java.io.File;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import canoe.utils.StringUtils;

public class ASClass {

	public static final String INDENT = "\t";

	private String packageName;
	private String className;
	private Set<String> importments;
	private Set<String> interfaces;
	private String parent;
	private ASComment comment;
	private List<ASField> fields;
	private List<ASMethod> methods;
	private ASMethod constructor;
	private String modifier = Modifiers.PUBLIC;

	public ASClass(String packageName, String className) {
		this.packageName = packageName;
		this.className = className;

		importments = new LinkedHashSet<String>();
		interfaces = new LinkedHashSet<String>();
		fields = new ArrayList<ASField>();
		methods = new ArrayList<ASMethod>();
	}

	public ASClass depends(String importment) {
		importments.add(importment);
		return this;
	}

	public ASClass inherits(String parent) {
		this.parent = parent;
		return this;
	}

	public ASClass adapt(String interfaceName) {
		interfaces.add(interfaceName);
		return this;
	}

	public ASClass addField(ASField field) {
		fields.add(field);
		return this;
	}

	public ASClass addMethod(ASMethod method) {
		methods.add(method);
		return this;
	}

	public ASClass setConstructor(String body, String comment, ASVar... args) {
		constructor = new ASMethod(className, null).modify(Modifiers.PUBLIC)
				.setComment(comment).setBody(body);

		for (ASVar arg : args) {
			constructor.addArg(arg);
		}

		return this;
	}

	public ASClass setConstructor(String body, ASVar... args) {
		return setConstructor(body, null, args);
	}

	public ASClass setConstructor(ASVar... args) {
		return setConstructor(null, null, args);
	}

	public ASClass setComment(String comment) {
		if (comment == null) {
			this.comment = null;
		} else {
			this.comment = new ASComment(comment);
		}
		return this;
	}

	public String getComment() {
		return comment == null ? null : comment.getMessage();
	}

	public String getPackageName() {
		return packageName;
	}

	public String getClassName() {
		return className;
	}

	public String getParent() {
		return parent;
	}

	public Set<String> getImportments() {
		return importments;
	}

	public Set<String> getInterfaces() {
		return interfaces;
	}

	public List<ASField> getFields() {
		return fields;
	}

	public ASClass modify(String modifier) {
		this.modifier = modifier;
		return this;
	}

	public List<ASMethod> getMethods() {
		return methods;
	}

	public File getSourceFile(String srcDir) {
		return new File(srcDir + File.separator
				+ packageName.replace(".", File.separator) + File.separator
				+ className + ".as");
	}

	public String getFullName() {
		return packageName + "." + className;
	}

	public String toString() {
		StringBuilder sb = new StringBuilder();
		sb.append("package ").append(packageName).append("{\n");

		for (String importment : importments) {
			sb.append(INDENT).append("import ").append(importment)
					.append(";\n");
		}

		sb.append("\n");

		if (comment != null) {
			String strComment = comment.toString();

			sb.append(INDENT)
					.append(strComment.replaceAll("\n", "\n" + INDENT))
					.append("\n");
		}

		sb.append(INDENT).append(modifier).append(" class ").append(className);

		if (parent != null) {
			sb.append(" extends ").append(parent);
		}

		if (!interfaces.isEmpty()) {
			sb.append(" implements ");

			for (String inf : interfaces) {
				sb.append(inf + ",");
			}

			StringUtils.removeLastComma(sb);
		}
		sb.append("{\n");

		for (ASField field : fields) {
			sb.append(INDENT)
					.append(INDENT)
					.append(field.toString().replaceAll("\n",
							"\n" + INDENT + INDENT)).append("\n");
		}

		sb.append("\n");

		if (constructor != null) {
			sb.append(INDENT)
					.append(INDENT)
					.append(constructor.toString().replaceAll("\n",
							"\n" + INDENT + INDENT)).append("\n");
			sb.append("\n");
		}

		for (ASMethod method : methods) {
			String strMethod = method.toString();
			strMethod = strMethod.replaceAll("\n", "\n" + INDENT + INDENT);

			sb.append(INDENT).append(INDENT).append(strMethod).append("\n");
		}

		sb.append(INDENT + "}\n");
		sb.append("}\n");

		return sb.toString();
	}
}
