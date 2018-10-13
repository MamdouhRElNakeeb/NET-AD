//
//  MainVC.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 7/7/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import CLImageEditor

class MainVC: UIViewController {

    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var homeTBI: UITabBarItem!
    @IBOutlet weak var newPostTBI: UITabBarItem!
    @IBOutlet weak var editorTBI: UITabBarItem!
    @IBOutlet weak var assignmentsTBI: UITabBarItem!
    @IBOutlet weak var notificationsTBI: UITabBarItem!
    
    var current = 0
    var type = "Editor"
    
    private lazy var newsFeedTVC: NewsFeedTVC = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "NewsFeedTVC") as! NewsFeedTVC
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var notificationsVC: NotificationsVC = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var tasksVC: TasksVC = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "TasksVC") as! TasksVC
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
        tabBar.delegate = self
        
        add(asChildViewController: newsFeedTVC)
        self.navigationItem.title = "الرئيسية"
        
        
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - tabBar.bounds.height)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
    private func updateView(){

        switch current {
        case 1:
            remove(asChildViewController: tasksVC)
            break
        case 2:
            remove(asChildViewController: notificationsVC)
            break
        default: // 0: newsfeed
            remove(asChildViewController: newsFeedTVC)
            break
        }
    }
    
}

extension MainVC: UITabBarDelegate, CLImageEditorDelegate{
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        switch item {
        case newPostTBI:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostCategoriesVC") as! PostCategoriesVC
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case homeTBI:
            updateView()
            add(asChildViewController: newsFeedTVC)
            current = 0
            self.navigationItem.title = "الرئيسية"
            break
        case editorTBI:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditorVC") as! EditorVC
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case assignmentsTBI:
            updateView()
            add(asChildViewController: tasksVC)
            current = 1
            self.navigationItem.title = "التكليفات"
            break
        case notificationsTBI:
            updateView()
            add(asChildViewController: notificationsVC)
            current = 2
            self.navigationItem.title = "الإشعارات"
            break
        default:
            break
        }
    }
}
