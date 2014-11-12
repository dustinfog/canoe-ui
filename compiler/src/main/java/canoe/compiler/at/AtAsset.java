package canoe.compiler.at;

import canoe.as.ASClass;
import canoe.compiler.Util;
import canoe.compiler.CXMLClass;
import canoe.utils.StringUtils;

public class AtAsset implements AtProcessor {

	@Override
	public void call(String varName, String attrName, String[] arguments,
			String state, CXMLClass cclazz, StringBuilder creationBuilder) {
		ASClass clazz = cclazz.getBaseClass();
		String uri = arguments[0];
		String expr = Util.parseExpression(uri, clazz);
		String binding = null;
		String assetURI = null;
		if (expr != null) {
			binding = Util.createAssetBuilding(varName, attrName, expr, clazz);
		} else {
			clazz.depends("canoe.asset.AssetURI");
			assetURI = "canoe.asset.AssetURI.parse("
					+ StringUtils.toAsLiteral(uri) + ")";
		}

		if (state == null) {
			if (binding == null) {
				clazz.depends("flash.display.BitmapData");
				clazz.depends("canoe.managers.AssetManager");
				creationBuilder
						.append("canoe.managers.AssetManager.bind(")
						.append(assetURI)
						.append(", ")
						.append("function( bitmapData : flash.display.BitmapData ) : void{\n\t")
						.append(varName).append(".").append(attrName)
						.append(" = bitmapData;\n});\n");
			} else {
				creationBuilder.append(Util.registerBinding(binding));
			}
		} else {
			if (binding == null) {
				creationBuilder
						.append(Util.pushOverride(state, Util
								.createAssetOverride(varName, varName,
										assetURI, clazz)));
			} else {
				creationBuilder.append(Util.pushOverride(state,
						Util.createBindingOverride(binding, clazz)));
			}
		}
	}

}
