//
//  String.swift
//  Cent
//
//  Created by Ankur Patel on 6/30/14.
//  Copyright (c) 2014 Encore Dev Labs LLC. All rights reserved.
//

import Foundation
import Dollar

public extension String {

    public var length: Int {
        get {
            return self.characters.count
        }
    }

    public var camelCase: String {
        get {
            return self.deburr().words().reduceWithIndex("") { (result, index, word) -> String in
                let lowered = word.lowercaseString
                return result + (index > 0 ? lowered.capitalizedString : lowered)
            }
        }
    }

    public var kebabCase: String {
        get {
            return self.deburr().words().reduceWithIndex("", combine: { (result, index, word) -> String in
                return result + (index > 0 ? "-" : "") + word.lowercaseString
            })
        }
    }

    public var snakeCase: String {
        get {
            return self.deburr().words().reduceWithIndex("", combine: { (result, index, word) -> String in
                return result + (index > 0 ? "_" : "") + word.lowercaseString
            })
        }
    }

    public var startCase: String {
        get {
            return self.deburr().words().reduceWithIndex("", combine: { (result, index, word) -> String in
                return result + (index > 0 ? " " : "") + word.capitalizedString
            })
        }
    }

    /// Get character at a subscript
    ///
    /// - parameter index: Index for which the character is returned
    /// - returns: Character at index i
    public subscript(index: Int) -> Character? {
        if let char = Array(self.characters).get(index) {
            return char
        }
        return .None
    }

    /// Get character at a subscript
    ///
    /// - parameter i: Index for which the character is returned
    /// - returns: Character at index i
    public subscript(pattern: String) -> String? {
        if let range = Regex(pattern).rangeOfFirstMatch(self).toRange() {
            return self[range]
        }
        return .None
    }

    /// Get substring using subscript notation and by passing a range
    ///
    /// - parameter range: The range from which to start and end the substring
    /// - returns: Substring
    public subscript(range: Range<Int>) -> String {
        let start = startIndex.advancedBy(range.startIndex)
        let end = startIndex.advancedBy(range.endIndex)
        return self.substringWithRange(start..<end)
    }

    /// Get the start index of Character
    ///
    /// - parameter char: Character to get index of
    /// - returns: start index of .None if not found
    public func indexOf(char: Character) -> Int? {
        return self.indexOf(char.description)
    }

    /// Get the start index of string
    ///
    /// - parameter str: String to get index of
    /// - returns: start index of .None if not found
    public func indexOf(str: String) -> Int? {
        return self.indexOfRegex(Regex.escapeStr(str))
    }

    /// Get the start index of regex pattern
    ///
    /// - parameter pattern: Regex pattern to get index of
    /// - returns: start index of .None if not found
    public func indexOfRegex(pattern: String) -> Int? {
        if let range = Regex(pattern).rangeOfFirstMatch(self).toRange() {
            return range.startIndex
        }
        return .None
    }

    /// Get an array from string split using the delimiter character
    ///
    /// - parameter delimiter: Character to delimit
    /// - returns: Array of strings after spliting
    public func split(delimiter: Character) -> [String] {
        return self.componentsSeparatedByString(String(delimiter))
    }

    /// Remove leading whitespace characters
    ///
    /// - returns: String without leading whitespace
    public func lstrip() -> String {
        return self["[^\\s]+.*$"]!
    }

    /// Remove trailing whitespace characters
    ///
    /// - returns: String without trailing whitespace
    public func rstrip() -> String {
        return self["^.*[^\\s]+"]!
    }

    /// Remove leading and trailing whitespace characters
    ///
    /// - returns: String without leading or trailing whitespace
    public func strip() -> String {
        return self.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
    }

    /// Split string into array of 'words'
    ///
    /// - returns: array of strings
    func words() -> [String] {
        let hasComplexWordRegex = try! NSRegularExpression(pattern: RegexHelper.hasComplexWord, options: [])
        let wordRange = NSMakeRange(0, self.characters.count)
        let hasComplexWord = hasComplexWordRegex.rangeOfFirstMatchInString(self, options: [], range: wordRange)
        let wordPattern = hasComplexWord.length > 0 ? RegexHelper.complexWord : RegexHelper.basicWord
        let wordRegex = try! NSRegularExpression(pattern: wordPattern, options: [])
        let matches = wordRegex.matchesInString(self, options: [], range: wordRange)
        let words = matches.map { (result: NSTextCheckingResult) -> String in
            if let range = self.rangeFromNSRange(result.range) {
                return self.substringWithRange(range)
            } else {
                return ""
            }
        }
        return words
    }

    /// Strip string of accents and diacritics
    ///
    /// - returns: New string
    func deburr() -> String {
        let mutString = NSMutableString(string: self)
        CFStringTransform(mutString, nil, kCFStringTransformStripCombiningMarks, false)
        return mutString as String
    }

    /// Converts an NSRange to a Swift friendly Range supporting Unicode
    ///
    /// - parameter nsRange: the NSRange to be converted
    /// - returns: A corresponding Range if possible
    func rangeFromNSRange(nsRange: NSRange) -> Range<String.Index>? {
        let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
        let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
        if let from = String.Index(from16, within: self) {
            if let to = String.Index(to16, within: self) {
                return from..<to
            }
        }
        return .None
    }

}

public extension Character {

    /// Get int representation of character
    ///
    /// - returns: UInt32 that represents the given character
    public var ord: UInt32 {
        get {
            let desc = self.description
            return desc.unicodeScalars[desc.unicodeScalars.startIndex].value
        }
    }

    /// Convert character to string
    ///
    /// - returns: String representation of character
    public var description: String {
        get {
            return String(self)
        }
    }
}

infix operator =~ {}

/// Regex match the string on the left with the string pattern on the right
///
/// - parameter str: String to test
/// - parameter pattern: Pattern to match
/// - returns: true if string matches the pattern otherwise false
public func=~(str: String, pattern: String) -> Bool {
    return Regex(pattern).test(str)
}

/// Concat the string to itself n times
///
/// - parameter str: String to test
/// - parameter num: Number of times to concat string
/// - returns: concatenated string
public func*(str: String, num: Int) -> String {
    var stringBuilder = [String]()
    num.times {
        stringBuilder.append(str)
    }
    return stringBuilder.joinWithSeparator("")
}
