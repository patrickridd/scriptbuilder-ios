//
//  EnlargedDescriptionViewController.swift
//  ScriptStarter
//
//  Created by patrick ridd on 4/24/24.
//  Copyright © 2024 patrickridd. All rights reserved.
//

import KMPlaceholderTextView
import UIKit

class EnlargedDescriptionViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descriptionTextViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: DescriptionDelegate?
    var viewController: ViewController = .outline
    var section: Int = 0
    var act: Act?
    var scene: Scene?
    var character: Character?
    var text: String?
    var defaultTextViewHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setUpLabelUI()
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let font = UIFont.systemFont(ofSize: isIpad ? 24: 14,
                                     weight: .regular)
        self.descriptionTextView.font = font
        view.backgroundColor = Theme.enlargedNavigationDescriptionBackground
        descriptionTextView.backgroundColor = Theme.enlargedNavigationDescriptionBackground
        descriptionTextView.textColor = Theme.descriptionTextColor
        descriptionTextView.placeholderColor = Theme.descriptionPlaceholderTextColor
        addToolBar(textView: descriptionTextView)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardDisplayed), name: UIResponder.keyboardWillShowNotification, object: nil)
        update(viewController: self.viewController,
               section: self.section,
               act: self.act,
               character: self.character,
               scene: self.scene)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        // Make sure the keyboard is visible at all times on this screen
        descriptionTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.updatedText(descriptionTextView.text,
                              in: section)
    }

    // MARK: - IBAction Methods

    @IBAction func reduceScreenButtonTapped(_ sender: Any) {
        self.dismiss(animated: true,
                     completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveButton.isEnabled = false
        delegate?.updatedText(descriptionTextView.text,
                              in: self.section)
        saveScreenplay {
            DispatchQueue.main.async {
                self.saveButton.isEnabled = true
            }
        }
    }
    
    // MARK: - UI Methods
    
    @objc func keyboardDisplayed(notification: Notification) {
        scrollView.scrollRectToVisible(descriptionTextView.frame, animated: true)
    }

    func setupNavigationBar() {
        var title: String = screenplay?.title ?? ""
        var font = UIFont.systemFont(ofSize: 20,
                                     weight: .semibold)
        switch viewController {
        case .actDetail:
            title = act?.title ?? title
            font = UIFont.systemFont(ofSize: 20,
                                     weight: .light)
        case .characterDetail:
            title = character?.name ?? title
            font = UIFont.systemFont(ofSize: 20,
                                     weight: .light)
        case .outline, .sceneDetail:
            break
        }
        // Remove Navigation bar shadow and borderline
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.topItem?.title = title
        let attributes = [NSAttributedString.Key.foregroundColor: Theme.navTitleColor,
                          NSAttributedString.Key.font: font]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.tintColor = .screenLightBlue
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = attributes
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.enlargedNavigationBarBackground
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }
    
    func setUpLabelUI() {
        sectionTitleLabel.textColor = Theme.navTitleColor
        subtitleLabel.textColor = UIColor.screenDarkMediumGray

        switch viewController {
        case .outline:
            subtitleLabel.text = "Overall description".localized
            switch self.section {
            case 0: // "Basic Idea (Log Line)"
                sectionTitleLabel.text = "Idea".localized
            default: // "Acts"
                sectionTitleLabel.text = act?.title
            }
            
        case .actDetail:
            guard let act = act else { break }
            if self.section == 0 {
                sectionTitleLabel.text = act.title
                subtitleLabel.text = "Overall description".localized
            } else {
                sectionTitleLabel.text = act.sectionsTitles[self.section-2]
                subtitleLabel.text = act.sectionSubTitles[self.section-2]
            }
        case .characterDetail:
            sectionTitleLabel.text = CharacterSection.sectionTitles[self.section-2]
            subtitleLabel.text = CharacterSection.sectionSubtitles[self.section-2]
        case .sceneDetail:
            sectionTitleLabel.text = Scene.sceneTitles[self.section]
            subtitleLabel.text = Scene.sceneSubtitles[self.section]
        }
    }

    func update(viewController: ViewController,
                section: Int,
                act: Act?,
                character: Character? = nil,
                scene: Scene? = nil
    ) {
        DispatchQueue.main.async {
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
                    self.descriptionTextView.placeholder = "About a ...".localized
                    self.descriptionTextView.text  = self.screenplay?.idea
                case 1: // Act 1
                    self.descriptionTextView.placeholder = "Setup".localized
                    self.descriptionTextView.text = self.screenplay?.actOneDescription
                    
                case 2: // Act 2
                    self.descriptionTextView.placeholder = "Confrontation".localized
                    self.descriptionTextView.text = self.screenplay?.actTwoDescription
                    
                case 3: // Act 3
                    self.descriptionTextView.placeholder = "Resolution".localized
                    self.descriptionTextView.text = self.screenplay?.actThreeDescription
                default:
                    self.descriptionTextView.text = ""
                    self.descriptionTextView.placeholder = ""
                }
                
            case .actDetail:
                guard let act = act else { break }
                switch act {
                case .idea:
                    switch section {
                    case 0:
                        self.descriptionTextView.text = self.screenplay?.idea
                    case 2:
                        self.descriptionTextView.text = self.screenplay?.logLine
                    case 3:
                        self.descriptionTextView.text = self.screenplay?.centralIntention
                    case 4:
                        self.descriptionTextView.text = self.screenplay?.mainObstacle
                    case 5:
                        self.descriptionTextView.text = self.screenplay?.theme
                    case 6:
                        self.descriptionTextView.text = self.screenplay?.notes
                    default:
                        self.descriptionTextView.text = ""
                        self.descriptionTextView.placeholder = ""
                    }
                case .one:
                    switch section {
                    case 0:
                        self.descriptionTextView.text = self.screenplay?.actOneDescription
                    case 2:
                        self.descriptionTextView.text = self.screenplay?.act1.oldWorldDescription
                    case 3:
                        self.descriptionTextView.text = self.screenplay?.act1.incitingIncident
                    case 4:
                        self.descriptionTextView.text = self.screenplay?.act1.callToAdventure
                    case 5:
                        self.descriptionTextView.text = self.screenplay?.act1.meetingMentor
                    case 6:
                        self.descriptionTextView.text = self.screenplay?.act1.theme
                    case 7:
                        self.descriptionTextView.text = self.screenplay?.act1.refusal
                    case 8:
                        self.descriptionTextView.text = self.screenplay?.act1.reasonToAdventure
                    case 9:
                        self.descriptionTextView.text = self.screenplay?.act1.enemyAtTheGates
                    default:
                        self.descriptionTextView.text = ""
                        self.descriptionTextView.placeholder = ""
                    }
                    if section == 0 {
                        self.descriptionTextView.placeholder = act.placeholders[section]
                    }  else {
                        self.descriptionTextView.placeholder = ""
                    }
                    
                case .two:
                    switch section {
                    case 0:
                        // General description
                        self.descriptionTextView.text = self.screenplay?.actTwoDescription
                    case 2:
                        // Strange New World
                        self.descriptionTextView.text = self.screenplay?.act2.newWorldDescription
                    case 3:
                        // Friends/Foes/Frenemies
                        self.descriptionTextView.text = self.screenplay?.act2.enemiesFriends
                    case 4:
                        // Test Resolve
                        self.descriptionTextView.text = self.screenplay?.act2.obstacles
                    case 5:
                        // Sharpening the sword
                        self.descriptionTextView.text = self.screenplay?.act2.sharpeningTheSword
                    case 6:
                        // Burn the Boats
                        self.descriptionTextView.text = self.screenplay?.act2.burnTheBoats
                    case 7:
                        // Supreme Sacrifice
                        self.descriptionTextView.text = self.screenplay?.act2.theDeadlyEncounter
                    case 8:
                        // Celebrate Good Times
                        self.descriptionTextView.text = self.screenplay?.act2.celebrate
                    case 9:
                        // Bad Guys Strike back
                        self.descriptionTextView.text = self.screenplay?.act2.badGuysStrikeBack
                    case 10:
                        // Darkness Before the Dawn
                        self.descriptionTextView.text = self.screenplay?.act2.allIsLost
                    default:
                        self.descriptionTextView.text = ""
                        self.descriptionTextView.placeholder = ""
                    }
                    if section == 0 {
                        self.descriptionTextView.placeholder = act.placeholders[section]
                    }  else {
                        self.descriptionTextView.placeholder = ""
                    }
                case .three:
                    switch section {
                    case 0:
                        self.descriptionTextView.text = self.screenplay?.actThreeDescription
                    case 2:
                        self.descriptionTextView.text = self.screenplay?.act3.theUltimateAnswer
                    case 3:
                        self.descriptionTextView.text = self.screenplay?.act3.rewards
                    case 4:
                        self.descriptionTextView.text = self.screenplay?.act3.untangleStory
                    case 5:
                        self.descriptionTextView.text =
                        self.screenplay?.act3.brandNewWorld
                    default:
                        self.descriptionTextView.text = ""
                        self.descriptionTextView.placeholder = ""
                    }
                    if section == 0 {
                        self.descriptionTextView.placeholder = act.placeholders[section]
                    }  else {
                        self.descriptionTextView.placeholder = ""
                    }
                }
            case .characterDetail:
                switch section {
                case 2:
                    self.descriptionTextView.text = character?.intention
                case 3:
                    self.descriptionTextView.text = character?.whyIntention
                case 4:
                    self.descriptionTextView.text = character?.whatToDo
                case 5:
                    self.descriptionTextView.text = character?.howDoesCharacterDoIt
                case 6:
                    self.descriptionTextView.text = character?.obstacles
                case 7:
                    self.descriptionTextView.text = character?.flaws
                case 8:
                    self.descriptionTextView.text = character?.intentionFix
                case 9:
                    self.descriptionTextView.text = character?.need
                case 10:
                    self.descriptionTextView.text = character?.howCharacterChanged
                case 11:
                    self.descriptionTextView.text = character?.notes
                default:
                    self.descriptionTextView.text = ""
                    self.descriptionTextView.placeholder = ""
                }
            case .sceneDetail:
                switch section {
                case 0:
                    self.descriptionTextView.text = scene?.sceneDescription
                case 1:
                    self.descriptionTextView.text = scene?.characters
                case 2:
                    self.descriptionTextView.text = scene?.dialogue
                case 3:
                    self.descriptionTextView.text = scene?.action
                case 4:
                    self.descriptionTextView.text = scene?.howPushesStory
                case 5:
                    self.descriptionTextView.text = scene?.notes
                default:
                    self.descriptionTextView.text = ""
                    self.descriptionTextView.placeholder = ""
                }
            }
            self.checkForResize(textView: self.descriptionTextView)
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            
            self.checkForResize(textView: textView)
            switch self.viewController {
            case .outline:
                switch self.section {
                case 0:
                    self.screenplay?.idea = textView.text
                case 1:
                    self.screenplay?.actOneDescription = textView.text
                case 2:
                    self.screenplay?.actTwoDescription = textView.text
                case 3:
                    self.screenplay?.actThreeDescription = textView.text
                default:
                    break
                }
            case .actDetail:
                guard let act = self.act else { break }
                switch act {
                case .idea:
                    switch self.section {
                    case 0:
                        self.screenplay?.idea = textView.text
                    case 2:
                        self.screenplay?.logLine = textView.text
                    case 3:
                        self.screenplay?.centralIntention = textView.text
                    case 4:
                        self.screenplay?.mainObstacle = textView.text
                    case 5:
                        self.screenplay?.theme = textView.text
                    case 6:
                        self.screenplay?.notes = textView.text
                    default:
                        break
                    }
                case .one:
                    switch self.section {
                    case 0:
                        self.screenplay?.actOneDescription = textView.text
                    case 2:
                        self.screenplay?.act1.oldWorldDescription = textView.text
                    case 3:
                        self.screenplay?.act1.incitingIncident = textView.text
                    case 4:
                        self.screenplay?.act1.callToAdventure = textView.text
                    case 5:
                        self.screenplay?.act1.meetingMentor = textView.text
                    case 6:
                        self.screenplay?.act1.theme = textView.text
                    case 7:
                        self.screenplay?.act1.refusal = textView.text
                    case 8:
                        self.screenplay?.act1.reasonToAdventure = textView.text
                    case 9:
                        self.screenplay?.act1.enemyAtTheGates = textView.text
                    default:
                        break
                    }
                    
                case .two:
                    switch self.section {
                    case 0:
                        // General description
                        self.screenplay?.actTwoDescription = self.descriptionTextView.text
                    case 2:
                        // Strange New World
                        self.screenplay?.act2.newWorldDescription = self.descriptionTextView.text
                    case 3:
                        // Friends/Foes/Frenemies
                        self.screenplay?.act2.enemiesFriends = self.descriptionTextView.text
                    case 4:
                        // Test Resolve
                        self.screenplay?.act2.obstacles = self.descriptionTextView.text
                    case 5:
                        // Sharpening the sword
                        self.screenplay?.act2.sharpeningTheSword = self.descriptionTextView.text
                    case 6:
                        // Burn the Boats
                        self.screenplay?.act2.burnTheBoats = self.descriptionTextView.text
                    case 7:
                        // Supreme Sacrifice
                        self.screenplay?.act2.theDeadlyEncounter = self.descriptionTextView.text
                    case 8:
                        // Celebrate Good Times
                        self.screenplay?.act2.celebrate = self.descriptionTextView.text
                    case 9:
                        // Bad Guys Strike back
                        self.screenplay?.act2.badGuysStrikeBack = self.descriptionTextView.text
                    case 10:
                        // Darkness Before the Dawn
                        self.screenplay?.act2.allIsLost = self.descriptionTextView.text
                    default:
                        break
                    }
                case .three:
                    switch self.section {
                    case 0:
                        self.screenplay?.actThreeDescription = textView.text
                    case 2:
                        self.screenplay?.act3.theUltimateAnswer = textView.text
                    case 3:
                        self.screenplay?.act3.rewards = textView.text
                    case 4:
                        self.screenplay?.act3.untangleStory = textView.text
                    case 5:
                        self.screenplay?.act3.brandNewWorld = textView.text
                    default:
                        break
                    }
                }
            case .characterDetail:
                switch self.section {
                case 2:
                    self.character?.intention = self.descriptionTextView.text
                case 3:
                    self.character?.whyIntention = self.descriptionTextView.text
                case 4:
                    self.character?.whatToDo = self.descriptionTextView.text
                case 5:
                    self.character?.howDoesCharacterDoIt = self.descriptionTextView.text
                case 6:
                    self.character?.obstacles = self.descriptionTextView.text
                case 7:
                    self.character?.flaws = self.descriptionTextView.text
                case 8:
                    self.character?.intentionFix = self.descriptionTextView.text
                case 9:
                    self.character?.need = self.descriptionTextView.text
                case 10:
                    self.character?.howCharacterChanged = self.descriptionTextView.text
                case 11:
                    self.character?.notes = self.descriptionTextView.text
                default:
                    break
                }
            case .sceneDetail:
                switch self.section {
                case 0:
                    self.scene?.sceneDescription = self.descriptionTextView.text
                case 1:
                    self.scene?.characters = self.descriptionTextView.text
                case 2:
                    self.scene?.dialogue = self.descriptionTextView.text
                case 3:
                    self.scene?.action = self.descriptionTextView.text
                case 4:
                    self.scene?.howPushesStory = self.descriptionTextView.text
                case 5:
                    self.scene?.notes = self.descriptionTextView.text
                default:
                    break
                }
            }
        }
    }
    
    func checkForResize(textView: UITextView) {
        if self.descriptionTextViewHeightConstraint == nil { return }

        // Get self.descriptionTextView size that fits in view
        let size = textView.sizeThatFits(CGSize(width: textView.bounds.size.width,
                                                height: CGFloat.greatestFiniteMagnitude))
        if size.height >= textView.bounds.height {
            self.descriptionTextViewHeightConstraint.constant = 500
        }
    }

}
