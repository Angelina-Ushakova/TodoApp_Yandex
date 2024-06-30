import SwiftUI

struct TodoListView: View {
    @State private var todoItems: [TodoItem] = []
    @State private var showingNewTodoItemView = false
    @State private var selectedItem: TodoItem?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackPrimary")
                    .edgesIgnoringSafeArea(.all) // Устанавливаем фон на весь экран
                
                List {
                    ForEach(todoItems) { item in
                        Button(action: {
                            selectedItem = item
                            showingNewTodoItemView = true
                        }) {
                            HStack {
                                if item.importance == .high {
                                    Image("high_importance")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                } else if item.importance == .low {
                                    Image("low_importance")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                }
                                VStack(alignment: .leading) {
                                    Text(item.text.split(separator: "\n").first.map(String.init) ?? "")
                                        .strikethrough(item.isDone, color: .black)
                                        .font(.custom("SF Pro Text", size: 17))
                                    if let deadline = item.deadline {
                                        Text(deadline, style: .date)
                                            .font(.footnote)
                                            .foregroundColor(Color("Gray"))
                                    }
                                }
                                Spacer()
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.isDone ? Color("Green") : Color("Gray"))
                            }
                            .background(Color("BackSecondary"))
                            .cornerRadius(10)
                        }
                        .swipeActions(edge: .leading) {
                            Button(action: {
                                toggleDone(item: item)
                            }) {
                                Label("Done", systemImage: "checkmark.circle")
                            }
                            .tint(Color("Green"))
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteItem(item: item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                    .onMove(perform: moveItems)
                }
                .scrollContentBackground(.hidden) // Применяем фон для содержимого списка
                .background(Color("BackPrimary")) // Фон для списка
            }
            .navigationTitle("Мои дела")
            .navigationBarItems(
                leading: EditButton().foregroundColor(Color("Blue")),
                trailing: Button(action: {
                    selectedItem = TodoItem(text: "", importance: .normal, deadline: nil, isDone: false, creationDate: Date(), modificationDate: nil)
                    showingNewTodoItemView = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color("Blue"))
                }
            )
            .sheet(isPresented: $showingNewTodoItemView, onDismiss: loadItems) {
                if let selectedItem = selectedItem {
                    NewTodoItemView(viewModel: TodoItemViewModel(todoItem: selectedItem), onSave: {
                        loadItems()
                        self.showingNewTodoItemView = false
                    })
                }
            }
        }
        .onAppear(perform: loadItems)
        .accentColor(Color("Blue"))
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "todoItems") {
            if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [Any] {
                todoItems = jsonArray.compactMap { TodoItem.parse(json: $0) }
            }
        }
    }
    
    private func saveItems() {
        let jsonArray = todoItems.map { $0.json }
        if let data = try? JSONSerialization.data(withJSONObject: jsonArray) {
            UserDefaults.standard.set(data, forKey: "todoItems")
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        todoItems.remove(atOffsets: offsets)
        saveItems()
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        todoItems.move(fromOffsets: source, toOffset: destination)
        saveItems()
    }
    
    private func toggleDone(item: TodoItem) {
        if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
            todoItems[index].isDone.toggle()
            saveItems()
        }
    }
    
    private func deleteItem(item: TodoItem) {
        todoItems.removeAll { $0.id == item.id }
        saveItems()
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}
