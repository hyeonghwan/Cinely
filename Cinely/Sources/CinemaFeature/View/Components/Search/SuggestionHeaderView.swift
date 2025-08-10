//
//  SuggestionHeaderView.swift
//  Cinely
//
//  Created by hwan on 8/10/25.
//

import UIKit
import Design
import RxSwift

final class SuggestionHeaderView: UITableViewHeaderFooterView, CellIdentifialble {
    private(set) var baseView = TitleActionButtonBaseView()
    private(set) var disposeBag = DisposeBag()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addAttributes()
        addChild()
        addLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    private func addAttributes() {
        self.baseView.setButtonTitle("전체삭제")
        self.baseView.setTitle("최근 검색")
    }
    
    private func addChild() {
        self.addSubview(baseView)
        self.baseView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addLayout() {
        NSLayoutConstraint.activate([
            baseView.topAnchor.constraint(equalTo: self.topAnchor),
            baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

final class TitleActionButtonBaseView: BaseView {
    private let sectionTitleLabel = UILabel()
    private(set) var actionButton = UIButton()
    
    override func addAttributes() {
        sectionTitleLabel.font = Font.bold14
        sectionTitleLabel.textColor = Color.white
        self.backgroundColor = .black
    }
    
    override func addChild() {
        self.addSubview(sectionTitleLabel)
        self.addSubview(actionButton)
        sectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        addLayout()
    }
    
    private func addLayout() {
        NSLayoutConstraint.activate([
            sectionTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            sectionTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            
            actionButton.centerYAnchor.constraint(equalTo: sectionTitleLabel.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
        ])
    }
    
    func setTitle(_ string: String) {
        sectionTitleLabel.text = string
    }
    
    func setButtonTitle(_ text: String) {
        actionButton
            .setAttributedTitle(
                NSAttributedString(
                    string: text,
                    attributes: [.foregroundColor : Color.green, .font : Font.bold14]
                ),
                for: .normal
            )
    }
    
    func setDeleteButtonHidden(_ bool: Bool) {
        actionButton.isHidden = bool
    }
}
