//
//  SceneDetailTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/23/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Domain
import UIKit
import Firebase

protocol SceneActSelected: class {
    func selected(newAct: OutlineSection)
}

class SceneDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var saveButton: SaveBarButtonItem!
    @IBOutlet weak var sceneTitleTextField: UITextField!
    @IBOutlet weak var sceneNumberTextField: UITextField!
    @IBOutlet weak var sceneHeaderTextField: UITextField!
    @IBOutlet weak var sceneActNumberTextField: UITextField!
    @IBOutlet weak var topHorizontalStackView: UIStackView!
    @IBOutlet weak var actTitleLabel: UILabel!
    @IBOutlet weak var sceneNumberLabel: UILabel!
    @IBOutlet weak var sceneHeadingLabel: UILabel!
    @IBOutlet weak var headerContainerView: UIView!

    var expandableSections: [ExpandableTableViewSection] = []
    var act: OutlineSection = .one
    var scene: Scene?

    var isExpandingCell: Bool = false
    var isCollapsingCell: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.view = self
        setupExpandableSections()
        headerContainerView.backgroundColor = Theme.tableViewBackgroundColor
        tableView.backgroundColor = Theme.tableViewBackgroundColor
        tableView.separatorColor = tableView.backgroundColor
        tableView.showsVerticalScrollIndicator = false
        sceneActNumberTextField.backgroundColor = Theme.descriptionTextViewBackground
        sceneNumberTextField.backgroundColor = Theme.descriptionTextViewBackground
        sceneHeaderTextField.backgroundColor = Theme.descriptionTextViewBackground
        sceneActNumberTextField.textColor = Theme.descriptionTextColor
        sceneNumberTextField.textColor = Theme.descriptionTextColor
        sceneHeaderTextField.textColor = Theme.descriptionTextColor
        actTitleLabel.textColor = Theme.navTitleColor
        sceneNumberLabel.textColor = Theme.navTitleColor
        sceneHeadingLabel.textColor = Theme.navTitleColor
        
        sceneTitleTextField.delegate = self
        sceneTitleTextField.tag = 0
        sceneTitleTextField.addTarget(self,
                                      action: #selector(textFieldDidChange(_:)),
                                      for: .editingChanged)
        sceneNumberTextField.delegate = self
        sceneNumberTextField.tag = 1
        sceneNumberTextField.addTarget(self,
                                       action: #selector(textFieldDidChange(_:)),
                                       for: .editingChanged)
        sceneHeaderTextField.delegate = self
        sceneHeaderTextField.tag = 2
        sceneHeaderTextField.addTarget(self,
                                       action: #selector(textFieldDidChange(_:)),
                                       for: .editingChanged)

        addToolBar(textField: self.sceneTitleTextField)
        addToolBar(textField: self.sceneNumberTextField)
        addToolBar(textField: self.sceneHeaderTextField)
        
        if let scene {
            self.updateView(with: scene)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.sceneTitleTextField.becomeFirstResponder()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Resizes Cells Dynamically
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK: UI Methods
    
    func updateView(with scene:Scene) {
        self.sceneTitleTextField.text = scene.title
        self.sceneActNumberTextField.text = "\(self.act.rawValue+1)"
        self.sceneNumberTextField.text = "\(scene.sceneNumber)"
        self.sceneHeaderTextField.text = scene.header
    }
    
    func createNewScene() {
        guard let screenplay = self.screenplay else {
            reloadScreenplaysWithAnimation {
                self.tableView.reloadData()
            }
            return
        }
        switch self.act {
        case .one:
            if let highestSceneNumber = screenplay.act1.scenes.sorted(by: {$0.sceneNumber > $1.sceneNumber }).first?.sceneNumber {
                let scene = Scene(title: "New Scene".localized,
                                  sceneNumber: highestSceneNumber + 1)
                self.scene = scene
                self.screenplay?.act1ScenesSet.insert(scene)
            } else {
                let scene = Scene(title: "New Scene".localized,
                                  sceneNumber: 1)
                self.scene = scene
                self.screenplay?.act1ScenesSet.insert(scene)
            }
        case .two:
            if let highestSceneNumber = screenplay.act2.scenes.sorted(by: {$0.sceneNumber > $1.sceneNumber }).first?.sceneNumber {
                let scene = Scene(title: "New Scene".localized,
                                  sceneNumber: highestSceneNumber+1)
                self.scene = scene
                self.screenplay?.act2ScenesSet.insert(scene)
            } else {
                let scene = Scene(title: "New Scene".localized,
                                  sceneNumber: 1)
                self.scene = scene
                self.screenplay?.act2ScenesSet.insert(scene)
            }
        case .three:
            if let highestSceneNumber = screenplay.act3.scenes.sorted(by: {$0.sceneNumber > $1.sceneNumber }).first?.sceneNumber {
                let scene = Scene(title: "New Scene".localized,
                                  sceneNumber: highestSceneNumber+1)
                self.scene = scene
                self.screenplay?.act3ScenesSet.insert(scene)
            } else {
                let scene = Scene(title: "New Scene".localized,
                                  sceneNumber: 1)
                self.scene = scene
                self.screenplay?.act3ScenesSet.insert(scene)
            }
        default:
            break
        }
        if let scene {
            self.sceneNumberTextField.text = "\(scene.sceneNumber)"
            self.sceneActNumberTextField.text = "\(self.act.rawValue+1)"
        }
        FirebaseController.shared.save(scene: scene, inAct: act.domainAct)
    }

    @IBAction func sceneTitleTextFieldChanged(_ sender: UITextField) {
        self.scene?.title = sender.text ?? "New Scene".localized
    }

    @IBAction func sceneNumberTextFieldChanged(_ sender: UITextField) {
        guard var screenplay else {
            reloadScreenplaysWithAnimation {
                self.tableView.reloadData()
            }
            return
        }
        guard let sceneNumberText = sender.text,
              let sceneNumber = Int(sceneNumberText) else { return }

        self.scene?.sceneNumber = sceneNumber
        
        if let scene = self.scene {
            SceneController.shared.adjustSceneNumbers(for: scene,
                                                      in: self.act,
                                                      with: &screenplay)
            self.screenplay = screenplay
            switch self.act {
            case .one:
                self.screenplay?.act1.scenes.sort(by: {$0.sceneNumber < $1.sceneNumber })
            case .two:
                self.screenplay?.act2.scenes.sort(by: {$0.sceneNumber < $1.sceneNumber })
            case .three:
                self.screenplay?.act3.scenes.sort(by: {$0.sceneNumber < $1.sceneNumber })
            default:
                break
            }
        }
    }
    
    @IBAction func sceneHeadingTextFieldChanged(_ sender: UITextField) {
        if let newHeaderText = sender.text {
            self.scene?.header = newHeaderText
        }
    }
    
    @IBAction func sceneActNumberButtonTapped(_ sender: UIButton) {
        
        guard let sceneActNumberTVC = self.storyboard?.instantiateViewController(withIdentifier: "sceneActNumberTVC") as? SceneActNumberPopTableViewController else { return }
        sceneActNumberTVC.modalPresentationStyle = .popover // So it knows to present it as a popover
        
        // Access the popController instance and configure its settings
        let popController = sceneActNumberTVC.popoverPresentationController
        popController?.permittedArrowDirections = [.up,
                                                   .down] // allow arrow to go both .up and .down
        popController?.delegate = self
        popController?.backgroundColor = .white // Makes the arrow white
        sceneActNumberTVC.view.layer.cornerRadius = 0 // Unround the view's corner.
        
        let centerRect = CGRect(x: sender.bounds.width/2,
                                y: 0,
                                width: 0,
                                height: sender.bounds.height)
        popController?.sourceView = sender
        popController?.sourceRect = centerRect
        
        sceneActNumberTVC.delegate = self // SceneActSelected protocol
        sceneActNumberTVC.preferredContentSize = CGSize(width:
            self.sceneActNumberTextField.bounds.width,
                                                        height: CGFloat(90))
        self.present(sceneActNumberTVC,
                     animated: true,
                     completion: nil)
    }
    
    @objc func expandButtonTapped(sender: UIButton) {
        let indexPath = IndexPath(row: 0,
                                  section: sender.tag)
        let storyboard = UIStoryboard(name: "Outline",
                                      bundle: nil)
        guard
            let enlargedNavigationController = storyboard.instantiateViewController(withIdentifier: "enlargedNavigationController") as? UINavigationController,
            let enlargedVC = enlargedNavigationController.children[0] as? EnlargedDescriptionViewController,
            let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell
        else {
            return
        }
        enlargedNavigationController.modalPresentationStyle = .fullScreen
        enlargedVC.viewController = .sceneDetail
        enlargedVC.text = descriptionCell.descriptionTextView.text
        enlargedVC.section = sender.tag
        enlargedVC.delegate = self
        enlargedVC.scene = self.scene
        enlargedVC.act = self.act
        self.present(enlargedNavigationController,
                     animated: true,
                     completion: nil)
    }

    // MARK: - TableView Data Source & Delegate Methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        // 1. Scene Description
        // 2. Dialogue
        // 3. Action
        // 4. Characters
        // 5. How scene moves story forward
        // 6. Notes
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
            return expandableSections[section].collapsed ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell",
                                                                for: indexPath) as? DescriptionTableViewCell
            descriptionCell?.delegate = self
            descriptionCell?.defaultHeight = self.getDefaultHeightOfCell()
            descriptionCell?.contentView.backgroundColor = Theme.descriptionTextViewBackground
            descriptionCell?.update(viewController: .sceneDetail,
                                    section: indexPath.section,
                                    act: self.act,
                                    character: nil,
                                    scene: self.scene)
            descriptionCell?.expandButton.tag = indexPath.section
            descriptionCell?.expandButton.addTarget(self,
                                                    action: #selector(expandButtonTapped(sender:)),
                                                    for: .touchUpInside)
            return descriptionCell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create Collapsible Header for Scene details
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleHeader ?? CollapsibleHeader(reuseIdentifier: "header")
        header.contentView.backgroundColor = expandableSections[section].collapsed ? Theme.tableViewSectionCollapsedColor : Theme.tableViewSectionExpandedColor
        header.titleLabel.text = Scene.sceneTitles[section]
        header.subtitleLabel.text = Scene.sceneSubtitles[section]
        // header.subtitleLabel.text = act.sectionSubTitles[section-self.sectionBesidesBeats]
        header.setCollapsed(expandableSections[section].collapsed)
        header.section = section
        header.delegate = self
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            guard let descriptionCell = cell as? DescriptionTableViewCell else { return }
            
            if self.isExpandingCell {
                descriptionCell.descriptionTextView.becomeFirstResponder()
                descriptionCell.descriptionTextView.isHidden = false
                self.isExpandingCell = false
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            guard let descriptionCell = cell as? DescriptionTableViewCell else { return }
            
            if self.isCollapsingCell {
                descriptionCell.descriptionTextView.resignFirstResponder()
                descriptionCell.resignFirstResponder()
                self.isCollapsingCell = false
            }
        }
    }
    
    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if scene == nil {
            createNewScene()
        }
        textField.resignFirstResponder()
        FirebaseController.shared.save(scene: scene, inAct: self.act.domainAct)
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if scene == nil {
            createNewScene()
        }
        switch textField.tag {
        case 0:
            self.scene?.title = textField.text ?? ""
        case 1:
            self.scene?.sceneNumber = Int(textField.text ?? "") ?? -1
        case 2:
            self.scene?.header = textField.text ?? ""
        default:
            break
        }
        _ = Timer.scheduledTimer(
            withTimeInterval: 2.0,
            repeats: false, block: { [weak self] _ in
                guard let self else { return }
                FirebaseController.shared.save(scene: self.scene, inAct: self.act.domainAct)
            })
    }

}

extension SceneDetailTableViewController: CollapsibleHeaderDelegate {
    
    func setupExpandableSections() {
        let sectionTitles = Scene.sceneTitles
        for index in 0...sectionTitles.count-1 {
            let title = Scene.sceneTitles[index]
            let subtitle = "" //act.sectionSubTitles[index]
            let section = ExpandableTableViewSection(sectionTitle: title,
                                                     sectionSubtitle: subtitle)
            expandableSections.append(section)
        }
    }
    
    func toggleSection(_ header: CollapsibleHeader, section: Int) {
        DispatchQueue.main.async {
            let collapsed = !self.expandableSections[section].collapsed
            // Toggle collapse
            self.expandableSections[section].collapsed = collapsed
            header.setCollapsed(collapsed)
            
            if collapsed {
                self.isExpandingCell = false
                self.isCollapsingCell = true
            } else {
                self.isExpandingCell = true
                self.isCollapsingCell = false
            }
            
            // Reload section tapped
            let indexSet = IndexSet(integer: section)
            self.tableView.performBatchUpdates({
                  self.tableView.reloadSections(indexSet, with: .automatic)
            }, completion: nil)
        }
    }
}

extension SceneDetailTableViewController: UIPopoverPresentationControllerDelegate {
    
    // MARK: UIPopoverPresentationControllerDelegate Methods
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

extension SceneDetailTableViewController: SceneActSelected {
    
    func selected(newAct: OutlineSection) {
        guard let _ = self.screenplay else {
            reloadScreenplaysWithAnimation {
                self.tableView.reloadData()
            }
            return
        }
        guard var scene = self.scene else {
            createNewScene()
            selected(newAct: newAct)
            return
        }

        guard newAct != self.act else { return }

        // Remove scene from old act
        switch self.act {
        case .one:
            self.screenplay?.act1ScenesSet.remove(scene)
        case .two:
            self.screenplay?.act2ScenesSet.remove(scene)
        case .three:
            self.screenplay?.act3ScenesSet.remove(scene)
        default:
            break
        }
        if let domainAct = act.domainAct {
            FirebaseController.shared.delete(scene: scene, inAct: domainAct)
        }

        // Add scene into newAct and make scene number last in newAct
        switch newAct {
        case .one:
            if let highestSceneNumber = self.screenplay?.act1.scenes.sorted(by: {$0.sceneNumber > $1.sceneNumber }).first?.sceneNumber {
                scene.sceneNumber = highestSceneNumber+1
                self.screenplay?.act1ScenesSet.insert(scene)
            } else {
                // If no scenes are in act just insert and make sceneNumber = 1
                scene.sceneNumber = 1
                self.screenplay?.act1ScenesSet.insert(scene)
            }
        case .two:
            if let highestSceneNumber = self.screenplay?.act2.scenes.sorted(by: {$0.sceneNumber > $1.sceneNumber }).first?.sceneNumber {
                scene.sceneNumber = highestSceneNumber+1
                self.screenplay?.act2ScenesSet.insert(scene)
            } else {
                // If no scenes are in act just insert and make sceneNumber = 1
                scene.sceneNumber = 1
                self.screenplay?.act2ScenesSet.insert(scene)
            }
        case .three:
            if let highestSceneNumber = self.screenplay?.act3.scenes.sorted(by: {$0.sceneNumber > $1.sceneNumber }).first?.sceneNumber {
                scene.sceneNumber = highestSceneNumber+1
                self.screenplay?.act3ScenesSet.insert(scene)
            } else {
                // If no scenes are in act just insert and make sceneNumber = 1
                scene.sceneNumber = 1
                self.screenplay?.act3ScenesSet.insert(scene)
            }
        default:
            break
        }

        // Set selected newAct
        self.act = newAct
        // Persist mutated copy back to the VC's state (Scene is a value type)
        self.scene = scene

        // Set Act number in textField to reflect the user's selection
        self.sceneActNumberTextField.text = "\(act.rawValue+1)"
        // Set Scene # in case it changed during the act change
        self.sceneNumberTextField.text = "\(scene.sceneNumber)"
        FirebaseController.shared.save(scene: scene, inAct: newAct.domainAct)
    }

}

extension SceneDetailTableViewController: DescriptionDelegate {
    
    func updatedText(_ text: String, in section: Int) {
        let indexPath = IndexPath(row: 0, section: section)
        guard let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell
        else { return }

        descriptionCell.descriptionTextView.text = text
        descriptionCell.textViewDidChange(descriptionCell.descriptionTextView)
    }

}
