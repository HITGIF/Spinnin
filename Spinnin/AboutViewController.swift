//
//  Copyright 2017 SchoolPower Studio

//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at

//  http://www.apache.org/licenses/LICENSE-2.0

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


import UIKit
import VTAcknowledgementsViewController

class AboutViewController: UITableViewController {
    
    @IBOutlet weak var licensesCell: UITableViewCell!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor.clear
    }
    
    func gotoAck() {
        
        let ackViewController = VTAcknowledgementsViewController.init(fileNamed: "Pods-Spinnin-acknowledgements")
        ackViewController?.title = "Licenses"
        ackViewController?.headerText = "I love open source software."
        self.show(ackViewController!, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 2: gotoAck()
        default: return
        }
    }
}
