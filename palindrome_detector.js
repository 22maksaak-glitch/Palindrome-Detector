// palindrome_detector.js
const readline = require('readline');
const fs = require('fs');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

function ask(question) {
    return new Promise(resolve => rl.question(question, resolve));
}

class PalindromeDetector {
    constructor(ignoreCase = true, ignorePunctuation = true) {
        this.ignoreCase = ignoreCase;
        this.ignorePunctuation = ignorePunctuation;
        this.stats = { total: 0, palindromes: 0, nonPalindromes: 0 };
    }

    normalize(text) {
        if (this.ignoreCase) text = text.toLowerCase();
        if (this.ignorePunctuation) {
            text = text.replace(/[^a-zA-Z0-9]/g, '');
        } else {
            text = text.replace(/\s+/g, '');
        }
        return text;
    }

    isPalindrome(text) {
        this.stats.total++;
        const norm = this.normalize(text);
        if (!norm) {
            this.stats.nonPalindromes++;
            return false;
        }
        const reversed = norm.split('').reverse().join('');
        const result = norm === reversed;
        if (result) this.stats.palindromes++;
        else this.stats.nonPalindromes++;
        return result;
    }

    findAllPalindromes(text, minLen = 3) {
        const norm = this.normalize(text);
        const n = norm.length;
        const palSet = new Set();
        // Expand around center
        for (let center = 0; center < n; center++) {
            // Odd
            let l = center, r = center;
            while (l >= 0 && r < n && norm[l] === norm[r]) {
                if (r - l + 1 >= minLen) {
                    palSet.add(norm.substring(l, r + 1));
                }
                l--; r++;
            }
            // Even
            l = center; r = center + 1;
            while (l >= 0 && r < n && norm[l] === norm[r]) {
                if (r - l + 1 >= minLen) {
                    palSet.add(norm.substring(l, r + 1));
                }
                l--; r++;
            }
        }
        return Array.from(palSet);
    }

    longestPalindrome(text) {
        const norm = this.normalize(text);
        const n = norm.length;
        if (n === 0) return "";
        const dp = Array.from({ length: n }, () => Array(n).fill(false));
        let start = 0, maxLen = 1;
        for (let i = 0; i < n; i++) dp[i][i] = true;
        for (let i = 0; i < n - 1; i++) {
            if (norm[i] === norm[i+1]) {
                dp[i][i+1] = true;
                start = i;
                maxLen = 2;
            }
        }
        for (let length = 3; length <= n; length++) {
            for (let i = 0; i <= n - length; i++) {
                const j = i + length - 1;
                if (norm[i] === norm[j] && dp[i+1][j-1]) {
                    dp[i][j] = true;
                    if (length > maxLen) {
                        start = i;
                        maxLen = length;
                    }
                }
            }
        }
        return norm.substring(start, start + maxLen);
    }

    batchCheck(lines) {
        const results = [];
        for (const line of lines) {
            const trimmed = line.trim();
            if (!trimmed) continue;
            const isPal = this.isPalindrome(trimmed);
            results.push({ text: trimmed, isPal });
        }
        return results;
    }

    showStats() {
        console.log(`\nStatistics: Total: ${this.stats.total}, Palindromes: ${this.stats.palindromes}, Non-palindromes: ${this.stats.nonPalindromes}`);
    }
}

async function main() {
    const detector = new PalindromeDetector(true, true);
    console.log("=== Palindrome Detector ===");
    while (true) {
        console.log("\n1. Check if a string is a palindrome");
        console.log("2. Find all palindromic substrings");
        console.log("3. Find longest palindrome");
        console.log("4. Batch check from file");
        console.log("5. Show statistics");
        console.log(`6. Toggle options (current: case_insensitive=${detector.ignoreCase}, ignore_punct=${detector.ignorePunctuation})`);
        console.log("7. Exit");
        const choice = await ask("Choose: ");
        switch (choice.trim()) {
            case '1': {
                const text = await ask("Enter text: ");
                const isPal = detector.isPalindrome(text);
                console.log(`Is palindrome? ${isPal ? 'Yes' : 'No'}`);
                break;
            }
            case '2': {
                const text = await ask("Enter text: ");
                const pals = detector.findAllPalindromes(text);
                if (pals.length) {
                    console.log("Palindromic substrings found:", pals.join(', '));
                } else {
                    console.log("No palindromic substrings found.");
                }
                break;
            }
            case '3': {
                const text = await ask("Enter text: ");
                const longest = detector.longestPalindrome(text);
                console.log(`Longest palindrome: ${longest || '(none)'}`);
                break;
            }
            case '4': {
                const fname = await ask("Enter file path: ");
                try {
                    const data = fs.readFileSync(fname, 'utf8');
                    const lines = data.split('\n');
                    const results = detector.batchCheck(lines);
                    console.log("\nBatch results:");
                    for (const r of results) {
                        const status = r.isPal ? '✓' : '✗';
                        console.log(`${status} ${r.text}`);
                    }
                } catch (e) {
                    console.log("File not found or error.");
                }
                break;
            }
            case '5':
                detector.showStats();
                break;
            case '6':
                detector.ignoreCase = !detector.ignoreCase;
                detector.ignorePunctuation = !detector.ignorePunctuation;
                console.log("Options toggled.");
                break;
            case '7':
                console.log("Goodbye!");
                rl.close();
                return;
            default:
                console.log("Invalid choice.");
        }
    }
}

main().catch(console.error);
