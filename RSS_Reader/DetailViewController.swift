import UIKit

class DetailViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!

    // MARK: - Variables to Receive Data
    var newsTitle: String?
    var newsDescription: String?
    var image: UIImage?
    var newsLink: String?

    @IBAction func openLinkButtonTapped(_ sender: UIButton) {
        if let link = newsLink, let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    // MARK: - Helper Methods
    private func configureView() {
        titleLabel.text = newsTitle
        descriptionLabel.text = newsDescription?.htmlToPlainText()
        newsImageView.image = image
        linkButton.setTitle("View Full Article", for: .normal)
    }
}


