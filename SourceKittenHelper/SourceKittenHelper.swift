//
//  SourceKittenHelper.swift
//  SourceKittenHelper
//
//  Created by Norio Nomura on 8/26/16.
//
//  Copyright (c) 2016 Norio Nomura
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import SourceKittenFramework

@objc class SourceKittenHelper: NSObject, SourceKittenHelperProtocol {
    @objc func allTestsExtensions(for contents: String, reply: @escaping SourceKittenHelperResultHandler) {
        let file = File(contents: contents)
        let structure = Structure(file: file)
        guard let substructure = structure.dictionary.substructure else {
            return reply(-1, "failed to analyze")
        }

        let testCases = substructure
            .filter { $0.isClass && $0.isInheritedXCTestCase }
            .flatMap { xctest -> TestCase? in
                let methods = xctest.instanceMethods
                    .filter { $0.isTestable }
                    .flatMap { $0.name }
                    .filter { $0.hasPrefix("test") && $0.hasSuffix("()") }
                    .map { String($0.dropLast(2)) }
                if !methods.isEmpty, let name = xctest.name {
                    return TestCase(name: name, tests: methods)
                } else {
                    return nil
                }
            }
        if testCases.isEmpty {
            reply(-1, "no test cases")
        } else {
            let extensions = testCases.map {
                $0.description
            }.joined(separator: "\n\n")
            reply(0, extensions)
        }
    }

    @objc func enumAvailabeExtensions(for contents: String, reply: @escaping  SourceKittenHelperResultHandler) {
        let file = File(contents: contents)
        let structure = Structure(file: file)
        guard let substructure = structure.dictionary.substructure else {
            return reply(-1, "failed to analyze")
        }

        let enums = substructure
            .filter { $0.isEnum }
            .flatMap { anEnum -> Enum? in
                let cases = anEnum.enumcases
                    .flatMap { $0.enumelements }
                    .flatMap { $0.name }
                if !cases.isEmpty, let name = anEnum.name {
                    return Enum(name: name, cases: cases)
                } else {
                    return nil
                }
        }
        if enums.isEmpty {
            reply(-1, "no enums")
        } else {
            let extensions = enums.map {
                $0.description
                }.joined(separator: "\n\n")
            reply(0, extensions)
        }
    }
}
