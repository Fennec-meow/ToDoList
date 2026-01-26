import UIKit

// MARK: - Protocol

protocol CreateTaskPresenterProtocol: AnyObject {
    var view: CreateTaskViewProtocol? { get set }
    var router: CreateTaskRouterProtocol? { get set }
    
    func viewDidLoad()
    func didTapSaveButton(title: String, description: String?)
    func didTapBackButton()
    func didTapCancelButton()
    func configureForEditing(task: TaskListEntity)
}

// MARK: - CreateTaskPresenter

final class CreateTaskPresenter {
    
    weak var view: CreateTaskViewProtocol?
    var router: CreateTaskRouterProtocol?
    
    private var originalTask: TaskListEntity?
    private var isEditingMode: Bool = false
    private var indexPath: IndexPath?
    private weak var delegate: ListEditDelegate?
    
    func setupForEditing(
        task: TaskListEntity,
        indexPath: IndexPath,
        delegate: ListEditDelegate
    ) {
        self.originalTask = task
        self.isEditingMode = true
        self.indexPath = indexPath
        self.delegate = delegate
    }
    
    func setupForCreating(delegate: ListEditDelegate) {
        self.delegate = delegate
    }
}

// MARK: - CreateTaskPresenterProtocol

extension CreateTaskPresenter: CreateTaskPresenterProtocol {
    func viewDidLoad() {
        if let task = originalTask {
            view?.configureForEditing(title: task.todo, description: task.description)
        }
    }
    
    func didTapSaveButton(title: String, description: String?) {
        print("CreateTaskPresenter: Сохраняем задачу '\(title)'")
        
        if isEditingMode, let originalTask = originalTask, let indexPath = indexPath {
            let updatedTask = TaskListEntity(
                id: originalTask.id,
                todo: title,
                completed: originalTask.completed,
                userId: originalTask.userId,
                description: description,
                date: originalTask.date
            )
            
            delegate?.didUpdateTask(updatedTask, at: indexPath)
        } else {
            delegate?.didAddTask(title: title, description: description)
        }
        
        router?.dismissModule()
    }
    
    func didTapBackButton() {
        if let viewController = view as? CreateTaskViewController {
            viewController.checkAndSaveIfNeeded()
        }
    }
    
    func didTapCancelButton() {
        router?.dismissModule()
    }
    
    func configureForEditing(task: TaskListEntity) {
        self.originalTask = task
        self.isEditingMode = true
    }
}
