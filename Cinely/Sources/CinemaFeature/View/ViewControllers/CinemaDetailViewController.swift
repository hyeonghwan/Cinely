//
//  CinemaDetailViewController.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import UIKit
import Design

final class CinemaDetailViewController: BaseViewController {
    
    private let dataSources           = CinemaDetailDataSource()
    private lazy var collectionView    = CinemaDetailCollectionView(dataSource: self.dataSources)
    private let pageControl = UIPageControl()
    
    override func addAttributes() {
        setDefaultBackground()
        setNavigationTint()
        setNavigationBackButton()
        navigationSetting()
    }
    
    private func navigationSetting() {
        self.navigationItem.title = "Cinely"
        self.navigationItem.rightBarButtonItem
        = UIBarButtonItem(image: Icons.magnifyingglass?.withTintColor(Color.green.withAlphaComponent(0.6)),
                          style: .plain,
                          target: self,
                          action: #selector(moveToSearchDetail(_:)))
    }
    
    private func pageSetting() {
        pageControl.currentPageIndicatorTintColor = Color.white
        pageControl.pageIndicatorTintColor = Color.mediumGray.withAlphaComponent(0.6)
        pageControl.currentPage = 0
        pageControl.numberOfPages = 5
    }
    
    override func addChild() {
        self.view.addSubview(collectionView)
        self.collectionView.addSubview(pageControl)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            pageControl.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: PagingHeaderCell.height - 8)
        ])
    }
    
    override func binding() {
        
    }
    
    @objc
    private func moveToSearchDetail(_ sender: Any) {
        let searchVC = CinemaMovieSearchVIewController()
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
}

