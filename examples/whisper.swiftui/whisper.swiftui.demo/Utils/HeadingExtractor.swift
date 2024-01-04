//
//  HeadingWalker.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/4/24.
//

import Markdown

struct Heading2Extractor: MarkupWalker {
    var currentHeading: String?
    var textUnderHeading: String = ""
    var extractedHeadings: [String: String] = [:]

    mutating func visitHeading(_ heading: Heading) {
        if heading.level == 2 {
            // Save the previous heading and its text
            if let currentHeading = currentHeading {
                extractedHeadings[currentHeading] = textUnderHeading.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            // Reset for the new heading
            currentHeading = heading.plainText
            textUnderHeading = ""
        } else if currentHeading != nil {
            // Save and reset if we encounter a new heading of any level
            extractedHeadings[currentHeading!] = textUnderHeading.trimmingCharacters(in: .whitespacesAndNewlines)
            currentHeading = nil
            textUnderHeading = ""
        }
        descendInto(heading)
    }

    mutating func visitText(_ text: Text) {
        if currentHeading != nil {
            textUnderHeading += text.plainText + " "
        }
        descendInto(text)
    }

    // Called after visiting all nodes to handle the last heading
    mutating func finalizeExtractedHeadings() {
        if let currentHeading = currentHeading {
            extractedHeadings[currentHeading] = textUnderHeading.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

struct HeadingBulletsExtractor: MarkupWalker {
    var currentHeading: String?
    var currentTextItems: [String] = []
    var extractedHeadings: [String: [String]] = [:]

    mutating func visitHeading(_ heading: Heading) {
        if heading.level == 2 {
            // Save the previous heading and its text
            if let currentHeading = currentHeading {
                extractedHeadings[currentHeading] = currentTextItems
            }

            // Reset for the new heading
            currentHeading = heading.plainText
            currentTextItems = []
        } else if currentHeading != nil {
            // Save and reset if we encounter a new heading of any level
            extractedHeadings[currentHeading!] = currentTextItems
            currentHeading = nil
            currentTextItems = []
        }
        descendInto(heading)
    }

    mutating func visitListItem(_ listItem: ListItem) {
        if currentHeading != nil {
            // Extract text from listItem's child nodes
            let itemText = extractText(from: listItem)
            currentTextItems.append(itemText.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        descendInto(listItem)  // This will ensure that the children of the listItem are visited.
    }
    
    // Function to extract text from any BlockContainer (like ListItem)
    private func extractText(from blockContainer: BlockContainer) -> String {
        var text = ""

        for child in blockContainer.children {
            if let paragraph = child as? Paragraph {
                // Extract text from Paragraph
                for inline in paragraph.inlineChildren {
                    if let textElement = inline as? Text {
                        text += textElement.string
                    }
                    // Handle other inline content types if necessary
                }
            }
            // Add additional cases here for other specific block types if needed
        }

        return text
    }

    mutating func visitParagraph(_ paragraph: Paragraph) {
        if currentHeading != nil && currentTextItems.isEmpty {
            // Add paragraph text only if there are no list items yet
            let paraText = paragraph.plainText.trimmingCharacters(in: .whitespacesAndNewlines)
            currentTextItems.append(paraText)
        }
        descendInto(paragraph)
    }

    // Called after visiting all nodes to handle the last heading
    mutating func finalizeExtractedHeadings() {
        if let currentHeading = currentHeading {
            extractedHeadings[currentHeading] = currentTextItems
        }
    }
}
