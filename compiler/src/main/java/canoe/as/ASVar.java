package canoe.as;

public class ASVar {
	private String name;
	private String type;
	private String assignment;

	public ASVar(String name, String type) {
		this.name = name;
		this.type = type;
	}

	public String getName() {
		return name;
	}

	public String getType() {
		return type;
	}
	
	public ASVar assign(String expression)
	{
		assignment = expression;
		return this;
	}
	
	public String toString()
	{
		StringBuilder sb = new StringBuilder();
		sb.append(name).append(":").append(type);
		
		if(assignment != null)
		{
			sb.append(" = ").append(assignment);
		}
		
		return sb.toString();
	}
}