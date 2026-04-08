import SwiftUI

struct NoteEditorView: View {
    @EnvironmentObject var vm: NotesViewModel
    @Environment(\.dismiss) var dismiss

    let note: Note?

    @State private var title: String
    @State private var content: String
    @State private var category: String
    @State private var eventDate: Date?
    @State private var isEvent: Bool
    
    let categories = ["Daily", "Work", "Ideas", "Personal", "Quotes"]

    init(note: Note? = nil, initialCategory: String? = nil, initialDate: Date? = nil) {
        self.note = note
        _title = State(initialValue: note?.title ?? "")
        _content = State(initialValue: note?.content ?? "")
        _category = State(initialValue: note?.category ?? initialCategory ?? "Daily")
        _eventDate = State(initialValue: note?.eventDate ?? initialDate)
        _isEvent = State(initialValue: note?.eventDate != nil || initialDate != nil)
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundColor(for: vm.appearanceTheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .fontWeight(.bold)
                            Text("Back")
                                .font(AppTheme.rounded(16, weight: .bold, base: vm.appFontSize))
                        }
                        .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.6))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        if let note {
                            Button(role: .destructive) {
                                withAnimation {
                                    vm.deleteNote(note)
                                }
                                dismiss()
                            } label: {
                                Image(systemName: "trash")
                                    .font(.title3)
                                    .foregroundColor(.red.opacity(0.7))
                            }
                        }
                        
                        Button {
                            let finalDate = isEvent ? (eventDate ?? Date()) : nil
                            if let note {
                                vm.updateNote(note: note, title: title, content: content, category: category, eventDate: finalDate)
                            } else {
                                vm.addNote(title: title, content: content, category: category, eventDate: finalDate)
                            }
                            dismiss()
                        } label: {
                            Text("Done")
                                .font(AppTheme.rounded(16, weight: .bold, base: vm.appFontSize))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(AppTheme.accent)
                                .clipShape(Capsule())
                        }
                        .disabled(title.isEmpty && content.isEmpty)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 20) {
                            TextField("Enter the title here", text: $title)
                                .font(AppTheme.rounded(32, weight: .bold, base: vm.appFontSize))
                                .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                                .accentColor(AppTheme.accent)
                            
                            // Event Scheduling Toggle
                            VStack(spacing: 16) {
                                Toggle(isOn: $isEvent.animation()) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "calendar")
                                            .foregroundColor(isEvent ? AppTheme.accent : AppTheme.textColor(for: vm.appearanceTheme).opacity(0.3))
                                        Text("Schedule Reminder")
                                            .font(AppTheme.rounded(16, weight: .bold, base: vm.appFontSize))
                                            .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                                    }
                                }
                                .tint(AppTheme.accent)
                                .padding()
                                .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                
                                if isEvent {
                                    DatePicker("Event Date", selection: Binding(
                                        get: { eventDate ?? Date() },
                                        set: { eventDate = $0 }
                                    ))
                                    .datePickerStyle(.graphical)
                                    .accentColor(AppTheme.accent)
                                    .colorScheme(vm.appearanceTheme == "Light" ? .light : .dark)
                                    .padding()
                                    .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                }
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if content.isEmpty {
                                    Text("Enter the content here")
                                        .font(AppTheme.rounded(18, weight: .medium, base: vm.appFontSize))
                                        .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.15))
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                }
                                TextEditor(text: $content)
                                    .font(AppTheme.rounded(18, weight: .medium, base: vm.appFontSize))
                                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.7))
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .accentColor(AppTheme.accent)
                            }
                            .frame(minHeight: 300)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
