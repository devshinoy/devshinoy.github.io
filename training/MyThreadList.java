package area;

import java.util.Scanner;

public class MyThreadList {

	public static void main(String[] args) throws InterruptedException {
		System.out.println("Enter the limit");
		Scanner sc = new Scanner(System.in);
		int n = sc.nextInt();
		Runnable r1 = new RunnableOdd(n);
		Thread t1 = new Thread(r1);
		Runnable r2 = new RunnableEven(n);
		Thread t2 = new Thread(r2);
		t1.start();
		t2.join();
		t2.start();
	}
}

class RunnableEven implements Runnable {
	int n;

	public RunnableEven(int n) {
		this.n = n;
	}

	public void run() {
		for (int i = 2; i <= n; i += 2) {
			System.out.println(i);
			try {
				Thread.sleep(60);

			} catch (InterruptedException e) {

				e.printStackTrace();
			}
		}
	}
}

class RunnableOdd implements Runnable {
	int n;

	public RunnableOdd(int n) {
		this.n = n;
	}

	public void run() {
		for (int i = 1; i <= n; i += 2) {
			System.out.println(i);
			try {
				Thread.sleep(50);

			} catch (InterruptedException e) {

				e.printStackTrace();
			}
		}
	}
}