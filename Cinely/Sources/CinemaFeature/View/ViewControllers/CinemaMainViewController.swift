//
//  CinemaMainViewController.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design

final class CinemaMainViewController: BaseViewController {
    
    private let dataSources            = CinemaDataSource()
    private lazy var collectionView    = CinemaCollectionView(dataSource: self.dataSources)
    
    override func addAttributes() {
        setDefaultBackground()
        setNavigationTint()
        setNavigationBackButton()
        navigationSetting()
        self.collectionView.delegate = self
        
    }
    
    private func navigationSetting() {
        self.navigationItem.title = "Cinely"
        self.navigationItem.rightBarButtonItem
        = UIBarButtonItem(image: Icons.magnifyingglass?.withTintColor(Color.green.withAlphaComponent(0.6)),
                          style: .plain,
                          target: self,
                          action: #selector(moveToSearch(_:)))
    }
    
    override func addChild() {
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    override func binding() {
        
    }
    
    @objc
    private func moveToSearch(_ sender: Any) {
        let searchVC = CinemaMovieSearchVIewController()
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
}

extension CinemaMainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = CinemaDetailViewController()
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
