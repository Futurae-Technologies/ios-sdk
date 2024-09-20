//
//  HistoryCell.swift
//  FuturaeDemo
//
//  Created by Ruben Dudek on 18/01/2023.
//  Copyright © 2023 Futurae. All rights reserved.
//

import UIKit

public final class HistoryCell: UITableViewCell {
    
    static let identifier: String = String(describing: HistoryCell.self)

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSetUp()
    }
    
    lazy var successLabel = Self.labelFabric()
    lazy var titleLabel = Self.labelFabric()
    lazy var dateLabel = Self.labelFabric()
    lazy var resultLabel = Self.labelFabric()
    
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 10
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Private
    
    private func initSetUp() {
        addSubviews()
        setUpLayout()
    }

    private func addSubviews() {
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(successLabel)
        mainStackView.addArrangedSubview(dateLabel)
        mainStackView.addArrangedSubview(resultLabel)
        contentView.addSubview(mainStackView)
    }

    private func setUpLayout() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        successLabel.text = nil
        titleLabel.text = nil
        dateLabel.text = nil
        resultLabel.text = nil
        let subviews = mainStackView.arrangedSubviews
        subviews.forEach {
            mainStackView.removeArrangedSubview($0)
        }
        initSetUp()
    }

    required init?(coder: NSCoder) { nil }
}

private extension HistoryCell {
    static func labelFabric() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
