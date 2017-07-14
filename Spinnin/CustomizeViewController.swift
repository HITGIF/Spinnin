//
//  Copyright 2017 Carbonylgroup Studio
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


import UIKit
import Material

class CustomizeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previewContainer: UIView!
    @IBOutlet weak var lightPreview: UIView!
    @IBOutlet weak var darkPreview: UIView!
    
    fileprivate let userDefaults = UserDefaults.standard
    fileprivate let playerView = UIImageView(frame: .zero)
    fileprivate let playerViewCopy = UIImageView(frame: .zero)
    fileprivate var indexSelected: Int = 0
    fileprivate var indexBackgroung: Int = 0
    fileprivate var radius: CGFloat = 24
    fileprivate let itemDiameter: CGFloat = 45.0
    fileprivate let colors = [#colorLiteral(red: 0.9568627451, green: 0.262745098, blue: 0.2117647059, alpha: 1),#colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1),#colorLiteral(red: 1, green: 0.5960784314, blue: 0, alpha: 1),#colorLiteral(red: 0.9333333333, green: 0.7333333333, blue: 0, alpha: 1),#colorLiteral(red: 0.5450980392, green: 0.7647058824, blue: 0.2901960784, alpha: 1),#colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1),#colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1),#colorLiteral(red: 0, green: 0.5882352941, blue: 0.5333333333, alpha: 1),#colorLiteral(red: 0, green: 0.737254902, blue: 0.831372549, alpha: 1),#colorLiteral(red: 0.1294117647, green: 0.5882352941, blue: 0.9529411765, alpha: 1),#colorLiteral(red: 0.2470588235, green: 0.3176470588, blue: 0.7098039216, alpha: 1),#colorLiteral(red: 0.4039215686, green: 0.2274509804, blue: 0.7176470588, alpha: 1),#colorLiteral(red: 0.6117647059, green: 0.1529411765, blue: 0.6901960784, alpha: 1),#colorLiteral(red: 0.9137254902, green: 0.1176470588, blue: 0.3882352941, alpha: 1)]
    fileprivate let playerBackgroundColors = [.clear,#colorLiteral(red: 0.1490196078, green: 0.1960784314, blue: 0.2196078431, alpha: 1),#colorLiteral(red: 0.9700000286, green: 0.9700000286, blue: 0.9700000286, alpha: 1)]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupSettings()
        initCollectionView()
        initPreview()
    }
    
    func setupSettings() {
        
        indexSelected = userDefaults.integer(forKey: "selectedplayer")
        indexBackgroung = UserDefaults.standard.integer(forKey: "playerbackground")
    }
    
    func saveSettings() {
        
        userDefaults.set(indexSelected, forKey: "selectedplayer")
    }
    
    func popOut() {
        
        if let vc = self.presentingViewController as? ViewController {
            self.dismiss(animated: true, completion: {vc.initSettings()})
        }
    }
    
    @IBAction func cancelOnClick(_ sender: Any) {
        popOut()
    }
    
    @IBAction func saveOnClick(_ sender: Any) {
        
        saveSettings()
        popOut()
    }
    
    func initCollectionView() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func initPreview() {
        
        previewContainer?.layer.masksToBounds = true
        previewContainer?.layer.cornerRadius = 16.0
        
        initPreviewPlayers()
    }
    
    func initPreviewPlayers() {
        
        var playerImage: UIImage?
        getDataFromUrl(url: loadPlayerImages()[self.indexSelected] as! URL) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                
                playerImage = UIImage(data: data)
                let rotation = CABasicAnimation(keyPath: "transform.rotation")
                rotation.fromValue = 0
                rotation.toValue = 2 * Double.pi
                rotation.duration = 1.1
                rotation.repeatCount = Float.infinity
                
                self.playerView.removeFromSuperview()
                self.playerView.bounds.size = CGSize(width: self.radius * 2, height: self.radius * 2)
                self.playerView.image = playerImage
                self.playerView.layer.cornerRadius = self.radius
                self.playerView.backgroundColor = self.playerBackgroundColors[self.indexBackgroung]
                self.playerView.layer.add(rotation, forKey: "Spin")
                self.playerView.layer.shadowOffset = CGSize.init(width: 0, height: 2.5)
                self.playerView.layer.shadowRadius = 2
                self.playerView.layer.shadowOpacity = 0.2
                self.lightPreview.layout(self.playerView).center(offsetY: 12).size(CGSize(width: self.radius * 2, height: self.radius * 2))
                
                self.playerViewCopy.removeFromSuperview()
                self.playerViewCopy.bounds.size = CGSize(width: self.radius * 2, height: self.radius * 2)
                self.playerViewCopy.image = playerImage
                self.playerViewCopy.layer.cornerRadius = self.radius
                self.playerViewCopy.backgroundColor = self.playerBackgroundColors[self.indexBackgroung]
                self.playerViewCopy.layer.add(rotation, forKey: "Spin")
                self.playerViewCopy.layer.shadowOffset = CGSize.init(width: 0, height: 2.5)
                self.playerViewCopy.layer.shadowRadius = 2
                self.playerViewCopy.layer.shadowOpacity = 0.2
                self.darkPreview.layout(self.playerViewCopy).center(offsetY: 12).size(CGSize(width: self.radius * 2, height: self.radius * 2))
            }
        }
    }
    
    func loadPlayerImages() -> Array<Any> {
        
        let res = Bundle.main.url(forResource: "Players", withExtension: nil)!
        let fm = FileManager()
        return try! fm.contentsOfDirectory(at: res, includingPropertiesForKeys: nil, options: [])
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func getRandomColor() -> UIColor {
        
        let index = arc4random_uniform(UInt32(colors.count))
        return colors[Int(index)]
    }
}

//MARK: Collection View
extension CustomizeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadPlayerImages().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let position = indexPath.row
        
        collectionView.register(UINib(nibName: "PlayerImageCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: itemDiameter, height: itemDiameter)
        
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        collectionCell.layer.cornerRadius = itemDiameter / 2
        collectionCell.layer.masksToBounds = true
        
        getDataFromUrl(url: loadPlayerImages()[position] as! URL) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                (collectionCell.viewWithTag(1) as! UIImageView).image = UIImage(data: data)
            }
        }
        
        collectionCell.viewWithTag(2)!.backgroundColor = getRandomColor()
        collectionCell.viewWithTag(2)!.layer.cornerRadius = itemDiameter / 2
        
        if position == indexSelected { collectionCell.viewWithTag(2)!.isHidden = false }
        else { collectionCell.viewWithTag(2)!.isHidden = true }
        
        return collectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let position = indexPath.row
        if position != indexSelected {
            
            for item in collectionView.visibleCells {
                if item.viewWithTag(2)!.isHidden == false {
                    UIView.animate(withDuration: 0.2, delay: 0,options: UIViewAnimationOptions.curveEaseOut,animations: {
                        item.viewWithTag(2)!.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    }, completion: { finish in item.viewWithTag(2)!.isHidden = true })
                }
            }
            
            indexSelected = position
            let selectedView = collectionView.cellForItem(at: indexPath)?.viewWithTag(2)!
            selectedView?.isHidden = false
            selectedView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.2, delay: 0,options: UIViewAnimationOptions.curveEaseOut,animations: {
                selectedView?.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
            
            initPreviewPlayers()
        }
    }
}
