package canoe.as;

public class ASComment {
	private String message;

	public void setMessage(String comment) {
		this.message = comment;
	}

	public String getMessage() {
		return message;
	}

	public ASComment(String comment) {
		setMessage(comment);
	}

	public String toString() {
		StringBuilder sb = new StringBuilder();
		sb.append("/**\n").append(" * ")
				.append(message.replaceAll("\n", "\n * ")).append("\n")
				.append(" */");

		return sb.toString();
	}

	public static void main(String[] args) {
		ASComment comment = new ASComment("hahahah\n你说对了");
		System.out.println(comment);
	}
}
