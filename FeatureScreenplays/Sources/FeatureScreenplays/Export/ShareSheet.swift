//
//  ShareSheet.swift
//  FeatureScreenplays
//
//  A thin SwiftUI wrapper around `UIActivityViewController` so screenplays can
//  be shared via AirDrop, Messages, Mail, Files, and more with the native sheet.
//

import SwiftUI

#if canImport(UIKit)
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
#endif
