//
//  Dependency.swift
//  KoCo
//
//  Created by 하연주 on 2/25/25.
//

import Foundation

@propertyWrapper
struct Dependency<T> {
    private var type: T.Type
    
    public var wrappedValue: T {
        DIContainer.resolve(type: type)
    }
    
    public init(_ type: T.Type) {
        self.type = type
    }
}
