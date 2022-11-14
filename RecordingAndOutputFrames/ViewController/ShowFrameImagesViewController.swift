//
//  ShowFrameImagesViewController.swift
//  RecordingAndOutputFrames
//
//  Created by Trixie Lulamoon on 2022/11/14.
//

import UIKit

class ShowFrameImagesViewController: UIViewController {
    //MARK: @IBOutlet
    @IBOutlet weak var frameCollcetion: UICollectionView!
    
    //MARK: values
    var arrayImages: [UIImage] = []
    
    
    //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.frameCollcetion.dataSource = self
        self.frameCollcetion.delegate = self
    }
    
    
    @IBAction func displayImages(_ sender: UIButton) {
        arrayImages = MediaHandler.shared.getAllFrameImages()
        self.frameCollcetion.reloadData()
    }
    

}
//MARK: UICollectionViewDataSource
extension ShowFrameImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrameCollectionViewCell", for: indexPath) as? FrameCollectionViewCell else { return UICollectionViewCell() }
        
        let image = arrayImages[indexPath.item]
        cell.imgFrame.contentMode = .scaleAspectFill
        cell.imgFrame.image = image
        
        return cell
    }
    
    
}

//MARK: - UICollectionViewDelegate
extension ShowFrameImagesViewController: UICollectionViewDelegate {
    
}
