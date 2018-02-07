//
//  CollapsibleHeaderView.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/5/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

protocol CollapsibleHeaderDelegate {
    func toggleSection(_ header: CollapsibleHeader, section: Int)
}

class CollapsibleHeader: UITableViewHeaderFooterView {
    
    var delegate: CollapsibleHeaderDelegate?
    var section: Int = 0
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let arrowImageView = UIImageView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
       // setupNumberOfReviewsLabel()
        setuparrowImage()
        setupTitleLabel()
       // setupSubtitleLabel()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CollapsibleHeader.tapHeader(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTitleLabel() {
        // Title label
        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 1
        titleLabel.minimumScaleFactor = 0.1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let marginGuide = contentView.layoutMarginsGuide
        titleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -10.0).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.centerYAnchor,constant: 5).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
    }
    
    func setupSubtitleLabel() {
        contentView.addSubview(subtitleLabel)
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 0).isActive = true
    }
    
    func setuparrowImage() {
        // Arrow label
        contentView.addSubview(arrowImageView)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10).isActive = true
        arrowImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        arrowImageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        arrowImageView.contentMode = .scaleAspectFill
        arrowImageView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        arrowImageView.widthAnchor.constraint(equalToConstant: 5).isActive = true
    }
//
//    func setupNumberOfReviewsLabel() {
//        // NumberOfReviews label
//        contentView.addSubview(numberOfReviewsLabel)
//        numberOfReviewsLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
//        numberOfReviewsLabel.translatesAutoresizingMaskIntoConstraints = false
//        numberOfReviewsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
//        numberOfReviewsLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//    }
    
    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? CollapsibleHeader else {
            return
        }
        delegate?.toggleSection(self, section: cell.section)
    }
    
    func setCollapsed(_ collapsed: Bool) {
       // arrowImageView.image = collapsed ? #imageLiteral(resourceName: "collapsedTriangle") : #imageLiteral(resourceName: "expandedTriangle")
    }
}
