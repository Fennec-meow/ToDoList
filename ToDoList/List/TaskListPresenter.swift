import UIKit

// MARK: - Protocol

protocol TaskListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapAddButton()
    func didSearch(text: String)
    func toggleTaskCompletion(at indexPath: IndexPath)
    func editTask(task: TaskListEntity, at indexPath: IndexPath)
    func shareTask(task: TaskListEntity, at indexPath: IndexPath)
    func deleteTask(task: TaskListEntity, at indexPath: IndexPath)
    
    func didFetchTasks(_ tasks: [TaskListEntity])
    func didUpdateTaskFromInteractor(_ task: TaskListEntity, at indexPath: IndexPath)
    func didDeleteTask(at indexPath: IndexPath)
    func didAddTask(_ task: TaskListEntity)
    func didUpdateTaskInInteractor(id: Int, title: String, description: String?)
}

// MARK: - TaskListPresenter

final class TaskListPresenter {
    
    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorProtocol?
    var router: TaskListRouterProtocol?
}

// MARK: - TaskListPresenterProtocol

extension TaskListPresenter: TaskListPresenterProtocol {
    
    func viewDidLoad() {
        interactor?.fetchLists()
    }
    
    func didTapAddButton() {
        if let router = router as? TaskListRouter {
            router.showCreateTask(delegate: self)
        }
    }
    
    func didSearch(text: String) {
        interactor?.searchTasks(with: text)
    }
    
    func toggleTaskCompletion(at indexPath: IndexPath) {
        interactor?.toggleTaskCompletion(at: indexPath)
    }
    
    func editTask(task: TaskListEntity, at indexPath: IndexPath) {
        if let router = router as? TaskListRouter {
            router.showEditTask(task: task, at: indexPath, delegate: self)
        }
    }
    
    func shareTask(task: TaskListEntity, at indexPath: IndexPath) {
        if let router = router as? TaskListRouter,
           let view = view as? UIViewController {
            router.shareTask(task: task, from: view)
        }
    }
    
    func deleteTask(task: TaskListEntity, at indexPath: IndexPath) {
        interactor?.deleteTask(at: indexPath)
    }
    
    // MARK: Callbacks from Interactor
    
    func didFetchTasks(_ tasks: [TaskListEntity]) {
        view?.showTasks(tasks)
    }
    
    func didUpdateTaskFromInteractor(_ task: TaskListEntity, at indexPath: IndexPath) {
        view?.updateTask(task, at: indexPath)
    }
    
    func didDeleteTask(at indexPath: IndexPath) {
        view?.deleteTask(at: indexPath)
    }
    
    func didAddTask(_ task: TaskListEntity) {
        view?.insertTask(task, at: IndexPath(row: 0, section: 0))
    }
    
    func didUpdateTaskInInteractor(id: Int, title: String, description: String?) {
        if let view = view as? TaskListViewController,
           let indexPath = view.getIndexPath(forTaskId: id) {
            interactor?.fetchLists()
        }
    }
}

// MARK: - ListEditDelegate

extension TaskListPresenter: ListEditDelegate {
    func didAddTask(title: String, description: String?) {
        interactor?.addTask(title: title, description: description)
    }
    
    func didUpdateTask(_ task: TaskListEntity, at indexPath: IndexPath) {
        interactor?.updateTask(id: task.id, title: task.todo, description: task.description)
    }
}
