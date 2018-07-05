import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class ConnectionFactory {
	Connection con;
	String dri="oracle.jdbc.driver.OracleDriver";
	String URL="jdbc:oracle:thin:@server:1521:orcl11g";
	String user="USER";
	String pass="USER";

	public ConnectionFactory() throws ClassNotFoundException, SQLException {
		Class.forName(dri);
		con=DriverManager.getConnection(URL,user,pass);
		
	}
	public Connection getConnection(){
		return con;
	}
}
