import SwiftUI
import PhotosUI

struct CalendarView: View {
    @EnvironmentObject var vm: NotesViewModel
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showAdd = false
    @State private var showProfile = false
    @State private var showDatePicker = false
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppTheme.backgroundColor(for: vm.appearanceTheme).ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    // Modern Header
                    HStack(alignment: .center) {
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
                        
                        Spacer()
                        
                        Button {
                            showDatePicker = true
                        } label: {
                            Image(systemName: "calendar")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(AppTheme.cardBackground)
                                .clipShape(Circle())
                        }
                        
                        Menu {
                            Button(role: .destructive) {
                                withAnimation {
                                    vm.deleteNotes(on: selectedDate)
                                }
                            } label: {
                                Label("Clear Day's Events", systemImage: "trash")
                            }
                            
                            Button {
                                withAnimation {
                                    selectedDate = Date()
                                }
                            } label: {
                                Label("Back to Today", systemImage: "clock.arrow.circlepath")
                            }
                            
                            Divider()
                            
                            NavigationLink {
                                NoteEditorView()
                                    .environmentObject(vm)
                            } label: {
                                Label("New Quick Note", systemImage: "plus.rectangle.on.rectangle")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(AppTheme.cardBackground)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Calendar")
                            .font(AppTheme.rounded(32, weight: .bold, base: vm.appFontSize))
                            .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                        Text(selectedDate.formatted(date: .long, time: .omitted))
                            .font(AppTheme.rounded(16, weight: .medium, base: vm.appFontSize))
                            .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.5))
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Horizontal Date Tape
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(generateDaysAround(date: selectedDate), id: \.self) { date in
                                    DateTapeCell(
                                        date: date, 
                                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                        hasEvents: !vm.agendaItems(for: date).isEmpty
                                    ) {
                                        withAnimation(.spring()) {
                                            selectedDate = date
                                        }
                                    }
                                    .id(date)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 25)
                        .onChange(of: selectedDate) { newDate in
                            withAnimation(.spring()) {
                                proxy.scrollTo(newDate, anchor: .center)
                            }
                        }
                        .onAppear {
                            proxy.scrollTo(selectedDate, anchor: .center)
                        }
                    }
                    
                    // Timeline Agenda
                    ScrollView {
                        VStack(alignment: .leading, spacing: 32) {
                            // Selected Date Section
                            VStack(alignment: .leading, spacing: 16) {
                                let todayItems = vm.agendaItems(for: selectedDate)
                                
                                Text(calendar.isDateInToday(selectedDate) ? "Today's Schedule" : "Selected Date")
                                    .font(AppTheme.rounded(16, weight: .bold, base: vm.appFontSize))
                                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.4))
                                    .padding(.leading, 4)
                                
                                if todayItems.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "calendar.badge.clock")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.05))
                                        Text("Free day! No events planned.")
                                            .font(AppTheme.rounded(14, weight: .medium, base: vm.appFontSize))
                                            .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.2))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else {
                                    ForEach(todayItems) { item in
                                        UnifiedAgendaCard(item: item)
                                    }
                                }
                            }
                            
                            // Upcoming Items Section
                            let upcomingItems = vm.upcomingAgendaItems()
                            if !upcomingItems.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Coming Up Soon")
                                        .font(AppTheme.rounded(16, weight: .bold, base: vm.appFontSize))
                                        .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.4))
                                        .padding(.leading, 4)
                                    
                                    ForEach(upcomingItems) { item in
                                        UnifiedAgendaCard(item: item, showDate: true)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 120)
                    }
                }
                
                // FAB
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(24)
                        .background(
                            Circle()
                                .fill(AppTheme.accent)
                                .shadow(color: AppTheme.accent.opacity(0.4), radius: 20, x: 0, y: 10)
                        )
                }
                .padding(24)
                .padding(.bottom, 80)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAdd) {
                NoteEditorView(note: nil, initialDate: selectedDate)
                    .environmentObject(vm)
            }
            .sheet(isPresented: $showProfile) {
                ProfileDashboardView()
                    .environmentObject(vm)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showDatePicker) {
                VStack(spacing: 20) {
                    Text("Jump to Date")
                        .font(AppTheme.rounded(24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .tint(AppTheme.accent)
                        .padding(.horizontal)
                    
                    Button {
                        showDatePicker = false
                    } label: {
                        Text("Done")
                            .font(AppTheme.rounded(18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.accent)
                            .clipShape(Capsule())
                    }
                    .padding()
                }
                .background(AppTheme.background.ignoresSafeArea())
                .presentationDetents([.height(500)])
            }
        }
    }
    
    func generateDaysAround(date: Date) -> [Date] {
        var days: [Date] = []
        for i in -15...15 {
            if let d = calendar.date(byAdding: .day, value: i, to: date) {
                days.append(d)
            }
        }
        return days
    }
    
    func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            withAnimation {
                currentMonth = newDate
            }
        }
    }
    
    func isNoteInMonth(_ note: Note, month: Date) -> Bool {
        guard let ed = note.eventDate else { return false }
        return calendar.isDate(ed, equalTo: month, toGranularity: .month)
    }
    
    func generateDaysInMonth(for month: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let offset = (firstWeekday + 5) % 7 // Monday start adjustment
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    func getEventColors(for notes: [Note]) -> [Color] {
        let colors = notes.map { getCategoryColor($0.category) }
        return Array(Set(colors)).prefix(4).map { $0 }
    }
    
    func getCategoryColor(_ cat: String) -> Color {
        switch cat.lowercased() {
        case "work": return AppTheme.workColor
        case "ideas": return AppTheme.ideasColor
        case "personal": return AppTheme.personalColor
        case "quotes": return AppTheme.quotesColor
        default: return AppTheme.accent
        }
    }
}

struct DateTapeCell: View {
    @EnvironmentObject var vm: NotesViewModel
    let date: Date
    let isSelected: Bool
    let hasEvents: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(date.formatted(.dateTime.weekday(.narrow)))
                    .font(AppTheme.rounded(14, weight: .bold, base: vm.appFontSize))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.3))
                
                ZStack(alignment: .bottom) {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(AppTheme.rounded(18, weight: .heavy, base: vm.appFontSize))
                        .foregroundColor(.white)
                        .frame(width: 46, height: 46)
                        .background(
                            isSelected ? 
                            AnyView(LinearGradient(colors: [AppTheme.accent, AppTheme.accent.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)) : 
                            AnyView(Circle().fill(Color.white.opacity(0.08)))
                        )
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.white.opacity(0.2) : Color.clear, lineWidth: 1)
                        )
                    
                    if hasEvents {
                        Circle()
                            .fill(isSelected ? .white : AppTheme.accent)
                            .frame(width: 6, height: 6)
                            .offset(y: 4)
                            .shadow(color: AppTheme.accent.opacity(0.5), radius: 4)
                    }
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 4)
            .background(isSelected ? Color.white.opacity(0.05) : Color.clear)
            .clipShape(Capsule())
        }
    }
}

struct UnifiedAgendaCard: View {
    @EnvironmentObject var vm: NotesViewModel
    let item: AgendaItem
    var showDate: Bool = false
    
    var body: some View {
        Group {
            switch item {
            case .note(let note):
                NavigationLink {
                    NoteEditorView(note: note)
                        .environmentObject(vm)
                } label: {
                    AgendaCardContent(
                        title: note.title.isEmpty ? "Untitled Note" : note.title,
                        subtitle: note.category,
                        time: note.eventDate?.formatted(.dateTime.hour().minute()) ?? "No time",
                        icon: "note.text",
                        color: getCategoryColor(note.category),
                        isCompleted: false,
                        showDate: showDate,
                        date: note.eventDate
                    )
                }
                .buttonStyle(.plain)
                
            case .todo(let todo):
                Button {
                    withAnimation(.spring()) {
                        vm.toggleTodo(todo.id)
                    }
                } label: {
                    AgendaCardContent(
                        title: todo.title,
                        subtitle: todo.category,
                        time: todo.dueDate?.formatted(.dateTime.hour().minute()) ?? "All day",
                        icon: "checklist",
                        color: todo.priority.color,
                        isCompleted: todo.isCompleted,
                        showDate: showDate,
                        date: todo.dueDate
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    func getCategoryColor(_ cat: String) -> Color {
        switch cat.lowercased() {
        case "work": return AppTheme.workColor
        case "ideas": return AppTheme.ideasColor
        case "personal": return AppTheme.personalColor
        case "quotes": return AppTheme.quotesColor
        default: return AppTheme.accent
        }
    }
}

struct AgendaCardContent: View {
    @EnvironmentObject var vm: NotesViewModel
    let title: String
    let subtitle: String
    let time: String
    let icon: String
    let color: Color
    let isCompleted: Bool
    var showDate: Bool = false
    var date: Date?
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Left Side: Time / Date
            VStack(alignment: .trailing, spacing: 4) {
                if showDate, let d = date {
                    Text(d.formatted(.dateTime.day().month(.abbreviated)))
                        .font(AppTheme.rounded(14, weight: .bold, base: vm.appFontSize))
                        .foregroundColor(AppTheme.accent)
                }
                
                Text(time)
                    .font(AppTheme.rounded(12, weight: .semibold, base: vm.appFontSize))
                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.4))
            }
            .frame(width: 65)
            .padding(.top, 14)
            
            // Right Side: Card
            HStack(spacing: 0) {
                Rectangle()
                    .fill(color)
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(AppTheme.rounded(18, weight: .bold, base: vm.appFontSize))
                                .foregroundColor(isCompleted ? AppTheme.textColor(for: vm.appearanceTheme).opacity(0.3) : AppTheme.textColor(for: vm.appearanceTheme))
                                .strikethrough(isCompleted)
                            
                            Text(subtitle)
                                .font(AppTheme.rounded(12, weight: .semibold, base: vm.appFontSize))
                                .foregroundColor(color.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(color)
                            .padding(8)
                            .background(color.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme).opacity(isCompleted ? 0.5 : 1.0))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
}

struct ProfileDashboardView: View {
    @EnvironmentObject var vm: NotesViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isEditingName = false
    @FocusState private var isNameFocused: Bool
    @State private var selectedItem: PhotosPickerItem?
    
    let avatars = ["person.crop.circle.fill", "person.crop.square.fill", "person.circle.fill", "person.badge.plus", "person.2.circle.fill"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor(for: vm.appearanceTheme).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Profile Section with Photo Picker
                        VStack(spacing: 20) {
                            ZStack(alignment: .bottomTrailing) {
                                Group {
                                    if let data = vm.profileImageData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: avatars[vm.profileImageIndex % avatars.count])
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(AppTheme.accent)
                                            .padding(8)
                                            .background(Circle().fill(Color.white.opacity(0.1)))
                                    }
                                }
                                
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    Image(systemName: "camera.fill")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(AppTheme.accent)
                                        .clipShape(Circle())
                                }
                                .onChange(of: selectedItem) { newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            vm.profileImageData = data
                                        }
                                    }
                                }
                            }
                            
                            VStack(spacing: 8) {
                                if isEditingName {
                                    TextField("Your Name", text: $vm.userName, onCommit: {
                                        isEditingName = false
                                    })
                                    .textFieldStyle(.plain)
                                    .font(AppTheme.rounded(28, weight: .bold, base: vm.appFontSize))
                                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                                    .multilineTextAlignment(.center)
                                    .focused($isNameFocused)
                                    .padding(.horizontal, 40)
                                } else {
                                    HStack(spacing: 12) {
                                        Text(vm.userName)
                                            .font(AppTheme.rounded(28, weight: .bold, base: vm.appFontSize))
                                            .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                                        
                                Button {
                                            isEditingName = true
                                            isNameFocused = true
                                        } label: {
                                            Image(systemName: "pencil")
                                                .font(.title3)
                                                .foregroundColor(AppTheme.accent)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 40)
                        
                        // Stats Section
                        HStack(spacing: 16) {
                            StatCardV2(title: "Total Notes", value: "\(vm.totalNotesCount)", icon: "note.text", color: .blue)
                            StatCardV2(title: "Upcoming", value: "\(vm.upcomingEventsCount)", icon: "calendar.day.timeline.left", color: .orange)
                        }
                        .padding(.horizontal)
                        
                        // Quick Links
                        VStack(spacing: 16) {
                            NavigationLink {
                                AppSettingsView()
                                    .environmentObject(vm)
                            } label: {
                                HStack {
                                    Image(systemName: "gearshape.fill")
                                        .iconBox(color: .purple)
                                    Text("App Settings")
                                        .font(AppTheme.rounded(18, weight: .semibold, base: vm.appFontSize))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.bold())
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                .padding()
                                .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                dismiss()
                            } label: {
                                Text("Back to Notes")
                                    .font(AppTheme.rounded(16, weight: .bold, base: vm.appFontSize))
                                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.4))
                                    .padding(.vertical, 10)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct StatCardV2: View {
    @EnvironmentObject var vm: NotesViewModel
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .padding(12)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(AppTheme.rounded(28, weight: .bold, base: vm.appFontSize))
                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                Text(title)
                    .font(AppTheme.rounded(13, weight: .medium, base: vm.appFontSize))
                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

extension View {
    func iconBox(color: Color) -> some View {
        self.foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(color.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension Date {
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }
}
