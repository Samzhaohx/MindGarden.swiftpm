import SwiftUI

struct ArticlesView: View {
    var body: some View {
        ZStack {
            Color.FCEDE2
                .ignoresSafeArea()

            ArticleDetailView(article: Article1.data)
            }
        }
    }

