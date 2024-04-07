//
//  ActBeatSectionHeader.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/8/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class ActBeatSectionHeader: UITableViewHeaderFooterView {
    
    var titleLabel = UILabel()
    var infoButton = UIButton()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    func setupViews() {
        setupTitleLabel()
        setupInfoButton()
    }
    
    func setupTitleLabel() {
        self.addSubview(titleLabel)
        let marginGuide = contentView.layoutMarginsGuide

        let font = UIFont.systemFont(ofSize: 18,
                                     weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor,
                                            constant:0).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor,
                                           constant: 10).isActive = true
        titleLabel.textColor = Theme.navTitleColor
        titleLabel.font = font
    }
    
    func setupInfoButton() {
        // moreButton
        contentView.addSubview(infoButton)
        
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor,
                                            constant: 5).isActive = true
        infoButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        infoButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000),
                                                           for: .horizontal)
        infoButton.contentMode = .scaleAspectFill
        infoButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        infoButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        let image = UIImage(named: "blueInfoButtonAsset 1")
        infoButton.setImage(image,
                            for: .normal)
    }

}
