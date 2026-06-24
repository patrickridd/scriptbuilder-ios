//
//  CustomTextView.swift
//  ScriptStarter
//
//  Created by patrick ridd on 6/14/26.
//  Copyright © 2026 patrickridd. All rights reserved.
//


import UIKit

public class CustomTextView: UITextView, UITextViewDelegate {
    
    public let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter here..."
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholder()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlaceholder()
    }
    
    private func setupPlaceholder() {
        self.delegate = self
        
        // Add the label to the text view hierarchy
        addSubview(placeholderLabel)
        
        // Pin constraints tightly inside the textContainer padding
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5)
        ])
    }
    
    // Toggle label visibility when text edits happen
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
