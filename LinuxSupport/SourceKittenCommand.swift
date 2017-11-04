//
//  SourceKittenCommand.swift
//  LinuxSupport
//
//  Created by Norio Nomura on 8/27/16.
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
import XcodeKit

private let ServiceName = "io.github.norio-nomura.LinuxSupportForXcode.SourceKittenHelper"

extension SourceKittenCommand: InvocationHandler {
    func handle(invocation: XCSourceEditorCommandInvocation) throws -> Bool {
        switch invocation.commandIdentifier {
        case "io.github.norio-nomura.LinuxSupportForXcode.LinuxSupport.GenerateAllTests":
            try generateAllTests(for: invocation.buffer)
        case "io.github.norio-nomura.LinuxSupportForXcode.LinuxSupport.GenerateEnumAvailable":
            try generateEnumAvailabeFor(for: invocation.buffer)
        default:
            return false
        }
        return true
    }
}

class SourceKittenCommand {
    enum Error: Swift.Error {
        case error(String)
        case helperConnectionError
    }

    deinit {
        connection.invalidate()
    }

    fileprivate let connection = { () -> NSXPCConnection in
        let connection = NSXPCConnection(serviceName: ServiceName)
        connection.remoteObjectInterface = NSXPCInterface(with: SourceKittenHelperProtocol.self)
        return connection
    }()
}

// MARK: - generateAllTests
extension SourceKittenCommand {
    fileprivate func generateAllTests(for buffer: XCSourceTextBuffer) throws {
        let extensions = try allTestsExtensions(for: buffer.completeBuffer)

        // adjust tabs to buffer configurations
        let formatted: String
        if buffer.usesTabsForIndentation {
            formatted = extensions
        } else {
            let spaces = String(repeating: Character(" "), count: buffer.tabWidth)
            formatted = extensions.replacingOccurrences(of: "\t", with: spaces)
        }

        // add blank line before extensions
        buffer.lines.add("\n")

        // add extensions
        var start = formatted.startIndex, end = formatted.startIndex, contentsEnd = formatted.startIndex
        while start < formatted.endIndex {
            formatted.getLineStart(&start, end: &end, contentsEnd: &contentsEnd, for: start..<start)
            let newLine = formatted[start..<end]
            buffer.lines.add(newLine)
            start = end
        }
    }

    private func allTestsExtensions(for contents: String) throws -> String {
        connection.resume()
        defer { connection.suspend() }
        guard let helper = connection.remoteObjectProxy as? SourceKittenHelperProtocol else {
            print("Failt to connect: \(connection)")
            throw Error.helperConnectionError
        }

        let semaphore = DispatchSemaphore(value: 0)
        var (status, output) = (-1, "")
        helper.allTestsExtensions(for: contents) {
            (status, output) = ($0, $1)
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .now() + .seconds(10))

        if status != 0 {
            throw Error.error(output)
        }

        return output
    }
}

// MARK: - generateEnumAvailabe
extension SourceKittenCommand {
    fileprivate func generateEnumAvailabeFor(for buffer: XCSourceTextBuffer) throws {
        let extensions = try enumAvailabeExtensions(for: buffer.completeBuffer)

        // adjust tabs to buffer configurations
        let formatted: String
        if buffer.usesTabsForIndentation {
            formatted = extensions
        } else {
            let spaces = String(repeating: Character(" "), count: buffer.tabWidth)
            formatted = extensions.replacingOccurrences(of: "\t", with: spaces)
        }

        // add blank line before extensions
        buffer.lines.add("\n")

        // add extensions
        var start = formatted.startIndex, end = formatted.startIndex, contentsEnd = formatted.startIndex
        while start < formatted.endIndex {
            formatted.getLineStart(&start, end: &end, contentsEnd: &contentsEnd, for: start..<start)
            let newLine = formatted[start..<end]
            buffer.lines.add(newLine)
            start = end
        }
    }

    private func enumAvailabeExtensions(for contents: String) throws -> String {
        connection.resume()
        defer { connection.suspend() }
        guard let helper = connection.remoteObjectProxy as? SourceKittenHelperProtocol else {
            print("Failt to connect: \(connection)")
            throw Error.helperConnectionError
        }

        let semaphore = DispatchSemaphore(value: 0)
        var (status, output) = (-1, "")
        helper.enumAvailabeExtensions(for: contents) {
            (status, output) = ($0, $1)
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .now() + .seconds(10))

        if status != 0 {
            throw Error.error(output)
        }

        return output
    }
}
