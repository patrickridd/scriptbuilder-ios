//
//  PdfHelper.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 11/29/19.
//  Copyright © 2019 patrickridd. All rights reserved.
//

import Domain
import PDFKit

/// The PDF export uses the outline-section copy (titles/subtitles/placeholders),
/// including the non-act `.idea` section. Alias keeps the legacy `Act.*`
/// references in this file pointing at `OutlineSection` after the rename that
/// disambiguated it from `Domain.Act`.
private typealias Act = OutlineSection

class PdfHelper {
    
    let pageHeight = 11 * 72.0
    let pageWidth = 8.5 * 72.0
    let newScreenplayRect = CGRect(x: 50, y: 50, width: (8.5 * 72.0)-100, height: 11 * 72.0)
    
    var currentPageHeight: Int = 0

    func getHeight(for attributedString: NSAttributedString) -> CGFloat {
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let largestSize = CGSize(width: pageWidth, height: .greatestFiniteMagnitude)
        let textSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRange(), nil, largestSize, nil)
        return textSize.height
    }
    
    func createPdf(with screenplay: Screenplay) -> Data {
        // 1
        let pdfMetaData = [
            kCGPDFContextCreator: "ScriptBuilder",
            kCGPDFContextAuthor: "scriptbuilderapp.com",
            kCGPDFContextTitle: screenplay.title,
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // 2
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        // 3
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        // 4
        let data = renderer.pdfData { (context) in
            // 5
            context.beginPage()

            // Screenplay Title
            formatAndAdd(screenplayTitle: screenplay.title, with: context)
            
            // Outline section //
            formatAndAdd(sectionTitle: "Outline".localized, with: context)
            
            // Idea section
            createIdeaSection(with: screenplay, with: context)
            
            // Act 1 Section
            addNewLine(context: context)
            createAct1Section(with: screenplay, in: context)
            
            // Act 2
            addNewLine(context: context)
            createAct2Section(with: screenplay, in: context)
            
            // Act 3
            addNewLine(context: context)
            createAct3Section(with: screenplay, in: context)
            
            // Characters Section //
            addNewLine(context: context)
            formatAndAdd(sectionTitle: "Characters".localized, with: context)
            createCharacterSection(with: screenplay, in: context)
            
            
            // Scenes //
            addNewLine(context: context)
            formatAndAdd(sectionTitle: "Scenes".localized, with: context)

            // Act 1//
            addNewLine(context: context)
            formatAndAdd(sectionSubtitle: "\(Act.one.title) " + "Scenes".localized, with: context)
            createSceneSection(for: screenplay.act1.scenes, in: context)
            
           
            // Act 2 //
            addNewLine(context: context)
            formatAndAdd(sectionSubtitle: "\(Act.two.title) " + "Scenes".localized, with: context)
            createSceneSection(for: screenplay.act2.scenes, in: context)
            
            // Act 3 //
            addNewLine(context: context)
            formatAndAdd(sectionSubtitle: "\(Act.three.title) " + "Scenes".localized, with: context)
            createSceneSection(for: screenplay.act3.scenes, in: context)
        }
        
        return data
    }
    
    func addNewLine(context: UIGraphicsPDFRendererContext) {
        let newlineAttributedString =  NSAttributedString(string: "\n")
        add(content: newlineAttributedString, in: context)
    }
    
    // Screenplay Title
    func formatAndAdd(screenplayTitle: String, with context: UIGraphicsPDFRendererContext) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35, weight: .heavy),
                                         NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        let attributedTitle = NSAttributedString(string: "\n" + screenplayTitle + "\n\n",
                                                        attributes: attributes)
        
        
        add(content: attributedTitle, in: context)
    }
    
    // Formats Sections - Outline, Characters, Scenes
    func formatAndAdd(sectionTitle: String, with context: UIGraphicsPDFRendererContext) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let sectionTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .bold),
                                      NSAttributedString.Key.paragraphStyle: paragraphStyle]
      
        let attributedTitle = NSAttributedString(string: sectionTitle + "\n",
                                                 attributes: sectionTitleAttributes)
        add(content: attributedTitle, in: context)
    }
    
    // Formats Section Subtitles - Idea, Act 1, Act 2, Act 2
    func formatAndAdd(sectionSubtitle: String, with context: UIGraphicsPDFRendererContext) {
        let sectionTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .semibold)]
        let attributedTitle = NSAttributedString(string:"- " + sectionSubtitle + " -\n",
                                                 attributes: sectionTitleAttributes)
        
        add(content: attributedTitle, in: context)
    }
    
    // Formats "Overall Description" titles
    func formatOverAllDescriptionAndAdd(in context: UIGraphicsPDFRendererContext) {
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .medium)]
        let overAllDescription = NSAttributedString(string: "Overall Description".localized + "\n",
                                                    attributes: attributes)
        
        add(content: overAllDescription, in: context)
    }
    
    // Formats question titles e.g. Old World, Inciting Incident, Call To Action, etc...
    func formatAndAdd(questionTitle: String, with context: UIGraphicsPDFRendererContext) {
        let questionTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .medium)]
        let attributedTitle = NSAttributedString(string: questionTitle, attributes: questionTitleAttributes)
        
        add(content: attributedTitle, in: context)
    }
    
    // Formats question subtitles e.g "What is life like before the story begins?"
    func formatAndAdd(questionSubtitle: String, with context: UIGraphicsPDFRendererContext) {
        let attributes = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 14)]
        let attributedTitle = NSAttributedString(string: questionSubtitle + "\n", attributes: attributes)
        
        add(content: attributedTitle, in: context)
    }
    
    // Formats all user input
    func formatAndAdd(content: String, with context: UIGraphicsPDFRendererContext) {

        if content == "" {
            addNewLine(context: context)
        } else {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .natural
            paragraphStyle.lineBreakMode = .byWordWrapping
            
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                              NSAttributedString.Key.paragraphStyle: paragraphStyle]
            let attributedString = NSAttributedString(string: content + "\n\n\n\n", attributes: attributes)
            add(content: attributedString, in: context)
            addNewLine(context: context)

        }
    }
    
    // Format Character name
    func formatAndAdd(characterName: String, with context: UIGraphicsPDFRendererContext) {
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .semibold)]
        let attributedTitle = NSAttributedString(string: characterName, attributes: attributes)
          
        add(content: attributedTitle, in: context)
    }
    
    func formatAndAdd(characterRole: String, with context: UIGraphicsPDFRendererContext) {
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .light)]
        let attributedTitle = NSAttributedString(string: characterRole + "\n\n", attributes: attributes)
          
        add(content: attributedTitle, in: context)
    }
    
    func formatAndAdd(sceneTitleAndNumber: String, with context: UIGraphicsPDFRendererContext) {
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold)]
        let attributedTitle = NSAttributedString(string: sceneTitleAndNumber, attributes: attributes)
            
        add(content: attributedTitle, in: context)
    }
    
    func formatAndAdd(sceneHeading: String, with context: UIGraphicsPDFRendererContext) {
        if sceneHeading == "" {
            addNewLine(context: context)
        } else {
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .light)]
            let attributedTitle = NSAttributedString(string: sceneHeading + "\n\n", attributes: attributes)
            
            add(content: attributedTitle, in: context)
        }
    }
    
    
    func add(content: NSAttributedString, in context: UIGraphicsPDFRendererContext) {
        /* If adding this string's size plus the current page height is greater than or equal we need to
            • Create new page
            • Add content to new page
            • Reset and update currentPageHeight
         */
        if currentPageHeight + Int(getHeight(for: content)) >= Int(pageHeight) {
            context.beginPage()
            content.draw(in: newScreenplayRect)
            currentPageHeight = Int(getHeight(for: content))+50
            
        /* Else we need to
          • Create rect with y value the height of the currentpageHeight
          • Draw content on current page with new rect
          • Update current page height
        */
        } else {
            let newScreenplayRect = CGRect(x: 50,
                                           y: currentPageHeight,
                                           width: Int(pageWidth)-100,
                                           height: Int(pageHeight))
            content.draw(in: newScreenplayRect)
            currentPageHeight += Int(getHeight(for: content))
        }
        
    }
    
    // Creates Outline Idea section
    func createIdeaSection(with screenplay: Screenplay, with context: UIGraphicsPDFRendererContext) {
        
        // Idea section
        formatAndAdd(sectionSubtitle: Act.idea.title, with: context)
        
        // overall description
        formatOverAllDescriptionAndAdd(in: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.idea, with: context)
        
        // logLine
        formatAndAdd(questionTitle: Act.idea.sectionsTitles[0], with: context)
        formatAndAdd(questionSubtitle: Act.idea.sectionSubTitles[0], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.logLine, with: context)
        
        // intention
        formatAndAdd(questionTitle: Act.idea.sectionsTitles[1], with: context)
        formatAndAdd(questionSubtitle: Act.idea.sectionSubTitles[1], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.centralIntention, with: context)
        
        // obstacle
        formatAndAdd(questionTitle: Act.idea.sectionsTitles[2], with: context)
        formatAndAdd(questionSubtitle: Act.idea.sectionSubTitles[2], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.mainObstacle, with: context)
        
        // themes
        formatAndAdd(questionTitle: Act.idea.sectionsTitles[3], with: context)
        formatAndAdd(questionSubtitle: Act.idea.sectionSubTitles[3], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.theme, with: context)
        
        // notes
        formatAndAdd(questionTitle: Act.idea.sectionsTitles[4], with: context)
        formatAndAdd(questionSubtitle: Act.idea.sectionSubTitles[4], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.notes, with: context)
    }
    
    // Act 1 section
    func createAct1Section(with screenplay: Screenplay, in context: UIGraphicsPDFRendererContext) {
        // Act 1 //
        formatAndAdd(sectionSubtitle: Act.one.title, with: context)
               
        // overall description
        formatOverAllDescriptionAndAdd(in: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.actOneDescription, with: context)
        
        // old world
        formatAndAdd(questionTitle: Act.one.sectionsTitles[0], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[0], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act1.oldWorldDescription, with: context)
              
        // inciting incident
        formatAndAdd(questionTitle: Act.one.sectionsTitles[1], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[1], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act1.incitingIncident, with: context)
        
        // call to action
        formatAndAdd(questionTitle: Act.one.sectionsTitles[2], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[2], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act1.callToAdventure, with: context)
        
        // meet your mentor
        formatAndAdd(questionTitle: Act.one.sectionsTitles[3], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[3], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act1.meetingMentor, with: context)
        
        // themes introduced
        formatAndAdd(questionTitle: Act.one.sectionsTitles[4], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[4], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act1.theme, with: context)
        
        // analysis paralysis
        formatAndAdd(questionTitle: Act.one.sectionsTitles[5], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[5], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act1.refusal, with: context)
        
        // i must go
        formatAndAdd(questionTitle: Act.one.sectionsTitles[6], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[6], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act1.reasonToAdventure, with: context)
        
        // we won't let you go
        formatAndAdd(questionTitle: Act.one.sectionsTitles[7], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[7], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act1.enemyAtTheGates, with: context)
    }
    
    // Act 2 section
    func createAct2Section(with screenplay: Screenplay, in context: UIGraphicsPDFRendererContext) {
        // Act 2
        formatAndAdd(sectionSubtitle: Act.two.title, with: context)
               
        // overall description
        formatOverAllDescriptionAndAdd(in: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.actTwoDescription, with: context)

        // Strange new world
        formatAndAdd(questionTitle: Act.two.sectionsTitles[0], with: context)
        formatAndAdd(questionSubtitle: Act.two.sectionSubTitles[0], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act2.newWorldDescription, with: context)
        
        // friends / foes / frenemies
        formatAndAdd(questionTitle: Act.two.sectionsTitles[1], with: context)
        formatAndAdd(questionSubtitle: Act.two.sectionSubTitles[1], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act2.enemiesFriends, with: context)
        
        // test resolve
        formatAndAdd(questionTitle: Act.two.sectionsTitles[2], with: context)
        formatAndAdd(questionSubtitle: Act.two.sectionSubTitles[2], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act2.obstacles, with: context)
        
        // sharpening the sword
        formatAndAdd(questionTitle: Act.two.sectionsTitles[3], with: context)
        formatAndAdd(questionSubtitle: Act.two.sectionSubTitles[3], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act2.sharpeningTheSword, with: context)
       
        // burn the boats
        formatAndAdd(questionTitle: Act.two.sectionsTitles[4], with: context)
        formatAndAdd(questionSubtitle: Act.two.sectionSubTitles[4], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act2.burnTheBoats, with: context)
        
        // supreme sacrifice
        formatAndAdd(questionTitle: Act.two.sectionsTitles[5], with: context)
        formatAndAdd(questionSubtitle: Act.two.sectionSubTitles[5], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act2.theDeadlyEncounter, with: context)
        
        // celebrate good times
        formatAndAdd(questionTitle: Act.two.sectionsTitles[6], with: context)
        formatAndAdd(questionSubtitle: Act.two.sectionSubTitles[6], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act2.celebrate, with: context)
        
        // empires strikes back
        formatAndAdd(questionTitle: Act.two.sectionsTitles[7], with: context)
        formatAndAdd(questionSubtitle: Act.two.sectionSubTitles[7], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act2.badGuysStrikeBack, with: context)
        
        // darkest before the dawn
        formatAndAdd(questionTitle: Act.two.sectionsTitles[8], with: context)
        formatAndAdd(questionSubtitle: Act.two.sectionSubTitles[8], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act2.allIsLost, with: context)
      
    }
    
    // Act 3 section
    func createAct3Section(with screenplay: Screenplay, in context: UIGraphicsPDFRendererContext) {
        // Act 3
        formatAndAdd(sectionSubtitle: Act.three.title, with: context)
        
        // overall description
        formatOverAllDescriptionAndAdd(in: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.actThreeDescription, with: context)

        // the ultimate answer
        formatAndAdd(questionTitle: Act.three.sectionsTitles[0], with: context)
        formatAndAdd(questionSubtitle: Act.three.sectionSubTitles[0], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act3.theUltimateAnswer, with: context)
        
        // reap rewards
        formatAndAdd(questionTitle: Act.three.sectionsTitles[1], with: context)
        formatAndAdd(questionSubtitle: Act.three.sectionSubTitles[1], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act3.rewards, with: context)
        
        // questions that need answering
        formatAndAdd(questionTitle: Act.three.sectionsTitles[2], with: context)
        formatAndAdd(questionSubtitle: Act.three.sectionSubTitles[2], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act3.untangleStory, with: context)
        
        // brand new world
        formatAndAdd(questionTitle: Act.three.sectionsTitles[3], with: context)
        formatAndAdd(questionSubtitle: Act.three.sectionSubTitles[3], with: context)
        addNewLine(context: context)
        formatAndAdd(content: screenplay.act3.brandNewWorld, with: context)
    }

    func createCharacterSection(with screenplay: Screenplay, in context: UIGraphicsPDFRendererContext) {
        
        for character in screenplay.characters {
            // name
            formatAndAdd(characterName: character.name, with: context)
            // role
            if let role = character.role {
                formatAndAdd(characterRole: role, with: context)
            }
     
            // intention
            formatAndAdd(questionTitle: CharacterSection.sectionTitles[0], with: context)
            formatAndAdd(questionSubtitle: CharacterSection.sectionSubtitles[0], with: context)
            addNewLine(context: context)
            formatAndAdd(content: character.intention, with: context)
                   
            // why
            formatAndAdd(questionTitle: CharacterSection.sectionTitles[1], with: context)
            formatAndAdd(questionSubtitle: CharacterSection.sectionSubtitles[1], with: context)
            addNewLine(context: context)
            formatAndAdd(content: character.whyIntention, with: context)
                              
            // what
            formatAndAdd(questionTitle: CharacterSection.sectionTitles[2], with: context)
            formatAndAdd(questionSubtitle: CharacterSection.sectionSubtitles[2], with: context)
            addNewLine(context: context)
            formatAndAdd(content: character.whatToDo, with: context)
                              
            // how
            formatAndAdd(questionTitle: CharacterSection.sectionTitles[3], with: context)
            formatAndAdd(questionSubtitle: CharacterSection.sectionSubtitles[3], with: context)
            addNewLine(context: context)
            formatAndAdd(content: character.howDoesCharacterDoIt, with: context)
                              
            // obstacles
            formatAndAdd(questionTitle: CharacterSection.sectionTitles[4], with: context)
            formatAndAdd(questionSubtitle: CharacterSection.sectionSubtitles[4], with: context)
            addNewLine(context: context)
            formatAndAdd(content: character.obstacles, with: context)
                              
            // flaws
            formatAndAdd(questionTitle: CharacterSection.sectionTitles[5], with: context)
            formatAndAdd(questionSubtitle: CharacterSection.sectionSubtitles[5], with: context)
            addNewLine(context: context)
            formatAndAdd(content: character.flaws, with: context)
                              
            // problem solved?
            formatAndAdd(questionTitle: CharacterSection.sectionTitles[6], with: context)
            formatAndAdd(questionSubtitle: CharacterSection.sectionSubtitles[6], with: context)
            addNewLine(context: context)
            formatAndAdd(content: character.intentionFix, with: context)
                              
            // need
            formatAndAdd(questionTitle: CharacterSection.sectionTitles[7], with: context)
            formatAndAdd(questionSubtitle: CharacterSection.sectionSubtitles[7], with: context)
            addNewLine(context: context)
            formatAndAdd(content: character.need, with: context)
            
            // changed
            formatAndAdd(questionTitle: CharacterSection.sectionTitles[8], with: context)
            formatAndAdd(questionSubtitle: CharacterSection.sectionSubtitles[8], with: context)
            addNewLine(context: context)
            formatAndAdd(content: character.howCharacterChanged, with: context)
            
            // notes
            formatAndAdd(questionTitle: CharacterSection.sectionTitles[9], with: context)
            formatAndAdd(questionSubtitle: CharacterSection.sectionSubtitles[9], with: context)
            addNewLine(context: context)
            formatAndAdd(content: character.notes, with: context)
        }
    }
    
    func createSceneSection(for scenes: [Scene], in context: UIGraphicsPDFRendererContext) {
        
        var sceneNumber: Int = 1
        for scene in scenes {
            
            // scene number + title
            formatAndAdd(sceneTitleAndNumber: "\(sceneNumber). \(scene.title)", with: context)
            
            // heading
            formatAndAdd(sceneHeading: scene.header, with: context)
            
            // scene description
            formatAndAdd(questionTitle: Scene.sceneTitles[0], with: context)
            formatAndAdd(questionSubtitle: Scene.sceneSubtitles[0], with: context)
            addNewLine(context: context)
            formatAndAdd(content: scene.sceneDescription, with: context)
            
            // characters
            formatAndAdd(questionTitle: Scene.sceneTitles[1], with: context)
            formatAndAdd(questionSubtitle: Scene.sceneSubtitles[1], with: context)
            addNewLine(context: context)
            formatAndAdd(content: scene.characters, with: context)
            
            // dialogue
            formatAndAdd(questionTitle: Scene.sceneTitles[2], with: context)
            formatAndAdd(questionSubtitle: Scene.sceneSubtitles[2], with: context)
            addNewLine(context: context)
            formatAndAdd(content: scene.dialogue, with: context)
            
            // action
            formatAndAdd(questionTitle: Scene.sceneTitles[3], with: context)
            formatAndAdd(questionSubtitle: Scene.sceneSubtitles[3], with: context)
            addNewLine(context: context)
            formatAndAdd(content: scene.action, with: context)
           
            // story progression
            formatAndAdd(questionTitle: Scene.sceneTitles[4], with: context)
            formatAndAdd(questionSubtitle: Scene.sceneSubtitles[4], with: context)
            addNewLine(context: context)
            formatAndAdd(content: scene.howPushesStory, with: context)
            
            // notes
            formatAndAdd(questionTitle: Scene.sceneTitles[5], with: context)
            formatAndAdd(questionSubtitle: Scene.sceneSubtitles[5], with: context)
            addNewLine(context: context)
            formatAndAdd(content: scene.notes, with: context)
            
            sceneNumber += 1
        }
    }
    
}
