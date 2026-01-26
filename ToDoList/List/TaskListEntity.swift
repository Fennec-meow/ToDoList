import UIKit

protocol ListEditDelegate: AnyObject {
    func didAddTask(title: String, description: String?)
    func didUpdateTask(_ task: TaskListEntity, at indexPath: IndexPath)
}

// MARK: - API Response

struct TodosResponse: Codable {
    let todos: [TaskListEntity]
    let total: Int
    let skip: Int
    let limit: Int
}

struct TaskListEntity: Codable {
    let id: Int
    var todo: String
    var completed: Bool
    let userId: Int
    var description: String?
    var date: Date
    
    init(
        id: Int,
        todo: String,
        completed: Bool,
        userId: Int,
        description: String? = nil,
        date: Date = Date()
    ) {
        self.id = id
        self.todo = todo
        self.completed = completed
        self.userId = userId
        self.description = description
        self.date = date
    }
    
    var title: String { todo }
    var isCompleted: Bool { completed }
}

// MARK: - JSON Decoder Helper

struct JSONHelper {
    static func loadTodosFromJSON() -> [TaskListEntity]? {
        guard let url = Bundle.main.url(
            forResource: "todos",
            withExtension: "json"
        ) else {
            print("ERROR: JSON file not found in bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            struct TodoItem: Codable {
                let id: Int
                let todo: String
                let completed: Bool
                let userId: Int
            }
            
            struct Response: Codable {
                let todos: [TodoItem]
            }
            
            let response = try decoder.decode(Response.self, from: data)
            
            let taskEntities = response.todos.map { item in
                TaskListEntity(
                    id: item.id,
                    todo: item.todo,
                    completed: item.completed,
                    userId: item.userId,
                    description: "",
                    date: Date()
                )
            }
            
            print("Successfully loaded \(taskEntities.count) tasks from JSON")
            return taskEntities
            
        } catch {
            print("ERROR decoding JSON: \(error)")
            return nil
        }
    }
    
    static func printJSONFileContent() {
        guard let url = Bundle.main.url(forResource: "todos", withExtension: "json") else {
            print("JSON file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("=== JSON FILE CONTENT ===")
                print(jsonString)
                print("=== END JSON ===")
            }
        } catch {
            print("Error reading JSON file: \(error)")
        }
    }
}
