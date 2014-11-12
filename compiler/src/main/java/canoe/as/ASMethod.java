package canoe.as;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class ASMethod {
	public static enum Accessor {
		set, get
	}

	private Set<String> importments;
	private List<String> modifiers;
	private String namespace;
	private String name;
	private String returnType;
	private List<ASVar> args;
	private String body;
	private Accessor accessor;
	private ASComment comment;
	private boolean override;

	public ASMethod(String name, String returnType) {
		this(null, name, returnType);
	}
	
	public ASMethod(String namespace, String name, String returnType) {
		this.name = name;
		this.returnType = returnType;
		this.namespace = namespace;
		modifiers = new ArrayList<String>();
		args = new ArrayList<ASVar>();
		importments = new LinkedHashSet<String>();
	}

	public ASMethod depends(String importment) {
		importments.add(importment);
		return this;
	}

	public Set<String> getImportments() {
		return importments;
	}
	
	public String getName() {
		return name;
	}

	public String getReturnType() {
		return returnType;
	}

	public ASMethod addArg(ASVar arg) {
		args.add(arg);
		return this;
	}

	public ASMethod modify(String modifier) {
		modifiers.add(modifier);

		return this;
	}

	public List<ASVar> getArgs() {
		return args;
	}

	public ASMethod setAccessor(Accessor accessor) {
		this.accessor = accessor;
		return this;
	}

	public ASMethod setBody(String body) {
		this.body = body;
		return this;
	}

	public String getBody() {
		return body;
	}

	public ASMethod setComment(String comment) {
		if(comment == null)
		{
			this.comment = null;
		}
		else
		{
			this.comment = new ASComment(comment);
		}
		return this;
	}

	public ASComment getComment() {
		return comment;
	}

	public boolean getOverride() {
		return override;
	}

	public ASMethod setOverride(boolean override) {
		this.override = override;
		return this;
	}

	public String toString() {
		StringBuilder sb = new StringBuilder();
		
		if(namespace != null)
		{
			sb.append("package ").append(namespace).append("{\n");

			for (String importment : importments) {
				sb.append("import ").append(importment)
						.append(";\n");
			}
		}

		if(comment != null)
		{
			sb.append(comment).append("\n");
		}
		
		if(override)
		{
			sb.append("override ");
		}
		
		for (String modifier : modifiers) {
			sb.append(modifier + " ");
		}

		sb.append("function ");

		if (accessor != null) {
			sb.append(accessor).append(" ");
		}

		sb.append(name).append("(");

		if (args != null) {
			boolean first = true;

			for (ASVar arg : args) {
				if (!first) {
					sb.append(", ");
				}

				sb.append(arg);
				first = false;
			}
		}

		sb.append(")");
		
		if(returnType != null)
		{
			sb.append(":").append(returnType);
		}
		
		sb.append("{\n");

		if (body != null) {
			sb.append("\t").append(body.replace("\n", "\n\t"));
		}

		sb.append("\n}");
		
		if(namespace != null)
		{
			sb.append("\n}");
		}
		return sb.toString();
	}
}
