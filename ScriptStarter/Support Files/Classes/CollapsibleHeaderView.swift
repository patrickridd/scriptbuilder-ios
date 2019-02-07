//
//  CollapsibleHeaderView.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/5/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

protocol CollapsibleHeaderDelegate {
  
    var expandableSections: [ExpandableTableViewSection] { get set }
    func toggleSection(_ header: CollapsibleHeader, section: Int)
    func setupExpandableSections()
}

class CollapsibleHeader: UITableViewHeaderFooterView {
    
    var delegate: CollapsibleHeaderDelegate?
    var section: Int = 0
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let plusButtonLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupPlusButtonLabel()
        setupTitleLabel()
        setupSubtitleLabel()
        addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                    action: #selector(CollapsibleHeader.tapHeader(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTitleLabel() {
        // Title label
        contentView.addSubview(titleLabel)
        let font = UIFont.systemFont(ofSize: 14,
                                     weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor,
                                        constant: 10).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: plusButtonLabel.trailingAnchor,
                                            constant: 10).isActive = true
        titleLabel.font = font
    }
    
    func setupSubtitleLabel() {
        contentView.addSubview(subtitleLabel)
        let font = UIFont.systemFont(ofSize: 12,
                                     weight: .light)
        subtitleLabel.font = font
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                constant: -5).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor,
                                           constant: 0).isActive = true
    }
    
    func setupPlusButtonLabel() {
        // Plus button label
        contentView.addSubview(plusButtonLabel)
        plusButtonLabel.translatesAutoresizingMaskIntoConstraints = false
        let marginGuide = contentView.layoutMarginsGuide
        plusButtonLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor,
                                                 constant: 0).isActive = true
        plusButtonLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor,
                                                 constant: 0).isActive = true
        plusButtonLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000),
                                                                for: .horizontal)
        let font = UIFont.systemFont(ofSize: 24,
                                     weight: .semibold)
        plusButtonLabel.font = font
        plusButtonLabel.textColor = .screenLightBlue
        plusButtonLabel.text = "+"
        
        plusButtonLabel.contentMode = .scaleAspectFill
    }
    
    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? CollapsibleHeader else {
            return
        }
        delegate?.toggleSection(self,
                                section: cell.section)
    }
    
    func setCollapsed(_ collapsed: Bool) {
        plusButtonLabel.text = collapsed ? "+".localized : "-".localized
    }
}
