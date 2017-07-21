package training;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;
import java.util.regex.Pattern;


class NoContentFileException extends Exception{
	NoContentFileException(String s){
		System.out.println(s);
	}
}

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

	public void findFile(String path, String ext) throws Exception {
		try{
			File folder = new File(path);
			File[] list = folder.listFiles();
			String name;
			for(File file : list)
			{
				if(file.isFile())
					{
						name = file.getName();
						if(name.matches("shutdown.txt"))
						{
							System.exit(0);
							break;
						}
						else if(name.matches("^.*."+ext+"$"))
						{
							findDoneFile(name,path,ext);
						}
						
						
					}	
			}
			}
			catch(Exception e)
			{
				System.out.println(e);
			}
	}

	public void findDoneFile(String fileName, String path, String ext) throws Exception {
		
		File folder = new File(path);
		File[] list = folder.listFiles();
		String extDone = ext+".done";
		String doneName;
		//PrintStream logStream = new PrintStream(new FileOutputStream("C:\\Users\\Abraham\\Desktop\\SunTec\\Training\\outputlog.txt"));
		String finalName[] = new String[1];
		for(File file : list)


			if(file.isFile())
			{
				doneName = file.getName();
				//System.out.println(Name);
				if (doneName.matches("^.*."+extDone+"$"))
				{		
					 finalName[0] = doneName.split(".done")[0];
					 if(finalName[0].equals(fileName))
					 {
						 
							System.out.println(fileName);
							int count = 0;
							String filePath = path.concat("\\");
							String pathFile = filePath.concat(fileName);
							Scanner sc = new Scanner(new FileReader(pathFile));
							PrintStream backupStream = new PrintStream(new FileOutputStream(pathFile+"_backup.txt"));
							while (sc.hasNext()) {
								backupStream.append(sc.next()).append(" ");
								count++;
							}
							if(count == 0){
								System.out.println("Total word count is : " + count);
								//logStream.append(String.valueOf(count)).append("\n");
								throw new NoContentFileException("The File Has No Content");
							}
							else{
							System.out.println("Total word count is : " + count);
							//logStream.append(String.valueOf(count)).append("\n");
							}
							Scanner fileRead = new Scanner(new FileReader(pathFile));
							String[] str = new String[count];
							int i = 0;
							while (fileRead.hasNext()) {
								str[i] = fileRead.next();
								String ed = str[i];
								if (ed.matches("^.*ed$")) {
									System.out.println(ed);
//									logStream.append(ed).append("\n");
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
							wordOccurence(newString, fileName);
						}
					}

					/*else {
						System.out.println("Not found");
					}*/
				}
		
		
	}

	

	void wordOccurence(String strContent, String fileName) throws Exception {

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
		PrintStream printStream = new PrintStream(new FileOutputStream("unique_" + fileName));
		for (Map.Entry<String, Integer> entry : repeatedWord.entrySet()) {
			System.out.println(entry.getKey() + "\t\t" + entry.getValue());
			printStream.append(entry.getKey().toString()).append(" ");
			

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
