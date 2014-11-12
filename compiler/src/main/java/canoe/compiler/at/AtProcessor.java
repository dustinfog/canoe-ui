package canoe.compiler.at;

import canoe.compiler.CXMLClass;

public interface AtProcessor{
	void call(String varName, String attrName, String[] arguments,
			String state, CXMLClass cclazz, StringBuilder creationBuilder);
}
