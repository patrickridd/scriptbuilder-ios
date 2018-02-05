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
    var expandButton = UIButton()
    var moreButton = UIButton()
    
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
        self.backgroundColor = UIColor.screenLightGray
        setupSectionLabel()
        setupMoreButton()
    }
    
    func setupSectionLabel() {
        self.addSubview(sectionLabel)
        let font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        sectionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        sectionLabel.textColor = UIColor.screenDark
        sectionLabel.font = font
    }
    
    func setupMoreButton() {
        // moreButton
        contentView.addSubview(moreButton)
        moreButton.setTitle("→", for: .normal)
        moreButton.titleLabel?.textColor = UIColor.screenLightBlue
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.trailingAnchor.constraint(equalTo: sectionLabel.leadingAnchor, constant: -25).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        moreButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        moreButton.contentMode = .scaleAspectFill
        moreButton.heightAnchor.constraint(equalToConstant: 5).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: 5).isActive = true
    }

}
