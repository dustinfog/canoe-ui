package canoe.utils;

import java.security.MessageDigest;

public class StringUtils {
	public static boolean matchInt(String str)
	{
		return str == null ? false : str.matches("^[0-9]+$");
	}
	
	public static boolean matchBoolean(String str)
	{
		return "true".equals(str) || "false".equals(str);
	}
	

	public static boolean isEmpty(String str) {
		return str == null || str.length() == 0 || str.matches("^\\s+$");
	}

	
	public static String md5(String s) {
		char hexDigits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
				'a', 'b', 'c', 'd', 'e', 'f' };
		try {
			byte[] strTemp = s.getBytes();
			MessageDigest mdTemp = MessageDigest.getInstance("MD5");
			mdTemp.update(strTemp);
			byte[] md = mdTemp.digest();
			int j = md.length;
			char str[] = new char[j * 2];
			int k = 0;
			for (int i = 0; i < j; i++) {
				byte byte0 = md[i];
				str[k++] = hexDigits[byte0 >>> 4 & 0xf];
				str[k++] = hexDigits[byte0 & 0xf];
			}
			return new String(str);
		} catch (Exception e) {
			return null;
		}
	}

	public static StringBuilder removeLastComma(StringBuilder sb) {
		int length = sb.length();
		char lastChar = sb.charAt(length - 1);

		if (lastChar == ',') {
			sb.deleteCharAt(length - 1);
		} else if (lastChar == '\n' && sb.charAt(length - 2) == ',') {
			sb.deleteCharAt(length - 2);
		}

		return sb;
	}
	
	public static String[] trimAll(String[] arr)
	{
		for(int i = 0; i < arr.length; i ++)
		{
			arr[i] = arr[i].trim();
		}
		
		return arr;
	}
	
	public static String toAsLiteral(String str)
	{
		if(str.matches("^[+-]?0[0-7]*$") || str.matches("^[+-]?[1-9][0-9]*$") || str.matches("^[+-]?[0-9]*\\.[0-9]*$") || str.matches("^[+-]?0x[0-9a-fA-F]+$") || str.equals("true") || str.equals("NaN") || str.equals("undefined") || str.equals("null") || str.equals("false"))
		{
			return str;
		}
		
		return "\"" + str.replace("\\", "\\\\").replace("\"", "\\\"") + "\"";
	}

	public static void main(String[] args) {
		System.out.println("7 月 4日".matches("^[0-9]+$"));
	}
}
