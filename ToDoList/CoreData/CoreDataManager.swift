import UIKit
import CoreData

// MARK: - CoreDataManager

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
}

// MARK: - Public Methods

extension CoreDataManager {
    func initializeDataIfNeeded() {
        if !UserDefaults.standard.bool(forKey: "hasLoadedInitialData") {
            print("Loading initial data...")
            loadDataFromJSON()
        } else {
            print("Data already loaded")
        }
    }
    
    func saveTask(title: String, description: String? = nil, isCompleted: Bool = false) -> TaskListEntity {
        let id = Int(Date().timeIntervalSince1970 * 1000)
        let currentDate = Date()
        
        let taskObject = NSEntityDescription.insertNewObject(forEntityName: "Task", into: context)
        
        taskObject.setValue(Int64(id), forKey: "id")
        taskObject.setValue(title, forKey: "title")
        taskObject.setValue(description ?? "", forKey: "taskDescription")
        taskObject.setValue(currentDate, forKey: "date")
        taskObject.setValue(isCompleted, forKey: "isCompleted")
        taskObject.setValue(Int64(1), forKey: "userId")
        
        saveContext()
        
        return TaskListEntity(
            id: id,
            todo: title,
            completed: isCompleted,
            userId: 1,
            description: description ?? "",
            date: currentDate
        )
    }
    
    func getAllTasks() -> [TaskListEntity] {
        print("Fetching all tasks from CoreData...")
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let tasks = try context.fetch(fetchRequest)
            print("Found \(tasks.count) tasks in CoreData")
            
            var taskEntities: [TaskListEntity] = []
            
            for taskObject in tasks {
                guard let id = taskObject.value(forKey: "id") as? Int64,
                      let title = taskObject.value(forKey: "title") as? String,
                      let isCompleted = taskObject.value(forKey: "isCompleted") as? Bool,
                      let userId = taskObject.value(forKey: "userId") as? Int64 else {
                    print("Failed to parse task object")
                    continue
                }
                
                let description = taskObject.value(forKey: "taskDescription") as? String
                let date = taskObject.value(forKey: "date") as? Date ?? Date()
                
                let task = TaskListEntity(
                    id: Int(id),
                    todo: title,
                    completed: isCompleted,
                    userId: Int(userId),
                    description: description,
                    date: date
                )
                
                taskEntities.append(task)
            }
            
            print("Converted \(taskEntities.count) tasks to TaskEntity")
            return taskEntities
            
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }
    
    func updateTask(id: Int, title: String? = nil, isCompleted: Bool? = nil, description: String? = nil) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let tasks = try context.fetch(fetchRequest)
            if let task = tasks.first {
                if let title = title {
                    task.setValue(title, forKey: "title")
                }
                if let isCompleted = isCompleted {
                    task.setValue(isCompleted, forKey: "isCompleted")
                }
                if let description = description {
                    task.setValue(description, forKey: "taskDescription")
                }
                
                saveContext()
            }
        } catch {
            print("Failed to update task: \(error)")
        }
    }
    
    func deleteTask(id: Int) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let tasks = try context.fetch(fetchRequest)
            tasks.forEach { context.delete($0) }
            saveContext()
        } catch {
            print("Failed to delete task: \(error)")
        }
    }
}

// MARK: - Private Methods

private extension CoreDataManager {
    func loadDataFromJSON() {
        guard let jsonTasks = JSONHelper.loadTodosFromJSON() else {
            print("Failed to load JSON data")
            return
        }
        
        print("Loaded \(jsonTasks.count) tasks from JSON")
        
        for task in jsonTasks {
            saveTaskFromJSON(task)
        }
        
        saveContext()
        
        UserDefaults.standard.set(true, forKey: "hasLoadedInitialData")
        print("Initial data loaded and saved to CoreData")
    }
    
    func saveTaskFromJSON(_ task: TaskListEntity) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %d", task.id)
        
        do {
            let existingTasks = try context.fetch(fetchRequest)
            
            if !existingTasks.isEmpty {
                print("Task with ID \(task.id) already exists")
                return
            }
            
            let taskObject = NSEntityDescription.insertNewObject(forEntityName: "Task", into: context)
            
            taskObject.setValue(Int64(task.id), forKey: "id")
            taskObject.setValue(task.todo, forKey: "title")
            taskObject.setValue("", forKey: "taskDescription")
            taskObject.setValue(Date(), forKey: "date")
            taskObject.setValue(task.completed, forKey: "isCompleted")
            taskObject.setValue(Int64(task.userId), forKey: "userId")
            
        } catch {
            print("Error saving task from JSON: \(error)")
        }
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
