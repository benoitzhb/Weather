//
//  GenericFactory.swift
//  Weather
//
//  Created by Ted Zhang on 6/6/23.
//

protocol GenericFactory {
    associatedtype Input
    associatedtype Output
            static func build(_ config: Input) -> Output
}
