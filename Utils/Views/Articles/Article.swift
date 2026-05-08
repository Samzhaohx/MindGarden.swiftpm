import SwiftUI

struct Article: Identifiable, Hashable {
    let id: Int
    let mainTitle: String      
    let subtitle: String       
    let content: String        
    let references: String     
    let imageName: String?     

    /// Header image height
    let headerHeight: CGFloat
    let headerOffsetY: CGFloat

    var fullTitle: String {
        "\(mainTitle)：\(subtitle)"
    }

    init(
        id: Int,
        mainTitle: String,
        subtitle: String,
        content: String,
        references: String,
        imageName: String? = nil,
        headerHeight: CGFloat = 220,
        headerOffsetY: CGFloat = 90
    ) {
        self.id = id
        self.mainTitle = mainTitle
        self.subtitle = subtitle
        self.content = content
        self.references = references
        self.imageName = imageName
        self.headerHeight = headerHeight
        self.headerOffsetY = headerOffsetY
    }
}
