//
//  SectionHeaderView.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/29/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class SectionHeaderView: UITableViewHeaderFooterView {

    var sectionLabel = UILabel()
    var subtitleLabel = UILabel()
    var expandButton = UIButton()
    var moreButton = UIButton()
    var navigationButton = UIButton()
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
     
    */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    func setupViews() {
       // self.backgroundColor = UIColor.screenLightGray
        setupSectionLabel()
        setupMoreButton()
        setupNavigationButton()
        setupSubtitleLabel()
    }
    
    func setupSectionLabel() {
        self.addSubview(sectionLabel)
        let font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                               constant: 15).isActive = true
        sectionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                              constant: 20).isActive = true
        sectionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor,
                                              constant: 0).isActive = true
        sectionLabel.textColor = UIColor.screenDark
        sectionLabel.font = font
        sectionLabel.numberOfLines = 0
    }
    
    func setupSubtitleLabel() {
        contentView.addSubview(subtitleLabel)
        let font = UIFont.systemFont(ofSize: 12,
                                     weight: .light)
        subtitleLabel.font = font
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.leadingAnchor.constraint(equalTo: self.sectionLabel.leadingAnchor).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                constant: -5).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: self.sectionLabel.bottomAnchor,
                                           constant: 0).isActive = true
    }
    
    func setupMoreButton() {
        // moreButton
        contentView.addSubview(moreButton)
        
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.leadingAnchor.constraint(equalTo: self.sectionLabel.trailingAnchor,
                                            constant: 0).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        moreButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000),
                                                           for: .horizontal)
        moreButton.contentMode = .scaleAspectFill
        moreButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        moreButton.setImage(#imageLiteral(resourceName: "rightArrowButtonAsset 1"),
                            for: .normal)
    }
    
    func setupNavigationButton() {
        // navigationButton
        contentView.addSubview(navigationButton)
        
        navigationButton.translatesAutoresizingMaskIntoConstraints = false
        navigationButton.leadingAnchor.constraint(equalTo: self.sectionLabel.leadingAnchor,
                                                  constant: 0).isActive = true
         navigationButton.topAnchor.constraint(equalTo: self.moreButton.topAnchor,
                                               constant: 0).isActive = true
         navigationButton.bottomAnchor.constraint(equalTo: self.moreButton.bottomAnchor,
                                                  constant: 0).isActive = true
         navigationButton.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                    constant: 0).isActive = true
        navigationButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        navigationButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000),
                                                                 for: .horizontal)
        navigationButton.contentMode = .scaleAspectFill
        moreButton.setImage(#imageLiteral(resourceName: "rightArrowButtonAsset 1"),
                            for: .normal)
    }

}
