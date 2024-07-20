import UIKit
import SwiftUI

class CalendarViewController: UIViewController {

    var todoItems: [TodoItem] = []

    private let tableView = UITableView()
    private let addButton = UIButton()
    private let calendarHeaderView = CalendarHeaderView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "BackPrimary")
        navigationItem.title = "Календарь дел"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(addNewTodoItem))

        calendarHeaderView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(calendarHeaderView)
        view.addSubview(tableView)
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            calendarHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarHeaderView.heightAnchor.constraint(equalToConstant: 80),

            tableView.topAnchor.constraint(equalTo: calendarHeaderView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TodoItemCell.self, forCellReuseIdentifier: "TodoItemCell")

        addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addButton.tintColor = .systemBlue
        addButton.contentVerticalAlignment = .fill
        addButton.contentHorizontalAlignment = .fill
        addButton.addTarget(self, action: #selector(addNewTodoItem), for: .touchUpInside)

        // Передаем todoItems в календарный заголовок
        calendarHeaderView.configure(with: todoItems) { [weak self] selectedDate in
            self?.scrollToSection(for: selectedDate)
        }
    }

    @objc private func addNewTodoItem() {
        let newTodoItem = TodoItem(text: "")
        let newTodoItemView = NewTodoItemView(viewModel: TodoItemViewModel(todoItem: newTodoItem)) {
            self.todoItems.append(newTodoItem)
            self.tableView.reloadData()
            self.calendarHeaderView.configure(with: self.todoItems) { [weak self] selectedDate in
                self?.scrollToSection(for: selectedDate)
            }
            NotificationCenter.default.post(name: NSNotification.Name("TodoItemsUpdated"), object: nil, userInfo: ["todoItems": self.todoItems])
        }
        let hostingController = UIHostingController(rootView: newTodoItemView)
        present(hostingController, animated: true, completion: nil)
    }

    private func scrollToSection(for date: Date?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = date {
            let selectedDateString = dateFormatter.string(from: date)
            if let indexPath = todoItems.enumerated().first(where: { dateFormatter.string(from: $0.element.deadline ?? Date()) == selectedDateString })?.offset {
                tableView.scrollToRow(at: IndexPath(row: 0, section: indexPath), at: .top, animated: true)
            }
        } else {
            let otherSectionIndex = todoItems.compactMap { $0.deadline }.unique().count
            tableView.scrollToRow(at: IndexPath(row: 0, section: otherSectionIndex), at: .top, animated: true)
        }
    }

    private func saveItems() {
        let jsonArray = todoItems.map { $0.json }
        if let data = try? JSONSerialization.data(withJSONObject: jsonArray) {
            UserDefaults.standard.set(data, forKey: "todoItems")
        }
        NotificationCenter.default.post(name: NSNotification.Name("TodoItemsUpdated"), object: nil, userInfo: ["todoItems": todoItems])
    }
}

extension CalendarViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let dates = todoItems.compactMap { $0.deadline }.unique().sorted()
        return dates.count + 1 // Последняя секция для "Другое"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dates = todoItems.compactMap { $0.deadline }.unique().sorted()
        if section < dates.count {
            let date = dates[section]
            return todoItems.filter { $0.deadline == date }.count
        } else {
            return todoItems.filter { $0.deadline == nil }.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath) as! TodoItemCell
        let dates = todoItems.compactMap { $0.deadline }.unique().sorted()
        let item: TodoItem

        if indexPath.section < dates.count {
            let date = dates[indexPath.section]
            item = todoItems.filter { $0.deadline == date }[indexPath.row]
        } else {
            item = todoItems.filter { $0.deadline == nil }[indexPath.row]
        }

        cell.configure(with: item)
        return cell
    }
}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "BackPrimary")

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .gray
        
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        let dates = todoItems.compactMap { $0.deadline }.unique().sorted()
        if section < dates.count {
            let date = dates[section]
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            titleLabel.text = formatter.string(from: date)
        } else {
            titleLabel.text = "Другое"
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = getItem(at: indexPath)
        // Открыть экран редактирования задачи
        let editTodoItemView = NewTodoItemView(viewModel: TodoItemViewModel(todoItem: item)) {
            self.tableView.reloadData()
            self.calendarHeaderView.configure(with: self.todoItems) { [weak self] selectedDate in
                self?.scrollToSection(for: selectedDate)
            }
        }
        let hostingController = UIHostingController(rootView: editTodoItemView)
        present(hostingController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = getItem(at: indexPath)
            // Удалить задачу
            if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
                todoItems.remove(at: index)
                tableView.performBatchUpdates({
                    if tableView.numberOfRows(inSection: indexPath.section) == 1 {
                        tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                    } else {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }, completion: { _ in
                    self.calendarHeaderView.configure(with: self.todoItems) { [weak self] selectedDate in
                        self?.scrollToSection(for: selectedDate)
                    }
                    self.saveItems()  // Сохраняем изменения после удаления
                })
            }
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = getItem(at: indexPath)
        
        if item.isDone {
            let notDoneAction = UIContextualAction(style: .normal, title: "Not Done") { (action, view, completionHandler) in
                if let cell = tableView.cellForRow(at: indexPath) as? TodoItemCell {
                    cell.unmarkAsDone()
                }
                if let index = self.todoItems.firstIndex(where: { $0.id == item.id }) {
                    self.todoItems[index].isDone = false
                    self.saveItems()  // Сохраняем изменения после отмены выполнения
                }
                completionHandler(true)
            }
            notDoneAction.backgroundColor = .orange
            return UISwipeActionsConfiguration(actions: [notDoneAction])
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = getItem(at: indexPath)
        
        if !item.isDone {
            let doneAction = UIContextualAction(style: .normal, title: "Done") { (action, view, completionHandler) in
                if let cell = tableView.cellForRow(at: indexPath) as? TodoItemCell {
                    cell.markAsDone()
                }
                if let index = self.todoItems.firstIndex(where: { $0.id == item.id }) {
                    self.todoItems[index].isDone = true
                    self.saveItems()  // Сохраняем изменения после выполнения
                }
                completionHandler(true)
            }
            doneAction.backgroundColor = .green
            return UISwipeActionsConfiguration(actions: [doneAction])
        } else {
            return nil
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let firstVisibleIndexPath = tableView.indexPathsForVisibleRows?.first else { return }
        let dates = todoItems.compactMap { $0.deadline }.unique().sorted()
        if firstVisibleIndexPath.section < dates.count {
            let date = dates[firstVisibleIndexPath.section]
            calendarHeaderView.selectDate(date)
        } else {
            calendarHeaderView.selectDate(nil)
        }
    }

    private func getItem(at indexPath: IndexPath) -> TodoItem {
        let dates = todoItems.compactMap { $0.deadline }.unique().sorted()
        let item: TodoItem

        if indexPath.section < dates.count {
            let date = dates[indexPath.section]
            item = todoItems.filter { $0.deadline == date }[indexPath.row]
        } else {
            item = todoItems.filter { $0.deadline == nil }[indexPath.row]
        }
        
        return item
    }
}

extension Array where Element: Equatable {
    func unique() -> [Element] {
        var uniqueValues: [Element] = []
        for value in self {
            if !uniqueValues.contains(value) {
                uniqueValues.append(value)
            }
        }
        return uniqueValues
    }
}
