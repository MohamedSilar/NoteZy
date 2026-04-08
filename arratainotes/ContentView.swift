import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: NotesViewModel
    @State private var activeTab: AppTab = .notes
    
    enum AppTab { case notes, todo, calendar }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
            AppTheme.backgroundColor(for: vm.appearanceTheme).ignoresSafeArea()
                
                Group {
                    if activeTab == .notes {
                        NotesHomeView()
                    } else if activeTab == .todo {
                        TodoListView()
                    } else {
                        CalendarView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom Bottom Tab Bar
                HStack {
                    TabItem(icon: "note.text", label: "Notes", isSelected: activeTab == .notes) {
                        activeTab = .notes
                    }
                    
                    Spacer()
                    
                    TabItem(icon: "checklist", label: "To-do", isSelected: activeTab == .todo) {
                        activeTab = .todo
                    }
                    
                    Spacer()
                    
                    TabItem(icon: "calendar", label: "Calendar", isSelected: activeTab == .calendar) {
                        activeTab = .calendar
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 18)
                .background(
                    AppTheme.cardBackgroundColor(for: vm.appearanceTheme)
                        .opacity(0.9)
                        .background(.ultraThinMaterial)
                )
                .clipShape(Capsule())
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
            .toolbar(.hidden)
        }
    }
}

struct NotesHomeView: View {
    @EnvironmentObject var vm: NotesViewModel
    @State private var showAdd = false
    @State private var showAddFolder = false
    @State private var newFolderName = ""
    @State private var selectedSubTab = 0 // 0: All, 1: Folders
    @State private var isSearchActive = false
    @FocusState private var isSearchFocused: Bool
    @State private var showProfile = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // Header
                    HStack(spacing: 12) {
                        if isSearchActive {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white.opacity(0.4))
                                
                                TextField("Search by title...", text: $vm.searchText)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(.white)
                                    .font(AppTheme.rounded(16, weight: .medium))
                                    .focused($isSearchFocused)
                                
                                if !vm.searchText.isEmpty {
                                    Button {
                                        vm.searchText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white.opacity(0.4))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(AppTheme.accent.opacity(0.3), lineWidth: 1)
                            )
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            
                            Button {
                                withAnimation(.spring()) {
                                    isSearchActive = false
                                    vm.searchText = ""
                                }
                            } label: {
                                Text("Cancel")
                                    .font(AppTheme.rounded(16, weight: .bold, base: vm.appFontSize))
                                    .foregroundColor(AppTheme.accent)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 0) {
                                    Text("N")
                                        .foregroundColor(AppTheme.accent)
                                    Text("oteZy")
                                        .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                                }
                                .font(AppTheme.rounded(34, weight: .bold, base: vm.appFontSize))
                                
                                Text("Organize your thoughts")
                                    .font(AppTheme.rounded(14, weight: .medium, base: vm.appFontSize))
                                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.4))
                            }
                            .transition(.move(edge: .leading).combined(with: .opacity))
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.spring()) {
                                    isSearchActive = true
                                    isSearchFocused = true
                                }
                            } label: {
                                Image(systemName: "magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.6))
                                    .padding(12)
                                    .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme))
                                    .clipShape(Circle())
                            }
                            
                            Button {
                                showProfile = true
                            } label: {
                                Group {
                                    if let data = vm.profileImageData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 44, height: 44)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .frame(width: 44, height: 44)
                                            .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.8))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Tab Selector
                    HStack(spacing: 30) {
                        TabButtonV2(title: "All", isSelected: selectedSubTab == 0) { selectedSubTab = 0 }
                        TabButtonV2(title: "Folders", isSelected: selectedSubTab == 1) { selectedSubTab = 1 }
                    }
                    .padding(.horizontal)
                    
                    if selectedSubTab == 0 {
                        // All Notes Grid
                        if vm.filteredNotes.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: vm.searchText.isEmpty ? "note.text" : "magnifyingglass")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.1))
                                Text(vm.searchText.isEmpty ? "No notes yet" : "No results for \"\(vm.searchText)\"")
                                    .font(AppTheme.rounded(18, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.2))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(vm.filteredNotes) { note in
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
                    } else {
                        // Folders Grid
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(vm.categories, id: \.self) { category in
                                NavigationLink {
                                    CategoryNotesView(category: category)
                                        .environmentObject(vm)
                                } label: {
                                    FolderCardView(title: category, count: vm.notes.filter { $0.category == category }.count)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 120)
                }
            }
            
            // FABs
            VStack(spacing: 16) {
                if selectedSubTab == 1 {
                    Button {
                        showAddFolder = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(18)
                            .background(
                                Circle()
                                    .fill(AppTheme.accent.opacity(0.8))
                                    .shadow(color: AppTheme.accent.opacity(0.2), radius: 10, x: 0, y: 5)
                            )
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Add Note Button
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
                                .shadow(color: AppTheme.accent.opacity(0.3), radius: 15, x: 0, y: 8)
                        )
                }
            }
            .padding(24)
            .padding(.bottom, 80) // Offset for custom tab bar
        }
        .sheet(isPresented: $showAdd) {
            NoteEditorView()
                .environmentObject(vm)
        }
        .alert("New Folder", isPresented: $showAddFolder) {
            TextField("Folder Name", text: $newFolderName)
                .foregroundColor(.black)
            Button("Cancel", role: .cancel) { newFolderName = "" }
            Button("Create") {
                withAnimation {
                    vm.addCategory(newFolderName)
                    newFolderName = ""
                }
            }
        } message: {
            Text("Enter a name for your new folder.")
        }
        .sheet(isPresented: $showProfile) {
            ProfileDashboardView()
                .environmentObject(vm)
                .presentationDetents([.medium])
        }
    }
}

struct TabItem: View {
    @EnvironmentObject var vm: NotesViewModel
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? AppTheme.accent : AppTheme.textColor(for: vm.appearanceTheme).opacity(0.4))
                
                Text(label)
                    .font(AppTheme.rounded(10, weight: .bold, base: vm.appFontSize))
                    .foregroundColor(isSelected ? AppTheme.accent : AppTheme.textColor(for: vm.appearanceTheme).opacity(0.4))
            }
        }
    }
}

struct TabButtonV2: View {
    @EnvironmentObject var vm: NotesViewModel
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(AppTheme.rounded(20, weight: .bold, base: vm.appFontSize))
                    .foregroundColor(isSelected ? AppTheme.textColor(for: vm.appearanceTheme) : AppTheme.textColor(for: vm.appearanceTheme).opacity(0.3))
                
                Circle()
                    .fill(isSelected ? AppTheme.accent : Color.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .buttonStyle(.plain)
    }
}
