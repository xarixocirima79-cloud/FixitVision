import SwiftUI
import RealmSwift

struct MyStuffView: View {
    @ObservedResults(UserTool.self, sortDescriptor: SortDescriptor(keyPath: "name", ascending: true)) var tools
    
    @State private var isShowingAddToolSheet = false
    
    var body: some View {
        NavigationStack {
            Group {
                if tools.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(tools) { tool in
                            ToolRowView(tool: tool)
                        }
                        .onDelete(perform: $tools.remove)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My Tools")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isShowingAddToolSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddToolSheet) {
                AddToolView()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 70))
                .foregroundColor(.accent.opacity(0.7))
            
            Text("Your Personal Tool Inventory")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Tap the '+' button to add tools you own, including their photos and where you keep them.")
                .font(.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    MyStuffView()
}
