//
//  LibraryViewController.swift
//  NurInfoApp
//
//  Created by Mohamed Elmoghazi on 8/4/17.
//  Copyright © 2017 Nursing Informatics Department. All rights reserved.
//

import UIKit
import WebKit

class LibraryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let PDFList = ["Mission", "2", "3"]
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PDFList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! PDFCollectionViewCell
        
        cell.PDFLabel.text! = PDFList[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let pdfURL = Bundle.main.url(forResource: PDFList[indexPath.row], withExtension: "pdf") {
            let webView = UIWebView(frame: view.frame)
            let urlRequest = NSURLRequest(url: pdfURL)
            webView.loadRequest(urlRequest as URLRequest)

            let PDFViewController = UIViewController()
            
            PDFViewController.view.addSubview(webView)
            PDFViewController.title = PDFList[indexPath.row]
            self.navigationController?.pushViewController(PDFViewController, animated: true)
        }
    }

}
