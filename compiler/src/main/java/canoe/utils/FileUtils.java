package canoe.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.math.BigInteger;
import java.security.MessageDigest;

public class FileUtils {
	public static String getFileContent(File file, String charset) {
		byte[] bytes = getFileBytes(file);

		if (bytes == null)
			return null;

		if (bytes.length >= 3) {
			if (bytes[0] == (byte) 0xEF && bytes[1] == (byte) 0xBB
					&& bytes[2] == (byte) 0xBF) {
				byte[] newBytes = new byte[bytes.length - 3];
				System.arraycopy(bytes, 3, newBytes, 0, newBytes.length);
				bytes = newBytes;
			}
		}

		if (bytes.length == 0) {
			return "";
		}

		try {
			return new String(bytes, charset);
		} catch (IOException e) {
			return null;
		}
	}

	public static String getFileContent(File file) {
		return getFileContent(file, "utf-8");
	}

	public static byte[] getFileBytes(File file) {
		FileInputStream input = null;
		try {
			input = new FileInputStream(file);
			byte[] bytes = new byte[input.available()];
			input.read(bytes);
			return bytes;
		} catch (IOException e) {
			e.printStackTrace(System.err);
		} finally {
			if (input != null) {
				try {
					input.close();
				} catch (IOException e) {
					e.printStackTrace(System.err);
				}
			}
		}

		return null;
	}

	public static void writeFileBytes(File file, byte[] bytes) {
		FileOutputStream output = null;
		try {
			output = new FileOutputStream(file);
			output.write(bytes);
		} catch (IOException e) {
			e.printStackTrace(System.err);
		} finally {
			if (output != null) {
				try {
					output.close();
				} catch (IOException e) {
					e.printStackTrace(System.err);
				}
			}
		}
	}

	public static void copy(File src, File dist) {
		if (src.isDirectory()) {
			if (!dist.exists()) {
				dist.mkdirs();
			}

			File[] subFiles = src.listFiles();
			for (File subFile : subFiles) {
				copy(subFile, new File(dist.getAbsolutePath() + File.separator
						+ subFile.getName()));
			}
		} else {
			writeFileBytes(dist, getFileBytes(src));
		}
	}
	
	public static void remove(File file) {
		if(file.isDirectory())
		{
			File[] subFiles = file.listFiles();
			for(File subFile : subFiles)
			{
				remove(subFile);
			}

			file.delete();
		}
		else
		{
			file.delete();
		}
	}

	public static void writeFileContent(File file, String content) {
		OutputStreamWriter writer = null;
		try {
			File parent = file.getParentFile();
			if (!parent.exists()) {
				parent.mkdirs();
			}

			writer = new OutputStreamWriter(
					new FileOutputStream(file), "utf-8");
			writer.write(content);
		} catch (IOException e) {
			e.printStackTrace(System.err);
		}
		finally {
			if (writer != null) {
				try {
					writer.close();
				} catch (IOException e) {
					e.printStackTrace(System.err);
				}
			}
		}
	}

	public static String getBaseName(File file) {
		String filename = file.getName();
		int p = filename.indexOf('.');
		if (p == -1) {
			return filename;
		}

		return filename.substring(0, p);
	}

	public static String getExtensionName(File file) {
		String filename = file.getName();
		int p = filename.indexOf('.');
		if (p == -1) {
			return "";
		}

		return filename.substring(p + 1);
	}

	public static String getFileMD5(File file) {
		if (!file.isFile()) {
			return null;
		}
		MessageDigest digest = null;
		FileInputStream in = null;
		byte buffer[] = new byte[1024];
		int len;
		try {
			digest = MessageDigest.getInstance("MD5");
			in = new FileInputStream(file);
			while ((len = in.read(buffer, 0, 1024)) != -1) {
				digest.update(buffer, 0, len);
			}
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
		finally{
			if (in != null) {
				try {
					in.close();
				} catch (IOException e) {
					e.printStackTrace(System.err);
				}
			}
		}
		BigInteger bigInt = new BigInteger(1, digest.digest());
		return bigInt.toString(16);
	}
}
