//
//  SceneDetailTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/23/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Firebase

class SceneDetailTableViewController: UITableViewController, CollapsibleHeaderDelegate, UIPopoverPresentationControllerDelegate, SceneActSelected {

    @IBOutlet weak var sceneTitleTextField: UITextField!
    @IBOutlet weak var sceneNumberTextField: UITextField!
    @IBOutlet weak var sceneHeaderTextField: UITextField!
    
    @IBOutlet weak var sceneActNumberTextField: UITextField!
    
    var scene: Scene?
    
    var expandableSections: [ExpandableTableViewSection] = []
    var act: Act = .one
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupExpandableSections()
        
        // Set Google Analytics Screen Name
        Analytics.setScreenName("SceneDetail", screenClass: "SceneDetailTableViewController")
        self.tableView.backgroundColor = UIColor.screenLightGray
        self.tableView.separatorColor = self.tableView.backgroundColor
      
        self.sceneTitleTextField.delegate = self
        addToolBar(textField: self.sceneTitleTextField)
        if let scene = self.scene {
            self.updateView(with: scene)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let _ = self.scene else {
            createNewScene()
            self.sceneTitleTextField.becomeFirstResponder()
            return
        }
    }
    
    
    // MARK: UI Methods
    
    func updateView(with scene:Scene) {
        self.sceneTitleTextField.text = scene.title
        // TODO: update act and scene number
    }
    
    func createNewScene() {
        guard let screenplay = self.screenplay else { return }
        switch self.act {
            
        case .one:
           let scenesCount = screenplay.act1.scenes.count
           let scene = Scene(title: "New Scene", sceneNumber: scenesCount+1)
           self.scene = scene
            self.screenplay?.act1.sceneSet.insert(scene)
        case .two:
            let scenesCount = screenplay.act2.scenes.count
            let scene = Scene(title: "New Scene", sceneNumber: scenesCount+1)
            self.scene = scene
            self.screenplay?.act2.sceneSet.insert(scene)
        case .three:
            let scenesCount = screenplay.act3.scenes.count
            let scene = Scene(title: "New Scene", sceneNumber: scenesCount+1)
            self.scene = scene
            self.screenplay?.act3.sceneSet.insert(scene)
        default:
            break
        }
    }

    @IBAction func sceneTitleTextFieldChanged(_ sender: UITextField) {
        self.scene?.title = sender.text ?? "New Scene"
    }

    @IBAction func sceneNumberTextFieldChanged(_ sender: UITextField) {
        guard let sceneNumberText = sender.text,
            let sceneNumber = Int(sceneNumberText) else { return }
        
        self.scene?.sceneNumber = sceneNumber
    }
    
    @IBAction func sceneHeadingTextFieldChanged(_ sender: UITextField) {
        if let newHeaderText = sender.text {
            self.scene?.header = newHeaderText
        }
    }
    
    @IBAction func sceneNumberButtonTapped(_ sender: UIButton) {
        
        guard let sceneNumberTVC = self.storyboard?.instantiateViewController(withIdentifier: "rolePopoverTVC") as? SceneNumberPopTableViewController else { return }
        sceneNumberTVC.modalPresentationStyle = .popover // So it knows to present it as a popover
        
        // Access the popController instance and configure its settings
        let popController = sceneNumberTVC.popoverPresentationController
        popController?.permittedArrowDirections = [.up,.down] // allow arrow to go both .up and .down
        popController?.delegate = self
        popController?.backgroundColor = .white // Makes the arrow white
        sceneNumberTVC.view.layer.cornerRadius = 0 // Unround the view's corner.
        popController?.sourceView = sender
        popController?.sourceRect = sender.bounds
        
        sceneNumberTVC.delegate = self // SceneActSelected protocol
        
        // change size of view controller to the size of my three cells.
        let contentHeightSize = (Role.count+1) * 40
        sceneNumberTVC.preferredContentSize = CGSize(width: self.view.bounds.width, height: CGFloat(contentHeightSize))
        
        self.present(sceneNumberTVC, animated: true, completion: nil)
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        self.saveScreenplay()
    }
    
    func setupExpandableSections() {
        let sectionTitles = Scene.sceneTitles
        for index in 0...sectionTitles.count-1 {
            let title = Scene.sceneTitles[index]
            let subtitle = "" //act.sectionSubTitles[index]
            let section = ExpandableTableViewSection(sectionTitle: title, sectionSubtitle: subtitle)
            expandableSections.append(section)
        }
    }
    
    // MARK: - Table view data source

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
            guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as? DescriptionTableViewCell else { return UITableViewCell() }
            descriptionCell.contentView.backgroundColor = .screenLightGray
            descriptionCell.update(viewController: .sceneDetail, section: indexPath.section, act: self.act, character: nil, scene: self.scene)
            return descriptionCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
        // Create Collapsible Header for Scene details
        switch section {
        case 0:
            return nil
        default:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleHeader ?? CollapsibleHeader(reuseIdentifier: "header")
            header.contentView.backgroundColor = expandableSections[section].collapsed ? .white : UIColor.screenLightGray
            header.titleLabel.text = Scene.sceneTitles[section]
            header.subtitleLabel.text = Scene.sceneSubtitles[section]
           // header.subtitleLabel.text = act.sectionSubTitles[section-self.sectionBesidesBeats]
            header.setCollapsed(expandableSections[section].collapsed)
            header.section = section
            header.delegate = self
            return header
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.0001
        default:
            return 60
        }
    }
    
    
    // MARK: CollapsibleHeaderDelegate
    
    func toggleSection(_ header: CollapsibleHeader, section: Int) {
        DispatchQueue.main.async {
            let collapsed = !self.expandableSections[section].collapsed
            // Toggle collapse
            self.expandableSections[section].collapsed = collapsed
            header.setCollapsed(collapsed)
            
            // Reload section tapped
            let indexSet = IndexSet(integer: section)
            self.tableView.beginUpdates()
            self.tableView.reloadSections(indexSet, with: .automatic)
            self.tableView.endUpdates()
        }
    }
    

    // MARK: - SceneActSelected Methods
    
    func selected(newAct: Act) {
        guard let scene = self.scene else { return }
        
        // Remove scene from old act
        switch self.act {
        case .one:
            self.screenplay?.act1.sceneSet.remove(scene)
        case .two:
            self.screenplay?.act2.sceneSet.remove(scene)
        case .three:
            self.screenplay?.act3.sceneSet.remove(scene)
        default:
            break
        }
        
        // Add scene into newAct
        switch newAct {
        case .one:
            self.screenplay?.act1.sceneSet.insert(scene)
        case .two:
            self.screenplay?.act2.sceneSet.insert(scene)
        case .three:
            self.screenplay?.act3.sceneSet.insert(scene)
        default:
            break
        }
        
        // Set selected newAct
        self.act = newAct
        
        self.sceneActNumberTextField.text = act.rawValue+1
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: UIPopoverPresentationControllerDelegate Methods
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol SceneActSelected: class {
    func selected(newAct:Act)
}
