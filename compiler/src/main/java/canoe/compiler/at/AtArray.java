package canoe.compiler.at;

import canoe.as.ASClass;
import canoe.compiler.CXMLClass;
import canoe.compiler.Util;
import canoe.utils.StringUtils;

public class AtArray implements AtProcessor {

	@Override
	public void call(String varName, String attrName, String[] arguments,
			String state, CXMLClass cclazz, StringBuilder creationBuilder) {
		ASClass clazz = cclazz.getBaseClass();

		StringBuilder elementsBuilder = new StringBuilder("[");
		for (String arg : arguments) {
			arg = arg.trim();
			if(arg.length() == 0)
				continue;

			String asArg = StringUtils.toAsLiteral(arg.trim());
			if (asArg.charAt(0) == '"') {
				elementsBuilder.append("_(");
			}

			elementsBuilder.append(asArg);

			if (asArg.charAt(0) == '"') {
				elementsBuilder.append(")");
			}
			elementsBuilder.append(",");
		}
		StringUtils.removeLastComma(elementsBuilder).append("]");

		if (state == null) {
			creationBuilder.append(varName).append(".").append(attrName)
					.append(" = ").append(elementsBuilder.toString())
					.append(";\n");
		} else {
			creationBuilder.append(Util.pushOverride(state, Util
					.createSimpleOverride(varName, attrName,
							elementsBuilder.toString(), clazz)));
		}
	}
}
