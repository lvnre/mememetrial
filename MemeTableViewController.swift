//
//  VillainTableViewController.swift
//  MemeMeTrial
//
//  Created by Lanre Akomolafe on 8/3/16.
//  Copyright © 2016 Lanre. All rights reserved.
//

import Foundation
import UIKit

class MemeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var memes = [Meme]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        let object = UIApplication.sharedApplication().delegate as! AppDelegate
        memes = object.memes
        print("view appeared. there are \(memes.count) meme(s)")
        if memes.count > 0 {
            print(memes[0].bottomText)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell")!
        let meme = memes[indexPath.row]
        
        cell.textLabel?.text = "\(meme.topText) - \(meme.bottomText)"
        cell.imageView?.image = meme.memedImage
        
        return cell
    }

}