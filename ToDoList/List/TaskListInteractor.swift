import UIKit

// MARK: - Protocol

protocol TaskListInteractorProtocol: AnyObject {
    func fetchLists()
    func toggleTaskCompletion(at indexPath: IndexPath)
    func deleteTask(at indexPath: IndexPath)
    func addTask(title: String, description: String?)
    func updateTask(id: Int, title: String, description: String?)
    func searchTasks(with text: String)
}

// MARK: - TaskListInteractor

final class TaskListInteractor {
    
    weak var presenter: TaskListPresenterProtocol?
    private var tasks: [TaskListEntity] = []
}

// MARK: - TaskListInteractorProtocol

extension TaskListInteractor: TaskListInteractorProtocol {
    
    func fetchLists() {
        print("ListInteractor: Fetching tasks...")
        
        let allTasks = CoreDataManager.shared.getAllTasks()
        print("ListInteractor: Got \(allTasks.count) tasks")
        
        if allTasks.isEmpty {
            print("ListInteractor: No tasks found, checking JSON...")
            
            if let jsonTasks = JSONHelper.loadTodosFromJSON() {
                print("ListInteractor: Loaded \(jsonTasks.count) from JSON")
                
                for task in jsonTasks {
                    _ = CoreDataManager.shared.saveTask(
                        title: task.todo,
                        description: task.description,
                        isCompleted: task.completed
                    )
                }
                
                let reloadedTasks = CoreDataManager.shared.getAllTasks()
                self.tasks = reloadedTasks
                self.presenter?.didFetchTasks(reloadedTasks)
                return
            }
        }
        
        self.tasks = allTasks
        self.presenter?.didFetchTasks(allTasks)
    }
    
    func toggleTaskCompletion(at indexPath: IndexPath) {
        guard indexPath.row < tasks.count else { return }
        
        var task = tasks[indexPath.row]
        task.completed = !task.completed
        
        CoreDataManager.shared.updateTask(id: task.id, isCompleted: task.completed)
        
        tasks[indexPath.row] = task
        
        presenter?.didUpdateTaskFromInteractor(task, at: indexPath)
    }
    
    func deleteTask(at indexPath: IndexPath) {
        guard indexPath.row < tasks.count else { return }
        
        let task = tasks[indexPath.row]
        
        CoreDataManager.shared.deleteTask(id: task.id)
        
        tasks.remove(at: indexPath.row)
        
        presenter?.didDeleteTask(at: indexPath)
    }
    
    func addTask(title: String, description: String?) {
        let task = CoreDataManager.shared.saveTask(title: title, description: description)
        
        tasks.insert(task, at: 0)
        
        presenter?.didAddTask(task)
    }
    
    func updateTask(id: Int, title: String, description: String?) {
        CoreDataManager.shared.updateTask(id: id, title: title, description: description)
        
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            var task = tasks[index]
            task.todo = title
            task.description = description
            tasks[index] = task
            
            presenter?.didFetchTasks(tasks)
        }
    }
    
    func searchTasks(with text: String) {
        let allTasks = CoreDataManager.shared.getAllTasks()
        
        if text.isEmpty {
            tasks = allTasks
        } else {
            tasks = allTasks.filter { $0.todo.lowercased().contains(text.lowercased()) }
        }
        presenter?.didFetchTasks(tasks)
    }
}
