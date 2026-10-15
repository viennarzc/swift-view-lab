import SwiftUI

struct CatalogView: View {
    @State private var selection: Study?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selection) {
                Section {
                    CatalogIntroduction()
                }
                ForEach(StudyCategory.allCases) { category in
                    Section {
                        ForEach(Study.allCases.filter { $0.category == category }) { study in
                            NavigationLink(value: study) {
                                StudyRow(study: study)
                            }
                        }
                    } header: {
                        Text(category.title)
                    }
                }
            }
            .navigationTitle("Components")
        } detail: {
            if let selection {
                selection.destination
            } else {
                ContentUnavailableView(
                    "Choose a study",
                    systemImage: "square.stack.3d.up",
                    description: Text("Explore the same idea in SwiftUI and UIKit.")
                )
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

private struct CatalogIntroduction: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("A small laboratory for interfaces.")
                .font(.title3.weight(.semibold))
            Text("Paired studies in SwiftUI and UIKit. Try the interaction, change the settings, and compare the implementation.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

private struct StudyRow: View {
    let study: Study

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: study.symbol)
                .font(.title2)
                .foregroundStyle(.indigo)
                .frame(width: 36, height: 44)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                Text(study.title).font(.headline)
                Text(study.summary).font(.subheadline).foregroundStyle(.secondary)
                Text("SwiftUI + UIKit").font(.caption.weight(.medium)).foregroundStyle(.indigo)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    CatalogView()
}
