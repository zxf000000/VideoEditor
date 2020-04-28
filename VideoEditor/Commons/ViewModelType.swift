//
//  ViewModelType.swift
//  HealthInnovationTech
//
//  Copyright © 2020 YJKJ. All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}
