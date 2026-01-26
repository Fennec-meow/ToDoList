import UIKit

// MARK: - Protocol

protocol TaskListViewProtocol: AnyObject {
    func showTasks(_ tasks: [TaskListEntity])
    func showError(_ message: String)
    func updateTask(_ task: TaskListEntity, at indexPath: IndexPath)
    func deleteTask(at indexPath: IndexPath)
    func insertTask(_ task: TaskListEntity, at indexPath: IndexPath)
}

// MARK: - TaskListViewController

final class TaskListViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: TaskListPresenterProtocol?
    private var tasks: [TaskListEntity] = []
    
    private lazy var ui: UI = {
        let ui = createUI()
        layout(ui)
        return ui
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupTableView()
        setupButtonActions()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Public Methods

extension TaskListViewController {
    
    func getIndexPath(forTaskId id: Int) -> IndexPath? {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            return IndexPath(row: index, section: 0)
        }
        return nil
    }
}

// MARK: - Private Methods

private extension TaskListViewController {
    
    func setupTableView() {
        ui.tableView.delegate = self
        ui.tableView.dataSource = self
        ui.tableView.register(TaskListTableViewCell.self, forCellReuseIdentifier: TaskListTableViewCell.reuseIdentifier)
        ui.tableView.backgroundColor = .clear
        ui.tableView.separatorStyle = .none
        ui.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    func setupButtonActions() {
        ui.addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    func updateTasksCountLabel() {
        let totalTasks = tasks.count
        
        let lastDigit = totalTasks % 10
        let lastTwoDigits = totalTasks % 100
        
        let taskWord: String
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            taskWord = "Задач"
        } else {
            switch lastDigit {
            case 1:
                taskWord = "Задача"
            case 2...4:
                taskWord = "Задачи"
            default:
                taskWord = "Задач"
            }
        }
        
        ui.label.text = "\(totalTasks) \(taskWord)"
    }
    
    @objc private func addButtonTapped() {
        presenter?.didTapAddButton()
    }
    
    @objc private func searchTextFieldChanged(_ textField: UITextField) {
        presenter?.didSearch(text: textField.text ?? "")
    }
}

// MARK: - TaskListViewProtocol

extension TaskListViewController: TaskListViewProtocol {
    func showTasks(_ tasks: [TaskListEntity]) {
        self.tasks = tasks
        ui.tableView.reloadData()
        updateTasksCountLabel()
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func updateTask(_ task: TaskListEntity, at indexPath: IndexPath) {
        guard indexPath.row < tasks.count else { return }
        tasks[indexPath.row] = task
        
        if let cell = ui.tableView.cellForRow(at: indexPath) as? TaskListTableViewCell {
            cell.configure(with: task, at: indexPath)
        }
        updateTasksCountLabel()
    }
    
    func deleteTask(at indexPath: IndexPath) {
        guard indexPath.row < tasks.count else { return }
        tasks.remove(at: indexPath.row)
        ui.tableView.deleteRows(at: [indexPath], with: .fade)
        updateTasksCountLabel()
    }
    
    func insertTask(_ task: TaskListEntity, at indexPath: IndexPath) {
        tasks.insert(task, at: indexPath.row)
        ui.tableView.insertRows(at: [indexPath], with: .automatic)
        updateTasksCountLabel()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskListTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? TaskListTableViewCell else {
            return UITableViewCell()
        }
        
        let task = tasks[indexPath.row]
        cell.configure(with: task, at: indexPath)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.toggleTaskCompletion(at: indexPath)
    }
}

// MARK: - ListTableViewCellDelegate

extension TaskListViewController: TaskListTableViewCellDelegate {
    func toggleTaskCompletion(at indexPath: IndexPath) {
        presenter?.toggleTaskCompletion(at: indexPath)
    }
    
    func editTask(task: TaskListEntity, at indexPath: IndexPath) {
        presenter?.editTask(task: task, at: indexPath)
    }
    
    func shareTask(task: TaskListEntity, at indexPath: IndexPath) {
        presenter?.shareTask(task: task, at: indexPath)
    }
    
    func deleteTask(task: TaskListEntity, at indexPath: IndexPath) {
        presenter?.deleteTask(task: task, at: indexPath)
    }
}

// MARK: - UI Setup

extension TaskListViewController {
    
    struct UI {
        let titleLabel: UILabel
        let searchTextField: UITextField
        let tableView: UITableView
        let footerContainer: UIView
        let label: UILabel
        let addButton: UIButton
    }
    
    func createUI() -> UI {
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Задачи"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .ypWhite
        view.addSubview(titleLabel)
        
        let searchTextField = UITextField()
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.placeholder = "Search"
        searchTextField.font = .systemFont(ofSize: 17, weight: .regular)
        searchTextField.textColor = .ypWhite.withAlphaComponent(0.9)
        searchTextField.backgroundColor = .ypGray
        searchTextField.layer.cornerRadius = 10
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.ypGray.cgColor
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.ypWhite.withAlphaComponent(0.6),
            .font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: placeholderAttributes
        )
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 40))
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .ypWhite.withAlphaComponent(0.6) // Белая лупа с прозрачностью
        searchIcon.frame = CGRect(x: 12, y: 10, width: 20, height: 20)
        searchIcon.contentMode = .scaleAspectFit
        leftView.addSubview(searchIcon)
        searchTextField.leftView = leftView
        searchTextField.leftViewMode = .always
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        searchTextField.rightView = rightView
        searchTextField.rightViewMode = .always
        
        searchTextField.addTarget(self, action: #selector(searchTextFieldChanged), for: .editingChanged)
        view.addSubview(searchTextField)
        
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        let footerContainer = UIView()
        footerContainer.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.backgroundColor = .ypBlack
        view.addSubview(footerContainer)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0 Задач"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .ypWhite.withAlphaComponent(0.8)
        footerContainer.addSubview(label)
        
        let addButton = UIButton(type: .custom)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        if let createTaskImage = UIImage(named: "createTask") {
            addButton.setImage(createTaskImage, for: .normal)
            addButton.imageView?.contentMode = .scaleAspectFit
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
            let plusImage = UIImage(systemName: "plus", withConfiguration: config)
            addButton.setImage(plusImage, for: .normal)
            addButton.tintColor = .ypBlack
        }
        
        addButton.layer.cornerRadius = 22
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addButton.layer.shadowRadius = 6
        addButton.layer.shadowOpacity = 0.3
        footerContainer.addSubview(addButton)
        
        return .init(
            titleLabel: titleLabel,
            searchTextField: searchTextField,
            tableView: tableView,
            footerContainer: footerContainer,
            label: label,
            addButton: addButton
        )
    }
    
    func layout(_ ui: UI) {
        NSLayoutConstraint.activate([
            
            ui.titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            ui.titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ui.titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            ui.searchTextField.topAnchor.constraint(equalTo: ui.titleLabel.bottomAnchor, constant: 24),
            ui.searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ui.searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ui.searchTextField.heightAnchor.constraint(equalToConstant: 44),
            
            ui.tableView.topAnchor.constraint(equalTo: ui.searchTextField.bottomAnchor, constant: 20),
            ui.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ui.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ui.tableView.bottomAnchor.constraint(equalTo: ui.footerContainer.topAnchor),
            
            ui.footerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ui.footerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ui.footerContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ui.footerContainer.heightAnchor.constraint(equalToConstant: 90),
            
            ui.label.centerXAnchor.constraint(equalTo: ui.footerContainer.centerXAnchor),
            ui.label.topAnchor.constraint(equalTo: ui.footerContainer.topAnchor, constant: 20),
            
            ui.addButton.trailingAnchor.constraint(equalTo: ui.footerContainer.trailingAnchor, constant: -20),
            ui.addButton.centerYAnchor.constraint(equalTo: ui.label.centerYAnchor),
            ui.addButton.widthAnchor.constraint(equalToConstant: 68),
            ui.addButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
