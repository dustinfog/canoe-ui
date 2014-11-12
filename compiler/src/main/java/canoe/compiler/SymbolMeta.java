package canoe.compiler;

import java.util.HashMap;
import java.util.Map;

public class SymbolMeta {
	public int quality = 80;
	public float scale = 1;

	private int[] corePoint;
	private String name;
	private Map<String, Object> properties;

	public SymbolMeta() {
		properties = new HashMap<String, Object>();
	}

	public Map<String, Object> getProperties() {
		return properties;
	}

	public int[] getCorePoint() {
		return corePoint;
	}

	public void setCorePoint(int[] corePoint) {
		this.corePoint = corePoint;
		properties.put("corePoint", corePoint);
	}
	
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
		properties.put("name", name);
	}
}