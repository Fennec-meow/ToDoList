import UIKit

// MARK: - Protocol

protocol CreateTaskRouterProtocol: AnyObject {
    static func createModule(for task: TaskListEntity?, delegate: ListEditDelegate, indexPath: IndexPath?) -> UIViewController
    func dismissModule()
}

// MARK: - CreateTaskRouter

final class CreateTaskRouter {
    
    weak var viewController: UIViewController?
    weak var delegate: ListEditDelegate?
    var indexPath: IndexPath?
}

// MARK: - CreateTaskRouterProtocol

extension CreateTaskRouter: CreateTaskRouterProtocol {
    
    static func createModule(
        for task: TaskListEntity? = nil,
        delegate: ListEditDelegate,
        indexPath: IndexPath? = nil
    ) -> UIViewController {
        let view = CreateTaskViewController()
        let presenter = CreateTaskPresenter()
        let router = CreateTaskRouter()
        
        view.presenter = presenter
        
        presenter.view = view
        presenter.router = router
                
        router.viewController = view
        router.delegate = delegate
        router.indexPath = indexPath
        
        if let task = task, let indexPath = indexPath {
            presenter.setupForEditing(task: task, indexPath: indexPath, delegate: delegate)
        } else {
            presenter.setupForCreating(delegate: delegate)
        }
        
        return view
    }
    
    func dismissModule() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
