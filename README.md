🔄 Palindrome Detector – Multi‑Language Edition

A powerful **palindrome detection tool** that identifies palindromic words, phrases, and even substrings within text.  
Supports case‑insensitive and punctuation‑ignoring modes, multi‑language alphabets, and batch processing.  
Built in **7 programming languages** – ideal for learning or integration.

## ✨ Features
- **Classic palindrome check** – detects if a string reads the same forwards and backwards.
- **Flexible options**:
  - Ignore case (on by default)
  - Ignore punctuation, spaces, and special characters
  - Consider only letters (alphabetical) or all characters
- **Search all palindromes** – finds every palindromic substring of length ≥ 3 (or custom) in a given text.
- **Longest palindrome** – finds the longest palindromic substring (useful for large texts).
- **Batch mode** – process multiple lines from a file.
- **Statistics** – track total checks, palindromes found, and non‑palindromes.
- **Interactive CLI** – easy‑to‑use menu.

## 🗂 Languages & Files
| Language          | File                      |
|-------------------|---------------------------|
| Python            | `palindrome_detector.py`  |
| Go                | `palindrome_detector.go`  |
| JavaScript        | `palindrome_detector.js`  |
| C#                | `PalindromeDetector.cs`   |
| Java              | `PalindromeDetector.java` |
| Ruby              | `palindrome_detector.rb`  |
| Swift             | `palindrome_detector.swift`|

## 🚀 How to Run
Each file is standalone – run it with the appropriate interpreter/compiler:

| Language | Command |
|----------|---------|
| Python   | `python palindrome_detector.py` |
| Go       | `go run palindrome_detector.go` |
| JavaScript | `node palindrome_detector.js` |
| C#       | `dotnet run` (or `csc PalindromeDetector.cs`) |
| Java     | `javac PalindromeDetector.java && java PalindromeDetector` |
| Ruby     | `ruby palindrome_detector.rb` |
| Swift    | `swift palindrome_detector.swift` |

## 📊 Example Session
=== Palindrome Detector ===

Check if a string is a palindrome

Find all palindromic substrings

Find longest palindrome

Batch check from file

Show statistics

Toggle options (ignore case, punctuation)

Exit
Choose: 1

Enter text: A man, a plan, a canal: Panama
Is palindrome? Yes
(ignoring case and punctuation)

Choose: 2
Enter text: racecar level civic
Palindromes found: racecar, level, civic

Choose: 3
Enter text: banana
Longest palindrome: anana

text

## 📁 Batch File Format
A plain text file with one phrase per line:
A man a plan a canal Panama
racecar
hello

text
The detector processes each line and outputs results.

## 🔧 Technical Details
- **Normalization** – removes non‑alphanumeric characters (configurable).
- **Case sensitivity** – can be toggled.
- **Substring search** – uses dynamic programming (O(n²)) for longest palindrome; a more efficient algorithm (Manacher) can be added.
- **Multi‑language** – works with any Unicode characters (Latin, Cyrillic, etc.) when ignoring case using proper Unicode handling.

## 🤝 Contributing
Add Manacher’s algorithm for O(n) longest palindrome, support for emoji, or GUI – PRs welcome!

## 📜 License
MIT – use freely.
