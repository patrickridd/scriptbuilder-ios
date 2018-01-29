//
//  SectionHeaderView.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/29/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class SectionHeaderView: UIView {

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
    
//    override init(reuseIdentifier: String?) {
//        super.init(reuseIdentifier: reuseIdentifier)
//        setupViews()
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        self.backgroundColor = UIColor.screenLightGray
        setupSectionLabel()
    }
    
    func setupSectionLabel() {
        self.addSubview(sectionLabel)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        sectionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
    }

}
