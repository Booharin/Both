//
//  String+localization.swift
//  Both
//
//  Created by Alexandr Booharin on 08/01/2020.
//  Copyright © 2020 Alexandr Booharin. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self,
                                 tableName: nil,
                                 bundle: Bundle.main,
                                 value: "",
                                 comment: "")
    }
}
