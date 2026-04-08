import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var vm: NotesViewModel
    @State private var newTodoTitle = ""
    @State private var selectedPriority: TodoPriority = .medium
    @State private var selectedCategory: String = "General"
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @FocusState private var isFieldFocused: Bool
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor(for: vm.appearanceTheme).ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header with Progress
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(selectedCategory) Progress")
                            .font(AppTheme.rounded(14, weight: .bold, base: vm.appFontSize))
                            .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.4))
                        
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text("\(Int(vm.completionProgress(for: selectedCategory) * 100))%")
                                .font(AppTheme.rounded(44, weight: .bold, base: vm.appFontSize))
                                .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                            
                            Text("\(vm.completedTodosCount(for: selectedCategory))/\(vm.totalTodosCount(for: selectedCategory)) Completed")
                                .font(AppTheme.rounded(14, weight: .semibold, base: vm.appFontSize))
                                .foregroundColor(AppTheme.accent)
                        }
                    }
                    
                    Spacer()
                    
                    // Circular Progress
                    ZStack {
                        Circle()
                            .stroke(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.1), lineWidth: 8)
                            .frame(width: 70, height: 70)
                        
                        Circle()
                            .trim(from: 0, to: vm.completionProgress(for: selectedCategory))
                            .stroke(
                                LinearGradient(colors: [AppTheme.accent, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 70, height: 70)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: vm.completionProgress(for: selectedCategory))
                        
                        Image(systemName: "checklist")
                            .font(.title3.bold())
                            .foregroundColor(vm.completionProgress(for: selectedCategory) == 1.0 ? AppTheme.accent : AppTheme.textColor(for: vm.appearanceTheme).opacity(0.2))
                    }
                    .padding(.bottom, 4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Category Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button {
                            showingAddCategory = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.accent)
                                .frame(width: 36, height: 36)
                                .background(AppTheme.accent.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        ForEach(vm.todoCategories, id: \.self) { category in
                            Button {
                                withAnimation(.spring()) {
                                    selectedCategory = category
                                }
                            } label: {
                                Text(category)
                                    .font(AppTheme.rounded(14, weight: .bold, base: vm.appFontSize))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? AppTheme.accent : AppTheme.cardBackgroundColor(for: vm.appearanceTheme))
                                    .foregroundColor(selectedCategory == category ? .white : AppTheme.textColor(for: vm.appearanceTheme).opacity(selectedCategory == category ? 1.0 : 0.4))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(selectedCategory == category ? 0 : 0.05), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Add Todo Inline
                HStack(spacing: 12) {
                    TextField("Add task to \(selectedCategory)...", text: $newTodoTitle)
                        .textFieldStyle(.plain)
                        .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                        .font(AppTheme.rounded(16, weight: .medium, base: vm.appFontSize))
                        .focused($isFieldFocused)
                    
                    Menu {
                        Picker("Priority", selection: $selectedPriority) {
                            ForEach(TodoPriority.allCases, id: \.self) { priority in
                                Label(priority.rawValue, systemImage: "flag.fill")
                                    .tag(priority)
                            }
                        }
                    } label: {
                        Circle()
                            .fill(selectedPriority.color.opacity(0.2))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "flag.fill")
                                    .font(.caption)
                                    .foregroundColor(selectedPriority.color)
                            )
                    }
                    
                    Button {
                        if !newTodoTitle.isEmpty {
                            hapticFeedback()
                            withAnimation(.spring()) {
                                vm.addTodo(title: newTodoTitle, priority: selectedPriority, category: selectedCategory)
                                newTodoTitle = ""
                                isFieldFocused = false
                            }
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(newTodoTitle.isEmpty ? AppTheme.textColor(for: vm.appearanceTheme).opacity(0.2) : AppTheme.accent)
                    }
                    .disabled(newTodoTitle.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                
                // Todo List
                let filteredTodos = vm.todos.filter { $0.category == selectedCategory }
                
                if filteredTodos.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checklist")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.1))
                        Text("No tasks in \(selectedCategory)")
                            .font(AppTheme.rounded(18, weight: .semibold, base: vm.appFontSize))
                            .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.2))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredTodos) { todo in
                                TodoRowView(todo: todo)
                                    .environmentObject(vm)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120) // Bottom bar offset
                    }
                }
                
                Spacer()
            }
        }
        .alert("New Category", isPresented: $showingAddCategory) {
            TextField("Category Name", text: $newCategoryName)
                .foregroundColor(.black)
            Button("Cancel", role: .cancel) { newCategoryName = "" }
            Button("Create") {
                withAnimation {
                    vm.addTodoCategory(newCategoryName)
                    selectedCategory = newCategoryName
                    newCategoryName = ""
                }
            }
        } message: {
            Text("Enter a name for your new task folder.")
        }
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct TodoRowView: View {
    @EnvironmentObject var vm: NotesViewModel
    let todo: Todo
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkmark button
            Button {
                let generator = UISelectionFeedbackGenerator()
                generator.selectionChanged()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    vm.toggleTodo(todo.id)
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(todo.isCompleted ? AppTheme.accent : AppTheme.textColor(for: vm.appearanceTheme).opacity(0.2), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    
                    if todo.isCompleted {
                        Circle()
                            .fill(AppTheme.accent)
                            .frame(width: 18, height: 18)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(AppTheme.rounded(16, weight: .semibold, base: vm.appFontSize))
                    .foregroundColor(todo.isCompleted ? AppTheme.textColor(for: vm.appearanceTheme).opacity(0.3) : AppTheme.textColor(for: vm.appearanceTheme))
                    .strikethrough(todo.isCompleted, color: AppTheme.textColor(for: vm.appearanceTheme).opacity(0.3))
                
                HStack(spacing: 8) {
                    // Priority Tag
                    HStack(spacing: 4) {
                        Circle()
                            .fill(todo.priority.color)
                            .frame(width: 6, height: 6)
                        Text(todo.priority.rawValue)
                            .font(AppTheme.rounded(10, weight: .bold, base: vm.appFontSize))
                            .foregroundColor(todo.priority.color)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(todo.priority.color.opacity(0.1))
                    .clipShape(Capsule())
                    
                    if let due = todo.dueDate {
                        Text(due.formatted(.dateTime.day().month()))
                            .font(AppTheme.rounded(10, weight: .medium, base: vm.appFontSize))
                            .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.3))
                    }
                }
            }
            
            Spacer()
            
            // Delete button
            Button {
                withAnimation(.spring()) {
                    vm.deleteTodo(todo.id)
                }
            } label: {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundColor(.red.opacity(0.4))
            }
        }
        .padding(16)
        .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme).opacity(todo.isCompleted ? 0.5 : 1.0))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
