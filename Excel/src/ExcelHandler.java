

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

public class ExcelHandler {
	public void dataExtract (HSSFWorkbook  workbook,String name) throws Exception{
		HSSFSheet sheet 		 = workbook.getSheetAt(0);
		Iterator rIterator  	 = sheet.rowIterator();
		List<String> columnNames = new ArrayList<>();
		List<String> datalist    = new ArrayList<>();
		int flag 				 = 0;
		DBWriter dbWriter 		 =  new DBWriter();

        while(rIterator.hasNext())
        {
        	HSSFRow row = (HSSFRow) rIterator.next();
        	Iterator cellIterator = row.cellIterator();
        	while(cellIterator.hasNext())
            {
        		HSSFCell  cell =(HSSFCell ) cellIterator.next();
        		System.out.println(cell.getStringCellValue());
        		if(flag==0){
        			columnNames.add(cell.getStringCellValue());
        		}else
        			datalist.add(cell.getStringCellValue());
            }
        	if(flag==0){
        		dbWriter.createTable(columnNames, name);
        	}else
        		dbWriter.writeData(datalist, name);
        	flag=1;
        }
		
	}
}
