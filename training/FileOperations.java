import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.regex.Pattern;

public class FileOperations {

	public static void main(String[] args) throws Exception {

		try {
			System.out.println("Please Enter the folder path");
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			String strFolderName = br.readLine();
			System.out.println("Please Enter the file extension to be found");
			String strFileExt = br.readLine();
			FindFile ff = new FindFile();
			ff.findFile(strFolderName, strFileExt);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}

class FindFile {

	public void findFile(String folderName, String fileExt) throws Exception {
		try {
			Pattern pattern;
			File name = new File(folderName);
			File[] list = name.listFiles();
			for (File fileName : list) {

				if (fileName.isFile()) {
					String fName = fileName.getName();
					if (fName.matches("^.*." + fileExt + "$")) {
						System.out.println(fName);
						findDoneFile(fName, fileExt, folderName);

					}
				}
			}
		}

		catch (Exception e) {
			e.printStackTrace();
		}

	}

	public void findDoneFile(String fileName, String fileExt, String folderName) {

		String fileDone = fileName.concat(".done");
		File name = new File(folderName);
		File[] list = name.listFiles();
		for (File fileN : list) {

			if (fileN.isFile()) {
				if (fileName.matches("^.*." + fileExt + "$")) {
					System.out.println(fileDone);
					break;
				}
			}

			else {
				System.out.println("Not found");
			}
		}
	}

}
