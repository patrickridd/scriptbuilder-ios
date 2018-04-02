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
    @IBOutlet weak var descriptionTextViewHeightConstraint: NSLayoutConstraint!
    
    var screenplay: Screenplay? {
        return ScreenplayController.shared.currentScreenplay
    }
    
    var section: Int = 0
    var viewController: ViewController = .outline
    var act: Act?
    var character: Character?
    var scene: Scene?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descriptionTextView.textColor = UIColor.screenDarkGray
        descriptionTextView.placeholderColor = UIColor.flamenco
        let font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionTextView.font = font
        descriptionTextView.delegate = self
        addToolBar(textView: descriptionTextView)
        
       //self.descriptionTextView.textContainerInset = UIEdgeInsetsMake(5, 10, 5, 10);
    }

    func update(viewController: ViewController, section: Int, act: Act?, character: Character? = nil, scene: Scene? = nil) {
        self.section = section
        self.viewController = viewController
        
        // Set act for textViewDidChange
        if let act = act {
            self.act = act
        }
        
        // Set character
        if let character = character {
            self.character = character
        }
        
        // Set scene
        if let scene = scene {
            self.scene = scene
        }
        
        switch viewController {
        case .outline:
            switch section {
            case 0: // Idea
                self.descriptionTextView.placeholder = "About a ..."
                self.descriptionTextView.text = screenplay?.idea
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
                    descriptionTextView.placeholder = "About a ..."
                case 3:
                    descriptionTextView.text = screenplay?.logLine
                case 4:
                    descriptionTextView.text = screenplay?.centralIntention
                case 5:
                     descriptionTextView.text = screenplay?.mainObstacle
                case 6:
                     descriptionTextView.text = screenplay?.theme
                case 7:
                    descriptionTextView.text = screenplay?.notes
                default:
                    break
                }
            case .one:
                switch section {
                case 0:
                    descriptionTextView.text = screenplay?.actOneDescription
                case 3:
                    descriptionTextView.text = screenplay?.act1.oldWorldDescription
                case 4:
                    descriptionTextView.text = screenplay?.act1.incitingIncident
                case 5:
                    descriptionTextView.text = screenplay?.act1.callToAdventure
                case 6:
                    descriptionTextView.text = screenplay?.act1.theme
                case 7:
                    descriptionTextView.text = screenplay?.act1.refusal
                case 8:
                    descriptionTextView.text = screenplay?.act1.reasonToAdventure
                case 9:
                    descriptionTextView.text = screenplay?.act1.enemyAtTheGates
                default:
                    break
                }
                if section == 0 {
                    descriptionTextView.placeholder = act.placeholders[section]
                }  else {
                    descriptionTextView.placeholder = ""
                }

            case .two:
                switch section {
                case 0:
                    // General description
                    descriptionTextView.text = screenplay?.actTwoDescription
                case 3:
                     // Strange New World
                    descriptionTextView.text = screenplay?.act2.newWorldDescription
                case 4:
                    // Friends/Foes/Frenemies
                    descriptionTextView.text = screenplay?.act2.enemiesFriends
                case 5:
                    // Test Resolve
                    descriptionTextView.text = screenplay?.act2.obstacles
                case 6:
                    // Sharpening the sword
                    descriptionTextView.text = screenplay?.act2.sharpeningTheSword
                case 7:
                    // Burn the Boats
                    descriptionTextView.text =  screenplay?.act2.burnTheBoats
                case 8:
                    // Supreme Sacrifice
                    descriptionTextView.text = screenplay?.act2.theDeadlyEncounter
                case 9:
                      // Celebrate Good Times
                    descriptionTextView.text = screenplay?.act2.celebrate
                case 10:
                       // Bad Guys Strike back
                    descriptionTextView.text = screenplay?.act2.badGuysStrikeBack
                case 11:
                     // Darkness Before the Dawn
                    descriptionTextView.text = screenplay?.act2.allIsLost
                default:
                    break
                }
                if section == 0 {
                    descriptionTextView.placeholder = act.placeholders[section]
                }  else {
                    descriptionTextView.placeholder = ""
                }
            case .three:
                switch section {
                case 0:
                    descriptionTextView.text = screenplay?.actThreeDescription
                case 3:
                    descriptionTextView.text = screenplay?.act3.theUltimateAnswer
                case 4:
                    descriptionTextView.text = screenplay?.act3.rewards
                case 5:
                    descriptionTextView.text = screenplay?.act3.untangleStory
                case 6:
                    descriptionTextView.text =
                    screenplay?.act3.brandNewWorld
                default:
                    break
                }
                if section == 0 {
                    descriptionTextView.placeholder = act.placeholders[section]
                }  else {
                    descriptionTextView.placeholder = ""
                }
            }
        case .characterDetail:
            switch section {
            case 2:
                descriptionTextView.text = character?.intention
            case 3:
                descriptionTextView.text = character?.whyIntention
            case 4:
                descriptionTextView.text = character?.whatToDo
            case 5:
                descriptionTextView.text = character?.howDoesCharacterDoIt
            case 6:
                descriptionTextView.text = character?.obstacles
            case 7:
                descriptionTextView.text = character?.flaws
            case 8:
                descriptionTextView.text = character?.intentionFix
            case 9:
                descriptionTextView.text = character?.need
            case 10:
                descriptionTextView.text = character?.howCharacterChanged
            case 11:
                descriptionTextView.text = character?.notes
            default:
                break
            }
        case .sceneDetail:
            switch section {
            case 1:
                descriptionTextView.text = scene?.sceneDescription
            case 2:
                descriptionTextView.text = scene?.characters
            case 3:
                descriptionTextView.text = scene?.dialogue
            case 4:
                descriptionTextView.text = scene?.action
            case 5:
                descriptionTextView.text = scene?.howPushesStory
            case 6:
                descriptionTextView.text = scene?.notes
            default:
                break
            }
        }
        checkForResize(textView: self.descriptionTextView)

    }
    
    func textViewDidChange(_ textView: UITextView) {
        
      checkForResize(textView: textView)
        
        switch viewController {
        case .outline:
            switch section {
            case 0:
                screenplay?.idea = textView.text
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
                case 3:
                    screenplay?.logLine = textView.text
                case 4:
                    screenplay?.centralIntention = textView.text
                case 5:
                    screenplay?.mainObstacle = textView.text
                case 6:
                    screenplay?.theme = textView.text
                case 7:
                    screenplay?.notes = textView.text
                default:
                    break
                }
            case .one:
                switch section {
                case 0:
                    screenplay?.actOneDescription = textView.text
                case 3:
                    screenplay?.act1.oldWorldDescription = textView.text
                case 4:
                    screenplay?.act1.incitingIncident = textView.text
                case 5:
                    screenplay?.act1.callToAdventure = textView.text
                case 6:
                    screenplay?.act1.theme = textView.text
                case 7:
                    screenplay?.act1.refusal = textView.text
                case 8:
                    screenplay?.act1.reasonToAdventure = textView.text
                case 9:
                    screenplay?.act1.enemyAtTheGates = textView.text
                default:
                    break
                }
                
            case .two:
                switch section {
                    case 0:
                    // General description
                     screenplay?.actTwoDescription = descriptionTextView.text
                    case 3:
                    // Strange New World
                     screenplay?.act2.newWorldDescription = descriptionTextView.text
                    case 4:
                    // Friends/Foes/Frenemies
                     screenplay?.act2.enemiesFriends = descriptionTextView.text
                    case 5:
                    // Test Resolve
                     screenplay?.act2.obstacles = descriptionTextView.text
                    case 6:
                    // Sharpening the sword
                    screenplay?.act2.sharpeningTheSword = descriptionTextView.text
                    case 7:
                    // Burn the Boats
                    screenplay?.act2.burnTheBoats = descriptionTextView.text
                    case 8:
                    // Supreme Sacrifice
                    screenplay?.act2.theDeadlyEncounter = descriptionTextView.text
                    case 9:
                    // Celebrate Good Times
                     screenplay?.act2.celebrate = descriptionTextView.text
                    case 10:
                    // Bad Guys Strike back
                     screenplay?.act2.badGuysStrikeBack = descriptionTextView.text
                    case 11:
                    // Darkness Before the Dawn
                    screenplay?.act2.allIsLost = descriptionTextView.text
                    default:
                        break
                    }
            case .three:
                switch section {
                case 0:
                    screenplay?.actThreeDescription = textView.text
                case 3:
                    screenplay?.act3.theUltimateAnswer = textView.text
                case 4:
                    screenplay?.act3.rewards = textView.text
                case 5:
                    screenplay?.act3.untangleStory = textView.text
                case 6:
                    screenplay?.act3.brandNewWorld = textView.text
                default:
                    break
                }
            }
        case .characterDetail:
            switch section {
            case 2:
                character?.intention = descriptionTextView.text
            case 3:
                character?.whyIntention = descriptionTextView.text
            case 4:
                character?.whatToDo = descriptionTextView.text
            case 5:
                character?.howDoesCharacterDoIt = descriptionTextView.text
            case 6:
                character?.obstacles = descriptionTextView.text
            case 7:
                character?.flaws = descriptionTextView.text
            case 8:
                character?.intentionFix = descriptionTextView.text
            case 9:
                character?.need = descriptionTextView.text
            case 10:
                character?.howCharacterChanged = descriptionTextView.text
            case 11:
                character?.notes = descriptionTextView.text
            default:
                break
            }
        case .sceneDetail:
            switch section {
            case 1:
                scene?.sceneDescription = descriptionTextView.text
            case 2:
                scene?.characters = descriptionTextView.text
            case 3:
                scene?.dialogue = descriptionTextView.text
            case 4:
                scene?.action = descriptionTextView.text
            case 5:
                scene?.howPushesStory = descriptionTextView.text
            case 6:
                scene?.notes = descriptionTextView.text
            default:
                break
            }
        }
    }
    
    func checkForResize(textView:UITextView) {
        // Get descriptionTextView size that fits in view
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if size.height > self.defaultHeight {
            descriptionTextViewHeightConstraint.constant = size.height
            delegate?.resizeCell(in: self.section)
        } else {
            descriptionTextViewHeightConstraint.constant = self.defaultHeight-10
            delegate?.resizeCell(in: self.section)

        }
        
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
