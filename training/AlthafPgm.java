

import java.awt.List;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Scanner;
import java.util.Set;

public class marker {

	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
		Scanner scan=new Scanner(System.in);
		String folderpath;
		String marker=".done";
		int i;
		//String processfiles;
		//String processfiles[]=new String[10];
		System.out.println("Enter the folder path");
		folderpath=scan.nextLine();
		File folder = new File(folderpath);
		File[] listOfFiles = folder.listFiles();
		System.out.println("File in the folder are:\n ");
		    for (i = 0; i < listOfFiles.length; i++) {
		        System.out.println(listOfFiles[i].getName());
	
		      } 
		    System.out.println("\nFile to be processed are:\n ");
		    for ( i = 0; i < listOfFiles.length; i++) {
		    	String filename=listOfFiles[i].getName();
		    	filename=filename.concat(marker);
		    	if(new File(folderpath,filename).exists()){
		    try{
		    	FileInputStream in=new FileInputStream(listOfFiles[i]);
		    	String filecontent;
		    	BufferedReader br= new BufferedReader(new InputStreamReader(new FileInputStream (listOfFiles[i])));
		    	filecontent=br.readLine();
		    	//System.out.println("File : "+listOfFiles[i]);
		    	System.out.println("The contents of file is : \n"+filecontent);
		    	char[] c=filecontent.toCharArray();
		    	int counter = 0;
		       
				for(int p = 0;p<filecontent.length();p++)
		        {
		              if(c[p] == 'a' || c[p] == 'e' || c[p] == 'i' || c[p] == 'o' || c[p] == 'u' || c[p] == 'y')
		                   counter++;
		        }
		       
		        //Tell the user the number of vowels
		        System.out.println("Number of Vowels: " + counter);

		    }
		    catch(Exception e){
		    	
		    }String[] str = new String[30];
		    int z=0;
		    Scanner sc = new Scanner(new FileReader(listOfFiles[i]));
			int count = 0;
			while(sc.hasNext())
			{
				str[i]=sc.next();
				count++;
				z++;
				
			}
			
			System.out.println("\nTotal word count is : " + count);
			
			
			
			
		
	        

			
	}
		    	
		
		    	
		    	
		    	
}}
}
