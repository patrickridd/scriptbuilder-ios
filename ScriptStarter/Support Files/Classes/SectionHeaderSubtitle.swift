//
//  SectionHeaderSubtitle.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/9/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class SectionHeaderSubtitle: UITableViewHeaderFooterView {
   
    var sectionLabel = UILabel()
    var subtitleLabel = UILabel()
    
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
        setupSubtitleLabel()
    }
    
    func setupSectionLabel() {
        self.addSubview(sectionLabel)
        let font = UIFont.systemFont(ofSize: 18,
                                     weight: .semibold)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                              constant: 20).isActive = true
        sectionLabel.bottomAnchor.constraint(equalTo: self.centerYAnchor,
                                             constant: 0).isActive = true
        sectionLabel.textColor = UIColor.screenDark
        sectionLabel.font = font
    }
    
    func setupSubtitleLabel() {
        contentView.addSubview(subtitleLabel)
        let font = UIFont.systemFont(ofSize: 12, weight: .light)
        subtitleLabel.font = font
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.leadingAnchor.constraint(equalTo: self.sectionLabel.leadingAnchor).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                constant: -5).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: self.sectionLabel.bottomAnchor,
                                           constant: 0).isActive = true
    }
}
