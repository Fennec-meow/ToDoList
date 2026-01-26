import UIKit

// MARK: - Protocol

protocol TaskListTableViewCellDelegate: AnyObject {
    func toggleTaskCompletion(at indexPath: IndexPath)
    func editTask(task: TaskListEntity, at indexPath: IndexPath)
    func shareTask(task: TaskListEntity, at indexPath: IndexPath)
    func deleteTask(task: TaskListEntity, at indexPath: IndexPath)
}

// MARK: - TaskListTableViewCell

final class TaskListTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "ListCell"
    
    weak var delegate: TaskListTableViewCellDelegate?
    private var task: TaskListEntity?
    private var indexPath: IndexPath?
    
    private lazy var ui: UI = {
        let ui = createUI()
        layout(ui)
        return ui
    }()
    
    // MARK: Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task = nil
        indexPath = nil
        ui.checkboxButton.isSelected = false
        
        ui.titleLabel.attributedText = nil
        ui.descriptionLabel.attributedText = nil
        ui.titleLabel.textColor = .ypWhite
        ui.descriptionLabel.textColor = .ypWhite
        ui.dateLabel.textColor = .ypStroke
    }
}

// MARK: - Public Methods

extension TaskListTableViewCell {
    
    func configure(with task: TaskListEntity, at indexPath: IndexPath) {
        self.task = task
        self.indexPath = indexPath
        
        ui.titleLabel.attributedText = nil
        ui.titleLabel.text = task.todo
        
        ui.descriptionLabel.text = task.description ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "dd/MM/yy"
        ui.dateLabel.text = dateFormatter.string(from: task.date)
        
        ui.checkboxButton.isSelected = task.completed
        
        updateAppearance()
    }
}

// MARK: - Private Methods

private extension TaskListTableViewCell {
    
    func updateAppearance() {
        guard let task else { return }
        
        if task.completed {
            applyCompletedStyle()
        } else {
            applyDefaultStyle()
        }
    }
    
    func applyCompletedStyle() {
        guard let task = task else { return }
        
        let attributedString = NSAttributedString(
            string: task.todo,
            attributes: [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.ypStroke
            ]
        )
        ui.titleLabel.attributedText = attributedString
        
        ui.descriptionLabel.textColor = .ypStroke
        
        ui.checkboxButton.setImage(UIImage(named: "onTask") ?? UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        ui.checkboxButton.tintColor = .ypYellow
        
        print("Применен стиль выполнено для: \(task.todo)")
    }
    
    func applyDefaultStyle() {
        
        ui.titleLabel.attributedText = nil
        if let todo = task?.todo {
            ui.titleLabel.text = todo
        }
        ui.titleLabel.textColor = .ypWhite
        
        ui.descriptionLabel.textColor = .ypWhite
        
        ui.checkboxButton.setImage(UIImage(named: "offTask") ?? UIImage(systemName: "circle"), for: .normal)
        ui.checkboxButton.tintColor = .ypGray
        
        print("Применен обычный стиль для: \(task?.todo ?? "")")
    }
    
    func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        let interaction = UIContextMenuInteraction(delegate: self)
        ui.containerView.addInteraction(interaction)
    }
    
    func setupActions() {
        ui.checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
    }
    
    @objc private func checkboxTapped() {
        guard let indexPath else { return }
        delegate?.toggleTaskCompletion(at: indexPath)
    }
}

// MARK: - UIContextMenuInteractionDelegate

extension TaskListTableViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        guard let indexPath, let task else { return nil }
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { _ in
                let editAction = UIAction(
                    title: "Редактировать",
                    image: UIImage(systemName: "pencil")
                ) { [weak self] _ in
                    self?.delegate?.editTask(task: task, at: indexPath)
                }
                
                let shareAction = UIAction(
                    title: "Поделиться",
                    image: UIImage(systemName: "square.and.arrow.up")
                ) { [weak self] _ in
                    self?.delegate?.shareTask(task: task, at: indexPath)
                }
                
                let deleteAction = UIAction(
                    title: "Удалить",
                    image: UIImage(systemName: "trash"),
                    attributes: .destructive
                ) { [weak self] _ in
                    self?.delegate?.deleteTask(task: task, at: indexPath)
                }
                
                return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
            }
        )
    }
}

// MARK: - UI Setup

extension TaskListTableViewCell {
    
    struct UI {
        let containerView: UIView
        let checkboxButton: UIButton
        let titleLabel: UILabel
        let descriptionLabel: UILabel
        let dateLabel: UILabel
        let separatorView: UIView
    }
    
    func createUI() -> UI {
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .ypBlack
        contentView.addSubview(containerView)
        
        let checkboxButton = UIButton(type: .custom)
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.contentMode = .center
        containerView.addSubview(checkboxButton)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .ypWhite
        containerView.addSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.numberOfLines = 2
        containerView.addSubview(descriptionLabel)
        
        
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .ypStroke
        containerView.addSubview(dateLabel)
        
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .ypGray
        containerView.addSubview(separatorView)
        
        return .init(
            containerView: containerView,
            checkboxButton: checkboxButton,
            titleLabel: titleLabel,
            descriptionLabel: descriptionLabel,
            dateLabel: dateLabel,
            separatorView: separatorView
        )
    }
    
    func layout(_ ui: UI) {
        NSLayoutConstraint.activate([
            ui.containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            ui.containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ui.containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ui.containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ui.containerView.heightAnchor.constraint(equalToConstant: 140),
            
            ui.checkboxButton.leadingAnchor.constraint(equalTo: ui.containerView.leadingAnchor, constant: 16),
            ui.checkboxButton.centerYAnchor.constraint(equalTo: ui.containerView.centerYAnchor),
            ui.checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            ui.checkboxButton.heightAnchor.constraint(equalToConstant: 48),
            
            ui.titleLabel.topAnchor.constraint(equalTo: ui.containerView.topAnchor, constant: 20),
            ui.titleLabel.leadingAnchor.constraint(equalTo: ui.checkboxButton.trailingAnchor, constant: 12),
            ui.titleLabel.trailingAnchor.constraint(equalTo: ui.containerView.trailingAnchor, constant: -16),
            
            ui.descriptionLabel.topAnchor.constraint(equalTo: ui.titleLabel.bottomAnchor, constant: 4),
            ui.descriptionLabel.leadingAnchor.constraint(equalTo: ui.checkboxButton.trailingAnchor, constant: 12),
            ui.descriptionLabel.trailingAnchor.constraint(equalTo: ui.containerView.trailingAnchor, constant: -16),
            
            ui.dateLabel.bottomAnchor.constraint(equalTo: ui.containerView.bottomAnchor, constant: -20),
            ui.dateLabel.leadingAnchor.constraint(equalTo: ui.checkboxButton.trailingAnchor, constant: 12),
            ui.dateLabel.trailingAnchor.constraint(equalTo: ui.containerView.trailingAnchor, constant: -16),
            
            ui.separatorView.leadingAnchor.constraint(equalTo: ui.containerView.leadingAnchor),
            ui.separatorView.trailingAnchor.constraint(equalTo: ui.containerView.trailingAnchor),
            ui.separatorView.bottomAnchor.constraint(equalTo: ui.containerView.bottomAnchor),
            ui.separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
