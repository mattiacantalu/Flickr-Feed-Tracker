import Foundation
import UIKit
import CoreLocation

final class ListViewController: UITableViewController {
    private let viewModel: ListViewModel
    private let locationModel: LocationViewModel

    private var dataSource: [ListCellViewModel] {
        didSet { tableView.reloadData() }
    }
    private var error: Error? {
        didSet { alert(title: "Error", message: error?.localizedDescription ?? "Unknown") }
    }

    init(viewModel: ListViewModel,
         locationModel: LocationViewModel) {
        self.viewModel = viewModel
        self.locationModel = locationModel
        self.dataSource = []
        self.error = nil
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not availble!")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Feeds"
        tableView.register(ListCell.self, forCellReuseIdentifier: "listCell")
        navigationItem.rightBarButtonItems = [UIBarButtonItem(target: self,
                                                              selector: #selector(startTracking))]
    }

    @objc
    func startTracking() {
        locationModel.requestAuthorization()
        locationModel.onAuthorization = { [weak self] in
            self?.locationModel.startTrack()
        }
        locationModel.onDeny = {
            self.error = NSError.deny
        }
        locationModel.onLocationUpdate = { [weak self] _ in
            self?.loadData()
        }
    }

    func loadData() {
        viewModel.fetch(success: { [weak self] in self?.dataSource = $0 },
                        failure: { [weak self] in self?.error = $0 })
    }
}

extension ListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell",
                                                 for: indexPath) as? ListCell
        cell?.setup(viewModel: dataSource[indexPath.row])
        return cell ?? UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
}

extension UIBarButtonItem {
    convenience init(target: Any,
                     selector: Selector) {
        self.init(title: "Start",
                  style: .plain,
                  target: target,
                  action: selector)
    }
}

private extension NSError {
    static var deny: NSError {
        NSError(domain: "sample.com",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "Location permession denied!"])
    }
}
