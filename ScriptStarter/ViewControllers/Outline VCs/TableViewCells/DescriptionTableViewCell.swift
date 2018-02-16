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

    weak var delegate: ResizeCellProtocol?
    var isResizing: Bool = false
    var defaultHeight: CGFloat = 0
    
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!
    @IBOutlet weak var expandButton: UIButton!
    
    var screenplay: Screenplay? {
        return ScreenplayController.shared.currentScreenplay
    }
    
    var section: Int = 0
    var viewController: ViewController = .outline
    var act: Act?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descriptionTextView.textColor = UIColor.screenDarkGray
        descriptionTextView.placeholderColor = UIColor.flamenco
        let font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionTextView.font = font
        descriptionTextView.delegate = self
        addToolBar(textView: descriptionTextView)
    }

    func update(viewController: ViewController, section: Int, act: Act?) {
        self.section = section
        self.viewController = viewController
        
        // Set act for textViewDidChange
        if let act = act {
            self.act = act
        }
        
        switch viewController {
        case .outline:
            switch section {
            case 0: // Log line
                self.descriptionTextView.placeholder = "••••"
                self.descriptionTextView.text = screenplay?.logLine
            case 1: // Act 1
                self.descriptionTextView.placeholder = "Setup"
                self.descriptionTextView.text = screenplay?.actOneDescription
                
            case 2: // Act 2
                self.descriptionTextView.placeholder = "Confrontation"
                self.descriptionTextView.text = screenplay?.actTwoDescription
                
            case 3: // Act 3
                self.descriptionTextView.placeholder = "Resolution"
                self.descriptionTextView.text = screenplay?.actThreeDescription

            default:
                break
            }
            
        case .actDetail:
            guard let act = act else { break }
            switch act {
            case .idea:
                switch section {
                case 0:
                    descriptionTextView.text = screenplay?.idea
                case 1:
                    descriptionTextView.text = screenplay?.logLine
                case 2:
                    descriptionTextView.text = screenplay?.centralIntention
                case 3:
                     descriptionTextView.text = screenplay?.mainObstacle
                case 4:
                     descriptionTextView.text = screenplay?.theme
                case 5:
                    descriptionTextView.text = screenplay?.notes
                default:
                    break
                }
            case .one:
                switch section {
                case 0:
                    descriptionTextView.text = screenplay?.actOneDescription
                case 2:
                    descriptionTextView.text = screenplay?.act1.oldWorldDescription
                case 3:
                    descriptionTextView.text = screenplay?.act1.incitingIncident
                case 4:
                    descriptionTextView.text = screenplay?.act1.callToAdventure
                case 5:
                    descriptionTextView.text = screenplay?.act1.theme
                case 6:
                    descriptionTextView.text = screenplay?.act1.refusal
                case 7:
                    descriptionTextView.text = screenplay?.act1.reasonToAdventure
                case 8:
                    descriptionTextView.text = screenplay?.act1.enemyAtTheGates
                default:
                    break
                }
                if section == 0 {
                    descriptionTextView.placeholder = act.placeholders[section]
                }  else {
                    descriptionTextView.placeholder = act.placeholders[section-1]
                }

            case .two:
                switch section {
                case 0:
                    descriptionTextView.text = screenplay?.actTwoDescription
                case 2:
                    descriptionTextView.text = screenplay?.act2.newWorldDescription
                case 3:
                    descriptionTextView.text = screenplay?.act2.enemiesFriends
                case 4:
                    descriptionTextView.text = screenplay?.act2.obstacles
                case 5:
                    descriptionTextView.text = screenplay?.act2.theDeadlyEncounter
                case 6:
                    descriptionTextView.text = screenplay?.act2.celebrate
                case 7:
                    descriptionTextView.text = screenplay?.act2.stormGathers
                case 8:
                    descriptionTextView.text = screenplay?.act2.badGuysStrikeBack
                case 9:
                    descriptionTextView.text = screenplay?.act2.allIsLost
                default:
                    break
                }
            case .three:
                switch section {
                case 0:
                    descriptionTextView.text = screenplay?.actThreeDescription
                case 2:
                    descriptionTextView.text = screenplay?.act3.theUltimateAnswer
                case 3:
                    descriptionTextView.text = screenplay?.act3.rewards
                case 4:
                    descriptionTextView.text = screenplay?.act3.untangleStory
                default:
                    break
                }
            }
        case .characterDetail:
            switch section {
            case 0:
                break
            default:
                break
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
      // checkForResize(textView: textView)
        
        switch viewController {
        case .outline:
            switch section {
            case 0:
                screenplay?.logLine = textView.text
            case 1:
                screenplay?.actOneDescription = textView.text
            case 2:
                screenplay?.actTwoDescription = textView.text
            case 3:
                screenplay?.actThreeDescription = textView.text
            default:
                break
            }
        case .actDetail:
            guard let act = self.act else { break }
            switch act {
            case .idea:
                switch section {
                case 0:
                    screenplay?.idea = textView.text
                case 1:
                    screenplay?.logLine = textView.text
                case 2:
                    screenplay?.centralIntention = textView.text
                case 3:
                    screenplay?.mainObstacle = textView.text
                case 4:
                    screenplay?.theme = textView.text
                case 5:
                    screenplay?.notes = textView.text
                default:
                    break
                }
            case .one:
                switch section {
                case 0:
                    screenplay?.actOneDescription = textView.text
                case 2:
                    screenplay?.act1.oldWorldDescription = textView.text
                case 3:
                    screenplay?.act1.incitingIncident = textView.text
                case 4:
                    screenplay?.act1.callToAdventure = textView.text
                case 5:
                    screenplay?.act1.theme = textView.text
                case 6:
                    screenplay?.act1.refusal = textView.text
                case 7:
                    screenplay?.act1.reasonToAdventure = textView.text
                case 8:
                    screenplay?.act1.enemyAtTheGates = textView.text
                default:
                    break
                }
                
            case .two:
                switch section {
                case 0:
                    screenplay?.actTwoDescription = textView.text
                case 2:
                    screenplay?.act2.newWorldDescription = textView.text
                case 3:
                    screenplay?.act2.enemiesFriends = textView.text
                case 4:
                    screenplay?.act2.obstacles = textView.text
                case 5:
                    screenplay?.act2.theDeadlyEncounter = textView.text
                case 6:
                    screenplay?.act2.celebrate = textView.text
                case 7:
                    screenplay?.act2.stormGathers = textView.text
                case 8:
                    screenplay?.act2.badGuysStrikeBack = textView.text
                case 9:
                    screenplay?.act2.allIsLost = textView.text
                default:
                    break
                }
            case .three:
                switch section {
                case 0:
                    screenplay?.actThreeDescription = textView.text
                case 2:
                    screenplay?.act3.theUltimateAnswer = textView.text
                case 3:
                    screenplay?.act3.rewards = textView.text
                case 4:
                    screenplay?.act3.untangleStory = textView.text
                default:
                    break
                }
            }
        case .characterDetail:
            switch section {
            case 0:
                
                break
            default:
                break
            }
        }
    }
    
    func checkForResize(textView:UITextView) {
        // Get descriptionTextView size that fits in view
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
      delegate?.resizeCell(in: self.section)
//        // Dynamically set descriptionTextView Height to that that fits in cell
//        if size.height > self.contentView.frame.height ||
//            size.height+50 < self.contentView.frame.height, size.height > defaultHeight {
//            delegate?.resizeCell(in: self.section)
//        } else {
//
//        }
    }

//    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//        if isResizing {
//            return false
//        } else {
//            return true
//        }
//    }
}
