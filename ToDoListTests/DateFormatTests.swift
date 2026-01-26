import XCTest
@testable import ToDoList

class DateFormatTests: XCTestCase {
    
    func testDateFormatInTableCell() {
        let task = TaskListEntity(
            id: 1,
            todo: "Тестовая задача",
            completed: false,
            userId: 1,
            description: "Описание",
            date: Date(timeIntervalSince1970: 946684800)
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        let formattedDate = dateFormatter.string(from: task.date)
        
        XCTAssertEqual(formattedDate, "01/01/00", "Дата должна быть в формате dd/MM/yy")
    }
    
    func testTodayDateInCreateTaskScreen() {
        let today = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        let todayFormatted = dateFormatter.string(from: today)
        
        let testFormatter = DateFormatter()
        testFormatter.dateFormat = "dd/MM/yy"
        let expectedFormat = testFormatter.string(from: today)
        
        XCTAssertEqual(todayFormatted, expectedFormat,
                      "Сегодняшняя дата должна быть в формате dd/MM/yy")
        print("Сегодня: \(todayFormatted)")
    }
}
