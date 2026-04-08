import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject var vm: NotesViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    @State private var showThemePicker = false
    @State private var showFontPicker = false
    @State private var showDeveloperCredit = false
    @State private var notificationsEnabled = true
    @State private var showingDeleteAll = false
    @State private var showingExportRange = false
    @State private var exportURL: ExportItem? = nil
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        hapticFeedback()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(12)
                            .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(AppTheme.rounded(20, weight: .bold, base: vm.appFontSize))
                        .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                    
                    Spacer()
                    
                    Circle().fill(Color.clear).frame(width: 44)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Section: Account
                        SettingsSection(title: "Account") {
                            Button {
                                hapticFeedback()
                                // Navigate to profile editor or show alert
                            } label: {
                                SettingsRow(icon: "person.fill", title: "Profile Info", value: vm.userName, color: .blue)
                            }
                        }
                        
                        // Section: Preferences
                        SettingsSection(title: "Preferences") {
                            Button {
                                hapticFeedback()
                                showThemePicker = true
                            } label: {
                                SettingsRow(icon: "paintbrush.fill", title: "App Theme", value: vm.appearanceTheme, color: AppTheme.accent)
                            }
                            
                            Button {
                                hapticFeedback()
                                showFontPicker = true
                            } label: {
                                SettingsRow(icon: "textformat.size", title: "Font Size", value: "\(Int(vm.appFontSize))pt", color: .orange)
                            }
                            
                            SettingsToggleRow(icon: "bell.fill", title: "Notifications", isOn: $notificationsEnabled, color: .red)
                        }
                        .environmentObject(vm)
                        
                        // Section: Security & Data
                        SettingsSection(title: "Security & Data") {
                            Button {
                                hapticFeedback()
                                showingExportRange = true
                            } label: {
                                SettingsRow(icon: "doc.text.fill", title: "Export Notes (PDF)", value: "Save to Files", color: .blue)
                            }
                            
                            Button {
                                hapticFeedback()
                                showingDeleteAll = true
                            } label: {
                                SettingsRow(icon: "trash.fill", title: "Clear All Data", color: .red, isDestructive: true)
                            }
                        }
                        
                        // Section: About
                        SettingsSection(title: "NoteZy") {
                            Button {
                                hapticFeedback()
                                showDeveloperCredit = true
                            } label: {
                                SettingsRow(icon: "cpu.fill", title: "Developer", value: "Mohamed Silar", color: .orange)
                            }
                        }
                        
                        Text("Version 1.2.0 (Build 42)")
                            .font(AppTheme.rounded(12, weight: .medium, base: vm.appFontSize))
                            .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.15))
                            .padding(.bottom, 60)
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Delete All Data?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Everything", role: .destructive) {
                hapticFeedback(style: .heavy)
                vm.deleteAllNotes()
            }
        } message: {
            Text("This action cannot be undone. All your notes and calendar events will be permanently removed from NoteZy.")
        }
        .sheet(isPresented: $showThemePicker) {
            ThemePickerView()
                .environmentObject(vm)
                .presentationDetents([.height(350)])
        }
        .sheet(isPresented: $showFontPicker) {
            FontPickerView()
                .environmentObject(vm)
                .presentationDetents([.height(280)])
        }
        .sheet(isPresented: $showDeveloperCredit) {
            DeveloperCreditView()
                .presentationDetents([.medium])
        }
        .sheet(item: $exportURL) { item in
            ActivityView(activityItems: [item.url])
        }
        .confirmationDialog("Export Range", isPresented: $showingExportRange, titleVisibility: .visible) {
            Button("Last 15 Days") { exportNotes(days: 15) }
            Button("Last 30 Days") { exportNotes(days: 30) }
            Button("Last 90 Days") { exportNotes(days: 90) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Select the period you want to export. All notes within this range will be saved as a PDF.")
        }
        .alert("Clear All Data", isPresented: $showingDeleteAll) {
            Button("Delete", role: .destructive) {
                hapticFeedback(style: .heavy)
                vm.deleteAllNotes()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all your notes and categories. This action cannot be undone.")
        }
    }
    
    private func exportNotes(days: Int) {
        let exportNotes = vm.notes(withinDays: days)
        if let url = PDFExportManager.shared.generatePDF(notes: exportNotes, title: "Last \(days) Days") {
            self.exportURL = ExportItem(url: url)
        }
    }
    
    private func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Subviews & Components

struct ThemePickerView: View {
    @EnvironmentObject var vm: NotesViewModel
    @Environment(\.dismiss) var dismiss
    
    let themes = ["Purple", "Dark", "Light"]
    let colors: [Color] = [AppTheme.accent, Color.black, Color.white]
    
    var body: some View {
        ZStack {
            AppTheme.cardBackgroundColor(for: vm.appearanceTheme).ignoresSafeArea()
            VStack(spacing: 32) {
                Text("Select App Theme")
                    .font(AppTheme.rounded(22, weight: .bold, base: vm.appFontSize))
                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                
                HStack(spacing: 40) {
                    ForEach(0..<themes.count, id: \.self) { index in
                        Button {
                            withAnimation(.spring()) {
                                vm.appearanceTheme = themes[index]
                            }
                        } label: {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(colors[index])
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Circle()
                                                .stroke(vm.appearanceTheme == themes[index] ? AppTheme.accent : Color.white.opacity(0.1), lineWidth: 3)
                                        )
                                        .shadow(color: colors[index].opacity(0.3), radius: 10, x: 0, y: 5)
                                    
                                    if vm.appearanceTheme == themes[index] {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(themes[index] == "Light" ? .black : .white)
                                            .font(.system(size: 20, weight: .bold))
                                    }
                                }
                                
                                Text(themes[index])
                                    .font(AppTheme.rounded(15, weight: .bold, base: vm.appFontSize))
                                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                            }
                        }
                    }
                }
                .padding()
                
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(AppTheme.rounded(18, weight: .bold, base: vm.appFontSize))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.accent)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
            }
            .padding(.vertical, 30)
        }
    }
}

struct FontPickerView: View {
    @EnvironmentObject var vm: NotesViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.cardBackgroundColor(for: vm.appearanceTheme).ignoresSafeArea()
            VStack(spacing: 30) {
                Text("Adjust Font Size")
                    .font(AppTheme.rounded(20, weight: .bold, base: vm.appFontSize))
                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                
                VStack(spacing: 10) {
                    Slider(value: $vm.appFontSize, in: 12...24, step: 1)
                        .tint(AppTheme.accent)
                    
                    Text("Sample Note Text (\(Int(vm.appFontSize))pt)")
                        .font(AppTheme.rounded(vm.appFontSize, base: vm.appFontSize))
                        .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.6))
                        .padding()
                        .background(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 30)
                
                Button("Done") { dismiss() }
                    .font(AppTheme.rounded(16, weight: .bold, base: vm.appFontSize))
                    .foregroundColor(AppTheme.accent)
            }
        }
    }
}

struct DeveloperCreditView: View {
    @EnvironmentObject var vm: NotesViewModel
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "cpu.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.accent)
                    .padding()
                    .background(Circle().fill(AppTheme.accent.opacity(0.1)))
                
                VStack(spacing: 8) {
                    Text("Mohamed Silar")
                        .font(AppTheme.rounded(32, weight: .bold, base: vm.appFontSize))
                        .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                    Text("Lead Product Developer")
                        .font(AppTheme.rounded(16, weight: .semibold, base: vm.appFontSize))
                        .foregroundColor(AppTheme.accent)
                }
                
                Text("Mohamed is a passionate software engineer focused on building premium, user-centric experiences. NoteZy is a testament to clean design and functional excellence.")
                    .font(AppTheme.rounded(16, base: vm.appFontSize))
                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                HStack(spacing: 20) {
                    LinkButton(icon: "globe", title: "Website", url: "https://silar.netlify.app")
                    LinkButton(icon: "link", title: "LinkedIn", url: "https://www.linkedin.com/in/mohamed-silar-374a09284")
                }
                .padding(.bottom, 40)
            }
            .padding(.top, 40)
        }
    }
}

struct LinkButton: View {
    @EnvironmentObject var vm: NotesViewModel
    let icon: String
    let title: String
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url) ?? URL(string: "https://google.com")!) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(AppTheme.rounded(14, weight: .bold, base: vm.appFontSize))
            .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
    }
}

struct SettingsSection<Content: View>: View {
    @EnvironmentObject var vm: NotesViewModel
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppTheme.rounded(14, weight: .bold, base: vm.appFontSize))
                .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.3))
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

struct SettingsRow: View {
    @EnvironmentObject var vm: NotesViewModel
    let icon: String
    let title: String
    var value: String? = nil
    let color: Color
    var isDestructive: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(title)
                .font(AppTheme.rounded(16, weight: .medium, base: vm.appFontSize))
                .foregroundColor(isDestructive ? .red : AppTheme.textColor(for: vm.appearanceTheme))
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(AppTheme.rounded(14, base: vm.appFontSize))
                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.4))
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.2))
        }
        .padding()
        .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme))
    }
}

struct SettingsToggleRow: View {
    @EnvironmentObject var vm: NotesViewModel
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Toggle(title, isOn: $isOn)
                .font(AppTheme.rounded(16, weight: .medium, base: vm.appFontSize))
                .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                .tint(AppTheme.accent)
        }
        .padding()
        .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme))
    }
}

struct ExportItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
