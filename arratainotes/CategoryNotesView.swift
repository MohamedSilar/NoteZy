import SwiftUI

struct CategoryNotesView: View {
    @EnvironmentObject var vm: NotesViewModel
    @Environment(\.dismiss) var dismiss
    
    let category: String
    
    @State private var showAdd = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var filteredNotes: [Note] {
        vm.notes.filter { $0.category == category }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppTheme.backgroundColor(for: vm.appearanceTheme).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                        .fontWeight(.bold)
                                    Text("Folders")
                                        .font(AppTheme.rounded(16, weight: .bold, base: vm.appFontSize))
                                }
                                .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.6))
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category)
                                .font(AppTheme.rounded(36, weight: .bold, base: vm.appFontSize))
                                .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                            Text("\(filteredNotes.count) notes found")
                                .font(AppTheme.rounded(14, weight: .medium, base: vm.appFontSize))
                                .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.4))
                        }
                        .padding(.horizontal)
                        
                        if filteredNotes.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "folder.badge.minus")
                                    .font(.system(size: 60))
                                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.1))
                                Text("Empty folder")
                                    .font(AppTheme.rounded(18, weight: .semibold, base: vm.appFontSize))
                                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.2))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredNotes) { note in
                                    NavigationLink {
                                        NoteEditorView(note: note)
                                            .environmentObject(vm)
                                    } label: {
                                        NoteCardView(note: note)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
                
                // Floating Action Button
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .padding(22)
                        .background(
                            Circle()
                                .fill(AppTheme.accent)
                                .shadow(color: AppTheme.accent.opacity(0.4), radius: 20, x: 0, y: 12)
                        )
                }
                .padding(24)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAdd) {
                NoteEditorView(note: nil, initialCategory: category)
                    .environmentObject(vm)
            }
        }
    }
}
