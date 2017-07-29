import java.io.File;

public class FileTree {

	static void fileDisplay(String path) {
		File name = new File(path);
		File[] list = name.listFiles();
		for (File fileName : list) {
			if (fileName.isFile()) {
				System.out.println(fileName.getName());

			} else {
				String dirName = name.getName();
				fileDisplay(path + "\\" + dirName);
			}
		}
	}

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		String str = "\\C:\\Users\\shinoys\\Documents\\shinoys_java";
		fileDisplay(str);
	}

}
	