import SwiftUI
import SceneKit

struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HeaderView()
            
            // The 3D Preview Card (Your "Recently Scanned")
            RecentlyScannedCard()
                .frame(height: 250)
                .padding(.horizontal)
            
            // Filters and List
            VStack(alignment: .leading) {
                Text("Previous Projects")
                    .font(.headline)
                    .padding(.leading)
                
                FilterPillsView()
                
                ScrollView {
                    VStack(spacing: 15) {
                        ProjectCard(title: "Cupboard 1", date: "Nov 16, 2025", image: "cupboard")
                        ProjectCard(title: "Living Room", date: "Nov 16, 2025", image: "livingroom")
                    }
                    .padding()
                }
            }
            
            Spacer()
            
            // Custom Tab Bar
            BottomNavBar()
        }
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
}