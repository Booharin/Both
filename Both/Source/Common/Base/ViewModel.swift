//
//  ViewModel.swift
//  Both
//
//  Created by Alexandr Booharin on 08/01/2020.
//  Copyright © 2020 Alexandr Booharin. All rights reserved.
//
import Foundation

protocol ViewModel {
    associatedtype ViewType
    mutating func assosiateView(_ view:  ViewType?)
    func viewDidSet()
    func removeBindings()
    
    var view: ViewType! {get set}
}

extension ViewModel {
    mutating func assosiateView(_ view:  ViewType?) {
        guard let view = view else {
            removeBindings()
            return
        }
        removeBindings()
        self.view = view
        viewDidSet()
    }
}
