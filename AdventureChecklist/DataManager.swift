import Foundation

class DataManager {
    static let shared = DataManager()
    
    private let adventuresKey = "adventures"
    private let templatesKey = "templates"
    
    private init() {}
    
    // MARK: - Adventures
    func saveAdventure(_ adventure: Adventure) {
        var adventures = loadAdventures()
        if let index = adventures.firstIndex(where: { $0.id == adventure.id }) {
            adventures[index] = adventure
        } else {
            adventures.append(adventure)
        }
        saveAdventures(adventures)
    }
    
    func loadAdventures() -> [Adventure] {
        guard let data = UserDefaults.standard.data(forKey: adventuresKey) else { return [] }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Adventure].self, from: data)
        } catch {
            print("Error loading adventures: \(error)")
            return []
        }
    }
    
    private func saveAdventures(_ adventures: [Adventure]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(adventures)
            UserDefaults.standard.set(data, forKey: adventuresKey)
        } catch {
            print("Error saving adventures: \(error)")
        }
    }
    
    func deleteAdventure(_ adventure: Adventure) {
        var adventures = loadAdventures()
        adventures.removeAll { $0.id == adventure.id }
        saveAdventures(adventures)
    }
    
    // MARK: - Templates
    func saveTemplate(_ template: Template) {
        var templates = loadTemplates()
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
        } else {
            templates.append(template)
        }
        saveTemplates(templates)
    }
    
    func resetTemplates() {
        UserDefaults.standard.removeObject(forKey: templatesKey)
        let defaultTemplates = createDefaultTemplates()
        saveTemplates(defaultTemplates)
    }
    
    func loadTemplates() -> [Template] {
        var templates: [Template] = []
        let defaultTemplateNames = ["Camping", "Snowboarding", "City", "Business"]
        
        // First try to load existing templates
        if let data = UserDefaults.standard.data(forKey: templatesKey) {
            if let loadedTemplates = try? JSONDecoder().decode([Template].self, from: data) {
                templates = loadedTemplates
            }
        }
        
        // Only create default templates on first launch
        if templates.isEmpty {
            // Create all default templates
            let defaultTemplates = createDefaultTemplates()
            templates = defaultTemplates
            saveTemplates(templates)
        }
        
        return templates
    }
    
    private func createDefaultTemplates() -> [Template] {
        let campingItems = [
            ChecklistItem(name: "Tent + stakes"),
            ChecklistItem(name: "Sleeping bag & pad"),
            ChecklistItem(name: "Headlamp / flashlight"),
            ChecklistItem(name: "Camping stove + fuel"),
            ChecklistItem(name: "Cookware (pot/pan, utensils, mug)"),
            ChecklistItem(name: "Cooler + food"),
            ChecklistItem(name: "Reusable water bottle / hydration bladder"),
            ChecklistItem(name: "Clothing layers (base, mid, waterproof)"),
            ChecklistItem(name: "Hiking boots"),
            ChecklistItem(name: "First aid kit"),
            ChecklistItem(name: "Sunscreen + bug spray"),
            ChecklistItem(name: "Trash bags"),
            ChecklistItem(name: "Map / compass / trail app"),
            ChecklistItem(name: "Firestarter / lighter")
        ]
        
        let snowboardingItems = [
            ChecklistItem(name: "Snowboard + bindings"),
            ChecklistItem(name: "Snowboard boots"),
            ChecklistItem(name: "Helmet"),
            ChecklistItem(name: "Snow goggles"),
            ChecklistItem(name: "Ski pass or lift ticket"),
            ChecklistItem(name: "Waterproof outerwear (jacket/pants)"),
            ChecklistItem(name: "Gloves/mittens"),
            ChecklistItem(name: "Base layers (thermal top/bottom)"),
            ChecklistItem(name: "Neck gaiter / face mask"),
            ChecklistItem(name: "Thick socks"),
            ChecklistItem(name: "Casual winter clothes"),
            ChecklistItem(name: "Hand warmers"),
            ChecklistItem(name: "Sunscreen"),
            ChecklistItem(name: "Snacks + water bottle")
        ]
        
        let cityItems = [
            ChecklistItem(name: "Casual outfits"),
            ChecklistItem(name: "Comfortable walking shoes"),
            ChecklistItem(name: "Phone + charger"),
            ChecklistItem(name: "Wallet / ID / cards"),
            ChecklistItem(name: "Sunglasses"),
            ChecklistItem(name: "Reusable water bottle"),
            ChecklistItem(name: "Travel-size toiletries"),
            ChecklistItem(name: "Light jacket or umbrella (weather-based)"),
            ChecklistItem(name: "Book / entertainment"),
            ChecklistItem(name: "Day bag or backpack"),
            ChecklistItem(name: "Local transport card (if applicable)")
        ]
        
        let businessItems = [
            ChecklistItem(name: "Business attire (suits, blouse, slacks, etc.)"),
            ChecklistItem(name: "Laptop + charger"),
            ChecklistItem(name: "Notebook / pen"),
            ChecklistItem(name: "Work documents / meeting notes"),
            ChecklistItem(name: "Business cards"),
            ChecklistItem(name: "Comfortable business shoes"),
            ChecklistItem(name: "Casual clothes for downtime"),
            ChecklistItem(name: "Phone + charger"),
            ChecklistItem(name: "Toiletries"),
            ChecklistItem(name: "ID / access badge (if needed)"),
            ChecklistItem(name: "Day bag or briefcase")
        ]
        
        let templates = [
            Template(name: "Camping", tripType: "Camping", checklistItems: campingItems),
            Template(name: "Snowboarding", tripType: "Snowboarding", checklistItems: snowboardingItems),
            Template(name: "City", tripType: "City", checklistItems: cityItems),
            Template(name: "Business", tripType: "Business", checklistItems: businessItems)
        ]
        
        return templates
    }
    
    private func saveTemplates(_ templates: [Template]) {
        print("Saving templates: \(templates.map { $0.name })") // Debug print
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(templates)
            UserDefaults.standard.set(data, forKey: templatesKey)
            print("Successfully saved templates") // Debug print
        } catch {
            print("Error saving templates: \(error)") // Debug print
        }
    }
    
    func deleteTemplate(_ template: Template) {
        var templates = loadTemplates()
        templates.removeAll { $0.id == template.id }
        saveTemplates(templates)
    }
} 
