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

func _testTokens(_ input: String, _ expected: [String], file: StaticString = #file, line: UInt = #line) throws {
  try XCTAssertEqual(input.tokenized(), expected, file: file, line: line)
}

extension StringTokenizedTests {
  func testTokensSimple() throws {
    try _testTokens(#""#, [])
    try _testTokens(#"     "#, [])
    try _testTokens(#"one"#, ["one"])
    try _testTokens(#"      one      "#, ["one"])
    try _testTokens(#"one two three"#, ["one", "two", "three"])
    try _testTokens(#"   one two     three"#, ["one", "two", "three"])
    try _testTokens(#"one two     three      "#, ["one", "two", "three"])
    try _testTokens(#"one\ two three"#, ["one two", "three"])
    try _testTokens(#"one two \  three"#, ["one", "two", " ", "three"])
    try _testTokens(#"one \ \ two three\ \ "#, ["one", "  two", "three  "])
  }
  
  func testTokensSingleQuotes() throws {
    try _testTokens(#"one two 'three four'"#, ["one", "two", "three four"])
    try _testTokens(#"one two 'three    four'"#, ["one", "two", "three    four"])
    try _testTokens(#"one two \'three four"#, ["one", "two", #"'three"#, "four"])
    try _testTokens(#"one two '\'three four'"#, ["one", "two", #"\'three four"#])
    try _testTokens(#"one two 'three  "  four'"#, ["one", "two", #"three  "  four"#])
    try _testTokens(#"one two three'  "  'four"#, ["one", "two", #"three  "  four"#])
    try _testTokens(#"one two thr'ee  "  fo'ur"#, ["one", "two", #"three  "  four"#])
  }
  
  func testTokensDoubleQuotes() throws {
    try _testTokens(#"one two "three four""#, ["one", "two", "three four"])
    try _testTokens(#"one two "three    four""#, ["one", "two", "three    four"])
    try _testTokens(#"one two \"three four"#, ["one", "two", #""three"#, "four"])
    try _testTokens(#"one two "\"three four""#, ["one", "two", #"\"three four"#])
    try _testTokens(#"one two "three  '  four""#, ["one", "two", #"three  '  four"#])
    try _testTokens(#"one two three"  '  "four"#, ["one", "two", #"three  '  four"#])
    try _testTokens(#"one two thr"ee  '  fo"ur"#, ["one", "two", #"three  '  four"#])
  }
  
  func testTokensEscapes() throws {
    try _testTokens(#"one \a three"#, ["one", #"\a"#, "three"])
  }

  func testTokenizedFails() {
    // Unterminated quotes
    XCTAssertThrowsError(try #"one two "three"#.tokenized())
    XCTAssertThrowsError(try #"one two 'three"#.tokenized())
    // Backslash in last position
    XCTAssertThrowsError(try #"one two three\"#.tokenized())
  }
}
