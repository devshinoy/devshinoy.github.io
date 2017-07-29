package area;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Calendar;

public class ThreadFile {

	public static void main(String[] args) throws IOException {

		System.out.println("Enter the first file path");
		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
		String pathOne = br.readLine();
		System.out.println("Enter the second file path");
		String pathTwo = br.readLine();
		Runnable r1 = new RunnableFileOne(pathOne);
		Thread t1 = new Thread(r1);
		Runnable r2 = new RunnableFileTwo(pathTwo);
		Thread t2 = new Thread(r2);
		t1.start();
		t2.start();
	}

}

class RunnableFileOne implements Runnable {

	String path;

	public RunnableFileOne(String pathOne) {
		path = pathOne;
	}

	public void run() {
		File folder = new File(path);
		File[] list = folder.listFiles();
		String name;
		for (File file : list) {
			if (file.isFile()) {
				name = file.getName();
				if (name.matches("shutdown.*")) {
					System.out.println("Terminated");
					return;
				}
			}
		}
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
					timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss").format(Calendar.getInstance().getTime());
					log.writeLog(timeStamp + " : Extension Matched for " + name);
					timeStamp = new SimpleDateFormat("yyyy/MM/dd : HH mm ss").format(Calendar.getInstance().getTime());
					log.writeLog(timeStamp + " :Invoking donefile method for the file " + name);
					findDoneFile(name, path, ext);
				}

			}
		}
	}

}

class RunnableFileTwo implements Runnable {
	String path;

	public RunnableFileTwo(String pathTwo) {
		path = pathTwo;
	}

	public void run() {

	}

}