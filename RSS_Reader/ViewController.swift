import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var newsItems: [NewsItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Navigation Bar ayarı (Başlık yukarıda kalmasın istiyorsan bunu kaldırabilirsin)
        navigationItem.largeTitleDisplayMode = .automatic

        fetchNews()
    }

    func fetchNews() {
        newsItems.removeAll() // Önce temizle, tekrar eklenmesin!

        let parser = RSSParser()

        // BBC Kaynağı
        parser.parseFeed(url: "http://feeds.bbci.co.uk/news/world/rss.xml") { items in
            self.newsItems.append(contentsOf: items)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        // The Guardian Kaynağı
        parser.parseFeed(url: "https://www.theguardian.com/world/rss") { items in
            self.newsItems.append(contentsOf: items)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }


    // MARK: - Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsTableViewCell
        let item = newsItems[indexPath.row]

        cell.titleLabel.text = item.title
        cell.descriptionLabel.text = item.description.htmlToPlainText()

        if let imageURLString = item.imageURL, let imageURL = URL(string: imageURLString) {
            // Görseli asenkron yükle
            URLSession.shared.dataTask(with: imageURL) { data, _, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.newsImageView.image = image
                        cell.newsImageView.layer.cornerRadius = 0
                        cell.newsImageView.clipsToBounds = true
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.newsImageView.image = UIImage(systemName: "photo") // Placeholder
                    }
                }
            }.resume()
        } else {
            cell.newsImageView.image = UIImage(systemName: "photo") // Placeholder
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }

        let selectedItem = newsItems[indexPath.row]
        detailVC.newsTitle = selectedItem.title
        detailVC.newsDescription = selectedItem.description
        detailVC.newsLink = selectedItem.link

        // Görseli de detay sayfasına gönderelim
        if let imageURLString = selectedItem.imageURL, let imageURL = URL(string: imageURLString),
           let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
            detailVC.image = image
        } else {
            detailVC.image = UIImage(systemName: "photo")
        }

        navigationController?.pushViewController(detailVC, animated: true)
    }
}

