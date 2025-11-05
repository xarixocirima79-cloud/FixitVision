import SwiftUI

struct ToolRowView: View {
    let tool: UserTool
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let photoData = tool.photo, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                } else {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.secondaryText.opacity(0.5))
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tool.name)
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                if let location = tool.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
