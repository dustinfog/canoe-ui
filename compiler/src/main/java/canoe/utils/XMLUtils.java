package canoe.utils;

import java.io.File;
import java.io.FileInputStream;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;

public class XMLUtils {
	public static Document load(File file) {
		Document doc;
		FileInputStream input = null;
		try {
			DocumentBuilderFactory factory = DocumentBuilderFactory
					.newInstance();
			factory.setNamespaceAware(true);
			factory.setIgnoringElementContentWhitespace(true);
			factory.setIgnoringComments(true);
			DocumentBuilder db = factory.newDocumentBuilder();
			input = new FileInputStream(file);
			doc = db.parse(input);
		} catch (Exception e) {
			e.printStackTrace(System.err);
			return null;
		} finally {
			if (input != null) {
				try {

					input.close();
				} catch (Exception e) {
					e.printStackTrace(System.err);
					return null;
				}
			}
		}

		return doc;
	}
}
