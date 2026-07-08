// palindrome_detector.go
package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strings"
)

type PalindromeDetector struct {
	IgnoreCase       bool
	IgnorePunctuation bool
	Stats            struct{ Total, Palindromes, NonPalindromes int }
}

func NewDetector(ignoreCase, ignorePunct bool) *PalindromeDetector {
	return &PalindromeDetector{
		IgnoreCase:       ignoreCase,
		IgnorePunctuation: ignorePunct,
	}
}

func (d *PalindromeDetector) normalize(text string) string {
	if d.IgnoreCase {
		text = strings.ToLower(text)
	}
	if d.IgnorePunctuation {
		// Keep only letters and digits
		re := regexp.MustCompile(`[^a-zA-Z0-9]`)
		text = re.ReplaceAllString(text, "")
	} else {
		// Remove whitespace only
		re := regexp.MustCompile(`\s+`)
		text = re.ReplaceAllString(text, "")
	}
	return text
}

func (d *PalindromeDetector) IsPalindrome(text string) bool {
	d.Stats.Total++
	norm := d.normalize(text)
	if norm == "" {
		d.Stats.NonPalindromes++
		return false
	}
	// Check palindrome
	runes := []rune(norm)
	for i, j := 0, len(runes)-1; i < j; i, j = i+1, j-1 {
		if runes[i] != runes[j] {
			d.Stats.NonPalindromes++
			return false
		}
	}
	d.Stats.Palindromes++
	return true
}

func (d *PalindromeDetector) FindAllPalindromes(text string, minLen int) []string {
	norm := d.normalize(text)
	n := len(norm)
	if n == 0 {
		return []string{}
	}
	palMap := make(map[string]bool)
	// Expand around center
	for center := 0; center < n; center++ {
		// Odd
		l, r := center, center
		for l >= 0 && r < n && norm[l] == norm[r] {
			if r-l+1 >= minLen {
				palMap[norm[l:r+1]] = true
			}
			l--
			r++
		}
		// Even
		l, r = center, center+1
		for l >= 0 && r < n && norm[l] == norm[r] {
			if r-l+1 >= minLen {
				palMap[norm[l:r+1]] = true
			}
			l--
			r++
		}
	}
	// Convert map to slice
	results := make([]string, 0, len(palMap))
	for s := range palMap {
		results = append(results, s)
	}
	return results
}

func (d *PalindromeDetector) LongestPalindrome(text string) string {
	norm := d.normalize(text)
	n := len(norm)
	if n == 0 {
		return ""
	}
	// DP
	dp := make([][]bool, n)
	for i := range dp {
		dp[i] = make([]bool, n)
	}
	start, maxLen := 0, 1
	for i := 0; i < n; i++ {
		dp[i][i] = true
	}
	for i := 0; i < n-1; i++ {
		if norm[i] == norm[i+1] {
			dp[i][i+1] = true
			start = i
			maxLen = 2
		}
	}
	for length := 3; length <= n; length++ {
		for i := 0; i <= n-length; i++ {
			j := i + length - 1
			if norm[i] == norm[j] && dp[i+1][j-1] {
				dp[i][j] = true
				if length > maxLen {
					start = i
					maxLen = length
				}
			}
		}
	}
	return norm[start : start+maxLen]
}

func (d *PalindromeDetector) BatchCheck(lines []string) []struct {
	Text   string
	IsPal  bool
} {
	results := []struct {
		Text   string
		IsPal  bool
	}{}
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		isPal := d.IsPalindrome(line)
		results = append(results, struct {
			Text   string
			IsPal  bool
		}{line, isPal})
	}
	return results
}

func (d *PalindromeDetector) ShowStats() {
	fmt.Printf("\nStatistics: Total: %d, Palindromes: %d, Non-palindromes: %d\n",
		d.Stats.Total, d.Stats.Palindromes, d.Stats.NonPalindromes)
}

func main() {
	detector := NewDetector(true, true)
	scanner := bufio.NewScanner(os.Stdin)
	fmt.Println("=== Palindrome Detector ===")
	for {
		fmt.Println("\n1. Check if a string is a palindrome")
		fmt.Println("2. Find all palindromic substrings")
		fmt.Println("3. Find longest palindrome")
		fmt.Println("4. Batch check from file")
		fmt.Println("5. Show statistics")
		fmt.Printf("6. Toggle options (current: case_insensitive=%v, ignore_punct=%v)\n", detector.IgnoreCase, detector.IgnorePunctuation)
		fmt.Println("7. Exit")
		fmt.Print("Choose: ")
		scanner.Scan()
		choice := strings.TrimSpace(scanner.Text())
		switch choice {
		case "1":
			fmt.Print("Enter text: ")
			scanner.Scan()
			text := scanner.Text()
			isPal := detector.IsPalindrome(text)
			fmt.Printf("Is palindrome? %v\n", isPal)
		case "2":
			fmt.Print("Enter text: ")
			scanner.Scan()
			text := scanner.Text()
			pals := detector.FindAllPalindromes(text, 3)
			if len(pals) > 0 {
				fmt.Println("Palindromic substrings found:", strings.Join(pals, ", "))
			} else {
				fmt.Println("No palindromic substrings found.")
			}
		case "3":
			fmt.Print("Enter text: ")
			scanner.Scan()
			text := scanner.Text()
			longest := detector.LongestPalindrome(text)
			if longest != "" {
				fmt.Printf("Longest palindrome: %s\n", longest)
			} else {
				fmt.Println("(none)")
			}
		case "4":
			fmt.Print("Enter file path: ")
			scanner.Scan()
			fname := strings.TrimSpace(scanner.Text())
			file, err := os.Open(fname)
			if err != nil {
				fmt.Println("File not found.")
				break
			}
			defer file.Close()
			var lines []string
			fileScanner := bufio.NewScanner(file)
			for fileScanner.Scan() {
				lines = append(lines, fileScanner.Text())
			}
			results := detector.BatchCheck(lines)
			fmt.Println("\nBatch results:")
			for _, r := range results {
				status := "✓"
				if !r.IsPal {
					status = "✗"
				}
				fmt.Printf("%s %s\n", status, r.Text)
			}
		case "5":
			detector.ShowStats()
		case "6":
			detector.IgnoreCase = !detector.IgnoreCase
			detector.IgnorePunctuation = !detector.IgnorePunctuation
			fmt.Println("Options toggled.")
		case "7":
			fmt.Println("Goodbye!")
			return
		default:
			fmt.Println("Invalid choice.")
		}
	}
}
