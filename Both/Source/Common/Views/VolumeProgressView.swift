//
//  VolumeProgressView.swift
//  Both
//
//  Created by Alexandr Booharin on 12/01/2020.
//  Copyright © 2020 Alexandr Booharin. All rights reserved.
//

import UIKit

class VolumeProgressView: UIProgressView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let gradientImage = UIImage.gradientImage(with: self.frame,
                                                  colors: [#colorLiteral(red: 0, green: 1, blue: 0.09803921569, alpha: 1).cgColor,
                                                           #colorLiteral(red: 1, green: 0.9019607843, blue: 0, alpha: 1).cgColor])
        progressImage = gradientImage
        layer.cornerRadius = 5
        clipsToBounds = true
        
        guard
            let subLayer = layer.sublayers?[1],
            subviews.count > 1 else { return }
        subLayer.cornerRadius = 5
        subviews[1].clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
