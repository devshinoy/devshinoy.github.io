import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

class NoContentFileException extends Exception {
	public NoContentFileException(String s) {
		System.out.println(s);
	}
}

class LogFile {

	PrintStream backupStream;

	LogFile() throws FileNotFoundException {
		backupStream = new PrintStream(new FileOutputStream("log", true));
	}

	void writeLog(String str) {
		backupStream.append(str).append("\r\n");
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
			LogFile log = new LogFile();
			log.writeLog("***************************log file***************************************");
			String timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss").format(Calendar.getInstance().getTime());
			log.writeLog(timeStamp + " : " + "Folder Name and Extension recieved");
			File folder = new File(strFolderName);
			File[] list = folder.listFiles();
			String name;
			for (File file : list) {
				if (file.isFile()) {
					name = file.getName();
					if (name.matches("shutdown.*")) {
						timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss")
								.format(Calendar.getInstance().getTime());
						log.writeLog(timeStamp + " : " + "shutdown.txt found");
						log.writeLog(timeStamp + " : " + "Process Terminated");
						System.out.println("Terminated");
						return;
					}
				}
			}
			FindFile ff = new FindFile();
			timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss").format(Calendar.getInstance().getTime());
			log.writeLog(timeStamp + " : " + "find the file method invoked");
			ff.findFile(strFolderName, strFileExt);

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}

class FindFile {

	public void findFile(String path, String ext) throws Exception {
		try {
			File folder = new File(path);
			File[] list = folder.listFiles();
			String name;
			LogFile log = new LogFile();
			String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(Calendar.getInstance().getTime());
			timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss").format(Calendar.getInstance().getTime());
			log.writeLog(timeStamp + " : " + "Reading Files");
			for (File file : list) {
				if (file.isFile()) {
					name = file.getName();
					timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss").format(Calendar.getInstance().getTime());
					log.writeLog(timeStamp + " :  Checking the file for extension" + name);
					if (name.matches("^.*." + ext + "$")) {
						timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss")
								.format(Calendar.getInstance().getTime());
						log.writeLog(timeStamp + " : Extension Matched for " + name);
						timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss")
								.format(Calendar.getInstance().getTime());
						log.writeLog(timeStamp + " :Invoking donefile method for the file " + name);
						findDoneFile(name, path, ext);
					}

				}
			}
		} catch (Exception e) {
			System.out.println(e);
		}
	}

	public void findDoneFile(String fileName, String path, String ext) throws Exception {

		File folder = new File(path);
		File[] list = folder.listFiles();
		String extDone = ext + ".done";
		String doneName;
		LogFile log = new LogFile();
		String timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss").format(Calendar.getInstance().getTime());
		String finalName[] = new String[1];
		for (File file : list) {
			if (file.isFile()) {
				doneName = file.getName();
				if (doneName.matches("^.*." + extDone + "$")) {
					finalName[0] = doneName.split(".done")[0];
					if (finalName[0].equals(fileName)) {
						timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss")
								.format(Calendar.getInstance().getTime());
						log.writeLog(timeStamp + " :Found the done file " + fileName);
						System.out.println(fileName);
						int count = 0;
						String filePath = path.concat("\\");
						String pathFile = filePath.concat(fileName);
						Scanner sc = new Scanner(new FileReader(pathFile));
						timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss")
								.format(Calendar.getInstance().getTime());
						log.writeLog(timeStamp + " Created the Backup file");
						PrintStream backupStream = new PrintStream(new FileOutputStream(pathFile + "_backup"));
						timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss")
								.format(Calendar.getInstance().getTime());
						log.writeLog(timeStamp + "Finding Total count ");
						while (sc.hasNext()) {

							backupStream.append(sc.next()).append(" ");
							count++;
						}
						timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss")
								.format(Calendar.getInstance().getTime());
						log.writeLog(timeStamp + "Total count " + count);
						try {
							if (count == 0) {
								System.out.println("Total word count is : " + count);

							} else {
								System.out.println("Total word count is : " + count);

							}
						} catch (Exception e) {
							System.out.println(e);
						}
						Scanner fileRead = new Scanner(new FileReader(pathFile));
						String[] str = new String[count];
						int i = 0, edCount = 0;
						timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss")
								.format(Calendar.getInstance().getTime());
						log.writeLog(timeStamp + " :Found the word with \"ed\" at the end " + fileName);
						while (fileRead.hasNext()) {
							str[i] = fileRead.next();
							String ed = str[i];
							if (ed.matches("^.*ed$")) {
								System.out.println(ed);
								edCount++;
							}
							i++;
						}
						timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss")
								.format(Calendar.getInstance().getTime());
						log.writeLog(timeStamp + "Total words ends with \"ed\"t " + edCount);
						System.out.println("Total words ends with \"ed\" " + edCount);
						StringBuilder strBuilder = new StringBuilder();
						for (i = 0; i < str.length; i++) {
							strBuilder.append(str[i]);
							strBuilder.append(" ");
						}
						String newString = strBuilder.toString();
						System.out.println(newString);
						timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss")
								.format(Calendar.getInstance().getTime());
						log.writeLog(timeStamp + " : Invoking the wordOccurence Function");
						wordOccurence(newString, fileName);
					}
				}

			}

		}
	}

	void wordOccurence(String strContent, String fileName) throws Exception {

		LogFile log = new LogFile();
		String timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss").format(Calendar.getInstance().getTime());

		Map<String, Integer> repeatedWord = new HashMap<String, Integer>();
		String[] words = strContent.split(" ");
		for (String word : words) {
			String temp = word.toLowerCase();
			timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss").format(Calendar.getInstance().getTime());
			log.writeLog(timeStamp + " : Finding the occurence of each word");
			if (repeatedWord.containsKey(temp)) {
				repeatedWord.put(temp, repeatedWord.get(temp) + 1);
				timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss").format(Calendar.getInstance().getTime());
				log.writeLog(timeStamp + " : Finding the occurence of each word with multiple Occurence");
			} else {
				repeatedWord.put(temp, 1);
				timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss").format(Calendar.getInstance().getTime());
				log.writeLog(timeStamp + " : Finding the occurence of each word with Single Occurence");
			}
		}
		PrintStream printStream = new PrintStream(new FileOutputStream("unique_" + fileName));
		timeStamp = new SimpleDateFormat("yyyy//MM//dd /: HHmmss").format(Calendar.getInstance().getTime());
		log.writeLog(timeStamp + " : Created File for keeping unique Words");
		for (Map.Entry<String, Integer> entry : repeatedWord.entrySet()) {
			System.out.println(entry.getKey() + "\t\t" + entry.getValue());
			timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss").format(Calendar.getInstance().getTime());
			log.writeLog(timeStamp + " : " + entry.getKey() + " " + entry.getValue());
			printStream.append(entry.getKey().toString()).append(" ");

		}

		System.out.println("Unique Words Count : ");
		int count = 0;
		for (Map.Entry<String, Integer> entry : repeatedWord.entrySet()) {
			if (entry.getValue() == 1) {
				count++;
			}
		}
		timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss").format(Calendar.getInstance().getTime());
		log.writeLog(timeStamp + " : Total Number of Unique Words " + count);
		System.out.print(count);
	}

}