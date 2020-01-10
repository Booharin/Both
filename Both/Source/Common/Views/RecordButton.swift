//
//  RecordButton.swift
//  Both
//
//  Created by Alexandr Booharin on 10/01/2020.
//  Copyright © 2020 Alexandr Booharin. All rights reserved.
//

import UIKit

final class RecordButton: UIView {
    
    private var recordView = UIView()
    private let animateDuration = 0.2

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 35
        backgroundColor = .white
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        let roundView = UIView()
        roundView.backgroundColor = .black
        roundView.layer.cornerRadius = 30
        self.addSubview(roundView)
        roundView.snp.makeConstraints() {
            $0.width.height.equalTo(60)
            $0.center.equalToSuperview()
        }
        
        roundView.addSubview(recordView)
        recordView.layer.cornerRadius = 28
        recordView.backgroundColor = Colors.recordButton
        recordView.snp.makeConstraints() {
            $0.width.height.equalTo(56)
            $0.center.equalToSuperview()
        }
    }
    
    func updateButton(_ record: Bool) {
        if record {
            recordView.snp.updateConstraints() {
                $0.width.height.equalTo(30)
            }
            UIView.animate(withDuration: animateDuration, animations: {
                self.recordView.layer.cornerRadius = 4
                self.layoutIfNeeded()
            })
        } else {
            recordView.snp.updateConstraints() {
                $0.width.height.equalTo(56)
            }
            UIView.animate(withDuration: animateDuration, animations: {
                self.recordView.layer.cornerRadius = 28
                self.layoutIfNeeded()
            })
        }
    }
}
