//
//  DescriptionTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/23/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class DescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!
    @IBOutlet weak var expandButton: UIButton!
    
    var screenplay: Screenplay? {
        return ScreenplayController.shared.currentScreenplay
    }
    
    var section: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descriptionTextView.textColor = UIColor.screenDarkGray
        descriptionTextView.placeholderColor = UIColor.flamenco
       
        descriptionTextView.delegate = self
        addToolBar(textView: descriptionTextView)
    }

    func update(section: Int) {
        
        self.section = section
        switch section {
        case 0: // Log line
            self.descriptionTextView.placeholder = "About a robot lizard who..."
            self.descriptionTextView.text = screenplay?.logLine
            self.imageView?.heroID = "About a robot lizard who..."
        case 1: // Act 1
            self.descriptionTextView.placeholder = "Setup"
            self.descriptionTextView.text = screenplay?.actOne
            self.imageView?.heroID = "Setup"

        case 2: // Act 2
            self.descriptionTextView.placeholder = "Confrontation"
            self.descriptionTextView.text = screenplay?.actTwo
            self.imageView?.heroID = "Confrontation"

        case 3: // Act 3
            self.descriptionTextView.placeholder = "Resolution"
            self.descriptionTextView.text = screenplay?.actThree
            self.imageView?.heroID = "Resolution"

        default:
            break
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        switch section {
        case 0:
            screenplay?.logLine = textView.text
        case 1:
            screenplay?.actOne = textView.text
        case 2:
            screenplay?.actTwo = textView.text
        case 3:
            screenplay?.actThree = textView.text
        default:
            break
        }
    }
    
}
