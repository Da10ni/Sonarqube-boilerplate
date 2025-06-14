package com.example;

public class App {
    public static void main(String[] args) {
        System.out.println("Hello from SonarQube sample project!");
    }
    App.error(); // This line is intentionally incorrect to trigger a SonarQube issue
    public static void error() {
        // This method is intentionally left empty to demonstrate a SonarQube issue
    }
}
