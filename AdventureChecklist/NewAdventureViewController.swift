import UIKit

class NewAdventureViewController: UIViewController {
    
    // MARK: - Properties
    private let tripTypes = ["Camping", "Snowboarding", "City", "Business"]
    private var templates: [Template] = []
    private var selectedTemplate: Template? = nil
    
    // MARK: - IBOutlets
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var tripTypePicker: UIPickerView!
    @IBOutlet weak var internationalSwitch: UISwitch!
    @IBOutlet weak var useTemplateSwitch: UISwitch!
    @IBOutlet weak var templatesTableView: UITableView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load templates to ensure defaults are created
        _ = DataManager.shared.loadTemplates()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "New Adventure"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createTapped))
        
        // Set template switch off by default
        useTemplateSwitch.isOn = false
        templatesTableView.isHidden = true
        
        // Configure date pickers
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        endDatePicker.minimumDate = startDatePicker.date
        
        // Configure table view
        templatesTableView.delegate = self
        templatesTableView.dataSource = self
        templatesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TemplateCell")
        templatesTableView.allowsSelection = true
        templatesTableView.allowsMultipleSelection = false
        
        // Setup picker view
        tripTypePicker.delegate = self
        tripTypePicker.dataSource = self
    }
    
    @objc private func cancelTapped() {
        // Pop to root and switch to My Adventures tab
        if let tabBarController = tabBarController {
            tabBarController.selectedIndex = 0  // My Adventures is the first tab
            if let navigationController = tabBarController.viewControllers?[0] as? UINavigationController {
                navigationController.popToRootViewController(animated: false)
            }
        }
    }
    
    @objc private func createTapped() {
        let selectedTripType = tripTypes[tripTypePicker.selectedRow(inComponent: 0)]
        let isInternational = internationalSwitch.isOn
        
        // Get checklist items from selected template or default template
        var checklistItems: [ChecklistItem] = []
        
        if useTemplateSwitch.isOn, let selectedTemplate = selectedTemplate {
            // Use selected template
            checklistItems = selectedTemplate.checklistItems.map { ChecklistItem(name: $0.name, isChecked: false) }
        } else {
            // Start with empty checklist
            checklistItems = []
        }
        
        // If international, add passport and currency items
        if isInternational {
            // Check if these items already exist in the checklist
            let passportExists = checklistItems.contains { $0.name == "Passport/ID" }
            let currencyExists = checklistItems.contains { $0.name == "Local Currency" }
            
            if !passportExists {
                checklistItems.append(ChecklistItem(name: "Passport/ID"))
            }
            if !currencyExists {
                checklistItems.append(ChecklistItem(name: "Local Currency"))
            }
        }
        
        let adventure = Adventure(
            name: "\(selectedTripType) Trip to \(destinationTextField.text ?? "")",
            destination: destinationTextField.text ?? "",
            startDate: startDatePicker.date,
            endDate: endDatePicker.date,
            tripType: selectedTripType,
            isInternational: isInternational,
            checklistItems: checklistItems
        )
        
        // Save the adventure
        DataManager.shared.saveAdventure(adventure)
        
        // Reset all fields
        destinationTextField.text = ""
        tripTypePicker.selectRow(0, inComponent: 0, animated: false)
        internationalSwitch.isOn = false
        useTemplateSwitch.isOn = false
        templatesTableView.isHidden = true
        selectedTemplate = nil
        let today = Date()
        startDatePicker.date = today
        endDatePicker.date = today
        endDatePicker.minimumDate = today
        
        // Switch to My Adventures tab and pop to root
        if let tabBarController = tabBarController {
            tabBarController.selectedIndex = 0  // My Adventures is the first tab
            if let navigationController = tabBarController.viewControllers?[0] as? UINavigationController {
                navigationController.popToRootViewController(animated: false)
            }
        }
    }
    
    @objc private func startDateChanged() {
        endDatePicker.minimumDate = startDatePicker.date
        if endDatePicker.date < startDatePicker.date {
            endDatePicker.date = startDatePicker.date
        }
    }
    
    @IBAction func useTemplateSwitchChanged(_ sender: UISwitch) {
        templatesTableView.isHidden = !sender.isOn
        if sender.isOn {
            // Load all templates (both default and user-created)
            templates = DataManager.shared.loadTemplates()
                .sorted { $0.name < $1.name }
            templatesTableView.reloadData()
        } else {
            selectedTemplate = nil
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChecklist",
           let checklistVC = segue.destination as? ChecklistViewController,
           let adventure = sender as? Adventure {
            checklistVC.checklistItems = adventure.checklistItems
            checklistVC.isTemplateMode = false
            checklistVC.adventure = adventure
        }
    }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate
extension NewAdventureViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tripTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tripTypes[row]
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension NewAdventureViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateCell", for: indexPath)
        let template = templates[indexPath.row]
        cell.textLabel?.text = template.name
        cell.detailTextLabel?.text = "\(template.tripType) - \(template.itemsCount) items"
        
        // Show selection state
        if let selectedTemplate = selectedTemplate, selectedTemplate.id == template.id {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let template = templates[indexPath.row]
        selectedTemplate = template
        tableView.reloadData() // Refresh to show selection state
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedTemplate = nil
        tableView.reloadData() // Refresh to show deselection state
    }
} 
