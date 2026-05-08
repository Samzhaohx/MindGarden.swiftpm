import SwiftUI

struct ArticlesRootView: View {

    @State private var selectedArticleID: Int? = Article1.data.id
    @State private var showHelp = false

    let articles: [Article] = [
        Article1.data,
        Article2.data,
        Article3.data,
        Article4.data,
        Article5.data
    ]

    var body: some View {
        NavigationSplitView {

            // MARK: - Sidebar
            List(selection: $selectedArticleID) {
                    ForEach(articles) { article in
                        VStack(alignment: .leading, spacing: 8) {

                            if let imageName = article.imageName {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(article.mainTitle)
                                    .font(.headline)
                                Text(article.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .tag(article.id)
                    }
                }
            
            .navigationTitle("Contents")

        }detail: {
            ZStack {
                ArticlesView()
                    .opacity(selectedArticleID == nil ? 1 : 0)

                ForEach(articles) { article in
                    ArticleDetailView(article: article)
                        .opacity(selectedArticleID == article.id ? 1 : 0)
                }
            }
            .animation(.smooth, value: selectedArticleID)  
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ArticlesBGMButton()
                    ArticlesHelpButton()
                }
            }
        
        }
        }
    }

