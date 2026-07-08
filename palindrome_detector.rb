# palindrome_detector.rb
class PalindromeDetector
  attr_accessor :ignore_case, :ignore_punctuation
  attr_reader :stats

  def initialize(ignore_case: true, ignore_punctuation: true)
    @ignore_case = ignore_case
    @ignore_punctuation = ignore_punctuation
    @stats = { total: 0, palindromes: 0, non_palindromes: 0 }
  end

  def normalize(text)
    text = text.downcase if @ignore_case
    if @ignore_punctuation
      text = text.gsub(/[^a-zA-Z0-9]/, '')
    else
      text = text.gsub(/\s+/, '')
    end
    text
  end

  def is_palindrome?(text)
    @stats[:total] += 1
    norm = normalize(text)
    if norm.empty?
      @stats[:non_palindromes] += 1
      return false
    end
    result = norm == norm.reverse
    if result
      @stats[:palindromes] += 1
    else
      @stats[:non_palindromes] += 1
    end
    result
  end

  def find_all_palindromes(text, min_len: 3)
    norm = normalize(text)
    n = norm.length
    pals = Set.new
    (0...n).each do |center|
      # odd
      l = r = center
      while l >= 0 && r < n && norm[l] == norm[r]
        pals.add(norm[l..r]) if (r - l + 1) >= min_len
        l -= 1
        r += 1
      end
      # even
      l = center
      r = center + 1
      while l >= 0 && r < n && norm[l] == norm[r]
        pals.add(norm[l..r]) if (r - l + 1) >= min_len
        l -= 1
        r += 1
      end
    end
    pals.to_a
  end

  def longest_palindrome(text)
    norm = normalize(text)
    n = norm.length
    return "" if n == 0
    dp = Array.new(n) { Array.new(n, false) }
    start = 0
    max_len = 1
    n.times { |i| dp[i][i] = true }
    (0...n-1).each do |i|
      if norm[i] == norm[i+1]
        dp[i][i+1] = true
        start = i
        max_len = 2
      end
    end
    (3..n).each do |len|
      (0..n-len).each do |i|
        j = i + len - 1
        if norm[i] == norm[j] && dp[i+1][j-1]
          dp[i][j] = true
          if len > max_len
            start = i
            max_len = len
          end
        end
      end
    end
    norm[start, max_len]
  end

  def batch_check(lines)
    results = []
    lines.each do |line|
      trimmed = line.strip
      next if trimmed.empty?
      is_pal = is_palindrome?(trimmed)
      results << { text: trimmed, is_pal: is_pal }
    end
    results
  end

  def show_stats
    puts "\nStatistics: Total: #{@stats[:total]}, Palindromes: #{@stats[:palindromes]}, Non-palindromes: #{@stats[:non_palindromes]}"
  end
end

def main
  detector = PalindromeDetector.new(ignore_case: true, ignore_punctuation: true)
  puts "=== Palindrome Detector ==="
  loop do
    puts "\n1. Check if a string is a palindrome"
    puts "2. Find all palindromic substrings"
    puts "3. Find longest palindrome"
    puts "4. Batch check from file"
    puts "5. Show statistics"
    puts "6. Toggle options (current: case_insensitive=#{detector.ignore_case}, ignore_punct=#{detector.ignore_punctuation})"
    puts "7. Exit"
    print "Choose: "
    choice = gets.chomp.strip
    case choice
    when '1'
      print "Enter text: "
      text = gets.chomp
      is_pal = detector.is_palindrome?(text)
      puts "Is palindrome? #{is_pal ? 'Yes' : 'No'}"
    when '2'
      print "Enter text: "
      text = gets.chomp
      pals = detector.find_all_palindromes(text)
      if pals.any?
        puts "Palindromic substrings found: #{pals.join(', ')}"
      else
        puts "No palindromic substrings found."
      end
    when '3'
      print "Enter text: "
      text = gets.chomp
      longest = detector.longest_palindrome(text)
      puts "Longest palindrome: #{longest}"
    when '4'
      print "Enter file path: "
      fname = gets.chomp.strip
      unless File.exist?(fname)
        puts "File not found."
        next
      end
      lines = File.readlines(fname).map(&:chomp)
      results = detector.batch_check(lines)
      puts "\nBatch results:"
      results.each do |r|
        status = r[:is_pal] ? '✓' : '✗'
        puts "#{status} #{r[:text]}"
      end
    when '5'
      detector.show_stats
    when '6'
      detector.ignore_case = !detector.ignore_case
      detector.ignore_punctuation = !detector.ignore_punctuation
      puts "Options toggled."
    when '7'
      puts "Goodbye!"
      break
    else
      puts "Invalid choice."
    end
  end
end

main if __FILE__ == $0
