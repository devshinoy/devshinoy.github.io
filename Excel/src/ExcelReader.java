import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.List;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

public class ExcelReader {

	public void readExcel(List<HSSFWorkbook> list,List<String> names) {

		ExcelHandler handler = new ExcelHandler();
		int i = 0;
		try {
			for (HSSFWorkbook wb : list) {
				String name = names.get(i);
				handler.dataExtract(wb,name);
				i++;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
