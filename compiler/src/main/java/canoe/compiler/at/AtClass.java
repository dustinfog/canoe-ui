package canoe.compiler.at;

import canoe.as.ASClass;
import canoe.compiler.CXMLClass;
import canoe.compiler.Util;

public class AtClass implements AtProcessor {

	@Override
	public void call(String varName, String attrName, String[] arguments,
			String state, CXMLClass cclazz, StringBuilder creationBuilder) {
		ASClass clazz = cclazz.getBaseClass();

		String className = arguments[0];
		clazz.depends(className);

		if (state == null) {
			creationBuilder.append(varName).append(".").append(attrName)
					.append(" = ").append(className).append(";\n");
		} else {
			creationBuilder
					.append(Util.pushOverride(state, Util.createSimpleOverride(
							varName, attrName, className, clazz)));
		}
	}
}
