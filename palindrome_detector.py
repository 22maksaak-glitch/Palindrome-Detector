# palindrome_detector.py
import re
from typing import List, Tuple, Set

class PalindromeDetector:
    def __init__(self, ignore_case=True, ignore_punctuation=True):
        self.ignore_case = ignore_case
        self.ignore_punctuation = ignore_punctuation
        self.stats = {'total': 0, 'palindromes': 0, 'non_palindromes': 0}

    def _normalize(self, text: str) -> str:
        """Normalize string based on options."""
        if self.ignore_case:
            text = text.lower()
        if self.ignore_punctuation:
            # Keep only letters and digits
            text = re.sub(r'[^a-zA-Z0-9]', '', text)
        else:
            # Remove only whitespace if we want to keep punctuation
            text = re.sub(r'\s+', '', text)
        return text

    def is_palindrome(self, text: str) -> bool:
        """Check if a string is a palindrome."""
        self.stats['total'] += 1
        normalized = self._normalize(text)
        if not normalized:
            self.stats['non_palindromes'] += 1
            return False
        result = normalized == normalized[::-1]
        if result:
            self.stats['palindromes'] += 1
        else:
            self.stats['non_palindromes'] += 1
        return result

    def find_all_palindromes(self, text: str, min_len: int = 3) -> Set[str]:
        """Find all palindromic substrings of length >= min_len."""
        normalized = self._normalize(text)
        n = len(normalized)
        palindromes = set()
        # Expand around center
        for center in range(n):
            # Odd length
            l = r = center
            while l >= 0 and r < n and normalized[l] == normalized[r]:
                length = r - l + 1
                if length >= min_len:
                    palindromes.add(normalized[l:r+1])
                l -= 1
                r += 1
            # Even length
            l, r = center, center + 1
            while l >= 0 and r < n and normalized[l] == normalized[r]:
                length = r - l + 1
                if length >= min_len:
                    palindromes.add(normalized[l:r+1])
                l -= 1
                r += 1
        # Also add original palindromes if they were words? We only add substrings.
        # We can also split by whitespace and check words.
        # But this already finds substrings.
        return palindromes

    def longest_palindrome(self, text: str) -> str:
        """Find the longest palindromic substring."""
        normalized = self._normalize(text)
        n = len(normalized)
        if n == 0:
            return ""
        # Use DP: O(n^2)
        dp = [[False] * n for _ in range(n)]
        start, max_len = 0, 1
        # All single chars are palindromes
        for i in range(n):
            dp[i][i] = True
        # Check length 2
        for i in range(n-1):
            if normalized[i] == normalized[i+1]:
                dp[i][i+1] = True
                start = i
                max_len = 2
        # Check length >= 3
        for length in range(3, n+1):
            for i in range(n - length + 1):
                j = i + length - 1
                if normalized[i] == normalized[j] and dp[i+1][j-1]:
                    dp[i][j] = True
                    if length > max_len:
                        start = i
                        max_len = length
        return normalized[start:start+max_len]

    def batch_check(self, lines: List[str]) -> List[Tuple[str, bool]]:
        results = []
        for line in lines:
            line = line.strip()
            if not line:
                continue
            is_pal = self.is_palindrome(line)
            results.append((line, is_pal))
        return results

    def show_stats(self):
        print(f"\nStatistics: Total: {self.stats['total']}, Palindromes: {self.stats['palindromes']}, Non-palindromes: {self.stats['non_palindromes']}")

def main():
    detector = PalindromeDetector(ignore_case=True, ignore_punctuation=True)
    print("=== Palindrome Detector ===")
    while True:
        print("\n1. Check if a string is a palindrome")
        print("2. Find all palindromic substrings")
        print("3. Find longest palindrome")
        print("4. Batch check from file")
        print("5. Show statistics")
        print("6. Toggle options (current: case_insensitive={}, ignore_punct={})".format(
            detector.ignore_case, detector.ignore_punctuation))
        print("7. Exit")
        choice = input("Choose: ").strip()
        if choice == '1':
            text = input("Enter text: ")
            is_pal = detector.is_palindrome(text)
            print(f"Is palindrome? {'Yes' if is_pal else 'No'}")
        elif choice == '2':
            text = input("Enter text: ")
            pals = detector.find_all_palindromes(text)
            if pals:
                print("Palindromic substrings found:", ', '.join(sorted(pals)))
            else:
                print("No palindromic substrings found.")
        elif choice == '3':
            text = input("Enter text: ")
            longest = detector.longest_palindrome(text)
            print(f"Longest palindrome: {longest if longest else '(none)'}")
        elif choice == '4':
            fname = input("Enter file path: ")
            try:
                with open(fname, 'r') as f:
                    lines = f.readlines()
                results = detector.batch_check(lines)
                print("\nBatch results:")
                for line, is_pal in results:
                    status = "✓" if is_pal else "✗"
                    print(f"{status} {line}")
            except FileNotFoundError:
                print("File not found.")
        elif choice == '5':
            detector.show_stats()
        elif choice == '6':
            # Toggle options
            detector.ignore_case = not detector.ignore_case
            detector.ignore_punctuation = not detector.ignore_punctuation
            print("Options toggled.")
        elif choice == '7':
            print("Goodbye!")
            break
        else:
            print("Invalid choice.")

if __name__ == "__main__":
    main()
