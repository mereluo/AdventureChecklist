import Foundation

struct Adventure: Codable {
    let id: UUID
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var tripType: String
    var isInternational: Bool
    var checklistItems: [ChecklistItem]
    
    init(name: String, destination: String, startDate: Date, endDate: Date, tripType: String, isInternational: Bool, checklistItems: [ChecklistItem] = []) {
        self.id = UUID()
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.tripType = tripType
        self.isInternational = isInternational
        self.checklistItems = checklistItems
    }
    
    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

struct Template: Codable {
    let id: UUID
    var name: String
    var tripType: String
    var checklistItems: [ChecklistItem]
    let creationDate: Date
    
    init(name: String, tripType: String, checklistItems: [ChecklistItem]) {
        self.id = UUID()
        self.name = name
        self.tripType = tripType
        self.checklistItems = checklistItems
        self.creationDate = Date()
    }
    
    var itemsCount: Int {
        return checklistItems.count
    }
}

class ChecklistItem: Codable {
    let id: UUID
    var name: String
    var isChecked: Bool
    
    init(name: String, isChecked: Bool = false) {
        self.id = UUID()
        self.name = name
        self.isChecked = isChecked
    }
} 