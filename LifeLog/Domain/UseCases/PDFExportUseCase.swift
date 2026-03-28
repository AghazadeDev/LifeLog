import Foundation
import UIKit

struct PDFExportUseCase {
    func export(days: [DayEntry]) -> URL? {
        let sorted = days.sorted { $0.date < $1.date }
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let contentWidth = pageWidth - margin * 2
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let titleFont = UIFont.boldSystemFont(ofSize: 22)
        let dateFont = UIFont.boldSystemFont(ofSize: 16)
        let bodyFont = UIFont.systemFont(ofSize: 12)
        let captionFont = UIFont.systemFont(ofSize: 10)

        let titleColor = UIColor.label
        let dateColor = UIColor.systemBlue
        let bodyColor = UIColor.label
        let captionColor = UIColor.secondaryLabel

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { context in
            context.beginPage()
            var yOffset: CGFloat = margin

            let title = "LifeLog Journal"
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: titleFont, .foregroundColor: titleColor
            ]
            title.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: titleAttr)
            yOffset += 35

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"

            for day in sorted {
                let notes = day.notes.sorted { $0.createdAt < $1.createdAt }
                let dateStr = dateFormatter.string(from: day.date)
                let moodStr = day.dominantMood.map { " \($0)" } ?? ""
                let header = "\(dateStr)\(moodStr)"

                let headerAttr: [NSAttributedString.Key: Any] = [
                    .font: dateFont, .foregroundColor: dateColor
                ]

                let headerSize = (header as NSString).boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: .usesLineFragmentOrigin,
                    attributes: headerAttr,
                    context: nil
                )

                if yOffset + headerSize.height + 60 > pageHeight - margin {
                    context.beginPage()
                    yOffset = margin
                }

                (header as NSString).draw(
                    in: CGRect(x: margin, y: yOffset, width: contentWidth, height: headerSize.height),
                    withAttributes: headerAttr
                )
                yOffset += headerSize.height + 8

                for note in notes {
                    let time = timeFormatter.string(from: note.createdAt)
                    let moodPrefix = note.mood ?? ""
                    let tagSuffix = note.tags.isEmpty ? "" : " [\(note.tags.joined(separator: ", "))]"
                    let noteText = "\(time) \(moodPrefix) \(note.text)\(tagSuffix)"

                    let bodyAttr: [NSAttributedString.Key: Any] = [
                        .font: bodyFont, .foregroundColor: bodyColor
                    ]

                    let noteSize = (noteText as NSString).boundingRect(
                        with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                        options: .usesLineFragmentOrigin,
                        attributes: bodyAttr,
                        context: nil
                    )

                    if yOffset + noteSize.height + 10 > pageHeight - margin {
                        context.beginPage()
                        yOffset = margin
                    }

                    (noteText as NSString).draw(
                        in: CGRect(x: margin, y: yOffset, width: contentWidth, height: noteSize.height),
                        withAttributes: bodyAttr
                    )
                    yOffset += noteSize.height + 6

                    if let photoData = note.photoData, let image = UIImage(data: photoData) {
                        let maxPhotoHeight: CGFloat = 120
                        let scale = min(contentWidth * 0.5 / image.size.width, maxPhotoHeight / image.size.height)
                        let photoW = image.size.width * scale
                        let photoH = image.size.height * scale

                        if yOffset + photoH + 10 > pageHeight - margin {
                            context.beginPage()
                            yOffset = margin
                        }

                        image.draw(in: CGRect(x: margin, y: yOffset, width: photoW, height: photoH))
                        yOffset += photoH + 10
                    }
                }

                if let summary = day.aiSummary {
                    let summaryAttr: [NSAttributedString.Key: Any] = [
                        .font: captionFont, .foregroundColor: captionColor
                    ]
                    let summarySize = (summary as NSString).boundingRect(
                        with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                        options: .usesLineFragmentOrigin,
                        attributes: summaryAttr,
                        context: nil
                    )

                    if yOffset + summarySize.height + 10 > pageHeight - margin {
                        context.beginPage()
                        yOffset = margin
                    }

                    (summary as NSString).draw(
                        in: CGRect(x: margin, y: yOffset, width: contentWidth, height: summarySize.height),
                        withAttributes: summaryAttr
                    )
                    yOffset += summarySize.height + 10
                }

                yOffset += 15
            }
        }

        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("LifeLog_Journal.pdf")
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
}
