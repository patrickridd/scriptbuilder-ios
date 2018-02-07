//
//  ExpandableTableViewSection.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/6/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

struct ExpandableTableViewSection {
    var sectionTitle: String
    var collapsed: Bool
    
    init(sectionTitle: String, collapsed: Bool = true) {
        self.sectionTitle = sectionTitle
        self.collapsed = collapsed
    }
}
