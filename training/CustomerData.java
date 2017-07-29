import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.Enumeration;
import java.util.Vector;

public class CustomerData {

	private int custId, custBalance;
	private String custName;

	public int getCustBalance() {
		return custBalance;
	}

	public void setCustBalance(int custBalance) {
		this.custBalance = custBalance;
	}

	public int getCustId() {
		return custId;
	}

	public void setCustId(int custId) {
		this.custId = custId;
	}

	public String getCustName() {
		return custName;
	}

	public void setCustName(String custName) {
		this.custName = custName;
	}

	public static void main(String[] args) throws Exception {
		try {
			Vector custVector = new Vector();
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			String option = null;
			System.out.println("Enter the Customer Data");
			do {
				System.out.println("Enter your choice 1-Add 2-Delete 3-Update 4-Display");
				int i = Integer.parseInt(br.readLine());
				switch (i) {

				case 1:
					CustomerData custData = new CustomerData();
					System.out.println("Enter the Customer Id");
					custData.setCustId(Integer.parseInt(br.readLine()));
					System.out.println("Enter the Customer Name");
					custData.setCustName(br.readLine());
					System.out.println("Enter the Customer Balance");
					custData.setCustBalance(Integer.parseInt(br.readLine()));
					custVector.add(custData);
					break;
				case 2:
					System.out.println("Enter the Customer Id to Delete");
					int delCust = Integer.parseInt(br.readLine());
					for (int j = 0; j < custVector.size(); j++) {
						CustomerData cData = (CustomerData) custVector.elementAt(j);
						if (delCust == cData.getCustId()) {
							custVector.remove(j);
							break;
						}
					}
					break;
				case 3:
					System.out.println("Enter the Customer Id to Update");
					int upCust = Integer.parseInt(br.readLine());
					for (int j = 0; j < custVector.size(); j++) {
						CustomerData cData = (CustomerData) custVector.elementAt(j);
						if (upCust == cData.getCustId()) {
							System.out.println("click 1-update both, 2-Name , 3-Balance");
							int upOpt = Integer.parseInt(br.readLine());
							if (upOpt == 1) {
								System.out.println("Enter the Customer Name");
								cData.setCustName(br.readLine());
								System.out.println("Enter the Customer Balance");
								cData.setCustBalance(Integer.parseInt(br.readLine()));

								break;
							} else if (upOpt == 2) {
								System.out.println("Enter the Customer Name");
								cData.setCustName(br.readLine());

								break;
							} else if (upOpt == 3) {
								System.out.println("Enter the Customer Balance");
								cData.setCustBalance(Integer.parseInt(br.readLine()));

								break;
							} else {
								System.out.println("Enter a Valid option");
								break;
							}
						}
					}
					break;

				case 4:
					Enumeration enumCust = custVector.elements();

					while (enumCust.hasMoreElements()) {
						CustomerData outData = (CustomerData) enumCust.nextElement();
						System.out.println(
								outData.getCustId() + " " + outData.getCustName() + " " + outData.getCustBalance());
					}
					break;
				default:
					System.out.println("Enter a Valid option");

				}
				System.out.println("Do you want to Continue(y/n)");
				option = br.readLine();
			} while (option.equals("y"));

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
