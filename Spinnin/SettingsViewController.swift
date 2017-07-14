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

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var themeSwitch: UISwitch!
    @IBOutlet weak var statusBarSwitch: UISwitch!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var speedLabel: UILabel!
    
    let userDefaults = UserDefaults.standard
    var dotSize = 1.0
    var enemySpeed = 1.0

    override func viewDidLoad() {
        
        super.viewDidLoad()
        UIApplication.shared.isStatusBarHidden = false
        if UI_USER_INTERFACE_IDIOM() == .phone { UIApplication.shared.statusBarStyle = .default }
        
        setupSettings()
    }
    
    func setupSettings() {
        
        if userDefaults.integer(forKey: "theme") == 0 { themeSwitch.isOn = false }
        else { themeSwitch.isOn = true }
        statusBarSwitch.isOn = userDefaults.bool(forKey: "hidestatusbar")
        dotSize = userDefaults.double(forKey: "dotsize")
        enemySpeed = userDefaults.double(forKey: "enemyspeed")
        sizeSlider.value = Float(dotSize * 4)
        sizeLabel.text = String(dotSize) + "x"
        speedSlider.value = Float(enemySpeed * 4)
        speedLabel.text = String(enemySpeed) + "x"
    }
    
    func saveSettings() {
        
        if themeSwitch.isOn { userDefaults.set(1, forKey: "theme") }
        else { userDefaults.set(0, forKey: "theme") }
        userDefaults.set(statusBarSwitch.isOn, forKey: "hidestatusbar")
        userDefaults.set(dotSize, forKey: "dotsize")
        userDefaults.set(enemySpeed, forKey: "enemyspeed")
    }
    
    func popOut() {
        
        if let vc = self.presentingViewController as? ViewController {
            self.dismiss(animated: true, completion: {vc.initSettings()})
        }
    }
    
    @IBAction func sizeChanged(_ sender: Any) {
        
        dotSize = 0.25 * Double(Int(sizeSlider.value))
        sizeLabel.text = String(dotSize) + "x"

    }
    
    @IBAction func speedChanged(_ sender: Any) {
        
        enemySpeed = 0.25 * Double(Int(speedSlider.value))
        speedLabel.text = String(enemySpeed) + "x"
    }

    @IBAction func cancelOnClick(_ sender: Any) {
        popOut()
    }
    
    @IBAction func doneOnClick(_ sender: Any) {
        
        saveSettings()
        popOut()
    }
}
