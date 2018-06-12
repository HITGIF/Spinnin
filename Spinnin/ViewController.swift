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
import GoogleMobileAds

class ViewController: UIViewController {
    
    fileprivate enum ScreenEdge: Int {
        
        case top = 0
        case right = 1
        case bottom = 2
        case left = 3
    }
    fileprivate enum GameState {
        
        case ready
        case playing
        case gameOver
        case setting
    }
    
    @IBOutlet weak var deadView: UIView!
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var deadTitle: UILabel!
    @IBOutlet weak var deadClock: UILabel!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var bubbleButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    fileprivate var themeIndex: Int?
    fileprivate var enemyTimer: Timer?
    fileprivate var deadColor: UIColor?
    fileprivate var radius: CGFloat = 12
    fileprivate var playerImage: UIImage?
    fileprivate var deadBackView: UIView?
    fileprivate var gameOverBuffer: Int = 0
    fileprivate var enemySpeed: CGFloat = 50
    fileprivate var enemyMergeCount: Int = 0
    fileprivate var gameState = GameState.ready
    fileprivate var displayLink: CADisplayLink?
    fileprivate var enemyViews = [UIImageView]()
    fileprivate let playerAnimationDuration = 5.0
    fileprivate var elapsedTime: TimeInterval = 0
    fileprivate var beginTimestamp: TimeInterval = 0
    fileprivate var interstitialAdView: GADInterstitial!
    fileprivate var playerView = UIImageView(frame: .zero)
    fileprivate var playerAnimator: UIViewPropertyAnimator?
    fileprivate var enemyAnimators = [UIViewPropertyAnimator]()
    
    fileprivate let textColors = [#colorLiteral(red: 0.1490196078, green: 0.1960784314, blue: 0.2196078431, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
    fileprivate let backgroundColors = [#colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1),#colorLiteral(red: 0.1490196078, green: 0.1960784314, blue: 0.2196078431, alpha: 1)]
    fileprivate let playerBackgroundColors = [.clear,#colorLiteral(red: 0.1490196078, green: 0.1960784314, blue: 0.2196078431, alpha: 1),#colorLiteral(red: 0.9700000286, green: 0.9700000286, blue: 0.9700000286, alpha: 1)]
    fileprivate let colors = [#colorLiteral(red: 0.9568627451, green: 0.262745098, blue: 0.2117647059, alpha: 1),#colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1),#colorLiteral(red: 1, green: 0.5960784314, blue: 0, alpha: 1),#colorLiteral(red: 0.9333333333, green: 0.7333333333, blue: 0, alpha: 1),#colorLiteral(red: 0.5450980392, green: 0.7647058824, blue: 0.2901960784, alpha: 1),#colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1),#colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1),#colorLiteral(red: 0, green: 0.5882352941, blue: 0.5333333333, alpha: 1),#colorLiteral(red: 0, green: 0.737254902, blue: 0.831372549, alpha: 1),#colorLiteral(red: 0.1294117647, green: 0.5882352941, blue: 0.9529411765, alpha: 1),#colorLiteral(red: 0.2470588235, green: 0.3176470588, blue: 0.7098039216, alpha: 1),#colorLiteral(red: 0.4039215686, green: 0.2274509804, blue: 0.7176470588, alpha: 1),#colorLiteral(red: 0.6117647059, green: 0.1529411765, blue: 0.6901960784, alpha: 1),#colorLiteral(red: 0.9137254902, green: 0.1176470588, blue: 0.3882352941, alpha: 1)]
    fileprivate let statusBarColors = [.default,UIStatusBarStyle.lightContent]
    
    override func viewWillAppear(_ animated: Bool) {
        
        if gameState != .gameOver { setupPlayerView() }
        if gameState != .setting && gameState != .gameOver { gameState = .ready }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.applicationDidEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        if gameState != .setting && gameState != .gameOver {
            
            initAd()
            initSettings()
            prepareGame()
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if gameState == .ready { centerPlayerView() }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // First touch to start the game
        if gameState == .ready { startGame() }
        
        if gameState == .playing {
            if let touchLocation = event?.allTouches?.first?.location(in: view) {
                
                movePlayer(to: touchLocation)
                moveEnemies(to: touchLocation)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationDidEnterForeground() {
        if gameState != .gameOver { setupPlayerView() }
    }
    
    func initSettings() {
        
        centerPlayerView()
        registerSettings()
        gameState = .ready
        themeIndex = UserDefaults.standard.integer(forKey: "theme")
        radius = 12 * CGFloat(UserDefaults.standard.double(forKey: "dotsize"))
        enemySpeed = 50 * CGFloat(UserDefaults.standard.double(forKey: "enemyspeed"))
        
        UIView.animate(withDuration: 0.5, delay: 0,options: UIViewAnimationOptions.curveEaseOut,animations: {
            
            UIApplication.shared.isStatusBarHidden = true
            self.view.backgroundColor = self.backgroundColors[self.themeIndex!]
            self.clockLabel.textColor = self.textColors[self.themeIndex!]
            self.startLabel.textColor = self.textColors[self.themeIndex!]
            self.settingsButton.tintColor = self.textColors[self.themeIndex!]
            self.bubbleButton.tintColor = self.textColors[self.themeIndex!]
            
            if UserDefaults.standard.bool(forKey: "hidestatusbar") { UIApplication.shared.isStatusBarHidden = true }
            else {
                UIApplication.shared.isStatusBarHidden = false
                UIApplication.shared.statusBarStyle = self.statusBarColors[self.themeIndex!]
            }
        }, completion: nil)
        
        getDataFromUrl(url: loadPlayerImages()[UserDefaults.standard.integer(forKey: "selectedplayer")] as! URL) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                self.playerImage = UIImage(data: data)
                self.setupPlayerView()
            }
        }
    }
    
    func initAd() {
        interstitialAdView = createAndLoadInterstitial()
    }
    
    func registerSettings() {
        
        if UserDefaults.standard.object(forKey: "theme") == nil { UserDefaults.standard.register(defaults: ["theme": 0]) }
        if UserDefaults.standard.object(forKey: "hidestatusbar") == nil { UserDefaults.standard.register(defaults: ["hidestatusbar": true]) }
        if UserDefaults.standard.object(forKey: "playerbackground") == nil { UserDefaults.standard.register(defaults: ["playerbackground": 0]) }
        if UserDefaults.standard.object(forKey: "dotsize") == nil { UserDefaults.standard.register(defaults: ["dotsize": Double(1.0)]) }
        if UserDefaults.standard.object(forKey: "enemyspeed") == nil { UserDefaults.standard.register(defaults: ["enemyspeed": Double(1.0)]) }
    }
    
    func loadPlayerImages() -> Array<Any> {
        
        let res = Bundle.main.url(forResource: "Players", withExtension: nil)!
        let fm = FileManager()
        return try! fm.contentsOfDirectory(at: res, includingPropertiesForKeys: nil, options: [])
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in completion(data, response, error) }.resume()
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        
        let interstitial = GADInterstitial.init(adUnitID: "ca-app-pub-9841217337381410/7307443886")
        let request = GADRequest()
        
        /* TEST DEVICES */
        //        request.testDevices = [kGADSimulatorID]
        
        interstitial.delegate = self
        interstitial.load(request)
        return interstitial
    }
    
    func displayAd() {
        
        if shouldDisplayAd() {
            if interstitialAdView.isReady { interstitialAdView.present(fromRootViewController: self) }
            else { print("Ad wasn't ready") }
        }
    }
    
    func shouldDisplayAd() -> Bool {
        return arc4random_uniform(UInt32(3)) == 0
    }
}

//MARK: Game Control
extension ViewController {
    
    func setupPlayerView() {
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 1.1
        rotation.repeatCount = Float.infinity
        
        playerView.bounds.size = CGSize(width: radius * 2, height: radius * 2)
        playerView.image = playerImage
        playerView.layer.cornerRadius = radius
        playerView.backgroundColor = playerBackgroundColors[UserDefaults.standard.integer(forKey: "playerbackground")]
        playerView.layer.add(rotation, forKey: "Spin")
        playerView.layer.shadowOffset = CGSize.init(width: 0, height: 2.5)
        playerView.layer.shadowRadius = 2
        playerView.layer.shadowOpacity = 0.2
        
        view.addSubview(playerView)
    }
    
    func popPlayerView() {
        
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [0, 0.2, -0.2, 0.2, 0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = CFTimeInterval(0.7)
        animation.isAdditive = true
        animation.repeatCount = 1
        animation.beginTime = CACurrentMediaTime()
        playerView.layer.add(animation, forKey: "pop")
    }
    
    func centerPlayerView() {
        
        playerAnimator = UIViewPropertyAnimator(duration: playerAnimationDuration, dampingRatio: 0.5, animations: { [weak self] in self?.playerView.center = (self?.view.center)!})
        playerAnimator?.startAnimation()
    }
    
    func generateEnemy(timer: Timer) {
        
        // Generate an enemy at random position
        let screenEdge = ScreenEdge.init(rawValue: Int(arc4random_uniform(4)))
        let screenBounds = UIScreen.main.bounds
        var position: CGFloat = 0
        
        switch screenEdge! {
        case .left, .right:
            position = CGFloat(arc4random_uniform(UInt32(screenBounds.height)))
        case .top, .bottom:
            position = CGFloat(arc4random_uniform(UInt32(screenBounds.width)))
        }
        
        // Add the new enemy to the view
        let enemyView = UIImageView(frame: .zero)
        enemyView.bounds.size = CGSize(width: radius, height: radius)
        
        switch screenEdge! {
        case .left:
            enemyView.center = CGPoint(x: 0, y: position)
        case .right:
            enemyView.center = CGPoint(x: screenBounds.width, y: position)
        case .top:
            enemyView.center = CGPoint(x: position, y: screenBounds.height)
        case .bottom:
            enemyView.center = CGPoint(x: position, y: 0)
        }
        
        enemyView.tag = 1
        enemyView.backgroundColor = getRandomColor()
        enemyView.layer.cornerRadius = radius / 2
        enemyView.layer.shadowOffset = CGSize.init(width: 0, height: 2.5)
        enemyView.layer.shadowRadius = 2
        enemyView.layer.shadowOpacity = 0.2
        
        view.addSubview(enemyView)
        
        // Start animation
        let duration = getEnemyDuration(enemyView: enemyView)
        let enemyAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: { [weak self] in if let strongSelf = self { enemyView.center = strongSelf.playerView.center }})
        enemyAnimator.startAnimation()
        enemyAnimators.append(enemyAnimator)
        enemyViews.append(enemyView)
    }
    
    func getRandomColor() -> UIColor {
        
        let index = arc4random_uniform(UInt32(colors.count))
        return colors[Int(index)]
    }
    
    func getEnemyDuration(enemyView: UIView) -> TimeInterval {
        
        let dx = playerView.center.x - enemyView.center.x
        let dy = playerView.center.y - enemyView.center.y
        return TimeInterval(sqrt(dx * dx + dy * dy) / enemySpeed)
    }
    
    func prepareGame() {
        
        if deadBackView != nil { animateDeadView(reveal: false) }
        else {
            self.deadView.isHidden = true
            centerPlayerView()
        }
        
        setupPlayerView()
        popPlayerView()
        startView.isHidden = false
        clockLabel.text = "00:00.000"
        gameState = .ready
    }
    
    func startGame() {
        
        startEnemyTimer()
        startDisplayLink()
        startView.isHidden = true
        beginTimestamp = 0
        gameState = .playing
    }
    
    func startEnemyTimer() {
        enemyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(generateEnemy(timer:)), userInfo: nil, repeats: true)
    }
    
    func startDisplayLink() {
        
        displayLink = CADisplayLink(target: self, selector: #selector(tick(sender:)))
        displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func tick(sender: CADisplayLink) {
        
        updateCountUpTimer(timestamp: sender.timestamp)
        do { try checkCollision() }
        catch { print("MERGE ERROR") }
    }
    
    func movePlayer(to touchLocation: CGPoint) {
        
        playerAnimator = UIViewPropertyAnimator(duration: playerAnimationDuration, dampingRatio: 0.5, animations: { [weak self] in self?.playerView.center = touchLocation})
        playerAnimator?.startAnimation()
    }
    
    func moveEnemies(to touchLocation: CGPoint) {
        
        for (index, enemyView) in enemyViews.enumerated() {
            let duration = getEnemyDuration(enemyView: enemyView)
            enemyAnimators[index] = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: { enemyView.center = touchLocation })
            enemyAnimators[index].startAnimation()
        }
    }
    
    func updateCountUpTimer(timestamp: TimeInterval) {
        
        if beginTimestamp == 0 { beginTimestamp = timestamp }
        elapsedTime = timestamp - beginTimestamp
        clockLabel.text = format(timeInterval: elapsedTime)
    }
    
    func format(timeInterval: TimeInterval) -> String {
        
        let interval = Int(timeInterval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let milliseconds = Int(timeInterval * 1000) % 1000
        return String(format: "%02d:%02d.%03d", minutes, seconds, milliseconds)
    }
    
    func checkCollision() throws -> Void {
        
        enemyViews.forEach {
            
            guard let playerFrame = playerView.layer.presentation()?.frame,
                let enemyFrame = $0.layer.presentation()?.frame,
                playerFrame.intersects(enemyFrame) else { return }
            if gameOverBuffer == 3 {
                deadColor = $0.backgroundColor
                gameOver()
            }
            else { gameOverBuffer += 1 }
        }
        
        for now in enemyViews {
            for item in enemyViews {
                let itemFrame = item.layer.presentation()?.frame
                let nowFrame = now.layer.presentation()?.frame
                guard itemFrame != nil && nowFrame != nil else { print("MERGE ERROR"); return }
                if (itemFrame?.contains(nowFrame!))! {
                    if enemyViews.index(of: now) != enemyViews.index(of: item){
                        item.backgroundColor = now.backgroundColor
                        item.tag += now.tag
                        enemyViews[enemyViews.index(of: now)!].removeFromSuperview()
                        enemyViews.remove(at: enemyViews.index(of: now)!)
                        let scale = CGFloat((Double(item.tag) * 0.1) + 1)
                        item.transform = CGAffineTransform(scaleX: scale, y: scale)
                        enemyMergeCount += 1
                        break
                    }
                }
            }
        }
    }
    
    func gameOver() {
        
        stopGame()
        removeEnemies()
        displayAd()
        animateDeadView(reveal: true)
        
    }
    
    func stopGame() {
        
        stopEnemyTimer()
        stopDisplayLink()
        stopAnimators()
        gameState = .gameOver
    }
    
    func stopEnemyTimer() {
        
        guard let enemyTimer = enemyTimer, enemyTimer.isValid else { return }
        enemyTimer.invalidate()
    }
    
    func stopDisplayLink() {
        
        displayLink?.isPaused = true
        displayLink?.remove(from: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        displayLink = nil
    }
    
    func stopAnimators() {
        
        playerAnimator?.stopAnimation(true)
        playerAnimator = nil
        enemyAnimators.forEach { $0.stopAnimation(true) }
        enemyAnimators = []
    }
    
    func removeEnemies() {
        
        enemyViews.forEach { $0.removeFromSuperview() }
        enemyViews = []
    }
    
    func animateDeadView(reveal: Bool) {
        
        if reveal {
            
            deadBackView?.removeFromSuperview()
            deadBackView = UIView.init(frame: (playerView.layer.presentation()?.frame)!)
            deadBackView?.backgroundColor = deadColor ?? .red
            deadBackView?.layer.cornerRadius = radius
            view.addSubview(deadBackView!)
            
            self.deadView.isHidden = false
            self.deadView.alpha = 0
            self.deadClock.text = self.clockLabel.text
            self.view.addSubview(self.deadView)
            
            UIView.animate(withDuration: 1, delay: 0,options: UIViewAnimationOptions.curveEaseIn,animations: {
                
                let scaleX = self.view.bounds.width / (self.deadBackView?.bounds.width)! * 5.0
                let scaleY = self.view.bounds.height / (self.deadBackView?.bounds.height)! * 5.0
                
                self.deadBackView?.transform = CGAffineTransform(scaleX: max(scaleX, scaleY), y: max(scaleX, scaleY))
                self.deadBackView?.layer.cornerRadius = self.radius * 1.25
                self.deadView?.alpha = 1
                UIApplication.shared.statusBarStyle = .lightContent
            }, completion: nil)
            
        } else {
            
            UIView.animate(withDuration: 0.5, delay: 0,options: UIViewAnimationOptions.curveEaseOut,animations: {
                
                self.deadBackView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.deadView?.alpha = 0
                UIApplication.shared.statusBarStyle = self.statusBarColors[self.themeIndex!]
            }, completion: { finish in
                
                self.deadView.isHidden = true
                self.deadBackView?.removeFromSuperview()
                self.centerPlayerView()
            })
        }
    }
    
    @IBAction func bubblesOnClick () {
        gameState = .setting
    }
    
    @IBAction func settingsOnClick () {
        gameState = .setting
    }
    
    @IBAction func restartOnClick () {
        self.prepareGame()
    }
}

//MARK: Ad Listener
extension ViewController: GADInterstitialDelegate {
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        initAd()
    }
}
