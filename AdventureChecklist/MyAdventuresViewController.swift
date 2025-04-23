import UIKit

class MyAdventuresViewController: UITableViewController {
    
    // MARK: - Properties
    private var adventures: [Adventure] = []
    private let imageCache = NSCache<NSString, UIImage>()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAdventures()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "My Adventures"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    // MARK: - Data Management
    private func loadAdventures() {
        adventures = DataManager.shared.loadAdventures()
            .sorted { $0.startDate > $1.startDate } // Sort by start date, most recent first
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adventures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdventureCell", for: indexPath) as! AdventureCell
        let adventure = adventures[indexPath.row]
        
        // Configure cell
        cell.titleLabel.text = adventure.name
        cell.dateLabel.text = adventure.dateRange
        
        // Load image
        loadImage(for: adventure, in: cell.destinationImageView)
        
        return cell
    }
    
    private func loadImage(for adventure: Adventure, in imageView: UIImageView) {
        // Use cached image if available
        if let cachedImage = imageCache.object(forKey: adventure.destination as NSString) {
            imageView.image = cachedImage
            return
        }
        
        // Use Unsplash API to get an image for the destination
        let query = adventure.destination.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.unsplash.com/search/photos?query=\(query)&per_page=1"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(Config.unsplashAccessKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    imageView.image = UIImage(systemName: "photo")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let urls = firstResult["urls"] as? [String: String],
                   let imageUrlString = urls["regular"],
                   let imageUrl = URL(string: imageUrlString) {
                    
                    URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                        guard let data = data, let image = UIImage(data: data) else {
                            DispatchQueue.main.async {
                                imageView.image = UIImage(systemName: "photo")
                            }
                            return
                        }
                        
                        // Cache the image
                        self?.imageCache.setObject(image, forKey: adventure.destination as NSString)
                        
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    }.resume()
                } else {
                    DispatchQueue.main.async {
                        imageView.image = UIImage(systemName: "photo")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    imageView.image = UIImage(systemName: "photo")
                }
            }
        }.resume()
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 166 // 150 (image height) + 16 (padding)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let adventure = adventures[indexPath.row]
        performSegue(withIdentifier: "ShowChecklist", sender: adventure)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let adventure = adventures[indexPath.row]
            DataManager.shared.deleteAdventure(adventure)
            adventures.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
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

// MARK: - AdventureCell
class AdventureCell: UITableViewCell {
    @IBOutlet weak var destinationImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
} 
