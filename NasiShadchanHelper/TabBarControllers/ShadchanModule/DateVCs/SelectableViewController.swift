//
//  SelectableViewController.swift
//  PresenterRowSample
//
//  Created by Alfredo Luco on 13-03-20.
//  Copyright © 2020 Alfredo Luco. All rights reserved.
//

import UIKit
import Eureka

public class SelectableViewController: UIViewController, TypedRowControllerType {

    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Variables
    open var names: [String] = []
    public var row: RowOf<String>!
    public var onDismissCallback: ((UIViewController) -> Void)?
    
    //MARK: - Init
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    open override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
    }
    
    public convenience init(boyNames: [String]){
        // grab the string name of the view controller in the main bundle
        let name = String(describing: SelectableViewController.self)
        
        // get the bundle
        let bundle = Bundle(for: SelectableViewController.self)
        print(name)
        print(bundle)
        
        // call the base init method
        // passing the bundle and file name
        self.init(nibName: name, bundle: bundle)
        
        // set the images string identifiers property
        self.names = boyNames
        self.loadViewIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // register the cell nib with the table view
        // by passing in the nibName and the bundle
        // and the reuse identifier
        self.tableView.register(UINib(nibName: "ImagePresentedCell", bundle: Bundle(for: ImagePresentedCell.self)), forCellReuseIdentifier: "presentedIdentifier")
        
        // set the tableView's data source and delegate to self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
}

extension SelectableViewController: UITableViewDelegate, UITableViewDataSource{
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.names.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // take the nib that was registered and deque it
        // and set the imageView image property from the images array
        if let cell = tableView.dequeueReusableCell(withIdentifier: "presentedIdentifier", for: indexPath) as? ImagePresentedCell {
            
            //cell.iconImageView.image = UIImage(named: self.names[indexPath.row])
            //cell.imageCellLabel.text = self.names[indexPath.row]
            //cell.stackedLabel.text = self.names[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // get the image from the selected indexPath
        let name = self.names[indexPath.row]
        
        // use the selectedImage to assign it and set the value
        // of the row's value property
        self.row.value = name
        
        // now that we have a value for the row.. use the
        // row's value to update the cell
        self.row.updateCell()
        
        //
        guard let callback = self.onDismissCallback else{ return }
        callback(self)
    }
    
}
