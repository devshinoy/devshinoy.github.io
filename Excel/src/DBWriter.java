import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;


public class DBWriter {
	
	
	public void createTable(List<String> list,String name) throws Exception{
		
		Connection con = null;
		Statement stmt = null;
		try {
			con= new ConnectionFactory().getConnection();
			String strQuery = "Create table "+name+" (";
			for(String col : list){
				strQuery = strQuery + col + " varchar(255),";
			}
			strQuery = strQuery.substring(0, strQuery.length() - 1);
			strQuery = strQuery + " )";
			stmt = con.createStatement();
			stmt.executeUpdate(strQuery);
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		finally{
			con.close();
			stmt.close();
		}
	}
	
	public void writeData(List<String> list,String name) throws Exception{
		
		Connection con = null;
		Statement stmt = null;
		
		try {
			 con= new ConnectionFactory().getConnection();
			 String strQuery = "INSERT INTO "+name+" VALUES(";
			 for(String val : list){
					strQuery = strQuery +"'"+val+ "'"+",";
				}
			 strQuery = strQuery.substring(0, strQuery.length() - 1);
			 strQuery = strQuery + " )";
			 
			 stmt = con.createStatement();
			 stmt.executeUpdate(strQuery);
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		finally{
			con.close();
			stmt.close();
		}
		
	}
	
	
}
