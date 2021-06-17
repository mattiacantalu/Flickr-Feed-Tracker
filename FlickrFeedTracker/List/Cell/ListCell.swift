import Foundation
import UIKit

class ListCell: UITableViewCell {
    private var model : ListCellViewModel? {
        didSet { Task { do { try await loadImage() }}}
    }

    private let imgView : UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit(viewModel: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit(viewModel: nil)
    }

    private func commonInit(viewModel: ListCellViewModel?) {
        setupConstraint()
        self.imgView.image = nil
        self.imgView.contentMode = .scaleAspectFill
        self.model = viewModel
    }

    func setup(viewModel: ListCellViewModel) {
        commonInit(viewModel: viewModel)
    }
}

private extension ListCell {
    func loadImage() async throws {
        (try await model?.fetchImage())
            .map { imgView.image = UIImage(data: $0) }
    }

    func setupConstraint() {
        imgView.activate(constraints: [
            imgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ], on: contentView)
    }
}

private extension UIView {
    func activate(constraints: [NSLayoutConstraint], on view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        NSLayoutConstraint.activate(constraints)
    }
}
