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
        let defaultTemplateNames = ["Domestic Camping", "Domestic Snowboarding", "Domestic City", "Domestic Business",
                                  "International Camping", "International Snowboarding", "International City", "International Business"]
        
        // First try to load existing templates
        if let data = UserDefaults.standard.data(forKey: templatesKey) {
            if let loadedTemplates = try? JSONDecoder().decode([Template].self, from: data) {
                templates = loadedTemplates
            }
        }
        
        // Check if all default templates exist
        let existingDefaultNames = Set(templates.map { $0.name })
        let missingDefaults = defaultTemplateNames.filter { !existingDefaultNames.contains($0) }
        
        if !missingDefaults.isEmpty {
            // Create missing default templates
            let defaultTemplates = createDefaultTemplates()
            let missingTemplates = defaultTemplates.filter { missingDefaults.contains($0.name) }
            templates.append(contentsOf: missingTemplates)
            saveTemplates(templates)
        }
        
        return templates
    }
    
    private func createDefaultTemplates() -> [Template] {
        let domesticCampingItems = [
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
        
        let internationalItems = [
            ChecklistItem(name: "Passport (+ visa if needed)"),
            ChecklistItem(name: "Travel insurance"),
            ChecklistItem(name: "International SIM card / eSIM"),
            ChecklistItem(name: "Power adapter (plug converter)"),
            ChecklistItem(name: "Currency / travel credit card"),
            ChecklistItem(name: "Emergency contacts"),
            ChecklistItem(name: "Copy of itinerary / hotel confirmations"),
            ChecklistItem(name: "Language phrasebook or app"),
            ChecklistItem(name: "Medications with prescriptions"),
            ChecklistItem(name: "COVID vaccination card (if required)")
        ]
        
        let internationalCampingItems = domesticCampingItems + internationalItems + [
            ChecklistItem(name: "Multi-tool"),
            ChecklistItem(name: "Travel pillow"),
            ChecklistItem(name: "Compact cookware")
        ]
        
        let internationalSnowboardingItems = snowboardingItems + internationalItems + [
            ChecklistItem(name: "Ski insurance info"),
            ChecklistItem(name: "Boot dryer"),
            ChecklistItem(name: "International phone setup")
        ]
        
        let internationalCityItems = cityItems + internationalItems + [
            ChecklistItem(name: "Translation app"),
            ChecklistItem(name: "Offline maps"),
            ChecklistItem(name: "Pickpocket-safe bag")
        ]
        
        let internationalBusinessItems = businessItems + internationalItems + [
            ChecklistItem(name: "Presentation files backed up (USB + cloud)"),
            ChecklistItem(name: "Time zone watch app"),
            ChecklistItem(name: "Foreign etiquette research")
        ]
        
        let templates = [
            Template(name: "Domestic Camping", tripType: "Camping", checklistItems: domesticCampingItems),
            Template(name: "Domestic Snowboarding", tripType: "Snowboarding", checklistItems: snowboardingItems),
            Template(name: "Domestic City", tripType: "City", checklistItems: cityItems),
            Template(name: "Domestic Business", tripType: "Business", checklistItems: businessItems),
            Template(name: "International Camping", tripType: "Camping", checklistItems: internationalCampingItems),
            Template(name: "International Snowboarding", tripType: "Snowboarding", checklistItems: internationalSnowboardingItems),
            Template(name: "International City", tripType: "City", checklistItems: internationalCityItems),
            Template(name: "International Business", tripType: "Business", checklistItems: internationalBusinessItems)
        ]
        
        print("Created templates: \(templates.map { $0.name })") // Debug print
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
