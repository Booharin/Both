//
//  ExceededCaptureSessionCosts.swift
//  Both
//
//  Created by Alexandr Booharin on 08/01/2020.
//  Copyright © 2020 Alexandr Booharin. All rights reserved.
//

struct ExceededCaptureSessionCosts: OptionSet {
    let rawValue: Int
    
    static let systemPressureCost = ExceededCaptureSessionCosts(rawValue: 1 << 0)
    static let hardwareCost = ExceededCaptureSessionCosts(rawValue: 1 << 1)
}
