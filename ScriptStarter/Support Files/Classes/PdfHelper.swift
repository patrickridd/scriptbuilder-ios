//
//  PdfHelper.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 11/29/19.
//  Copyright © 2019 patrickridd. All rights reserved.
//

import PDFKit


class PdfHelper {
    
    let pageHeight = 11 * 72.0
    let pageWidth = 8.5 * 72.0
    let newScreenplayRect = CGRect(x: 50, y: 50, width: (8.5 * 72.0)-100, height: 11 * 72.0)
    
    var currentPageHeight: Int = 0

    
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
            
            // Create Outline section
            formatAndAdd(sectionTitle: "Outline".localized, with: context)
            
            // Idea section //
            createIdeaSection(with: screenplay, with: context)
            
            // Act 1 Section //
            createAct1Section(with: screenplay, in: context)
            
            // Act 2 //
            
            // overall description
            
            // friends / foes / frenemies
            
            // test resolve
            
            // sharpening the sword
            
            // burn the boats
            
            // supreme sacrifice
            
            // celebrate good times
            
            // empires strikes back
            
            // darkest before the dawn
            
            
            // Act 3 //
            
            // overall description
            
            // the ultimate answer
            
            // reap rewards
            
            // questions that need answering
            
            // brand new world
            
            
            // Characters //
            
            // name
            // title
            
            // intention
            
            // why
            
            // what
            
            // how
            
            // obstacles
            
            // flaws
            
            // problem solved?
            
            // need
            
            // changed
            
            // notes
            
            
            // Scenes //
            
            // Act 1//
            
            // scene number + title
            
            // heading
            
            // scene description
            
            // characters
            
            // dialogue
            
            // action
            
            // story progression
            
            // notes
            
            
            // Act 2 //
            
            // scenes
            
            
            // Act 3 //
            
            // scenes
            
//            let ideaTitle = "\(Act.idea)\n\n"
//            ideaTitle.
//            let idea = screenplay.idea
//
//            let act1 = screenplay.act1
//            act1.oldWorldDescription
//
//
            // Create Characters section
            
            
            
            // Create Scene section
            
        }
        
        return data
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
        let attributedTitle = NSAttributedString(string: sectionSubtitle + "\n",
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
        print(attributedTitle.size().height)
        
        add(content: attributedTitle, in: context)
    }
    
    // Formats question subtitles e.g "What is life like before the story begins?"
    func formatAndAdd(questionSubtitle: String, with context: UIGraphicsPDFRendererContext) {
        let attributes = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 14)]
        let attributedTitle = NSAttributedString(string: questionSubtitle + ":\n", attributes: attributes)
        print(attributedTitle.size().height)
        
        add(content: attributedTitle, in: context)
    }
    
    // Formats all user input
    func formatAndAdd(content: String, with context: UIGraphicsPDFRendererContext) {
        if content == "" {
            add(content: NSAttributedString(string: "\n"), in: context)
        } else {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .natural
            paragraphStyle.lineBreakMode = .byWordWrapping
            
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                              NSAttributedString.Key.paragraphStyle: paragraphStyle]
            let attributedString = NSAttributedString(string: content + "\n\n\n\n", attributes: attributes)
            add(content: attributedString, in: context)
        }
    }
    
    
    func add(content: NSAttributedString, in context: UIGraphicsPDFRendererContext) {
        /* If adding this string's size plus the current page height is greater than or equal we need to
            • Create new page
            • Add content to new page
            • Reset and update currentPageHeight
         */
        if currentPageHeight + Int(content.size().height) >= Int(pageHeight) {
            context.beginPage()
            content.draw(in: newScreenplayRect)
            currentPageHeight = Int(content.size().height)+50
            
        /* Else we need to
          • Create rect with y value the height of the currentpageHeight
          • Draw content on current page with new rect
          • Update current page height
        */
        } else {
            let newScreenplayRect = CGRect(x: 50, y: currentPageHeight, width: Int(pageWidth)-100, height: Int(pageHeight))
            content.draw(in: newScreenplayRect)
            currentPageHeight += Int(content.size().height)
        }
        
    }
    
    // Creates Outline Idea section
    func createIdeaSection(with screenplay: Screenplay, with context: UIGraphicsPDFRendererContext) {
        
        // Idea section
        formatAndAdd(sectionSubtitle: Act.idea.title, with: context)
        
        // overall description
        formatOverAllDescriptionAndAdd(in: context)
        formatAndAdd(content: screenplay.idea, with: context)
        
        // logLine
        formatAndAdd(questionTitle: Act.idea.sectionsTitles[0], with: context)
        formatAndAdd(questionSubtitle: Act.idea.sectionSubTitles[0], with: context)
        formatAndAdd(content: screenplay.logLine, with: context)
        
        // intention
        formatAndAdd(questionTitle: Act.idea.sectionsTitles[1], with: context)
        formatAndAdd(questionSubtitle: Act.idea.sectionSubTitles[1], with: context)
        formatAndAdd(content: screenplay.centralIntention, with: context)
        
        // obstacle
        formatAndAdd(questionTitle: Act.idea.sectionsTitles[2], with: context)
        formatAndAdd(questionSubtitle: Act.idea.sectionSubTitles[2], with: context)
        formatAndAdd(content: screenplay.mainObstacle, with: context)
        
        // themes
        formatAndAdd(questionTitle: Act.idea.sectionsTitles[3], with: context)
        formatAndAdd(questionSubtitle: Act.idea.sectionSubTitles[3], with: context)
        formatAndAdd(content: screenplay.theme, with: context)
        
        // notes
        formatAndAdd(questionTitle: Act.idea.sectionsTitles[4], with: context)
        formatAndAdd(questionSubtitle: Act.idea.sectionSubTitles[4], with: context)
        formatAndAdd(content: screenplay.notes, with: context)
    }
    
    
    func createAct1Section(with screenplay: Screenplay, in context: UIGraphicsPDFRendererContext) {
        // Act 1 //
        formatAndAdd(sectionSubtitle: Act.one.title, with: context)
               
        // overall description
        formatOverAllDescriptionAndAdd(in: context)
        formatAndAdd(content: screenplay.actOneDescription, with: context)
        
        // old world
        formatAndAdd(questionTitle: Act.one.sectionsTitles[0], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[0], with: context)
        formatAndAdd(content: screenplay.act1.oldWorldDescription, with: context)
              
        // inciting incident
        formatAndAdd(questionTitle: Act.one.sectionsTitles[1], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[1], with: context)
        formatAndAdd(content: screenplay.act1.incitingIncident, with: context)
        
        // call to action
        formatAndAdd(questionTitle: Act.one.sectionsTitles[2], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[2], with: context)
        formatAndAdd(content: screenplay.act1.callToAdventure, with: context)
        
        // meet your mentor
        formatAndAdd(questionTitle: Act.one.sectionsTitles[3], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[3], with: context)
        formatAndAdd(content: screenplay.act1.meetingMentor, with: context)
        
        // themes introduced
        formatAndAdd(questionTitle: Act.one.sectionsTitles[4], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[4], with: context)
        formatAndAdd(content: screenplay.act1.theme, with: context)
        
        // analysis paralysis
        formatAndAdd(questionTitle: Act.one.sectionsTitles[5], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[5], with: context)
        formatAndAdd(content: screenplay.act1.refusal, with: context)
        
        // i must go
        formatAndAdd(questionTitle: Act.one.sectionsTitles[6], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[6], with: context)
        formatAndAdd(content: screenplay.act1.reasonToAdventure, with: context)
        
        // we won't let you go
        formatAndAdd(questionTitle: Act.one.sectionsTitles[7], with: context)
        formatAndAdd(questionSubtitle: Act.one.sectionSubTitles[7], with: context)
        formatAndAdd(content: screenplay.act1.enemyAtTheGates, with: context)
    }

}
