package canoe.compiler;

import java.io.File;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.NodeList;

import canoe.utils.XMLUtils;

public class SymbolMetaManager {
	private SymbolMeta globalSymbolMeta = new SymbolMeta();
	private Map<String, SymbolMeta> symbolMetaMap; 
	
	public SymbolMeta getGlobalSymbolMeta()
	{
		return globalSymbolMeta;
	}
	
	public SymbolMeta getSymbolMeta(String symbolName)
	{
		if(symbolMetaMap == null)
			return globalSymbolMeta;
		
		SymbolMeta meta = symbolMetaMap.get(symbolName);
		if(meta == null)
		{
			return globalSymbolMeta;
		}
		
		return meta;
	}
	
	public void setSymbolMeta(String symbolName, SymbolMeta symbolMeta)
	{
		symbolMetaMap.put(symbolName, symbolMeta);
	}
	
	public boolean isGlobal(SymbolMeta symbolMeta)
	{
		return symbolMeta == globalSymbolMeta;
	}
	
	public Collection<SymbolMeta> getSymbolMetas()
	{
		return symbolMetaMap == null ? null : symbolMetaMap.values();
	}
	
	public void parse(File file) 
	{
		if(!file.exists()) return;
		Document doc = XMLUtils.load(file);
		if(doc == null) return;
        
		symbolMetaMap = new HashMap<String, SymbolMeta>();
        NodeList list = doc.getDocumentElement().getChildNodes();
        for(int i = 0, length = list.getLength(); i < length; i ++)
        {
        	Element element;
        	try
        	{
        		element = (Element)list.item(i);
        	}
        	catch (Exception e) {
				continue;
			}
        	
        	parseMeta(element);
        }
	}

	private void parseMeta(Element element)
	{
		SymbolMeta symbolMeta  = new SymbolMeta();
		Map<String, Object> properties = symbolMeta.getProperties();

		boolean isGlobal = element.getTagName().equals("global");
		String symbolName = null;
		
		NamedNodeMap nodeMap = element.getAttributes();
		for(int i = 0, length = nodeMap.getLength(); i < length; i ++)
		{
			Attr attr = (Attr)nodeMap.item(i);
			String attrName = attr.getName();
			String attrValue = attr.getValue();
			
			if(attrName.equals("name"))
			{
				symbolName = attrValue;
				symbolMeta.setName(attrValue);
			}
			else if(attrName.equals("quality"))
			{
				symbolMeta.quality = Integer.parseInt(attrValue);
			}
			else if(attrName.equals("scale"))
			{
				symbolMeta.scale = Float.parseFloat(attrValue);
			}
			else if(attrName.equals("scale9Grid"))
			{
				String[] splitted = attrValue.split(",");
				int[] rect = new int[4];
				for(int j = 0; j < 4; j ++)
				{
					rect[j] = Integer.parseInt(splitted[j].trim());
				}
				
				properties.put(attrName, rect);
			}
			else if(attrName.equals("corePoint"))
			{
				String[] splitted = attrValue.split(",");
				int[] point = new int[2];
				for(int j = 0; j < 2; j ++)
				{
					point[j] = Integer.parseInt(splitted[j].trim());
				}

				properties.put(attrName, point);
				symbolMeta.setCorePoint(point);
			}
			else
			{
				
				properties.put(attrName, attrValue);
			}

			if(isGlobal)
			{
				globalSymbolMeta = symbolMeta;
			}
			else
			{
				setSymbolMeta(symbolName, symbolMeta);
			}
		}
	}
	
	public boolean isEmpty(String str)
	{
		return str == null || str.length() == 0;
	}
}
