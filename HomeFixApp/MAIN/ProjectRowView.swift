import SwiftUI
import RealmSwift

struct ProjectRowView: View {
    @ObservedRealmObject var project: RepairProject
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(project.title)
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Text(project.category.title)
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
            
            Text(project.status.title)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.accent.opacity(0.2))
                .foregroundColor(.accent)
                .cornerRadius(8)
        }
        .padding(.vertical, 8)
    }
}
