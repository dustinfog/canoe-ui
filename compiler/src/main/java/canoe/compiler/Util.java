package canoe.compiler;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import canoe.as.ASClass;
import canoe.utils.StringUtils;

public class Util {
	public static String createSimpleOverride(String varName, String prop,
			String value, ASClass clazz) {
		clazz.depends("canoe.state.SimpleOverride");
		StringBuilder sb = new StringBuilder(
				"new canoe.state.SimpleOverride(function(value : *) : void{")
				.append(varName).append(".").append(prop)
				.append(" = value;}, function() : *{return ").append(varName)
				.append(".").append(prop).append(";}, ").append(value)
				.append(")");
		return sb.toString();
	}

	public static String createBindingOverride(String binding, ASClass clazz) {
		clazz.depends("canoe.state.BindingOverride");
		StringBuilder sb = new StringBuilder("new canoe.state.BindingOverride(")
				.append(binding).append(", this)");
		return sb.toString();
	}

	public static String createAssetOverride(String varName, String prop,
			String assetURI, ASClass clazz) {
		clazz.depends("canoe.state.AssetOverride");
		clazz.depends("flash.display.BitmapData");
		StringBuilder sb = new StringBuilder(
				"new canoe.state.AssetOverride(function(value : flash.display.BitmapData) : void{")
				.append(varName).append(".").append(prop)
				.append(" = value;}, ").append(assetURI).append(")");
		return sb.toString();
	}

	public static String pushOverride(String state, String override) {
		return state + ".overrides.push(" + override + ");\n";
	}

	public static String assign(String varName, String prop, String value) {
		StringBuilder sb = new StringBuilder();
		value = StringUtils.toAsLiteral(value);
		sb.append(varName).append(".").append(prop).append(" = ");
		boolean isString = (value.charAt(0) == '"');
		if (!isString) {
			sb.append("$(");
		}
		sb.append(value);
		if (!isString) {
			sb.append(")");
		}
		sb.append(";\n");

		return sb.toString();
	}

	public static String registerBinding(String binding) {
		return new StringBuilder("registerBinding(").append(binding)
				.append(");\n").toString();
	}

	public static String createAssetBuilding(String varName, String prop,
			String expression, ASClass clazz) {
		clazz.depends("canoe.binding.AssetBinding");
		clazz.depends("flash.display.BitmapData");
		StringBuilder sb = new StringBuilder(
				"new canoe.binding.AssetBinding(function(value : flash.display.BitmapData) : void{\n\t")
				.append(varName)
				.append(".")
				.append(prop)
				.append(" = value;\n}, \nfunction() : String {\n\ttry{\nreturn ")
				.append(expression)
				.append(";}\ncatch(e : Error){\nreturn null;\n}\n})");
		return sb.toString();
	}

	public static String createHandlerBinding(String varName, String prop,
			String expression, ASClass clazz) {
		clazz.depends("canoe.binding.HandlerBinding");
		StringBuilder sb = new StringBuilder(
				"new canoe.binding.HandlerBinding(function() : void{\n\ttry{")
				.append(varName).append(".").append(prop).append(" = ")
				.append(expression).append(";\n}catch(e : Error){\n")
				.append(varName).append(".").append(prop)
				.append(" = null;\n}\n})");

		return sb.toString();
	}

	public static String parseExpression(String str, ASClass clazz) {
		return parseExpression(str, clazz, false);
	}

	public static String parseExpression(String str, ASClass clazz, boolean i18n) {
		String expression = parseSimpleExpression(str);
		if (expression == null) {
			expression = parseTextTemplate(str, clazz, i18n);
		} else {
			expression = "$(" + expression + ")";
		}
		return expression;
	}

	private static String parseSimpleExpression(String str) {
		str = str.trim();
		if (!str.matches("^\\{[^\\}]+\\}$"))
			return null;

		return str.substring(1, str.length() - 1);
	}

	private static String parseTextTemplate(String str, ASClass clazz,
			boolean i18n) {
		final Pattern pattern = Pattern.compile("\\{[^\\}]+\\}");
		Matcher matcher = pattern.matcher(str);

		Map<String, Pair> expresIndexes = null;
		while (matcher.find()) {
			if (expresIndexes == null) {
				expresIndexes = new HashMap<String, Pair>();
			}

			String match = matcher.group();
			String expression = parseSimpleExpression(match);
			String compress = expression.replaceAll("[\\s]+", "");
			Pair pair = expresIndexes.get(compress);
			if (pair == null) {
				pair = new Pair(expression, expresIndexes.size());
				expresIndexes.put(compress, pair);
			}

			str = str.replace(match, "{" + pair.index + "}");
		}

		if (expresIndexes != null) {
			String[] exprs = new String[expresIndexes.size()];
			for (Pair pair : expresIndexes.values()) {
				exprs[pair.index] = pair.expression;
			}

			String literal = StringUtils.toAsLiteral(str);
			if (i18n) {
				literal = "_(" + literal + ")";
			}

			clazz.depends("canoe.util.StringUtil");
			StringBuilder sb = new StringBuilder(
					"canoe.util.StringUtil.substitute(").append(literal)
					.append(", [\n");

			for (String expression : exprs) {
				sb.append("(").append(expression).append("),\n");
			}

			StringUtils.removeLastComma(sb).append("])");

			return sb.toString();
		}

		return null;
	}

	private static class Pair {
		public Pair(String expression, int index) {
			this.expression = expression;
			this.index = index;
		}

		public String expression;
		public int index;
	}

	public static void main(String[] args) {
		System.out.println(parseTextTemplate(
				"{a.b.c} is good, {d.e} is bad, but {a .b.c} must be quick",
				new ASClass("haha", "hehe"), false));
	}
}
