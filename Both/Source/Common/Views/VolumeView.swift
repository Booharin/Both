//
//  VolumeView.swift
//  Both
//
//  Created by Alexandr Booharin on 12/01/2020.
//  Copyright © 2020 Alexandr Booharin. All rights reserved.
//

import UIKit

final class VolumeView: UIView {
    var backProgressView: VolumeProgressView
    var frontProgressView: VolumeProgressView
    
    override init(frame: CGRect) {
        backProgressView = VolumeProgressView(progressViewStyle: .bar)
        frontProgressView = VolumeProgressView(progressViewStyle: .bar)
        super.init(frame: frame)
        
        self.addSubviews([backProgressView, frontProgressView])
        
        backProgressView.snp.makeConstraints() {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(10)
        }
        
        frontProgressView.snp.makeConstraints() {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
