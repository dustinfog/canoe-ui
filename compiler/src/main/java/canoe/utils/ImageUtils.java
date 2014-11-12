package canoe.utils;

import java.awt.Image;
import java.awt.Rectangle;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

import javax.imageio.ImageIO;

public class ImageUtils {
	public static byte[] imageToBytes(BufferedImage image, String type)
	{
		ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
		
		try
		{
			ImageIO.write(image, "png", outputStream);
			return outputStream.toByteArray();
		}
		catch (IOException e) {
			e.printStackTrace();
			return null;
		}
		finally
		{
			try
			{
				outputStream.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	

	/**
	 * 图像缩放 - 参数指定目标图缩放比例。
	 * 
	 * @param srcImage
	 *            源图像对象。
	 * @param xscale
	 *            图像 x 轴（宽度）上的的缩放比例。
	 * @param yscale
	 *            图像 y 轴（高度）上的的缩放比例。
	 * @param hints
	 *            重新绘图使用的 RenderingHints 对象。
	 * @return 缩放后的图像对象。
	 */
	public static BufferedImage scaleJ2D(BufferedImage srcImage, double xscale,
			double yscale) {
		int ww = (int) (srcImage.getWidth() * xscale), hh = (int) (srcImage
				.getHeight() * yscale);
		Image tempimg = srcImage.getScaledInstance(ww, hh, Image.SCALE_SMOOTH);
		BufferedImage tag = new BufferedImage(ww, hh,
				BufferedImage.TYPE_INT_ARGB);
		tag.getGraphics().drawImage(tempimg, 0, 0, ww, hh, null);
		return tag;
	}
	
	public static Rectangle getColorBounds(BufferedImage image)
	{
		int width = image.getWidth();
		int height = image.getHeight();
		
		int[] rgbArray = new int[width * height];
		
		image.getRGB(0, 0, width, height, rgbArray, 0, width);
		
		int minX = width - 1, minY = height - 1, maxX = 0, maxY = 0;
		
		boolean found = false;
		for(int x = 0; x < image.getWidth(); x ++)
		{
			for(int y = 0; y < image.getHeight(); y ++)
			{
				int color = rgbArray[width * y + x];
				int alpha = color >> 24;
				int rgb = color & 0x00ffffff;
			
				if(alpha != 0 && rgb != 0)
				{
					minX = Math.min(minX, x);
					maxX = Math.max(maxX, x);
					minY = Math.min(minY, y);
					maxY = Math.max(maxY, y);
					
					found = true;
				}
			}
		}
		
		if(found)
		{
			return new Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1);
		}
		else
		{
			return new Rectangle(0, 0, 1, 1);
		}
	}
}
