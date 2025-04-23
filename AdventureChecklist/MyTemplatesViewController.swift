import UIKit

class MyTemplatesViewController: UITableViewController {
    
    // MARK: - Properties
    private var templates: [Template] = []
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTemplates()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "My Templates"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTemplate))
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        tableView.register(TemplateCell.self, forCellReuseIdentifier: "TemplateCell")
    }
    
    @objc private func addNewTemplate() {
        let alert = UIAlertController(title: "New Template", message: "Enter a name for your new template", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Template Name"
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let templateName = alert.textFields?.first?.text, !templateName.isEmpty else { return }
            
            let newTemplate = Template(name: templateName, tripType: "Custom", checklistItems: [])
            DataManager.shared.saveTemplate(newTemplate)
            self?.loadTemplates()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Data Management
    private func loadTemplates() {
        let allTemplates = DataManager.shared.loadTemplates()
        let defaultTemplateNames = ["Domestic Camping", "Domestic Snowboarding", "Domestic City", "Domestic Business",
                                  "International Camping", "International Snowboarding", "International City", "International Business"]
        
        // Filter out default templates and sort by creation date (newest first)
        templates = allTemplates.filter { !defaultTemplateNames.contains($0.name) }
            .sorted { $0.creationDate > $1.creationDate }
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateCell", for: indexPath) as! TemplateCell
        let template = templates[indexPath.row]
        
        cell.configure(with: template)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let template = templates[indexPath.row]
        performSegue(withIdentifier: "ShowChecklist", sender: template)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let template = templates[indexPath.row]
            DataManager.shared.deleteTemplate(template)
            templates.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChecklist",
           let checklistVC = segue.destination as? ChecklistViewController,
           let template = sender as? Template {
            checklistVC.checklistItems = template.checklistItems
            checklistVC.isTemplateMode = true
            checklistVC.template = template
        }
    }
}

// MARK: - TemplateCell
class TemplateCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
    }
    
    func configure(with template: Template) {
        titleLabel.text = template.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let dateString = dateFormatter.string(from: template.creationDate)
        subtitleLabel.text = "\(template.tripType) - \(template.itemsCount) items • Created: \(dateString)"
    }
}
