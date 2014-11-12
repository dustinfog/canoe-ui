package canoe.compiler.at;

import canoe.as.ASClass;
import canoe.compiler.CXMLClass;
import canoe.compiler.Util;

public class AtFalse implements AtProcessor {

	@Override
	public void call(String varName, String attrName, String[] arguments,
			String state, CXMLClass cclazz, StringBuilder creationBuilder) {
		ASClass clazz = cclazz.getBaseClass();
		if (state == null) {
			creationBuilder.append(varName).append(".").append(attrName)
					.append(" = ").append("false").append(";\n");
		} else {
			creationBuilder.append(Util.pushOverride(state, Util
					.createSimpleOverride(varName, attrName, "false", clazz)));
		}
	}
}
