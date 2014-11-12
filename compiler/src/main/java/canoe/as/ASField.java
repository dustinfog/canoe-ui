package canoe.as;

import java.util.ArrayList;
import java.util.List;

public class ASField extends ASVar {
	private boolean constant;
	private List<String> modifiers;
	private ASComment comment;

	public ASField setComment(String comment) {
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
	
	public ASField(String name, String type) {
		super(name, type);
		
		modifiers = new ArrayList<String>();
	}
	
	public ASField modify(String modifier)
	{
		modifiers.add(modifier);
		
		return this;
	}

	public ASField setConstant(boolean constant) {
		this.constant = constant;
		
		return this;
	}
	
	public boolean isConstant() {
		return constant;
	}
	
	public ASVar toVar() {
		return new ASVar(getName(), getType());
	}
	
	public String toString()
	{
		StringBuilder sb = new StringBuilder();
		
		if(comment != null)
		{
			sb.append(comment).append("\n");
		}
		
		for(String modifier : modifiers)
		{
			sb.append(modifier + " ");
		}
		
		sb.append(constant ? "const " : "var ").append(super.toString()).append(";");
		
		return sb.toString();
	}
}
