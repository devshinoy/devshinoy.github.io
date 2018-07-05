import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;


public class ClassMain {

	public static void main(String[] args) throws Exception {
		System.out.println("How many files, do you have to upload?");
		Scanner sc = new Scanner(System.in);
		int n = sc.nextInt();
		List<HSSFWorkbook> workBooks = new ArrayList<HSSFWorkbook>();
		List<String> filenames = new ArrayList<String>();
		while(n>0){
			System.out.println("Enter the Path : ");
			Scanner scanner = new Scanner(System.in);
			String path = scanner.nextLine();
			FileInputStream file = new FileInputStream(new File(path));
			File f = new File(path);
			HSSFWorkbook workbook = new HSSFWorkbook(file);
			workBooks.add(workbook);
			filenames.add(f.getName());
			n--;
		}
		
		ExcelReader reader = new ExcelReader();
		reader.readExcel(workBooks,filenames);
	}
}
