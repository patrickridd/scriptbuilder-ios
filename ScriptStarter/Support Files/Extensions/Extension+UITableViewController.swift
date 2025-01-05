//
//  Extension+UITableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/12/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

extension UITableViewController: @preconcurrency ResizeCellProtocol {
    
    @MainActor
    func resizeCell(in section: Int) {
        // Reload section tapped
        Task {
            self.tableView.performBatchUpdates(nil, completion: nil)
        }
    }

}

protocol ResizeCellProtocol: class {
    func resizeCell(in section: Int)
}

