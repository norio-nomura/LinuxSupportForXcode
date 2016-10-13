//
//  SourceKitRepresentable+LinuxSupport.swift
//  SourceKittenHelper
//
//  Created by Norio Nomura on 8/27/16.
//  Copyright © 2016 Norio Nomura. All rights reserved.
//

import SourceKittenFramework

extension SourceKitRepresentable {
    var dictionary: [String: SourceKitRepresentable]? {
        return self as? [String: SourceKitRepresentable]
    }

    subscript(key: SwiftDocKey) -> SourceKitRepresentable? {
        return dictionary?[key.rawValue]
    }

    subscript(key: String) -> SourceKitRepresentable? {
        return dictionary?[key]
    }

    // kind
    var kind: String? {
        return self[.Kind] as? String
    }

    var isClass: Bool {
        return kind == SwiftDeclarationKind.Class.rawValue
    }

    var isEnum: Bool {
        return kind == SwiftDeclarationKind.Enum.rawValue
    }

    var isInstanceMethod: Bool {
        return kind == SwiftDeclarationKind.FunctionMethodInstance.rawValue
    }

    var isEnumcase: Bool {
        return kind == SwiftDeclarationKind.Enumcase.rawValue
    }

    var isEnumelement: Bool {
        return kind == SwiftDeclarationKind.Enumelement.rawValue
    }

    // name
    var name: String? {
        return self[.Name] as? String
    }

    // accessibility
    var accessibility: String? {
        return self["key.accessibility"] as? String
    }

    var isTestable: Bool {
        return !(accessibility?.hasSuffix("private") ?? false)
    }

    // inheritedTypes
    var inheritedTypes: AnySequence<String> {
        if let array = self[.Inheritedtypes] as? [SourceKitRepresentable] {
            var generator = array.generate()
            let nameGenerator = AnyGenerator() { () -> String? in
                return generator.next()?.name
            }
            return AnySequence(nameGenerator)
        } else {
            return AnySequence(AnyGenerator(body: {nil}))
        }
    }

    var isInheritedXCTestCase: Bool {
        for type in inheritedTypes where type == "XCTestCase" {
            return true
        }
        return false
    }

    // substructure
    var substructure: [SourceKitRepresentable]? {
        return self[.Substructure] as? [SourceKitRepresentable]
    }

    var instanceMethods: [SourceKitRepresentable] {
        return substructure?.filter({ $0.isInstanceMethod }) ?? []
    }

    var enumcases: [SourceKitRepresentable] {
        return substructure?.filter({ $0.isEnumcase }) ?? []
    }

    var enumelements: [SourceKitRepresentable] {
        return substructure?.filter({ $0.isEnumelement }) ?? []
    }
}
