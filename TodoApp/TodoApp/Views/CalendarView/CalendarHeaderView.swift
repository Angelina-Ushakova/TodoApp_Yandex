import UIKit

class CalendarHeaderView: UIView {
    private var dates: [Date] = []
    private var selectedDate: Date?
    private var dateButtons: [UIButton] = []
    var onDateSelected: ((Date?) -> Void)?
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    func configure(with todoItems: [TodoItem], onDateSelected: @escaping (Date?) -> Void) {
        self.onDateSelected = onDateSelected
        dates = todoItems.compactMap { $0.deadline }.unique().sorted()
        setupUI()
    }

    private func setupUI() {
        subviews.forEach { $0.removeFromSuperview() }
        dateButtons.removeAll()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 20

        addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        for date in dates {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d\nMMM"

            let dateButton = UIButton()
            dateButton.setTitle(dateFormatter.string(from: date), for: .normal)
            dateButton.setTitleColor(.black, for: .normal)
            dateButton.setTitleColor(UIColor.brown, for: .selected)
            dateButton.layer.cornerRadius = 10
            dateButton.layer.borderWidth = 2 // Увеличиваем ширину обводки
            dateButton.layer.borderColor = UIColor.clear.cgColor
            dateButton.backgroundColor = .clear
            dateButton.titleLabel?.numberOfLines = 2
            dateButton.titleLabel?.textAlignment = .center
            dateButton.addTarget(self, action: #selector(dateButtonTapped(_:)), for: .touchUpInside)

            dateButtons.append(dateButton)
            stackView.addArrangedSubview(dateButton)
        }

        let otherButton = UIButton()
        otherButton.setTitle("Другое", for: .normal)
        otherButton.setTitleColor(.black, for: .normal)
        otherButton.setTitleColor(UIColor.brown, for: .selected)
        otherButton.layer.cornerRadius = 10
        otherButton.layer.borderWidth = 2 // Увеличиваем ширину обводки
        otherButton.layer.borderColor = UIColor.clear.cgColor
        otherButton.backgroundColor = .clear
        otherButton.titleLabel?.textAlignment = .center
        otherButton.addTarget(self, action: #selector(otherButtonTapped(_:)), for: .touchUpInside)

        dateButtons.append(otherButton)
        stackView.addArrangedSubview(otherButton)

        updateSelectedDate()
    }

    @objc private func dateButtonTapped(_ sender: UIButton) {
        guard let dateIndex = dateButtons.firstIndex(of: sender) else { return }
        selectedDate = dateIndex < dates.count ? dates[dateIndex] : nil
        onDateSelected?(selectedDate)
        updateSelectedDate()
    }

    @objc private func otherButtonTapped(_ sender: UIButton) {
        selectedDate = nil
        onDateSelected?(nil)
        updateSelectedDate()
    }

    func selectDate(_ date: Date?) {
        selectedDate = date
        updateSelectedDate()
    }

    private func updateSelectedDate() {
        dateButtons.forEach {
            $0.layer.borderColor = UIColor.clear.cgColor
            $0.backgroundColor = .clear
            $0.setTitleColor(.black, for: .normal)
            $0.isSelected = false
        }
        if let selectedDate = selectedDate, let dateIndex = dates.firstIndex(of: selectedDate) {
            dateButtons[dateIndex].layer.borderColor = UIColor.brown.cgColor
            dateButtons[dateIndex].setTitleColor(.brown, for: .normal)
            dateButtons[dateIndex].backgroundColor = UIColor.brown.withAlphaComponent(0.2)
            dateButtons[dateIndex].isSelected = true

            let buttonFrame = dateButtons[dateIndex].frame
            scrollView.scrollRectToVisible(buttonFrame, animated: true)
        } else {
            dateButtons.last?.layer.borderColor = UIColor.brown.cgColor
            dateButtons.last?.setTitleColor(.brown, for: .normal)
            dateButtons.last?.backgroundColor = UIColor.brown.withAlphaComponent(0.2)
            dateButtons.last?.isSelected = true

            let buttonFrame = dateButtons.last!.frame
            scrollView.scrollRectToVisible(buttonFrame, animated: true)
        }
    }
}
