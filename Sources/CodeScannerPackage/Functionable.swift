//
//  Functionable.swift
//  
//
//  Created by vinodh kumar on 10/05/23.
//

import Foundation

protocol Functionable {
    associatedtype ERawValue
    func callAsFunction() -> ERawValue
}

extension Functionable where Self: RawRepresentable {
    func callAsFunction() -> Self.RawValue {
        return rawValue
    }
}
