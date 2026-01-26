import UIKit

// MARK: - Protocol

protocol TaskListRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
    func showCreateTask(delegate: ListEditDelegate)
    func showEditTask(task: TaskListEntity, at indexPath: IndexPath, delegate: ListEditDelegate)
    func shareTask(task: TaskListEntity, from view: UIViewController)
}

// MARK: - TaskListRouter

final class TaskListRouter {
    
    weak var viewController: UIViewController?
}

// MARK: - TaskListRouterProtocol

extension TaskListRouter: TaskListRouterProtocol {
    static func createModule() -> UIViewController {
        let view = TaskListViewController()
        let presenter = TaskListPresenter()
        let interactor = TaskListInteractor()
        let router = TaskListRouter()
        
        view.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.presenter = presenter
        
        router.viewController = view
        
        return view
    }
    
    func showCreateTask(delegate: ListEditDelegate) {
        let createTaskVC = CreateTaskRouter.createModule(for: nil, delegate: delegate)
        viewController?.navigationController?.pushViewController(createTaskVC, animated: true)
    }
    
    func showEditTask(
        task: TaskListEntity,
        at indexPath: IndexPath,
        delegate: ListEditDelegate
    ) {
        let createTaskVC = CreateTaskRouter.createModule(
            for: task,
            delegate: delegate,
            indexPath: indexPath
        )
        viewController?.navigationController?.pushViewController(createTaskVC, animated: true)
    }
    
    func shareTask(task: TaskListEntity, from view: UIViewController) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        let dateString = dateFormatter.string(from: task.date)
        let statusString = task.completed ? "✅ Выполнена" : "⏳ Не выполнена"
        
        let shareText = """
        📋 Задача: \(task.todo)
        \(statusString)
        📅 Дата: \(dateString)
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        activityVC.popoverPresentationController?.sourceView = view.view
        activityVC.popoverPresentationController?.sourceRect = CGRect(
            x: UIScreen.main.bounds.width / 2,
            y: UIScreen.main.bounds.height / 2,
            width: 0,
            height: 0
        )
        view.present(activityVC, animated: true)
    }
}
