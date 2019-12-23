//
//  AppDelegateViewModel.swift
//  Both
//
//  Created by Alexandr Booharin on 22/12/2019.
//  Copyright © 2019 Alexandr Booharin. All rights reserved.
//

protocol AppDelegateViewModelProtocol {
    func didLaunch()
}

final class AppDelegateViewModel: AppDelegateViewModelProtocol {
    private let router: AppDelegateRouter
    
    init(router: AppDelegateRouter) {
        self.router = router
    }
    
    func didLaunch() {
        router.showMain()
    }
}
