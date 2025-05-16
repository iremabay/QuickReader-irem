import Foundation

class RSSParser: NSObject, XMLParserDelegate {
    private var newsItems: [NewsItem] = []
    private var currentElement = ""
    private var currentTitle = ""
    private var currentDescription = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentImageURL = ""
    private var completionHandler: (([NewsItem]) -> Void)?

    func parseFeed(url: String, completion: @escaping ([NewsItem]) -> Void) {
        self.completionHandler = completion
        guard let feedURL = URL(string: url) else { return }
        let parser = XMLParser(contentsOf: feedURL)
        parser?.delegate = self
        parser?.parse()
    }

    // MARK: - XMLParserDelegate Methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currentTitle = ""
            currentDescription = ""
            currentLink = ""
            currentPubDate = ""
            currentImageURL = ""
        }

        // Görsel URL’lerini yakala (BBC & Guardian)
        if currentElement == "media:content", let url = attributeDict["url"] {
            currentImageURL = url
        }
        if currentElement == "enclosure", let url = attributeDict["url"] {
            currentImageURL = url
        }
        if currentElement == "media:thumbnail", let url = attributeDict["url"] {
            currentImageURL = url
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !data.isEmpty {
            switch currentElement {
            case "title": currentTitle += data
            case "description": currentDescription += data
            case "link": currentLink += data
            case "pubDate": currentPubDate += data
            default: break
            }
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let cleanDescription = currentDescription.htmlToPlainText()

            let newsItem = NewsItem(
                title: currentTitle,
                description: cleanDescription,
                link: currentLink,
                pubDate: currentPubDate,
                imageURL: currentImageURL
            )
            newsItems.append(newsItem)
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        completionHandler?(newsItems)
    }
}

// MARK: - HTML Tag Temizleme Extension
extension String {
    func htmlToPlainText() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        if let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil) {
            return attributedString.string
        }
        return self
    }
}

