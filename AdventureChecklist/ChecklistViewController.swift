import UIKit

class ChecklistViewController: UIViewController {
    
    // MARK: - Properties
    var checklistItems: [ChecklistItem] = []
    var isTemplateMode: Bool = false
    var adventure: Adventure?
    var template: Template?
    
    // MARK: - IBOutlets
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveAsTemplateButton: UIButton!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        updateProgress()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Set title based on mode
        if isTemplateMode, let template = template {
            title = template.name
            saveAsTemplateButton.isHidden = true
        } else if let adventure = adventure {
            title = adventure.destination
            saveAsTemplateButton.isHidden = false
        } else {
            title = "Checklist"
            saveAsTemplateButton.isHidden = true
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
    }
    
    private func updateProgress() {
        let totalItems = checklistItems.count
        let checkedItems = checklistItems.filter { $0.isChecked }.count
        let progress = totalItems > 0 ? Float(checkedItems) / Float(totalItems) : 0
        
        progressView.setProgress(progress, animated: true)
        progressLabel.text = "\(checkedItems) of \(totalItems) items packed"
    }
    
    // MARK: - Actions
    @objc private func addTapped() {
        let alert = UIAlertController(title: "New Item", message: "Enter the item name", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Item Name"
            textField.autocapitalizationType = .sentences
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let name = textField.text, !name.isEmpty else { return }
            
            let newItem = ChecklistItem(name: name)
            self?.checklistItems.insert(newItem, at: 0)
            self?.saveChanges()
            self?.updateProgress()
            self?.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func saveChanges() {
        if isTemplateMode {
            if var template = template {
                template.checklistItems = checklistItems
                DataManager.shared.saveTemplate(template)
            }
        } else {
            if var adventure = adventure {
                adventure.checklistItems = checklistItems
                DataManager.shared.saveAdventure(adventure)
            }
        }
    }
    
    @IBAction func saveAsTemplateTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Save as Template", message: "Enter a name for your template", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Template Name"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty,
                  let adventure = self?.adventure else { return }
            
            let template = Template(
                name: name,
                tripType: adventure.tripType,
                checklistItems: self?.checklistItems ?? []
            )
            DataManager.shared.saveTemplate(template)
            
            // Pop to root and switch to My Templates tab
            if let tabBarController = self?.tabBarController {
                tabBarController.selectedIndex = 2  // My Templates is the third tab
                if let navigationController = tabBarController.viewControllers?[2] as? UINavigationController {
                    navigationController.popToRootViewController(animated: false)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ChecklistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklistItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItemCell", for: indexPath) as! ChecklistItemCell
        let item = checklistItems[indexPath.row]
        cell.configure(with: item)
        cell.checkboxTapped = { [weak self] in
            item.isChecked.toggle()
            self?.handleItemChecked()
        }
        return cell
    }
    
    private func handleItemChecked() {
        // Save changes
        saveChanges()
        
        // Update UI
        updateProgress()
        
        // Reload table with animation to move checked items
        let uncheckedItems = checklistItems.filter { !$0.isChecked }
        let checkedItems = checklistItems.filter { $0.isChecked }
        checklistItems = uncheckedItems + checkedItems
        
        // Save the new order
        saveChanges()
        
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            checklistItems.remove(at: indexPath.row)
            saveChanges()
            updateProgress()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - ChecklistItemCell
class ChecklistItemCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var checkboxButton: UIButton!
    @IBOutlet private weak var itemLabel: UILabel!
    
    var checkboxTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        checkboxButton.setImage(UIImage(systemName: "circle"), for: .normal)
        checkboxButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkboxButton.tintColor = .systemBlue
        
        checkboxButton.addTarget(self, action: #selector(checkboxButtonTapped), for: .touchUpInside)
    }
    
    func configure(with item: ChecklistItem) {
        itemLabel.text = item.name
        checkboxButton.isSelected = item.isChecked
        if item.isChecked {
            itemLabel.textColor = .systemGray
        } else {
            itemLabel.textColor = .label
        }
    }
    
    @objc private func checkboxButtonTapped() {
        checkboxTapped?()
    }
} 
