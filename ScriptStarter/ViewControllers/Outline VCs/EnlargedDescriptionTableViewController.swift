//
//  EnlargedDescriptionTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/29/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//
import Domain
import UIKit
import Firebase

class EnlargedDescriptionTableViewController: UITableViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var viewController: ViewController = .outline
    var section: Int = 0
    var act: Act?
    var scene: Scene?
    var character: Character?

    var text: String?
    
    weak var delegate: DescriptionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = Theme.tableViewBackgroundColor
        setupNavigationBar()
        
        self.tableView.backgroundColor = Theme.tableViewBackgroundColor
        self.tableView.separatorColor = tableView.backgroundColor
    }
    
    lazy var descriptionCell: DescriptionTableViewCell? = {
        let indexPath = IndexPath(row: 0, section: 0)
        return tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        // Make sure the keyboard is visible at all times on this screen
        guard let descriptionCell = descriptionCell else { return }
        descriptionCell.descriptionTextView.becomeFirstResponder()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard
            let descriptionCell = descriptionCell,
            let text = descriptionCell.descriptionTextView.text
        else {
            return
        }
        
        delegate?.updatedText(text,
                              in: self.section)
    }

    // MARK: - IBAction Methods

    @IBAction func reduceScreenButtonTapped(_ sender: Any) {
        self.dismiss(animated: true,
                     completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveButton.isEnabled = false
        guard
            let descriptionCell = descriptionCell,
            let text = descriptionCell.descriptionTextView.text
        else {
            self.saveScreenplay {
                DispatchQueue.main.async {
                    self.saveButton.isEnabled = true
                }
            }
            return
        }
        
        delegate?.updatedText(text,
                              in: self.section)
        self.saveScreenplay {
            DispatchQueue.main.async {
                self.saveButton.isEnabled = true
            }
        }
    }
    
    // MARK: - UI Methods
    
    func setupNavigationBar() {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { self.setupNavigationBar() }
        }
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
        navigationController?.navigationBar.tintColor = Theme.scriptBuilderUIColor
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = attributes
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.navigationBarBackground
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell") as? DescriptionTableViewCell else { return UITableViewCell() }
        
        descriptionCell.update(viewController: self.viewController,
                               section: section,
                               act: self.act,
                               character: self.character,
                               scene: self.scene)
        descriptionCell.backgroundColor = Theme.descriptionTextViewBackground
        addToolBar(textView: descriptionCell.descriptionTextView)
        
        return descriptionCell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderSubtitle ?? SectionHeaderSubtitle(reuseIdentifier: "header")
        
        switch viewController {
        case .outline:
            sectionHeader.subtitleLabel.text = "Overall description".localized
            switch self.section {
            case 0: // "Basic Idea (Log Line)"
                sectionHeader.sectionLabel.text = "Idea".localized
            default: // "Acts"
                sectionHeader.sectionLabel.text = act?.title
            }
            
        case .actDetail:
            guard let act = act else { break }
            if self.section == 0 {
                sectionHeader.sectionLabel.text = act.title
                sectionHeader.subtitleLabel.text = "Overall description".localized
            } else {
                sectionHeader.sectionLabel.text = act.sectionsTitles[self.section-2]
                sectionHeader.subtitleLabel.text = act.sectionSubTitles[self.section-2]
            }
        case .characterDetail:
            sectionHeader.sectionLabel.text = CharacterSection.sectionTitles[self.section-2]
            sectionHeader.subtitleLabel.text = CharacterSection.sectionSubtitles[self.section-2]
        case .sceneDetail:
            sectionHeader.sectionLabel.text = Scene.sceneTitles[self.section]
            sectionHeader.subtitleLabel.text = Scene.sceneSubtitles[self.section]
        }
        return sectionHeader
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * (1/3)
    }

}
