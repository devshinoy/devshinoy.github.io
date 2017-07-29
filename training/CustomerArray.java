package area;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;

public class CustomerArray {
	private int custID;

	public int getCustID() {
		return custID;
	}

	public void setCustID(int custID) {
		this.custID = custID;
	}

	public String getCustName() {
		return custName;
	}

	public void setCustName(String custName) {
		this.custName = custName;
	}

	public int getSalary() {
		return salary;
	}

	public void setSalary(int salary) {
		this.salary = salary;
	}

	private String custName;
	private int salary;

	public static void main(String[] args) {
		try {
			int custID, salary;
			String name;
			int choice;
			Boolean exitChoice = true;

			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			ArrayList cust = new ArrayList();
			do {
				System.out.println("1. Add\n2. Remove\n3. Update\n4. Display\n5. Exit\n");
				choice = Integer.parseInt(br.readLine());
				switch (choice) {
				case 1:
					CustomerArray custData = new CustomerArray();
					System.out.println("Enter the customer id");
					custID = Integer.parseInt(br.readLine());
					custData.setCustID(custID);
					System.out.println("Enter the customer name");
					name = br.readLine();
					custData.setCustName(name);
					System.out.println("Enter the customer salary");
					salary = Integer.parseInt(br.readLine());
					custData.setSalary(salary);
					cust.add(custData);
					break;
				case 2:
					System.out.println("Enter the customer ID to remove");
					int remID = Integer.parseInt(br.readLine());

					for (int i = 0; i < cust.size(); i++) {
						CustomerArray custDat = (CustomerArray) cust.get(i);
						int id = custDat.getCustID();
						if (id == remID)
							cust.remove(i);
					}
					break;
				case 3:
					System.out.println("Enter the ID");
					int upID = Integer.parseInt(br.readLine());

					for (int i = 0; i < cust.size(); i++) {
						CustomerArray custDat = (CustomerArray) cust.get(i);
						if (upID == custDat.getCustID()) {
							System.out.println("Enter the field to be updated, Name/Salary");
							String upField = br.readLine();
							System.out.println(upField);
							if (upField.equalsIgnoreCase("name")) {
								System.out.println("Enter the customer name");
								name = br.readLine();
								custDat.setCustName(name);
							} else if (upField.equalsIgnoreCase("salary")) {
								System.out.println("Enter the customer salary");
								salary = Integer.parseInt(br.readLine());
								custDat.setSalary(salary);
							}
						}
					}
					break;

				case 4:
					Enumeration e = Collections.enumeration(cust);
					while (e.hasMoreElements()) {
						CustomerArray custDet = (CustomerArray) e.nextElement();
						System.out.println("CustID: " + custDet.getCustID() + "\nCust Name: " + custDet.getCustName()
								+ "\nCust Salary: " + custDet.getSalary());
					}
					break;

				default:
					System.out.println("Invalid");

				}

			} while (choice < 5);

		} catch (Exception e) {
		}

	}
}
