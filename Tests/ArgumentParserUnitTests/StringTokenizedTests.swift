//===----------------------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Argument Parser open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import ArgumentParser

final class StringTokenizedTests: XCTestCase {}

func _testTokens(_ input: [String], _ expected: [String], file: StaticString = #file, line: UInt = #line) {
  var input: Array = input.reversed()
  let result = readTokens {
    input.popLast()
  }
  XCTAssertEqual(result, expected, file: file, line: line)
}

func _testTokens(_ input: String, _ expected: [String], file: StaticString = #file, line: UInt = #line) {
  _testTokens([input], expected, file: file, line: line)
}

extension StringTokenizedTests {
  func testTokensSimple() throws {
    _testTokens(#""#, [])
    _testTokens(#"     "#, [])
    _testTokens(#"one"#, ["one"])
    _testTokens(#"      one      "#, ["one"])
    _testTokens(#"one two three"#, ["one", "two", "three"])
    _testTokens(#"   one two     three"#, ["one", "two", "three"])
    _testTokens(#"one two     three      "#, ["one", "two", "three"])
    _testTokens(#"one\ two three"#, ["one two", "three"])
    _testTokens(#"one two \  three"#, ["one", "two", " ", "three"])
    _testTokens(#"one \ \ two three\ \ "#, ["one", "  two", "three  "])
  }
  
  func testTokensSingleQuotes() throws {
    _testTokens(#"one two 'three four'"#, ["one", "two", "three four"])
    _testTokens(#"one two 'three    four'"#, ["one", "two", "three    four"])
    _testTokens(#"one two \'three four"#, ["one", "two", #"'three"#, "four"])
    _testTokens(#"one two '\'three four'"#, ["one", "two", #"'three four"#])
    _testTokens(#"one two '\"three four'"#, ["one", "two", #"\"three four"#])
    _testTokens(#"one two 'three  "  four'"#, ["one", "two", #"three  "  four"#])
    _testTokens(#"one two three'  "  'four"#, ["one", "two", #"three  "  four"#])
    _testTokens(#"one two thr'ee  "  fo'ur"#, ["one", "two", #"three  "  four"#])
  }
  
  func testTokensDoubleQuotes() throws {
    _testTokens(#"one two "three four""#, ["one", "two", "three four"])
    _testTokens(#"one two "three    four""#, ["one", "two", "three    four"])
    _testTokens(#"one two \"three four"#, ["one", "two", #""three"#, "four"])
    _testTokens(#"one two "\"three four""#, ["one", "two", #""three four"#])
    _testTokens(#"one two "\'three four""#, ["one", "two", #"\'three four"#])
    _testTokens(#"one two "three  '  four""#, ["one", "two", #"three  '  four"#])
    _testTokens(#"one two three"  '  "four"#, ["one", "two", #"three  '  four"#])
    _testTokens(#"one two thr"ee  '  fo"ur"#, ["one", "two", #"three  '  four"#])
  }
  
  func testTokensEscapes() throws {
    _testTokens(#"one \a three"#, ["one", #"\a"#, "three"])
  }
  
  func testMultipleLines() throws {
    
  }

  func testTokenizedEdgeCases() throws {
    // Unterminated quotes
    _testTokens(#"one two "three"#, ["one", "two", "three"])
    _testTokens(#"one two 'three"#, ["one", "two", "three"])
    // Backslash in last position
    _testTokens(#"one two three\"#, ["one", "two", "three"])
  }
}
