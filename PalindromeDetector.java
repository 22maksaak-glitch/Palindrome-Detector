// PalindromeDetector.java
import java.io.*;
import java.util.*;

public class PalindromeDetector {
    private boolean ignoreCase;
    private boolean ignorePunctuation;
    private int total, palindromes, nonPalindromes;

    public PalindromeDetector(boolean ignoreCase, boolean ignorePunct) {
        this.ignoreCase = ignoreCase;
        this.ignorePunctuation = ignorePunct;
        total = palindromes = nonPalindromes = 0;
    }

    private String normalize(String text) {
        if (ignoreCase) text = text.toLowerCase();
        if (ignorePunctuation) {
            text = text.replaceAll("[^a-zA-Z0-9]", "");
        } else {
            text = text.replaceAll("\\s+", "");
        }
        return text;
    }

    public boolean isPalindrome(String text) {
        total++;
        String norm = normalize(text);
        if (norm.isEmpty()) {
            nonPalindromes++;
            return false;
        }
        String reversed = new StringBuilder(norm).reverse().toString();
        boolean result = norm.equals(reversed);
        if (result) palindromes++;
        else nonPalindromes++;
        return result;
    }

    public Set<String> findAllPalindromes(String text, int minLen) {
        String norm = normalize(text);
        int n = norm.length();
        Set<String> pals = new HashSet<>();
        for (int center = 0; center < n; center++) {
            // odd
            int l = center, r = center;
            while (l >= 0 && r < n && norm.charAt(l) == norm.charAt(r)) {
                if (r - l + 1 >= minLen) {
                    pals.add(norm.substring(l, r + 1));
                }
                l--; r++;
            }
            // even
            l = center; r = center + 1;
            while (l >= 0 && r < n && norm.charAt(l) == norm.charAt(r)) {
                if (r - l + 1 >= minLen) {
                    pals.add(norm.substring(l, r + 1));
                }
                l--; r++;
            }
        }
        return pals;
    }

    public String longestPalindrome(String text) {
        String norm = normalize(text);
        int n = norm.length();
        if (n == 0) return "";
        boolean[][] dp = new boolean[n][n];
        int start = 0, maxLen = 1;
        for (int i = 0; i < n; i++) dp[i][i] = true;
        for (int i = 0; i < n - 1; i++) {
            if (norm.charAt(i) == norm.charAt(i + 1)) {
                dp[i][i + 1] = true;
                start = i;
                maxLen = 2;
            }
        }
        for (int len = 3; len <= n; len++) {
            for (int i = 0; i <= n - len; i++) {
                int j = i + len - 1;
                if (norm.charAt(i) == norm.charAt(j) && dp[i + 1][j - 1]) {
                    dp[i][j] = true;
                    if (len > maxLen) {
                        start = i;
                        maxLen = len;
                    }
                }
            }
        }
        return norm.substring(start, start + maxLen);
    }

    public List<Result> batchCheck(String[] lines) {
        List<Result> results = new ArrayList<>();
        for (String line : lines) {
            String trimmed = line.trim();
            if (trimmed.isEmpty()) continue;
            boolean isPal = isPalindrome(trimmed);
            results.add(new Result(trimmed, isPal));
        }
        return results;
    }

    static class Result {
        String text;
        boolean isPal;
        Result(String t, boolean p) { text = t; isPal = p; }
    }

    public void showStats() {
        System.out.printf("\nStatistics: Total: %d, Palindromes: %d, Non-palindromes: %d\n", total, palindromes, nonPalindromes);
    }

    public static void main(String[] args) throws IOException {
        PalindromeDetector detector = new PalindromeDetector(true, true);
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        System.out.println("=== Palindrome Detector ===");
        while (true) {
            System.out.println("\n1. Check if a string is a palindrome");
            System.out.println("2. Find all palindromic substrings");
            System.out.println("3. Find longest palindrome");
            System.out.println("4. Batch check from file");
            System.out.println("5. Show statistics");
            System.out.printf("6. Toggle options (current: case_insensitive=%b, ignore_punct=%b)\n",
                    detector.ignoreCase, detector.ignorePunctuation);
            System.out.println("7. Exit");
            System.out.print("Choose: ");
            String choice = reader.readLine().trim();
            switch (choice) {
                case "1":
                    System.out.print("Enter text: ");
                    String text = reader.readLine();
                    boolean isPal = detector.isPalindrome(text);
                    System.out.println("Is palindrome? " + (isPal ? "Yes" : "No"));
                    break;
                case "2":
                    System.out.print("Enter text: ");
                    text = reader.readLine();
                    Set<String> pals = detector.findAllPalindromes(text, 3);
                    if (!pals.isEmpty())
                        System.out.println("Palindromic substrings found: " + String.join(", ", pals));
                    else
                        System.out.println("No palindromic substrings found.");
                    break;
                case "3":
                    System.out.print("Enter text: ");
                    text = reader.readLine();
                    String longest = detector.longestPalindrome(text);
                    System.out.println("Longest palindrome: " + longest);
                    break;
                case "4":
                    System.out.print("Enter file path: ");
                    String fname = reader.readLine().trim();
                    File file = new File(fname);
                    if (!file.exists()) {
                        System.out.println("File not found.");
                        break;
                    }
                    List<String> lines = new ArrayList<>();
                    try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                        String line;
                        while ((line = br.readLine()) != null) {
                            lines.add(line);
                        }
                    }
                    List<Result> results = detector.batchCheck(lines.toArray(new String[0]));
                    System.out.println("\nBatch results:");
                    for (Result r : results) {
                        String status = r.isPal ? "✓" : "✗";
                        System.out.println(status + " " + r.text);
                    }
                    break;
                case "5":
                    detector.showStats();
                    break;
                case "6":
                    detector.ignoreCase = !detector.ignoreCase;
                    detector.ignorePunctuation = !detector.ignorePunctuation;
                    System.out.println("Options toggled.");
                    break;
                case "7":
                    System.out.println("Goodbye!");
                    return;
                default:
                    System.out.println("Invalid choice.");
            }
        }
    }
}
