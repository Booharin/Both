//
//  LaunchViewController.swift
//  Both
//
//  Created by Alexandr Booharin on 08/01/2020.
//  Copyright © 2020 Alexandr Booharin. All rights reserved.
//

import UIKit
import SnapKit

class LaunchViewController: UIViewController {
    
    private var labelView = UIView()
    private var label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        addViews()
    }
    
    private func addViews() {
        self.view.addSubview(labelView)
        labelView.layer.cornerRadius = 15
        labelView.backgroundColor = Colors.launchLabelBackground
        labelView.snp.makeConstraints() {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        labelView.addSubview(label)
        label.snp.makeConstraints() {
            $0.centerY.equalToSuperview().offset(-1)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        let attributedString = NSMutableAttributedString(string: "launch.label.title".localized,
                                                  attributes: [
                                                    NSAttributedString.Key.foregroundColor: UIColor.white,
                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .medium)
        ])
        
        let additionalAttributedString = NSAttributedString(string: " \("launch.label.subTitle".localized)",
                                                  attributes: [
                                                    NSAttributedString.Key.foregroundColor: Colors.launchLabelAddingFont,
                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .medium)
        ])
        
        attributedString.append(additionalAttributedString)
        label.attributedText = attributedString
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "record_ring_icn"))
        self.view.addSubview(imageView)
        imageView.snp.makeConstraints() {
            $0.width.height.equalTo(74)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-14)
            $0.centerX.equalToSuperview()
        }
    }
}
