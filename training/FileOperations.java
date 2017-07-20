import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;
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

	public void findDoneFile(String fileName, String fileExt, String folderName) throws Exception {

		String fileDone = fileName.concat(".done");
		File name = new File(folderName);
		File[] list = name.listFiles();
		for (File fileN : list) {

			if (fileN.isFile()) {
				if (fileName.matches("^.*." + fileExt + "$")) {
					System.out.println(fileDone);
					int count = 0;
					String path = folderName.concat("\\");
					String pathFile = path.concat(fileName);
					Scanner sc = new Scanner(new FileReader(pathFile));
					while (sc.hasNext()) {
						sc.next();
						count++;
					}
					System.out.println("Total word count is : " + count);
					Scanner fileRead = new Scanner(new FileReader(pathFile));
					String[] str = new String[count];
					int i = 0;
					while (fileRead.hasNext()) {
						str[i] = fileRead.next();
						String ed = str[i];
						if (ed.matches("^.*ed$")) {
							System.out.println(ed);
						}
						i++;
					}
					StringBuilder strBuilder = new StringBuilder();
					for (i = 0; i < str.length; i++) {
						strBuilder.append(str[i]);
						strBuilder.append(" ");
					}
					String newString = strBuilder.toString();
					System.out.println(newString);
					wordOccurence(newString);
					break;
				}
			}

			else {
				System.out.println("Not found");
			}
		}
	}

	void wordOccurence(String strContent) throws Exception {

		Map<String, Integer> repeatedWord = new HashMap<String, Integer>();
		String[] words = strContent.split(" ");
		for (String word : words) {
			String temp = word.toLowerCase();
			if (repeatedWord.containsKey(temp)) {
				repeatedWord.put(temp, repeatedWord.get(temp) + 1);
			} else {
				repeatedWord.put(temp, 1);
			}
		}

		for (Map.Entry<String, Integer> entry : repeatedWord.entrySet()) {
			System.out.println(entry.getKey() + "\t\t" + entry.getValue());
		}

		System.out.println("Unique Words Count : ");
		int count = 0;
		for (Map.Entry<String, Integer> entry : repeatedWord.entrySet()) {
			if (entry.getValue() == 1) {
				count++;
			}
		}

		System.out.print(count);

	}

}
