import SwiftUI

struct TodoListView: View {
    @State private var todoItems: [TodoItem] = []
    @State private var showingNewTodoItemView = false
    @State private var selectedItem: TodoItem?
    @State private var showCompletedTasks = true
    @State private var showingCalendarView = false

    var body: some View {
        NavigationView {
            ZStack {
                Color("BackPrimary")
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 12) {
                    HStack {
                        Text("Выполнено — \(todoItems.filter { $0.isDone }.count)")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        Spacer()
                        Button(action: {
                            showCompletedTasks.toggle()
                        }) {
                            Text(showCompletedTasks ? "Скрыть" : "Показать")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 32)

                    List {
                        ForEach(todoItems.filter { showCompletedTasks || !$0.isDone }) { item in
                            HStack {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(item.isDone ? Color("Green") : (item.importance == .high ? .red : .gray))

                                VStack(alignment: .leading) {
                                    HStack {
                                        if item.importance == .high {
                                            Text("!!")
                                                .foregroundColor(.red)
                                        }
                                        Text(item.text.split(separator: "\n").first.map(String.init) ?? "")
                                            .strikethrough(item.isDone, color: .gray)
                                            .foregroundColor(item.isDone ? .gray : .primary)
                                            .font(.custom("SF Pro Text", size: 17))
                                    }
                                    if let deadline = item.deadline {
                                        Text(deadline, style: .date)
                                            .font(.footnote)
                                            .foregroundColor(Color("Gray"))
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    selectedItem = item
                                    showingNewTodoItemView = true
                                }) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.gray)
                                }
                            }
                            .background(Color("BackSecondary"))
                            .cornerRadius(10)
                            .swipeActions(edge: .leading) {
                                if !item.isDone {
                                    Button(action: {
                                        toggleDone(item: item)
                                    }) {
                                        Label("Done", systemImage: "checkmark.circle")
                                    }
                                    .tint(Color("Green"))
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                if item.isDone {
                                    Button(action: {
                                        toggleDone(item: item)
                                    }) {
                                        Label("Not Done", systemImage: "arrow.uturn.backward.circle")
                                    }
                                    .tint(.orange)
                                }
                                Button(action: {
                                    deleteItem(item: item)
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        }
                        .onDelete(perform: deleteItems)
                        .onMove(perform: moveItems)

                        Button(action: {
                            selectedItem = TodoItem(text: "", importance: .normal, deadline: nil, isDone: false, creationDate: Date(), modificationDate: nil)
                            showingNewTodoItemView = true
                        }) {
                            HStack {
                                Text("Новое")
                                    .foregroundColor(.gray)
                                    .padding()
                                Spacer()
                            }
                            .background(Color("BackSecondary"))
                            .cornerRadius(10)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color("BackPrimary"))
                }

                VStack {
                    Spacer()
                    Button(action: {
                        selectedItem = TodoItem(text: "", importance: .normal, deadline: nil, isDone: false, creationDate: Date(), modificationDate: nil)
                        showingNewTodoItemView = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color("Blue"))
                            .padding()
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .sheet(isPresented: $showingNewTodoItemView, onDismiss: loadItems) {
                        if let selectedItem = selectedItem {
                            NewTodoItemView(viewModel: TodoItemViewModel(todoItem: selectedItem), onSave: {
                                loadItems()
                                self.showingNewTodoItemView = false
                            })
                        }
                    }
                }
            }
            .navigationTitle("Мои дела")
            .navigationBarItems(trailing: Button(action: {
                showingCalendarView = true
            }) {
                Image(systemName: "calendar")
            })
            .sheet(isPresented: $showingCalendarView) {
                CalendarViewControllerWrapper(todoItems: $todoItems)
            }
        }
        .onAppear(perform: loadItems)
        .accentColor(Color("Blue"))
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TodoItemsUpdated")), perform: { notification in
            if let updatedItems = notification.userInfo?["todoItems"] as? [TodoItem] {
                todoItems = updatedItems
            }
        })
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

struct CalendarViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var todoItems: [TodoItem]

    func makeUIViewController(context: Context) -> CalendarViewController {
        let viewController = CalendarViewController()
        viewController.todoItems = todoItems
        return viewController
    }

    func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
        uiViewController.todoItems = todoItems
    }
}


struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}
