import SwiftUI

struct NewTodoItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TodoItemViewModel
    @State private var showingDatePicker = false
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    ZStack(alignment: .topLeading) {
                        if viewModel.todoItem.text.isEmpty {
                            Text("Что надо сделать?")
                                .foregroundColor(.gray)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 4)
                        }
                        TextEditor(text: $viewModel.todoItem.text)
                            .font(AppTextStyles.body)
                            .frame(minHeight: 100, alignment: .topLeading)
                    }
                }
                .listRowBackground(AppColors.Back.secondary)
                
                Section {
                    HStack {
                        Text("Важность")
                            .font(AppTextStyles.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Picker("Важность", selection: $viewModel.todoItem.importance) {
                            Image("low_importance")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .tag(Importance.low)
                            Text("нет")
                                .tag(Importance.normal)
                            Image("high_importance")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .tag(Importance.high)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(maxWidth: 150)
                    }
                    
                    Toggle(isOn: Binding(
                        get: { self.viewModel.todoItem.deadline != nil },
                        set: { self.viewModel.todoItem.deadline = $0 ? Date().addingTimeInterval(86400) : nil }
                    )) {
                        Text("Сделать до")
                            .font(AppTextStyles.body)
                    }
                    if viewModel.todoItem.deadline != nil {
                        withAnimation {
                            DatePicker(
                                "Выберите дату",
                                selection: Binding(
                                    get: { self.viewModel.todoItem.deadline ?? Date() },
                                    set: { self.viewModel.todoItem.deadline = $0 }
                                ),
                                displayedComponents: .date
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "ru"))
                        }
                    }
                }
                .listRowBackground(AppColors.Back.secondary)
                
                Section {
                    Button(action: {
                        self.viewModel.delete()
                        self.presentationMode.wrappedValue.dismiss()
                        onSave()
                    }) {
                        Text("Удалить")
                            .font(AppTextStyles.body)
                            .foregroundColor(Color.red)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowBackground(AppColors.Back.secondary)
            }
            .background(AppColors.Back.primary.edgesIgnoringSafeArea(.all)) // Используем AppColors для фона
            .navigationBarTitle("Дело", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Отменить") {
                    self.presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Сохранить") {
                    self.viewModel.save()
                    self.presentationMode.wrappedValue.dismiss()
                    onSave()
                }
            )
        }
    }
}

struct NewTodoItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewTodoItemView(viewModel: TodoItemViewModel(todoItem: TodoItem(id: UUID().uuidString, text: "", importance: .normal, deadline: nil, isDone: false, creationDate: Date(), modificationDate: nil)), onSave: {})
    }
}
