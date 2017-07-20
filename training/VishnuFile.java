package assignment;
import java.io.*;
import java.util.*;
public class ProcessFile {
	public static String getPath() throws IOException
	{
		String path;
		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
		System.out.println("Enter the path of your folder");
		path = br.readLine();
		return path;		
	}
	public static String getExtension()throws IOException
	{
		String ext;
		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
		System.out.println("Enter the extension of your file");
		ext = br.readLine();
		return ext;		
	}
	public static int countWord(String path, String fileName) throws IOException
	{
		int count = 0;
		Scanner sc = new Scanner(new FileReader(path+"\\"+fileName));
		while (sc.hasNext()) {
			sc.next();
			count++;
		}
		sc.close();
		return count;
	}
	public static void wordOccurence(String newString, String fileName) throws IOException
	{
		PrintStream pout=new PrintStream(new FileOutputStream("C:\\Users\\vishnur\\Vishnu\\unique_"+fileName+".txt"));  
	//	BufferedWriter bf = new BufferedWriter(new FileWriter("C:\\Users\\vishnur\\Vishnu\\unique_"+fileName+".txt") );
		Map<String, Integer> repeatedWord = new HashMap<String, Integer>();
		String[] words = newString.split(" ");
		for (String word : words) {
			String temp = word.toLowerCase();
			if (repeatedWord.containsKey(temp)) {
				repeatedWord.put(temp, repeatedWord.get(temp) + 1);
			} else {
				repeatedWord.put(temp, 1);
			}
		}

		int count = 0;
		for (Map.Entry<String, Integer> entry : repeatedWord.entrySet()) {
			pout.print(entry.getKey()+" ");
			if(entry.getValue()==1){
			System.out.println(entry.getKey() + "\t\t" + entry.getValue());
			
			count++;
			}
		}

		System.out.println(count);
	}
	
	public static void process(String path, String fileName) throws IOException
	{
		//System.out.println("In Prcess");
		File file = new File(path+"\\"+fileName);
		Scanner sc = new Scanner(file);
		String fileIn;
		int count = 0;
		while(sc.hasNextLine())
		{
			fileIn = sc.nextLine();
			System.out.println(fileIn);
			count++;
		}
		System.out.println("Count of Lines: "+count);
		int wordCount = countWord(path,fileName);
		Scanner scnWord = new Scanner(new FileReader(path+"\\"+fileName));
		String[] string = new String[wordCount];
		for(int i=0;scnWord.hasNext();i++)
		{
			string[i] = scnWord.next();
		}
		StringBuilder strBuilder = new StringBuilder();
		for (int i = 0; i < string.length; i++) {
			strBuilder.append(string[i]);
			strBuilder.append(" ");
		}
		String newString = strBuilder.toString();
		wordOccurence(newString, fileName);
		sc.close();
		
	}
	public static void searchDoneFile(String fileName, String path, String ext) throws IOException
	{
		File folder = new File(path);
		File[] list = folder.listFiles();
		String extDone = ext+".done";
		String doneName;
		String finalName[] = new String[1];
		for(File file : list)
		{
			if(file.isFile())
			{
				doneName = file.getName();
				//System.out.println(Name);
				if (doneName.matches("^.*."+extDone+"$"))
				{		
					 finalName[0] = doneName.split(".done")[0];
					 if(finalName[0].equals(fileName))
					 {
						 process(path,fileName);
					 }
					//System.out.println(finalName[0]);
				}
			}
		}
	}
	public static void searchFile(String path, String ext) 
	{
		try{
		File folder = new File(path);
		File[] list = folder.listFiles();
		String name;
	//	String fileName[] = new String[10];
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
					else if(name.matches("^.*.("+ext+")$"))
					{
						// call function 
						searchDoneFile(name,path,ext);
						//System.out.println(name);
					}
					else
						throw new MyFileNotFoundException("File Not Found");
					
				}	
		}
		}
		catch(Exception e)
		{
			System.out.println(e);
		}
	}
	public static void main(String[] args) throws IOException
	{
		String path,ext;
		path = getPath();
		ext = getExtension();
		searchFile(path,ext);
	}

}
