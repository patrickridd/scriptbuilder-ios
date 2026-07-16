//
//  ScreenplayPDFRenderer.swift
//  FeatureScreenplays
//
//  Renders the exported screenplay text into a paginated, US-Letter PDF using
//  Core Graphics + Core Text. The result is a clean, printable document that
//  people can email, AirDrop, or save to Files.
//

import Foundation
import CoreGraphics
import CoreText
import Domain

#if canImport(UIKit)
import UIKit
#endif

enum ScreenplayPDFRenderer {

    /// Renders `screenplay` to a temporary PDF file and returns its URL.
    /// Returns `nil` if the file could not be written.
    static func renderToTemporaryFile(_ screenplay: Screenplay) -> URL? {
        let text = ScreenplayExporter.plainText(for: screenplay)
        let stem = ScreenplayExporter.fileNameStem(for: screenplay)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(stem).pdf")

        // US Letter at 72 dpi.
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let margin: CGFloat = 54
        let textRect = pageRect.insetBy(dx: margin, dy: margin)

        let attributed = attributedString(from: text)
        let framesetter = CTFramesetterCreateWithAttributedString(attributed)

        guard let consumer = CGDataConsumer(url: url as CFURL),
              let context = CGContext(consumer: consumer, mediaBox: nil, nil) else {
            return nil
        }

        var mediaBox = pageRect
        var startIndex = 0
        let total = attributed.length

        while startIndex < total {
            context.beginPage(mediaBox: &mediaBox)
            context.textMatrix = .identity
            // Core Text's CTFrameDraw already lays text out top-down in the
            // PDF's native bottom-up coordinate space — no manual flip needed.

            let path = CGPath(rect: textRect, transform: nil)
            let frame = CTFramesetterCreateFrame(
                framesetter,
                CFRange(location: startIndex, length: 0),
                path,
                nil
            )
            CTFrameDraw(frame, context)

            let visible = CTFrameGetVisibleStringRange(frame)
            context.endPage()

            // Guard against a zero-length page (would loop forever).
            if visible.length <= 0 { break }
            startIndex += visible.length
        }

        context.closePDF()
        return url
    }

    // MARK: - Styling

    private static func attributedString(from text: String) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 2
        paragraph.paragraphSpacing = 4

        #if canImport(UIKit)
        let font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        let color = UIColor.black
        #else
        let font = CTFontCreateWithName("Menlo" as CFString, 11, nil)
        let color = CGColor(gray: 0, alpha: 1)
        #endif

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
}
