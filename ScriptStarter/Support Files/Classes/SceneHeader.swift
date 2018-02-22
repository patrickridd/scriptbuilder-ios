//
//  SceneHeader.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class SceneHeader: UITableViewHeaderFooterView {
    
    var titleLabel = UILabel()
    var plusButton = UIButton()
    var plusButtonCover = UIButton()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    func setupViews() {
        setupTitleLabel()
        setupPlusButton()
        setupPlusButtonCover()
    }
    
    func setupTitleLabel() {
        self.addSubview(titleLabel)
        let marginGuide = contentView.layoutMarginsGuide
        
        let font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor, constant:0).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor, constant: 5).isActive = true
        titleLabel.textColor = UIColor.screenDark
        titleLabel.font = font
    }
    
    func setupPlusButton() {
        // plusButton
        contentView.addSubview(plusButton)
        
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 5).isActive = true
        plusButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        plusButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        plusButton.contentMode = .scaleAspectFill
        plusButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        plusButton.setImage(#imageLiteral(resourceName: "blueAddButtonAsset 1"), for: .normal)
        
    }
    
    func setupPlusButtonCover() {
        // plusButtonCover
        contentView.addSubview(plusButtonCover)
        
        plusButtonCover.translatesAutoresizingMaskIntoConstraints = false
        plusButtonCover.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor, constant:0 ).isActive = true
        plusButtonCover.topAnchor.constraint(equalTo: self.titleLabel.topAnchor, constant:0 ).isActive = true
        plusButtonCover.bottomAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant:0 ).isActive = true
        plusButtonCover.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant:0 ).isActive = true
    plusButtonCover.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
    }
}
