import java.io.DataInputStream;
import java.io.FileInputStream;

public class FileRead {

	public static void main(String s[]) {

		try {
			FileInputStream fin = new FileInputStream("c:\\sample\\a.txt");
			DataInputStream din = new DataInputStream(System.in);
			String sg = din.readLine();
			while (sg != null) {

				System.out.println(sg);
				sg = din.readLine();

			}

		} catch (Exception ee) {
			System.out.print(ee);
		}
	}
}
