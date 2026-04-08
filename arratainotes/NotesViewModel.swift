import Foundation
import LocalAuthentication
import Combine

class NotesViewModel: ObservableObject {

    @Published var notes: [Note] = [] {
        didSet {
            saveNotes()
        }
    }
    
    @Published var customCategories: [String] = [] {
        didSet {
            saveCategories()
        }
    }
    
    @Published var customTodoCategories: [String] = [] {
        didSet {
            saveTodoCategories()
        }
    }
    
    @Published var userName: String = UserDefaults.standard.string(forKey: "user_name") ?? "NoteZy User" {
        didSet {
            UserDefaults.standard.set(userName, forKey: "user_name")
        }
    }
    
    @Published var profileImageIndex: Int = UserDefaults.standard.integer(forKey: "profile_image_index") {
        didSet {
            UserDefaults.standard.set(profileImageIndex, forKey: "profile_image_index")
        }
    }
    
    @Published var profileImageData: Data? = UserDefaults.standard.data(forKey: "profile_image_data") {
        didSet {
            UserDefaults.standard.set(profileImageData, forKey: "profile_image_data")
        }
    }
    
    @Published var appFontSize: Double = UserDefaults.standard.double(forKey: "app_font_size") == 0 ? 16.0 : UserDefaults.standard.double(forKey: "app_font_size") {
        didSet {
            UserDefaults.standard.set(appFontSize, forKey: "app_font_size")
        }
    }
    
    @Published var appearanceTheme: String = UserDefaults.standard.string(forKey: "appearance_theme") ?? "Purple" {
        didSet {
            UserDefaults.standard.set(appearanceTheme, forKey: "appearance_theme")
        }
    }
    
    @Published var isFaceIDEnabled: Bool = UserDefaults.standard.bool(forKey: "is_faceid_enabled") {
        didSet {
            UserDefaults.standard.set(isFaceIDEnabled, forKey: "is_faceid_enabled")
        }
    }
    
    @Published var isLocked: Bool = false
    
    @Published var todos: [Todo] = [] {
        didSet {
            saveTodos()
        }
    }
    
    @Published var searchText: String = ""

    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        } else {
            return notes.filter { 
                $0.title.lowercased().contains(searchText.lowercased())
            }
        }
    }

    let saveKey = "saved_notes"
    let categoriesKey = "saved_categories"
    let todoCategoriesKey = "saved_todo_categories"
    let todosKey = "saved_todos"

    init() {
        loadNotes()
        loadCategories()
        loadTodoCategories()
        loadTodos()
    }

    // MARK: - Todo Logic
    
    func addTodo(title: String, priority: TodoPriority = .medium, category: String = "General", dueDate: Date? = nil) {
        let newTodo = Todo(title: title, priority: priority, category: category, dueDate: dueDate)
        todos.insert(newTodo, at: 0)
    }
    
    func toggleTodo(_ todoId: UUID) {
        if let index = todos.firstIndex(where: { $0.id == todoId }) {
            todos[index].isCompleted.toggle()
        }
    }
    
    func deleteTodo(_ todoId: UUID) {
        todos.removeAll { $0.id == todoId }
    }
    
    func completedTodosCount(for category: String? = nil) -> Int {
        if let category = category {
            return todos.filter { $0.category == category && $0.isCompleted }.count
        }
        return todos.filter { $0.isCompleted }.count
    }
    
    func totalTodosCount(for category: String? = nil) -> Int {
        if let category = category {
            return todos.filter { $0.category == category }.count
        }
        return todos.count
    }
    
    func completionProgress(for category: String? = nil) -> Double {
        let total = totalTodosCount(for: category)
        guard total > 0 else { return 0 }
        return Double(completedTodosCount(for: category)) / Double(total)
    }
    
    var todoCategories: [String] {
        let defaults = ["General", "Work", "Personal", "Shopping", "Health"]
        let fromTodos = todos.map { $0.category }
        let combined = Set(defaults + fromTodos + customTodoCategories)
        return Array(combined).sorted()
    }
    
    func addTodoCategory(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty && !todoCategories.contains(trimmedName) {
            customTodoCategories.append(trimmedName)
        }
    }

    func addNote(title: String, content: String, category: String = "Daily", eventDate: Date? = nil) {
        var newNote = Note(title: title, content: content, category: category, eventDate: eventDate)
        if eventDate != nil {
            newNote.reminderIDs = NotificationManager.shared.scheduleReminders(for: newNote)
        }
        notes.append(newNote)
    }

    func addCategory(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty && !customCategories.contains(trimmedName) {
            customCategories.append(trimmedName)
        }
    }

    func deleteNote(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            if notes.indices.contains(index) {
                NotificationManager.shared.cancelReminders(ids: notes[index].reminderIDs)
                notes.remove(at: index)
            }
        }
    }
    
    func deleteNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            NotificationManager.shared.cancelReminders(ids: notes[index].reminderIDs)
            notes.remove(at: index)
        }
    }
    
    func deleteAllNotes() {
        for note in notes {
            NotificationManager.shared.cancelReminders(ids: note.reminderIDs)
        }
        notes.removeAll()
    }

    func toggleBookmark(_ note: Note) {
        if let index = notes.firstIndex(where: {$0.id == note.id}) {
            notes[index].isBookmarked.toggle()
        }
    }

    func updateNote(note: Note, title: String, content: String, category: String? = nil, eventDate: Date? = nil) {
        if let index = notes.firstIndex(where: {$0.id == note.id}) {
            // Cancel previous reminders
            NotificationManager.shared.cancelReminders(ids: notes[index].reminderIDs)
            
            notes[index].title = title
            notes[index].content = content
            if let category = category {
                notes[index].category = category
            }
            notes[index].eventDate = eventDate
            
            // Schedule new reminders if applicable
            if eventDate != nil {
                notes[index].reminderIDs = NotificationManager.shared.scheduleReminders(for: notes[index])
            } else {
                notes[index].reminderIDs = []
            }
        }
    }

    func deleteNotes(on date: Date) {
        let calendar = Calendar.current
        notes.removeAll { note in
            guard let ed = note.eventDate else { return false }
            return calendar.isDate(ed, inSameDayAs: date)
        }
    }

    var totalNotesCount: Int { notes.count }
    var upcomingEventsCount: Int {
        let now = Date()
        return notes.filter { ($0.eventDate ?? Date.distantPast) > now }.count
    }

    var categories: [String] {
        let defaults = ["Daily", "Work", "Ideas", "Personal", "Quotes"]
        let fromNotes = notes.map { $0.category }
        let combined = Set(defaults + fromNotes + customCategories)
        return Array(combined).sorted()
    }

    func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func saveCategories() {
        UserDefaults.standard.set(customCategories, forKey: categoriesKey)
    }
    
    func saveTodoCategories() {
        UserDefaults.standard.set(customTodoCategories, forKey: todoCategoriesKey)
    }
    
    func saveTodos() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: todosKey)
        }
    }

    func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded
        }
    }
    
    func loadCategories() {
        customCategories = UserDefaults.standard.stringArray(forKey: categoriesKey) ?? []
    }
    
    func loadTodoCategories() {
        customTodoCategories = UserDefaults.standard.stringArray(forKey: todoCategoriesKey) ?? []
    }
    
    func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: todosKey),
           let decoded = try? JSONDecoder().decode([Todo].self, from: data) {
            todos = decoded
        }
        
        if isFaceIDEnabled {
            isLocked = true
        }
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock your notes"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isLocked = false
                    } else {
                        // Handle failure
                    }
                }
            }
        } else {
            // No biometrics available
            self.isLocked = false
        }
    }
    
    // MARK: - Export Logic
    
    func notes(withinDays days: Int) -> [Note] {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) else {
            return notes
        }
        
        return notes.filter { $0.createdAt >= startDate }.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    // MARK: - Agenda Logic
    
    func agendaItems(for date: Date) -> [AgendaItem] {
        let calendar = Calendar.current
        
        let filteredNotes = notes.compactMap { note -> AgendaItem? in
            guard let eventDate = note.eventDate, calendar.isDate(eventDate, inSameDayAs: date) else { return nil }
            return .note(note)
        }
        
        let filteredTodos = todos.compactMap { todo -> AgendaItem? in
            guard let dueDate = todo.dueDate, calendar.isDate(dueDate, inSameDayAs: date) else { return nil }
            return .todo(todo)
        }
        
        return (filteredNotes + filteredTodos).sorted(by: { $0.date < $1.date })
    }
    
    func upcomingAgendaItems(days: Int = 14) -> [AgendaItem] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let endDate = calendar.date(byAdding: .day, value: days, to: today) else { return [] }
        
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        
        let upcomingNotes = notes.compactMap { note -> AgendaItem? in
            guard let eventDate = note.eventDate, eventDate >= tomorrow, eventDate <= endDate else { return nil }
            return .note(note)
        }
        
        let upcomingTodos = todos.compactMap { todo -> AgendaItem? in
            guard let dueDate = todo.dueDate, dueDate >= tomorrow, dueDate <= endDate else { return nil }
            return .todo(todo)
        }
        
        return (upcomingNotes + upcomingTodos).sorted(by: { $0.date < $1.date })
    }
}

enum AgendaItem: Identifiable {
    case note(Note)
    case todo(Todo)
    
    var id: UUID {
        switch self {
        case .note(let note): return note.id
        case .todo(let todo): return todo.id
        }
    }
    
    var date: Date {
        switch self {
        case .note(let note): return note.eventDate ?? note.createdAt
        case .todo(let todo): return todo.dueDate ?? todo.createdAt
        }
    }
    
    var title: String {
        switch self {
        case .note(let note): return note.title
        case .todo(let todo): return todo.title
        }
    }
    
    var category: String {
        switch self {
        case .note(let note): return note.category
        case .todo(let todo): return todo.category
        }
    }
}
