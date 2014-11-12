package canoe.utils;

import java.util.TreeMap;

public class Utils {

	public static TreeMap<Integer, String> splitToMap(String string)
	{
		TreeMap<Integer, String> map = new TreeMap<Integer, String>();
		if(string != null) {
			String[] subStrings = string.split(",");
			for(int i = 0; i < subStrings.length; i ++)
			{
				map.put(i, subStrings[i]);
			}
		}
		
		return map;
	}
	
	public static String joinMap(TreeMap<Integer, String> map, String seperator)
	{
		int max = map.lastKey();
		
		StringBuilder sb = new StringBuilder();
		
		for(int i = 0; i <= max; i ++)
		{
			String value = map.get(i);
			
			if(value != null)
			{
				sb.append(value);
			}
			
			if(i != max)
			{
				sb.append(seperator);
			}
		}
		
		return sb.toString();
	}
}
