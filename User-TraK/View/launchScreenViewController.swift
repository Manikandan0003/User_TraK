//
//  launchScreenViewController.swift
//  User-TraK
//
//  Created by MANIKANDAN RAJA on 18/05/24.
//

import UIKit
import SwiftGifOrigin

class launchScreenViewController: UIViewController {
    @IBOutlet weak var gifImageView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load and display the GIF
        gifImageView.image = UIImage.gif(name: "logo") // Use the name of your GIF file without the extension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // You can add a delay or transition to the main content of your app
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Adjust the delay as needed
            self.navigateToSecondScreen()
        }
    }
    
    func navigateToSecondScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondVC = storyboard.instantiateViewController(withIdentifier: "homeVC") as? ViewController else {
            print("Error: Could not instantiate view controller with identifier 'SecondViewController'")
            return
        }
        
        // Embed the second view controller in a navigation controller
        let navigationController = UINavigationController(rootViewController: secondVC)
        
        // Set the navigation controller as the root view controller
        if let window = UIApplication.shared.keyWindow {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
}

