package training;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.util.Scanner;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

public class WordCount {
	
	public static void main(String args[]) throws FileNotFoundException{
		Scanner sc = new Scanner(new FileReader("\\C:\\Users\\Abraham\\Desktop\\SunTec\\Training\\src\\training\\file.txt"));
		int count = 0;
		while(sc.hasNext()){
			sc.next();
			count++;
		}
		System.out.println("Total word count is : " + count);
		Scanner fileRead = new Scanner(new FileReader("\\C:\\Users\\Abraham\\Desktop\\SunTec\\Training\\src\\training\\file.txt"));
		String[] str = new String[count];
		int i = 0;
		while(fileRead.hasNext()){
			str[i] = fileRead.next();
			i++;
		}
		StringBuilder strBuilder = new StringBuilder();
		for (i = 0; i < str.length; i++) {
			   strBuilder.append(str[i]);
			   strBuilder.append(" ");
			}
		String newString = strBuilder.toString();
		wordOccurence(newString);	
		
		}
	
	public static void wordOccurence(String strContent) {
		 
        Map<String, Integer> repeatedWord = new HashMap<String, Integer>();
        String[] words = strContent.split(" ");
        for(String word : words) {
            String temp = word.toLowerCase();
            if(repeatedWord.containsKey(temp)){
                repeatedWord.put(temp, repeatedWord.get(temp) + 1);
            } 
            else {
                repeatedWord.put(temp, 1);
            }
        }
        
        for(Map.Entry<String, Integer> entry : repeatedWord.entrySet()){
            System.out.println(entry.getKey() + "\t\t" + entry.getValue());
        }

	
	}	
}
