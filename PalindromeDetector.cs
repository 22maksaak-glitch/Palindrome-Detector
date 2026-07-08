// PalindromeDetector.cs
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;

class PalindromeDetector
{
    public bool IgnoreCase { get; set; }
    public bool IgnorePunctuation { get; set; }
    private int total, palindromes, nonPalindromes;

    public PalindromeDetector(bool ignoreCase = true, bool ignorePunct = true)
    {
        IgnoreCase = ignoreCase;
        IgnorePunctuation = ignorePunct;
        total = palindromes = nonPalindromes = 0;
    }

    private string Normalize(string text)
    {
        if (IgnoreCase)
            text = text.ToLowerInvariant();
        if (IgnorePunctuation)
            text = Regex.Replace(text, @"[^a-zA-Z0-9]", "");
        else
            text = Regex.Replace(text, @"\s+", "");
        return text;
    }

    public bool IsPalindrome(string text)
    {
        total++;
        string norm = Normalize(text);
        if (string.IsNullOrEmpty(norm))
        {
            nonPalindromes++;
            return false;
        }
        char[] chars = norm.ToCharArray();
        Array.Reverse(chars);
        bool result = norm == new string(chars);
        if (result) palindromes++;
        else nonPalindromes++;
        return result;
    }

    public HashSet<string> FindAllPalindromes(string text, int minLen = 3)
    {
        string norm = Normalize(text);
        int n = norm.Length;
        var pals = new HashSet<string>();
        for (int center = 0; center < n; center++)
        {
            // odd
            int l = center, r = center;
            while (l >= 0 && r < n && norm[l] == norm[r])
            {
                if (r - l + 1 >= minLen)
                    pals.Add(norm.Substring(l, r - l + 1));
                l--; r++;
            }
            // even
            l = center; r = center + 1;
            while (l >= 0 && r < n && norm[l] == norm[r])
            {
                if (r - l + 1 >= minLen)
                    pals.Add(norm.Substring(l, r - l + 1));
                l--; r++;
            }
        }
        return pals;
    }

    public string LongestPalindrome(string text)
    {
        string norm = Normalize(text);
        int n = norm.Length;
        if (n == 0) return "";
        bool[,] dp = new bool[n, n];
        int start = 0, maxLen = 1;
        for (int i = 0; i < n; i++) dp[i, i] = true;
        for (int i = 0; i < n - 1; i++)
        {
            if (norm[i] == norm[i + 1])
            {
                dp[i, i + 1] = true;
                start = i;
                maxLen = 2;
            }
        }
        for (int len = 3; len <= n; len++)
        {
            for (int i = 0; i <= n - len; i++)
            {
                int j = i + len - 1;
                if (norm[i] == norm[j] && dp[i + 1, j - 1])
                {
                    dp[i, j] = true;
                    if (len > maxLen)
                    {
                        start = i;
                        maxLen = len;
                    }
                }
            }
        }
        return norm.Substring(start, maxLen);
    }

    public List<(string text, bool isPal)> BatchCheck(string[] lines)
    {
        var results = new List<(string, bool)>();
        foreach (var line in lines)
        {
            string trimmed = line.Trim();
            if (string.IsNullOrEmpty(trimmed)) continue;
            bool isPal = IsPalindrome(trimmed);
            results.Add((trimmed, isPal));
        }
        return results;
    }

    public void ShowStats()
    {
        Console.WriteLine($"\nStatistics: Total: {total}, Palindromes: {palindromes}, Non-palindromes: {nonPalindromes}");
    }

    static void Main()
    {
        var detector = new PalindromeDetector(true, true);
        Console.WriteLine("=== Palindrome Detector ===");
        while (true)
        {
            Console.WriteLine("\n1. Check if a string is a palindrome");
            Console.WriteLine("2. Find all palindromic substrings");
            Console.WriteLine("3. Find longest palindrome");
            Console.WriteLine("4. Batch check from file");
            Console.WriteLine("5. Show statistics");
            Console.WriteLine($"6. Toggle options (current: case_insensitive={detector.IgnoreCase}, ignore_punct={detector.IgnorePunctuation})");
            Console.WriteLine("7. Exit");
            Console.Write("Choose: ");
            string choice = Console.ReadLine()?.Trim() ?? "";
            switch (choice)
            {
                case "1":
                    Console.Write("Enter text: ");
                    string text = Console.ReadLine() ?? "";
                    bool isPal = detector.IsPalindrome(text);
                    Console.WriteLine($"Is palindrome? {(isPal ? "Yes" : "No")}");
                    break;
                case "2":
                    Console.Write("Enter text: ");
                    text = Console.ReadLine() ?? "";
                    var pals = detector.FindAllPalindromes(text);
                    if (pals.Count > 0)
                        Console.WriteLine("Palindromic substrings found: " + string.Join(", ", pals));
                    else
                        Console.WriteLine("No palindromic substrings found.");
                    break;
                case "3":
                    Console.Write("Enter text: ");
                    text = Console.ReadLine() ?? "";
                    string longest = detector.LongestPalindrome(text);
                    Console.WriteLine($"Longest palindrome: {longest}");
                    break;
                case "4":
                    Console.Write("Enter file path: ");
                    string fname = Console.ReadLine()?.Trim() ?? "";
                    if (!File.Exists(fname))
                    {
                        Console.WriteLine("File not found.");
                        break;
                    }
                    string[] lines = File.ReadAllLines(fname);
                    var results = detector.BatchCheck(lines);
                    Console.WriteLine("\nBatch results:");
                    foreach (var r in results)
                    {
                        string status = r.isPal ? "✓" : "✗";
                        Console.WriteLine($"{status} {r.text}");
                    }
                    break;
                case "5":
                    detector.ShowStats();
                    break;
                case "6":
                    detector.IgnoreCase = !detector.IgnoreCase;
                    detector.IgnorePunctuation = !detector.IgnorePunctuation;
                    Console.WriteLine("Options toggled.");
                    break;
                case "7":
                    Console.WriteLine("Goodbye!");
                    return;
                default:
                    Console.WriteLine("Invalid choice.");
                    break;
            }
        }
    }
}
