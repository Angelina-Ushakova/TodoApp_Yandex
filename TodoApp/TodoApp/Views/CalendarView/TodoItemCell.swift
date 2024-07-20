import UIKit

class TodoItemCell: UITableViewCell {
    func configure(with item: TodoItem) {
        textLabel?.text = item.text
        textLabel?.textColor = item.isDone ? .gray : .black
        textLabel?.attributedText = item.isDone ? NSAttributedString(string: item.text, attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]) : NSAttributedString(string: item.text)
    }

    func markAsDone() {
        textLabel?.textColor = .gray
        let text = textLabel?.text ?? ""
        textLabel?.attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
    }

    func unmarkAsDone() {
        textLabel?.textColor = .black
        let text = textLabel?.text ?? ""
        textLabel?.attributedText = NSAttributedString(string: text)
    }
}
