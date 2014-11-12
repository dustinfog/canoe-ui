package canoe.compiler.at;

import canoe.as.ASClass;
import canoe.compiler.Util;
import canoe.compiler.CXMLClass;
import canoe.utils.StringUtils;

public class At implements AtProcessor {

	@Override
	public void call(String varName, String attrName, String[] arguments,
			String state, CXMLClass cclazz, StringBuilder creationBuilder) {
		ASClass clazz = cclazz.getBaseClass();

		String value = arguments[0];
		String expr = Util.parseExpression(value, clazz, true);
		String binding = null;
		if (expr != null) {
			binding = Util.createHandlerBinding(varName, attrName, expr, clazz);
		}

		if (state == null) {
			if (binding == null) {
				creationBuilder.append(varName).append(".").append(attrName)
						.append(" = ").append("_(")
						.append(StringUtils.toAsLiteral(value)).append(");\n");
			} else {
				creationBuilder.append(Util.registerBinding(binding));
			}
		} else {
			if (binding == null) {
				creationBuilder
						.append(Util.pushOverride(state, Util
								.createSimpleOverride(varName, attrName, "_("
										+ StringUtils.toAsLiteral(value) + ")",
										clazz)));
			} else {
				creationBuilder.append(Util.pushOverride(state,
						Util.createBindingOverride(binding, clazz)));
			}
		}
	}
}
