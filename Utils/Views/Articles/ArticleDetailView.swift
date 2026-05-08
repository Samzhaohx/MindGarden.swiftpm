import SwiftUI

// Minimal Markdown: **bold** only
func boldMarkdownText(_ markdown: String) -> Text {
    var result = Text("")
    var buffer = ""
    var isBold = false

    var i = markdown.startIndex

    while i < markdown.endIndex {
        let ch = markdown[i]

        if ch == "*" {
            let next = markdown.index(after: i)
            if next < markdown.endIndex, markdown[next] == "*" {
           
                if !buffer.isEmpty {
                    let chunk = Text(buffer)
                    result = result + (isBold ? chunk.bold() : chunk)
                    buffer = ""
                }
                isBold.toggle()

                i = markdown.index(i, offsetBy: 2)
                continue
            }
        }

        buffer.append(ch)
        i = markdown.index(after: i)
    }

    if !buffer.isEmpty {
        let chunk = Text(buffer)
        result = result + (isBold ? chunk.bold() : chunk)
    }

    return result
}

struct ArticleDetailView: View {

    let article: Article

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                if let imageName = article.imageName {
                    ZStack {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .offset(y: article.headerOffsetY)   // Per-article header Y offset
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: article.headerHeight)       // Per-article header height
                    .clipped()
                    .cornerRadius(16)
                    .padding(.bottom, 4)
                }


                Text(article.mainTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(article.subtitle)
                    .font(.title3)
                    .foregroundColor(.secondary)

                Divider()
                    .padding(.vertical, 8)

                boldMarkdownText(article.content)
                    .font(.body)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                
                if !article.references.isEmpty {
                    Divider()
                        .padding(.vertical, 12)

                    Text("References (Explainers & Research Summaries)")
                        .font(.headline)
                        .padding(.bottom, 4)

                    Text(article.references)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }

                Spacer()
            }
            .padding()
        }
        .background(Color.FCEDE2.ignoresSafeArea())
    }
}
