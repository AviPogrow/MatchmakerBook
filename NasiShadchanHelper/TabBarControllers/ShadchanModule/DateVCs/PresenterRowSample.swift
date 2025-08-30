//
//  PresenterRowSample.swift
//  PresenterRowSample
//
//  Created by Alfredo Luco on 13-03-20.
//  Copyright © 2020 Alfredo Luco. All rights reserved.
//

import Foundation
import Eureka

public final class PresenterRowSample: Row<PresenterRowSampleCell>, RowType {

    // the required init for the Row
    public required init(tag: String?) {
        super.init(tag: tag)
        
        // this row needs to implement a cellProvider
        // pass in the presenterRowSampleCell to the cell provider
        // and pass in the nib name and bundle
        cellProvider = CellProvider<PresenterRowSampleCell>(nibName: "PresenterRowSampleCell", bundle: Bundle(for: PresenterRowSampleCell.self))
        
                
        
        // the row needs to provide a value
        // that the cell can take that value
        // and use it to display an image literal for that value
        // so we check result and pass it to the value
        
        displayValueFor = {
            guard let result = $0 else { return "fail" }
            self.value = "teste"//result
            self.updateCell()
            return result
        }
    }
    
    // invoked when row is tapped
    public override func customDidSelect() {
        super.customDidSelect()
        
        // make sure it is not disabled
        guard !isDisabled else { return }

        // init the incoming view controller passing in
        // its data model array
        let vc = SelectableViewController(boyNames: ["AviP","MOsheA","Yan kyB"])
        
        // set the row property on the incoming VC to
        // be the row that started the transition
        vc.row = self
        
        //tell the cell to go to its formViewController's nav controller
        // and use the nav controller to push this new selectableVC
        cell.formViewController()?.navigationController?.pushViewController(vc, animated: true)
        
        // set the callback closure on the invoming vc
        // so that it pops the vc
        vc.onDismissCallback = { _ in
            vc.navigationController?.popViewController(animated: true)
        }
    }
}
