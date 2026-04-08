import Foundation
import UIKit
import PDFKit

class PDFExportManager {
    static let shared = PDFExportManager()
    
    func generatePDF(notes: [Note], title: String) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "NoteZy",
            kCGPDFContextAuthor: "NoteZy App",
            kCGPDFContextTitle: title
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let fileName = "NoteZy_Export_\(Int(Date().timeIntervalSince1970)).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try renderer.writePDF(to: tempURL) { (context) in
                context.beginPage()
                
                var currentY: CGFloat = 50
                let margin: CGFloat = 60
                let contentWidth = pageWidth - (margin * 2)
                
                // Header
                let titleFont = UIFont.systemFont(ofSize: 28, weight: .bold)
                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: titleFont,
                    .foregroundColor: UIColor(red: 0.48, green: 0.38, blue: 1.0, alpha: 1.0) // NoteZy Purple
                ]
                let headerText = "NoteZy"
                headerText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: headerAttributes)
                
                let rangeFont = UIFont.systemFont(ofSize: 14, weight: .bold)
                let rangeAttributes: [NSAttributedString.Key: Any] = [
                    .font: rangeFont,
                    .foregroundColor: UIColor.gray
                ]
                let rangeText = "Range: \(title)"
                let rangeSize = rangeText.size(withAttributes: rangeAttributes)
                rangeText.draw(at: CGPoint(x: pageWidth - margin - rangeSize.width, y: currentY + 10), withAttributes: rangeAttributes)
                currentY += 45
                
                let dateFont = UIFont.systemFont(ofSize: 10, weight: .medium)
                let dateAttributes: [NSAttributedString.Key: Any] = [
                    .font: dateFont,
                    .foregroundColor: UIColor.lightGray
                ]
                let dateText = "Generated on \(Date().formatted(.dateTime.day().month().year().hour().minute()))"
                dateText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: dateAttributes)
                currentY += 30
                
                // Draw a separator line
                context.cgContext.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.5).cgColor)
                context.cgContext.setLineWidth(1.0)
                context.cgContext.move(to: CGPoint(x: margin, y: currentY))
                context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
                context.cgContext.strokePath()
                currentY += 40
                
                if notes.isEmpty {
                    let emptyFont = UIFont.systemFont(ofSize: 14, weight: .medium)
                    let emptyText = "No notes found for this period."
                    emptyText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: [.font: emptyFont, .foregroundColor: UIColor.gray])
                }
                
                for note in notes {
                    // Estimate content height
                    let contentFont = UIFont.systemFont(ofSize: 11, weight: .regular)
                    let contentAttr: [NSAttributedString.Key: Any] = [.font: contentFont]
                    let attributedContent = NSAttributedString(string: note.content, attributes: contentAttr)
                    let textRect = attributedContent.boundingRect(with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                    
                    let totalNoteHeight = 25 + 20 + textRect.height + 40
                    
                    // Check for new page
                    if currentY + totalNoteHeight > pageHeight - margin {
                        context.beginPage()
                        currentY = margin
                    }
                    
                    // Note Title
                    let noteTitleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
                    let noteTitleAttr: [NSAttributedString.Key: Any] = [.font: noteTitleFont, .foregroundColor: UIColor.black]
                    let noteTitle = note.title.isEmpty ? "Untitled Note" : note.title
                    noteTitle.draw(at: CGPoint(x: margin, y: currentY), withAttributes: noteTitleAttr)
                    currentY += 22
                    
                    // Note Date
                    let noteDateFont = UIFont.systemFont(ofSize: 9, weight: .bold)
                    let noteDateAttr: [NSAttributedString.Key: Any] = [.font: noteDateFont, .foregroundColor: UIColor.systemBlue.withAlphaComponent(0.7)]
                    let noteDate = "\(note.createdAt.formatted(.dateTime.day().month().year().hour().minute())) | Category: \(note.category)"
                    noteDate.draw(at: CGPoint(x: margin, y: currentY), withAttributes: noteDateAttr)
                    currentY += 18
                    
                    // Note Content
                    attributedContent.draw(in: CGRect(x: margin, y: currentY, width: contentWidth, height: textRect.height))
                    currentY += textRect.height + 30
                    
                    // Light Separator between notes
                    context.cgContext.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.2).cgColor)
                    context.cgContext.setLineWidth(0.5)
                    context.cgContext.move(to: CGPoint(x: margin, y: currentY - 15))
                    context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: currentY - 15))
                    context.cgContext.strokePath()
                    currentY += 10
                }
            }
            return tempURL
        } catch {
            print("Could not create PDF: \(error)")
            return nil
        }
    }
}
