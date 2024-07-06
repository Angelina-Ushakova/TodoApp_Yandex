import SwiftUI

struct NewTodoItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: TodoItemViewModel
    @State private var showingDatePicker = false
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    ZStack(alignment: .topLeading) {
                        if viewModel.todoItem.text.isEmpty {
                            Text("Что надо сделать?")
                                .foregroundColor(Color("LabelSecondary"))
                                .font(.custom("SF Pro Text", size: 17))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 4)
                        }
                        TextEditor(text: $viewModel.todoItem.text)
                            .font(.custom("SF Pro Text", size: 17))
                            .frame(minHeight: 100, alignment: .topLeading)
                        Rectangle()
                            .fill(viewModel.selectedColor)
                            .frame(width: 5)
                            .padding(.leading, -10)
                    }
                }
                .listRowBackground(Color("BackSecondary"))
                
                Section {
                    HStack {
                        Text("Важность")
                            .font(.custom("SF Pro Text", size: 17))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Picker("Важность", selection: $viewModel.todoItem.importance) {
                            Image(systemName: "arrow.down")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .tag(Importance.low)
                            Text("нет")
                                .tag(Importance.normal)
                            Image(systemName: "exclamationmark.2")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .foregroundColor(.red)
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
                            .font(.custom("SF Pro Text", size: 17))
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
                .listRowBackground(Color("BackSecondary"))
                
                Section {
                    HStack {
                        Text("Цвет")
                            .font(.custom("SF Pro Text", size: 17))
                        Spacer()
                        ColorPicker("", selection: $viewModel.selectedColor)
                            .labelsHidden()
                            .frame(width: 20, height: 20)
                    }
                    .listRowBackground(Color("BackSecondary"))
                    
                    Button(action: {
                        self.viewModel.delete()
                        self.presentationMode.wrappedValue.dismiss()
                        onSave()
                    }) {
                        Text("Удалить")
                            .font(.custom("SF Pro Text", size: 17))
                            .foregroundColor(Color("Red"))
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowBackground(Color("BackSecondary"))
            }
            .background(Color("BackPrimary").edgesIgnoringSafeArea(.all))
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
            .onAppear {
                self.viewModel.selectedColor = Color(hex: UserDefaults.standard.string(forKey: "\(self.viewModel.todoItem.id)_color") ?? "#0000FF")
            }
        }
        .accentColor(Color("Blue")) // Устанавливаем основной цвет
    }
}

struct NewTodoItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewTodoItemView(viewModel: TodoItemViewModel(todoItem: TodoItem(id: UUID().uuidString, text: "", importance: .normal, deadline: nil, isDone: false, creationDate: Date(), modificationDate: nil)), onSave: {})
    }
}
