//
//  LibraryViewController.swift
//  NurInfoApp
//
//  Created by Mohamed Elmoghazi on 8/4/17.
//  Copyright © 2017 Nursing Informatics Department. All rights reserved.
//

import UIKit
import WebKit
import Parse
import PDFReader

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,ExpandableHeaderViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var sections = [
        
        Section(title: "Approved Documents",
                documents: ["Moving Forward Plan", "NI Annual Project Plan", "NI Committees of the Facilities Award 2017", "NI Goals", "NI KPI", "NI Mission Vision", "NI Model", "NI Skills Fair v4 - proposal", "NI Strategic Plan 2015-2020", "NI Values", "SOP - Handling of HICT Requests", "SOP - Leave Endorsement"],
                expanded: false),
        
        Section(title: "Clairvia",
                documents: ["Cerner Clairvia Training Manual Troubleshooting", "Cerner Clairvia Training Manual v3"],
                expanded: false),
        
        Section(title: "Downtime",
                documents: ["724 DTV  v3", "Contingency Plan for CIS Downtime", "NI Roles and Responsibilities During CIS Downtime"],
                expanded: false),
        
        Section(title: "NI Bulletin",
                documents: ["1 NIB Apr 2015", "2 NIB Sep 2015","3 NIB Jan 2016", "4 NIB May 2016", "5 NIB Oct 2016", "6 NIB Mar 2017", "7 NIB Jun 2017", "8 NIB Sept 2017"],
                expanded: false),
        
        Section(title: "Brouchers",
                documents: ["An Introduction to Cerner Millennium", "Eye Care Tips for Computer Freaks", "How to Manage Your Computer Problems", "Nursing Informatics (new)", "Save Time with Quick Computer Shortcuts", "Tips on Healthy Computer Use", "Useful Websites for Nurses", "What is CIS"],
                expanded: false),
        
        Section(title: "NI Policies",
                documents: ["OP 4005 NI Skill Lab", "OP 4037 CIS Training for New Nurses"],
                expanded: false),
        
        Section(title: "NI Presentations",
                documents: ["Big Data - Jose Barbudo", "Change Management - Mr. Ali Abdelgadir", "Communication Technology in Nursing - Rawda", "Computer and Internet Security - Eyad", "Computerized Physician Order Entry (CPOE) - Khadafy", "Decision Making - Mr. Ali Abdelgadir", "Delivering Effective Presentation - Noha", "Effective Research on the Internet - Sherman", "Research on Human Subjects - Rocky", "Role of IT in Patient Safety - Fethi", "Team Building - Rafael" ],
                expanded: false),
        
        Section(title: "NI Posters",
                documents: ["Clinical Information System Elibrary Transforming Education through Technology", "Impact of Elearning on Nurses Professional Knowledge and Practice in HMC","Improving PFE Compliance in Outpatient Units og Al Wakra Hospital", "Innovating the Training Experience Nursing Informatics Department and the Clinical Information Journey", "NI Approach Towards EHR Training for Safe Patient Documentation", "NI Collaboration - Improving Medication Safety in Heart Hospital Thru Infusion Management Solution", "NI Journey Towards Improvement in Patient Safety Thru Infusion Management Technology", "Oncology Nurses Experience with Cerner Clairvia", "Oncology Nurses’ Experience with Cerner Clairvia™ A Case Study from Qatar", "Re-invigorating Nurses¹ Knowledge and Skills with the Cerner Oncology Solution"],
                expanded: false)
    ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70

    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].documents.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if sections[indexPath.section].expanded {
            
            return UITableViewAutomaticDimension
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderView()
        header.customInit(title: sections[section].title, section: section, delegate: self as ExpandableHeaderViewDelegate)
        return header
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell") as! LibraryTableViewCell
        
        cell.docTitle.text = sections[indexPath.section].documents[indexPath.row]
        
        return cell
    }
    
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        sections[section].expanded = !sections[section].expanded
        
        tableView.beginUpdates()
        for i in 0 ..< sections[section].documents.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
            
            if sections[section].expanded {
                header.arrowLabel.text = "-"
            } else {
                header.arrowLabel.text = "+"
            }
        }
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let documentFileURL = Bundle.main.url(forResource: sections[indexPath.section].documents[indexPath.row], withExtension: "pdf")!
        let document = PDFDocument(url: documentFileURL)!
        
        let readerController = PDFViewController.createNew(with: document, actionStyle: .activitySheet)
        
        navigationController?.pushViewController(readerController, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



