//
//  Image+Gradient.swift
//  Both
//
//  Created by Alexandr Booharin on 12/01/2020.
//  Copyright © 2020 Alexandr Booharin. All rights reserved.
//
import UIKit

extension UIImage {
    static func gradientImage(with bounds: CGRect,
                              colors: [CGColor]) -> UIImage? {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        // This makes it horizontal
        gradientLayer.startPoint = CGPoint(x: 0.0,
                                           y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0,
                                         y: 0.5)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }
}
