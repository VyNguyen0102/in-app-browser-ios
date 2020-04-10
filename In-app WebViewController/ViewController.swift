//
//  ViewController.swift
//  In-app WebViewController
//
//  Created by Vy Nguyen on 4/9/20.
//  Copyright © 2020 VVLab. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func openPopUp(_ sender: Any) {
        let vc = WebViewController.init(url: URL.init(string: "https://apple.com")!)
        present(vc, animated: true) {
            // DO nothing
        }
    }

}

