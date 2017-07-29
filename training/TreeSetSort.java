package area;

import java.util.Comparator;
import java.util.HashSet;
import java.util.Scanner;
import java.util.Set;
import java.util.TreeSet;

public class TreeSetSort {

	public static void main(String args[]) {
		Scanner sc = new Scanner(System.in);
		Set<Integer> set = new HashSet<Integer>();
		int count[] = new int[6];
		System.out.println("Enter the elements");
		try {
			for (int i = 0; i < 6; i++) {
				count[i] = sc.nextInt();
			}

			for (int i = 0; i < 6; i++) {
				set.add(count[i]);
			}
			System.out.println(set);
			TreeSet<Integer> sortedSet = new TreeSet<Integer>(set);
			System.out.println("Sorted List");
			System.out.println(sortedSet);

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}

class MyComp implements Comparator<Integer> {

	@Override
	public int compare(Integer i1, Integer i2) {
		return i1.compareTo(i2);
	}

}