import UIKit

struct CreateTaskEntity {
    let id: Int
    var title: String
    var description: String?
    var date: Date
    var isCompleted: Bool
    
    init(
        id: Int = 0,
        title: String = "",
        description: String? = nil,
        date: Date = Date(),
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.isCompleted = isCompleted
    }
    
    func toTaskEntity() -> TaskListEntity {
        return TaskListEntity(
            id: id,
            todo: title,
            completed: isCompleted,
            userId: 1
        )
    }
    
    static func fromTaskEntity(_ task: TaskListEntity) -> CreateTaskEntity {
        return CreateTaskEntity(
            id: task.id,
            title: task.todo,
            description: nil,
            date: Date(),
            isCompleted: task.completed
        )
    }
}
