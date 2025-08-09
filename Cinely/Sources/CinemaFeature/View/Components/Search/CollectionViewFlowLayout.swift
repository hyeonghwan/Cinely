import UIKit

final class TagCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        self.estimatedItemSize = CGSize(width: 100, height: 30)
        self.minimumInteritemSpacing = 4
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var sectionInsetLeft = sectionInset.left
        var maxY: CGFloat = -1.0
        
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                sectionInsetLeft = sectionInset.left
            }
            layoutAttribute.frame.origin.x = sectionInsetLeft
            
            sectionInsetLeft += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        return attributes
    }
}

