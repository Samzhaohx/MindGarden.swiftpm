import SwiftUI

struct GardenBackground: View {
    let imageName: String

    init(imageName: String = "background") {
        self.imageName = imageName
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .opacity(imageName == "background" ? 1 : 0)

                Image("background2")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .opacity(imageName == "background2" ? 1 : 0)
                
                Image("background3")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .opacity(imageName == "background3" ? 1 : 0)
                
                Image("background4")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .opacity(imageName == "background4" ? 1 : 0)
            }
            .animation(.easeInOut(duration: 0.8), value: imageName)
        }
    }
}
