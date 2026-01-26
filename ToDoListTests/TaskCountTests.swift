import XCTest
@testable import ToDoList

class TaskCountTests: XCTestCase {
    
    func testTaskCountCalculation() {
        let tasks = [
            TaskListEntity(id: 1, todo: "Задача 1", completed: false, userId: 1),
            TaskListEntity(id: 2, todo: "Задача 2", completed: true, userId: 1),
            TaskListEntity(id: 3, todo: "Задача 3", completed: false, userId: 1)
        ]
        
        let totalTasks = tasks.count
        
        XCTAssertEqual(totalTasks, 3, "Должно быть 3 задачи")
    }
    
    func testCompletedTasksCount() {
        let tasks = [
            TaskListEntity(id: 1, todo: "Задача 1", completed: false, userId: 1),
            TaskListEntity(id: 2, todo: "Задача 2", completed: true, userId: 1),
            TaskListEntity(id: 3, todo: "Задача 3", completed: true, userId: 1),
            TaskListEntity(id: 4, todo: "Задача 4", completed: false, userId: 1)
        ]
        
        let completedTasks = tasks.filter { $0.completed }.count
        
        XCTAssertEqual(completedTasks, 2, "Должно быть 2 выполненные задачи")
    }
    
    func testIncompleteTasksCount() {
        let tasks = [
            TaskListEntity(id: 1, todo: "Задача 1", completed: false, userId: 1),
            TaskListEntity(id: 2, todo: "Задача 2", completed: true, userId: 1),
            TaskListEntity(id: 3, todo: "Задача 3", completed: false, userId: 1)
        ]
        
        let incompleteTasks = tasks.filter { !$0.completed }.count
        
        XCTAssertEqual(incompleteTasks, 2, "Должно быть 2 невыполненные задачи")
    }
    
    func testTasksLabelText() {
        let tasks = [
            TaskListEntity(id: 1, todo: "Задача 1", completed: false, userId: 1),
            TaskListEntity(id: 2, todo: "Задача 2", completed: true, userId: 1),
            TaskListEntity(id: 3, todo: "Задача 3", completed: false, userId: 1)
        ]
        
        let totalTasks = tasks.count
        let taskWord = getCorrectTaskWord(count: totalTasks)
        let labelText = "\(totalTasks) \(taskWord)"
        
        XCTAssertEqual(labelText, "3 Задачи", "Должно быть '3 Задачи'")
    }
    
    private func getCorrectTaskWord(count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "Задач"
        } else {
            switch lastDigit {
            case 1:
                return "Задача"
            case 2...4:
                return "Задачи"
            default:
                return "Задач"
            }
        }
    }
    
    func testTaskWordDeclension() {
        XCTAssertEqual(getCorrectTaskWord(count: 1), "Задача")
        XCTAssertEqual(getCorrectTaskWord(count: 2), "Задачи")
        XCTAssertEqual(getCorrectTaskWord(count: 3), "Задачи")
        XCTAssertEqual(getCorrectTaskWord(count: 4), "Задачи")
        XCTAssertEqual(getCorrectTaskWord(count: 5), "Задач")
        XCTAssertEqual(getCorrectTaskWord(count: 11), "Задач")
        XCTAssertEqual(getCorrectTaskWord(count: 21), "Задача")
        XCTAssertEqual(getCorrectTaskWord(count: 22), "Задачи")
        XCTAssertEqual(getCorrectTaskWord(count: 25), "Задач")
    }
}
