package area;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.Stack;

public class CustomerStack {

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
			Stack custStack = new Stack();

			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			String option = null;
			System.out.println("Enter the Customer Data");
			do {
				System.out.println("Enter your choice 1-Add 2-Delete 3-Display");
				int i = Integer.parseInt(br.readLine());
				switch (i) {

				case 1:
					CustomerStack custData = new CustomerStack();
					System.out.println("Enter the Customer Id");
					custData.setCustId(Integer.parseInt(br.readLine()));
					System.out.println("Enter the Customer Name");
					custData.setCustName(br.readLine());
					System.out.println("Enter the Customer Balance");
					custData.setCustBalance(Integer.parseInt(br.readLine()));
					custStack.push(custData);
					break;
				case 2:
					custStack.pop();
					break;
				case 3:

					while (!(custStack.isEmpty())) {
						CustomerStack newData = (CustomerStack) custStack.peek();
						System.out.println(
								newData.getCustId() + " " + newData.getCustName() + " " + newData.getCustBalance());
						custStack.pop();
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
