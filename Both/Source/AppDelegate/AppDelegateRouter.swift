//
//  AppDelegateRouter.swift
//  Both
//
//  Created by Alexandr Booharin on 22/12/2019.
//  Copyright © 2019 Alexandr Booharin. All rights reserved.
//
import UIKit

final class AppDelegateRouter {
    
    private unowned var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func showMain() {
        let vc = MainViewController(viewModel: MainViewModel(router: MainRouter()))
        self.window.rootViewController = vc
    }
}
