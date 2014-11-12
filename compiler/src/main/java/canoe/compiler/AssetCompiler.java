package canoe.compiler;

import java.awt.Rectangle;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.imageio.ImageIO;

import canoe.utils.CompressUtils;
import canoe.utils.FileUtils;
import canoe.utils.ImageUtils;
import canoe.utils.StringUtils;

import com.exadel.flamingo.flex.messaging.amf.io.AMF3Serializer;

import flaze.item.AssetItem;
import flaze.main.AssetMaker;

public class AssetCompiler {
	public static boolean compile()
	{
		File assetsDir = new File(Project.instance.getAssetPath());
		return treeCompile(assetsDir, "");
	}
	
	private static boolean treeCompile(File assetsDir, String relativePath)
	{
		File[] subFiles = assetsDir.listFiles(new FilenameFilter() {
			
			@Override
			public boolean accept(File arg0, String arg1) {
				return !arg1.startsWith(".");
			}
		});

		String distPath = Project.instance.getBinaryPath() + File.separator + relativePath;
		boolean ret = false;
		for(File subFile : subFiles)
		{
			String subFileName = subFile.getName();
			if(!subFile.isDirectory())
			{
				FileUtils.copy(subFile, new File(distPath + subFileName));
			}
			else if(subFileName.endsWith(".swf"))
			{
				ret = compilePackDir(subFile.getAbsolutePath(), distPath) || ret;
			}
			else
			{
				ret = treeCompile(subFile, relativePath + subFileName + File.separator) || ret;
			}
		}
		
		return ret;
	}
	
	public static boolean compilePackDir(String packDir, String distDir)
	{
		File packFile = new File(packDir);
		File distFile = new File(distDir + File.separator + packFile.getName());

		SymbolMetaManager manager = new SymbolMetaManager();
		manager.parse(new File(packDir + File.separator + "metadata.xml"));
		
		List<AssetItem> assetList = new ArrayList<AssetItem>();
		long lastModified = readyAssetFiles(packFile, null, manager, assetList, 0);
		if(lastModified < distFile.lastModified()) return false;
		
		System.out.println("编译 " + packFile.getName());
		
		for(AssetItem item : assetList)
		{
			String extName = FileUtils.getExtensionName(item.file);
			if(extName.equals("png") || extName.equals("gif") || extName.equals("jpg"))
			{
				compileImage(item, manager);
			}
		}
		
		AssetItem metaItem = compileMetadata(manager);
		if(metaItem != null)
		{
			assetList.add(metaItem);
		}

		AssetItem[] items = new AssetItem[assetList.size()];
		assetList.toArray(items);

		distFile.getParentFile().mkdirs();
		
		AssetMaker assetMaker = new AssetMaker();
		assetMaker.assets = items;
		assetMaker.output = distFile;
		assetMaker.compile();
		
		return true;
	}

	private static long readyAssetFiles(File file, String prefix, SymbolMetaManager manager, List<AssetItem> list, long lastModified)
	{
		if(file.isDirectory())
		{
			File[] files = file.listFiles();
			for(File subFile : files)
			{
				String subPrefix = null;
				if(prefix == null)
				{
					subPrefix = "";
				}
				else if(prefix.equals(""))
				{
					subPrefix = file.getName();
				}
				else
				{
					subPrefix = prefix + "." + file.getName();
				}

				lastModified = readyAssetFiles(subFile, subPrefix, manager, list, lastModified);
			}
			
			return lastModified;
		}
		else
		{
			String fileName = FileUtils.getBaseName(file);

			if(!fileName.equals("metadata"))
			{
				AssetItem item = new AssetItem();
				item.file = file;
				item.className = StringUtils.isEmpty(prefix) ? fileName : (prefix + "." + fileName);
				list.add(item);
			}

			return Math.max(lastModified, file.lastModified());
		}
	}
	
	private static void compileImage(AssetItem item, SymbolMetaManager manager)
	{
		BufferedImage image;
		
		try {
			image = ImageIO.read(item.file);
		} catch (IOException e) {
			e.printStackTrace();
			return;
		}

		SymbolMeta symbolMeta = manager.getSymbolMeta(item.className);
		float scale = symbolMeta.scale;
		if(scale != 1)
		{
			image = ImageUtils.scaleJ2D(image, symbolMeta.scale, symbolMeta.scale);
		}

		int[] corePint = symbolMeta.getCorePoint();
		if(corePint != null)
		{
			Rectangle rect = ImageUtils.getColorBounds(image);
			image = image.getSubimage(rect.x, rect.y, rect.width, rect.height);

			int newCoreX = (int) (corePint[0] * scale) - rect.x;
			int newCoreY = (int) (corePint[1] * scale) - rect.y;
			
			if(manager.isGlobal(symbolMeta))
			{
				SymbolMeta newMeta = new SymbolMeta();
				newMeta.setName(item.className);
				newMeta.setCorePoint(new int[]{newCoreX, newCoreY});
				manager.setSymbolMeta(item.className, newMeta);
			}
			else
			{
				corePint[0] = newCoreX;
				corePint[1] = newCoreY;
			}
		}
		
		int quality = manager.getSymbolMeta(item.className).quality;
		if(quality <= 0 || quality > 100)
			quality = 80;
		
		item.quality = quality;
		item.data = ImageUtils.imageToBytes(image, "png");
	}
	
	private static AssetItem compileMetadata(SymbolMetaManager manager) 
	{
		Collection<SymbolMeta> symbolMetas = manager.getSymbolMetas();

		if(symbolMetas == null) return null;

		int size = symbolMetas.size() + 1;
		@SuppressWarnings("unchecked")
		Map<String, Object>[] propertiesArray = new Map[size];
		propertiesArray[0] = manager.getGlobalSymbolMeta().getProperties();
		
		int i = 1;
		for(Iterator<SymbolMeta> itr = symbolMetas.iterator(); itr.hasNext();)
		{
			propertiesArray[i ++] = itr.next().getProperties();
		}
		
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		AMF3Serializer serializer = new AMF3Serializer(out);
		try
		{
			serializer.writeObject(propertiesArray);
		} catch (IOException e) {
			e.printStackTrace(System.err);
		}
		byte[] data = CompressUtils.compressBytes(out.toByteArray());
		try {
			out.close();
		} catch (IOException e) {
			e.printStackTrace(System.err);
		}
		AssetItem item = new AssetItem();
		item.data = data;
		item.className = "metadata";
		return item;
	}
}
