// palindrome_detector.swift
import Foundation

class PalindromeDetector {
    var ignoreCase: Bool
    var ignorePunctuation: Bool
    private(set) var stats: (total: Int, palindromes: Int, nonPalindromes: Int) = (0, 0, 0)

    init(ignoreCase: Bool = true, ignorePunctuation: Bool = true) {
        self.ignoreCase = ignoreCase
        self.ignorePunctuation = ignorePunctuation
    }

    private func normalize(_ text: String) -> String {
        var result = text
        if ignoreCase {
            result = result.lowercased()
        }
        if ignorePunctuation {
            result = result.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "", options: .regularExpression)
        } else {
            result = result.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
        }
        return result
    }

    func isPalindrome(_ text: String) -> Bool {
        stats.total += 1
        let norm = normalize(text)
        if norm.isEmpty {
            stats.nonPalindromes += 1
            return false
        }
        let reversed = String(norm.reversed())
        let result = norm == reversed
        if result {
            stats.palindromes += 1
        } else {
            stats.nonPalindromes += 1
        }
        return result
    }

    func findAllPalindromes(_ text: String, minLen: Int = 3) -> Set<String> {
        let norm = normalize(text)
        let n = norm.count
        var pals = Set<String>()
        let chars = Array(norm)
        for center in 0..<n {
            // odd
            var l = center, r = center
            while l >= 0 && r < n && chars[l] == chars[r] {
                if r - l + 1 >= minLen {
                    pals.insert(String(chars[l...r]))
                }
                l -= 1; r += 1
            }
            // even
            l = center; r = center + 1
            while l >= 0 && r < n && chars[l] == chars[r] {
                if r - l + 1 >= minLen {
                    pals.insert(String(chars[l...r]))
                }
                l -= 1; r += 1
            }
        }
        return pals
    }

    func longestPalindrome(_ text: String) -> String {
        let norm = normalize(text)
        let n = norm.count
        if n == 0 { return "" }
        let chars = Array(norm)
        var dp = Array(repeating: Array(repeating: false, count: n), count: n)
        var start = 0, maxLen = 1
        for i in 0..<n { dp[i][i] = true }
        for i in 0..<n-1 {
            if chars[i] == chars[i+1] {
                dp[i][i+1] = true
                start = i
                maxLen = 2
            }
        }
        for length in 3...n {
            for i in 0...n-length {
                let j = i + length - 1
                if chars[i] == chars[j] && dp[i+1][j-1] {
                    dp[i][j] = true
                    if length > maxLen {
                        start = i
                        maxLen = length
                    }
                }
            }
        }
        return String(chars[start..<start+maxLen])
    }

    func batchCheck(_ lines: [String]) -> [(text: String, isPal: Bool)] {
        var results: [(String, Bool)] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            let isPal = isPalindrome(trimmed)
            results.append((trimmed, isPal))
        }
        return results
    }

    func showStats() {
        print("\nStatistics: Total: \(stats.total), Palindromes: \(stats.palindromes), Non-palindromes: \(stats.nonPalindromes)")
    }
}

func main() {
    let detector = PalindromeDetector(ignoreCase: true, ignorePunctuation: true)
    print("=== Palindrome Detector ===")
    while true {
        print("\n1. Check if a string is a palindrome")
        print("2. Find all palindromic substrings")
        print("3. Find longest palindrome")
        print("4. Batch check from file")
        print("5. Show statistics")
        print("6. Toggle options (current: case_insensitive=\(detector.ignoreCase), ignore_punct=\(detector.ignorePunctuation))")
        print("7. Exit")
        print("Choose: ", terminator: "")
        guard let choice = readLine()?.trimmingCharacters(in: .whitespaces) else { continue }
        switch choice {
        case "1":
            print("Enter text: ", terminator: "")
            guard let text = readLine() else { break }
            let isPal = detector.isPalindrome(text)
            print("Is palindrome? \(isPal ? "Yes" : "No")")
        case "2":
            print("Enter text: ", terminator: "")
            guard let text = readLine() else { break }
            let pals = detector.findAllPalindromes(text)
            if !pals.isEmpty {
                print("Palindromic substrings found: \(pals.sorted().joined(separator: ", "))")
            } else {
                print("No palindromic substrings found.")
            }
        case "3":
            print("Enter text: ", terminator: "")
            guard let text = readLine() else { break }
            let longest = detector.longestPalindrome(text)
            print("Longest palindrome: \(longest.isEmpty ? "(none)" : longest)")
        case "4":
            print("Enter file path: ", terminator: "")
            guard let fname = readLine()?.trimmingCharacters(in: .whitespaces) else { break }
            let fileURL = URL(fileURLWithPath: fname)
            guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
                print("File not found or unreadable.")
                break
            }
            let lines = content.components(separatedBy: .newlines)
            let results = detector.batchCheck(lines)
            print("\nBatch results:")
            for r in results {
                let status = r.isPal ? "✓" : "✗"
                print("\(status) \(r.text)")
            }
        case "5":
            detector.showStats()
        case "6":
            detector.ignoreCase.toggle()
            detector.ignorePunctuation.toggle()
            print("Options toggled.")
        case "7":
            print("Goodbye!")
            return
        default:
            print("Invalid choice.")
        }
    }
}

main()
