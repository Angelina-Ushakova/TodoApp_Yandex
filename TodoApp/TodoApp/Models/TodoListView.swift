import SwiftUI

struct TodoListView: View {
    @State private var todoItems: [TodoItem] = []
    @State private var showingNewTodoItemView = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(todoItems) { item in
                    NavigationLink(destination: NewTodoItemView(viewModel: TodoItemViewModel(todoItem: item), onSave: loadItems)) {
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
                                if let deadline = item.deadline {
                                    Text(deadline, style: .date)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Мои дела")
            .navigationBarItems(trailing: Button(action: {
                showingNewTodoItemView = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingNewTodoItemView) {
                NewTodoItemView(viewModel: TodoItemViewModel(todoItem: TodoItem(text: "", importance: .normal, deadline: nil, isDone: false, creationDate: Date(), modificationDate: nil)), onSave: loadItems)
            }
        }
        .onAppear(perform: loadItems)
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
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}
