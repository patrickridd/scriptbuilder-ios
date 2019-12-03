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
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        // 3
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        // 4
        let data = renderer.pdfData { (context) in
            // 5
        //    context.beginPage()
                        
            // Mutatble Attributed String that contains ENTIRE screenplay
            let screenplayString = NSMutableAttributedString()

            // Screenplay Title
            screenplayString.append(formatText(screenplayTitle: screenplay.title))
            
            // Create Outline section
            screenplayString.append(formatText(sectionTitle: "Outline".localized))
            
            
            // Idea section //
            screenplayString.append(createIdeaSection(with: screenplay))

            let estimatedSize = CGSize(width: pageWidth-100, height: 1000)
            let estimatedScreenplayRect = screenplayString.boundingRect(with: estimatedSize,
                                                                        options: .usesLineFragmentOrigin,
                                                                        context: nil)
            
            let screenplayRect = CGRect(x: 50, y: 50, width: pageWidth-100, height: 200000000)
            //screenplayString.draw(in: screenplayRect)
            
            let screenplayHeight = Int(screenplayString.size().height)
            let numberOfPages = screenplayHeight/(11 * 72)
            
            for _ in 0...numberOfPages {
                context.beginPage()
                screenplayString.draw(in: screenplayRect)

            }
            
            /////////////
            
            // Act 1 //
            
            // overall description
            
            // old world
            
            // inciting incident
            
            // call to action
            
            // meet your mentor
            
            // themes introduced
            
            // analysis paralysis
            
            // i must go
            
            // we won't let you go
            
            
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
    func formatText(screenplayTitle: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 40),
                                         NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        let attributedTitle = NSAttributedString(string: "\n" + screenplayTitle + "\n\n\n",
                                                        attributes: attributes)
        
        print(attributedTitle.size().height)
        return attributedTitle
        
    }
    
    // Formats Sections - Outline, Characters, Scenes
    func formatText(sectionTitle: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let sectionTitleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30),
                                      NSAttributedString.Key.paragraphStyle: paragraphStyle]
      
        let attributedTitle = NSAttributedString(string: sectionTitle + "\n\n",
                                                 attributes: sectionTitleAttributes)
        print(attributedTitle.size().height)
        return attributedTitle
    }
    
    // Formats Section Subtitles - Idea, Act 1, Act 2, Act 2
    func formatText(sectionSubtitle: String) -> NSAttributedString {
        let sectionTitleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]
        let attributedTitle = NSAttributedString(string: sectionSubtitle + "\n\n",
                                                 attributes: sectionTitleAttributes)
        print(attributedTitle.size().height)
        return attributedTitle
    }
    
    // Formats "Overall Description" titles
    func formatOverAllDescription() -> NSAttributedString {
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
        let overAllDescription = NSAttributedString(string: "Overall Description".localized + "\n\n",
                                                    attributes: attributes)
        
        print(overAllDescription.size().height)
        return overAllDescription
    }
    
    // Formats question titles e.g. Old World, Inciting Incident, Call To Action, etc...
    func format(questionTitle: String) -> NSAttributedString {
        let questionTitleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
        let attributedTitle = NSAttributedString(string: questionTitle + "\n", attributes: questionTitleAttributes)
        print(attributedTitle.size().height)
        return attributedTitle
    }
    
    // Formats question subtitles e.g "What is life like before the story begins?"
    func format(questionSubtitle: String) -> NSAttributedString {
        let attributes = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 14)]
        let attributedTitle = NSAttributedString(string: questionSubtitle + ":\n\n", attributes: attributes)
        print(attributedTitle.size().height)

        return attributedTitle
    }
    
    // Formats all user input
    func format(content: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                          NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let attributedString = NSAttributedString(string: content + "\n\n\n", attributes: attributes)
        print(attributedString.size().height)

        return attributedString
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
            
        /*Else we need to
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
    func createIdeaSection(with screenplay: Screenplay) -> NSAttributedString {
        let ideaSectionString = NSMutableAttributedString()
        
        // Idea section
        ideaSectionString.append(formatText(sectionSubtitle: Act.idea.title))
        
        // overall description
        ideaSectionString.append(formatOverAllDescription())
        ideaSectionString.append(format(content: screenplay.idea))
        
        // logLine
        ideaSectionString.append(format(questionTitle: Act.idea.sectionsTitles[0]))
        ideaSectionString.append(format(questionSubtitle: Act.idea.sectionSubTitles[0]))
        ideaSectionString.append(format(content: screenplay.logLine))
        
        // intention
        ideaSectionString.append(format(questionTitle: Act.idea.sectionsTitles[1]))
        ideaSectionString.append(format(questionSubtitle: Act.idea.sectionSubTitles[1]))
        ideaSectionString.append(format(content: screenplay.centralIntention))
        
        // obstacle
        ideaSectionString.append(format(questionTitle: Act.idea.sectionsTitles[2]))
        ideaSectionString.append(format(questionSubtitle: Act.idea.sectionSubTitles[2]))
        ideaSectionString.append(format(content: screenplay.mainObstacle))
        
        // themes
        ideaSectionString.append(format(questionTitle: Act.idea.sectionsTitles[3]))
        ideaSectionString.append(format(questionSubtitle: Act.idea.sectionSubTitles[3]))
        ideaSectionString.append(format(content: screenplay.theme))
        
        // notes
        ideaSectionString.append(format(questionTitle: Act.idea.sectionsTitles[4]))
        ideaSectionString.append(format(questionSubtitle: Act.idea.sectionSubTitles[4]))
        ideaSectionString.append(format(content: screenplay.notes))
        
        return ideaSectionString
    }
    
    
//    func addBodyText(pageRect: CGRect, textTop: CGFloat) {
//        let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
//        // 1
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.alignment = .natural
//        paragraphStyle.lineBreakMode = .byWordWrapping
//        // 2
//        let textAttributes = [
//            NSAttributedString.Key.paragraphStyle: paragraphStyle,
//            NSAttributedString.Key.font: textFont
//        ]
//        let attributedText = NSAttributedString(
//            string: body,
//            attributes: textAttributes
//        )
//        // 3
//        let textRect = CGRect(
//            x: 10,
//            y: textTop,
//            width: pageRect.width - 20,
//            height: pageRect.height - textTop - pageRect.height / 5.0
//        )
//        attributedText.draw(in: textRect)
//    }
//
//    func addTitle(pageRect: CGRect) -> CGFloat {
//        // 1
//        let titleFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
//        // 2
//        let titleAttributes: [NSAttributedString.Key: Any] =
//            [NSAttributedString.Key.font: titleFont]
//        // 3
//        let attributedTitle = NSAttributedString(
//            string: title,
//            attributes: titleAttributes
//        )
//        // 4
//        let titleStringSize = attributedTitle.size()
//        // 5
//        let titleStringRect = CGRect(
//            x: (pageRect.width - titleStringSize.width) / 2.0,
//            y: 36,
//            width: titleStringSize.width,
//            height: titleStringSize.height
//        )
//        // 6
//        attributedTitle.draw(in: titleStringRect)
//        // 7
//        return titleStringRect.origin.y + titleStringRect.size.height
//    }


}
