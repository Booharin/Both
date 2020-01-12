//
//  MainRouter.swift
//  Both
//
//  Created by Alexandr Booharin on 08/01/2020.
//  Copyright © 2020 Alexandr Booharin. All rights reserved.
//
import UIKit

final class MainRouter {
    unowned var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        window.makeKeyAndVisible()
    }
}
