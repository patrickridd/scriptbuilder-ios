//
//  SceneDetailTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/23/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

protocol SceneActSelected: class {
    func selected(newAct:Act)
}

class SceneDetailTableViewController: UITableViewController {

    @IBOutlet weak var sceneTitleTextField: UITextField!
    @IBOutlet weak var sceneNumberTextField: UITextField!
    @IBOutlet weak var sceneHeaderTextField: UITextField!
    
    @IBOutlet weak var sceneActNumberTextField: UITextField!
    
    var scene: Scene?
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = GoogleAds.bannerAdUnitId
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    var expandableSections: [ExpandableTableViewSection] = []
    var act: Act = .one
    
    var isExpandingCell: Bool = false
    var isCollapsingCell: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupExpandableSections()
        
        self.tableView.backgroundColor = UIColor.screenLightGray
        self.tableView.separatorColor = self.tableView.backgroundColor
      
        self.sceneTitleTextField.delegate = self
        self.sceneHeaderTextField.delegate = self
        
        addToolBar(textField: self.sceneTitleTextField)
        addToolBar(textField: self.sceneNumberTextField)
        addToolBar(textField: self.sceneHeaderTextField)
        
        if let scene = self.scene {
            self.updateView(with: scene)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Resizes Cells Dynamically
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        
        if InAppPurchases.shouldDisplayAds {
            adBannerView.load(GADRequest())
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
        self.sceneActNumberTextField.text = "\(self.act.rawValue+1)"
        self.sceneNumberTextField.text = "\(scene.sceneNumber)"
    }
    
    func createNewScene() {
        guard let screenplay = self.screenplay else { return }
        switch self.act {
            
        case .one:
            if let highestSceneNumber = screenplay.act1.scenes.sorted(by: {$0.sceneNumber > $1.sceneNumber }).first?.sceneNumber {
                let scene = Scene(title: "New Scene",
                                  sceneNumber: highestSceneNumber+1)
                self.scene = scene
                self.screenplay?.act1.sceneSet.insert(scene)
            } else {
                let scene = Scene(title: "New Scene",
                                  sceneNumber: 1)
                self.scene = scene
                self.screenplay?.act1.sceneSet.insert(scene)
            }
        case .two:
            if let highestSceneNumber = screenplay.act2.scenes.sorted(by: {$0.sceneNumber > $1.sceneNumber }).first?.sceneNumber {
                let scene = Scene(title: "New Scene",
                                  sceneNumber: highestSceneNumber+1)
                self.scene = scene
                self.screenplay?.act2.sceneSet.insert(scene)
            } else {
                let scene = Scene(title: "New Scene",
                                  sceneNumber: 1)
                self.scene = scene
                self.screenplay?.act2.sceneSet.insert(scene)
            }
        case .three:
            if let highestSceneNumber = screenplay.act3.scenes.sorted(by: {$0.sceneNumber > $1.sceneNumber }).first?.sceneNumber {
                let scene = Scene(title: "New Scene",
                                  sceneNumber: highestSceneNumber+1)
                self.scene = scene
                self.screenplay?.act3.sceneSet.insert(scene)
            } else {
                let scene = Scene(title: "New Scene",
                                  sceneNumber: 1)
                self.scene = scene
                self.screenplay?.act3.sceneSet.insert(scene)
            }
        default:
            break
        }
        if let scene = self.scene {
            self.sceneNumberTextField.text = "\(scene.sceneNumber)"
            self.sceneActNumberTextField.text = "\(self.act.rawValue+1)"
        }
       
    }

    @IBAction func sceneTitleTextFieldChanged(_ sender: UITextField) {
        self.scene?.title = sender.text ?? "New Scene"
    }

    @IBAction func sceneNumberTextFieldChanged(_ sender: UITextField) {
        guard let sceneNumberText = sender.text,
              let sceneNumber = Int(sceneNumberText) else { return }
        
        self.scene?.sceneNumber = sceneNumber
        
        if let scene = self.scene {
            SceneController.shared.adjustSceneNumbers(for: scene,
                                                      in: self.act,
                                                      with: self.screenplay)
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
        sceneActNumberTVC.preferredContentSize = CGSize(width: self.sceneActNumberTextField.bounds.width,
                                                        height: CGFloat(90))
        
        self.present(sceneActNumberTVC,
                     animated: true,
                     completion: nil)
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        self.saveScreenplay()
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
            descriptionCell?.contentView.backgroundColor = .screenLightGray
            descriptionCell?.update(viewController: .sceneDetail,
                                   section: indexPath.section,
                                   act: self.act,
                                   character: nil,
                                   scene: self.scene)
            return descriptionCell ?? UITableViewCell()
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            
            guard let descriptionCell = cell as? DescriptionTableViewCell else { return }
            
            if self.isExpandingCell {
                descriptionCell.descriptionTextView.becomeFirstResponder()
                self.isExpandingCell = false
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let descriptionCell = cell as? DescriptionTableViewCell else { return }
        
        if self.isCollapsingCell {
            descriptionCell.descriptionTextView.resignFirstResponder()
            descriptionCell.resignFirstResponder()
            self.isCollapsingCell = false
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
            self.tableView.beginUpdates()
            self.tableView.reloadSections(indexSet,
                                          with: .automatic)
            self.tableView.endUpdates()
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
    
    func selected(newAct: Act) {
        guard let scene = self.scene, newAct != self.act else { return }
        
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
        
        // Add scene into newAct and make scene number last in newAct
        switch newAct {
        case .one:
            if let highestSceneNumber = self.screenplay?.act1.scenes.sorted(by: {$0.sceneNumber > $1.sceneNumber }).first?.sceneNumber {
                scene.sceneNumber = highestSceneNumber+1
                self.screenplay?.act1.sceneSet.insert(scene)
            } else {
                // If no scenes are in act just insert and make sceneNumber = 1
                scene.sceneNumber = 1
                self.screenplay?.act1.sceneSet.insert(scene)
            }
            
        case .two:
            if let highestSceneNumber = self.screenplay?.act2.scenes.sorted(by: {$0.sceneNumber > $1.sceneNumber }).first?.sceneNumber {
                scene.sceneNumber = highestSceneNumber+1
                self.screenplay?.act2.sceneSet.insert(scene)
            } else {
                // If no scenes are in act just insert and make sceneNumber = 1
                scene.sceneNumber = 1
                self.screenplay?.act2.sceneSet.insert(scene)
            }
        case .three:
            if let highestSceneNumber = self.screenplay?.act3.scenes.sorted(by: {$0.sceneNumber > $1.sceneNumber }).first?.sceneNumber {
                scene.sceneNumber = highestSceneNumber+1
                self.screenplay?.act3.sceneSet.insert(scene)
            } else {
                // If no scenes are in act just insert and make sceneNumber = 1
                scene.sceneNumber = 1
                self.screenplay?.act3.sceneSet.insert(scene)
            }
        default:
            break
        }
        
        // Set selected newAct
        self.act = newAct
        
        // Set Act number in textField to reflect the user's selection
        self.sceneActNumberTextField.text = "\(act.rawValue+1)"
        
        // Set Scene # in case it changed during the act change
        self.sceneNumberTextField.text = "\(scene.sceneNumber)"
    }
    
}

extension SceneDetailTableViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        tableView.tableFooterView?.frame = bannerView.frame
        tableView.tableFooterView = bannerView
    }
    
}
