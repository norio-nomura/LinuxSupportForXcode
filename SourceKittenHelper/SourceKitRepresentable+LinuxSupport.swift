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
        return self[.kind] as? String
    }

    var isClass: Bool {
        return kind == SwiftDeclarationKind.class.rawValue
    }

    var isEnum: Bool {
        return kind == SwiftDeclarationKind.enum.rawValue
    }

    var isInstanceMethod: Bool {
        return kind == SwiftDeclarationKind.functionMethodInstance.rawValue
    }

    var isEnumcase: Bool {
        return kind == SwiftDeclarationKind.enumcase.rawValue
    }

    var isEnumelement: Bool {
        return kind == SwiftDeclarationKind.enumelement.rawValue
    }

    // name
    var name: String? {
        return self[.name] as? String
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
        if let array = self[.inheritedtypes] as? [SourceKitRepresentable] {
            var generator = array.makeIterator()
            let nameGenerator = AnyIterator { () -> String? in
                return generator.next()?.name
            }
            return AnySequence(nameGenerator)
        } else {
            return AnySequence(AnyIterator({nil}))
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
        return self[.substructure] as? [SourceKitRepresentable]
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
