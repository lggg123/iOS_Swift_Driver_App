//
//  HostBookingsViewController.swift
//  Driveway
//
//  Created by imac on 4/29/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Foundation
import UIKit
import JTAppleCalendar
import ActionSheetPicker_3_0

let colors: [UIColor] = [UIColor.blue, .green, .brown, .yellow, .magenta, .orange, .purple, .cyan]
class HostBookingsViewController : UIViewController {
    @IBOutlet var calendar : JTAppleCalendarView!
    @IBOutlet var lblMonth: UILabel!
    @IBOutlet var tfFilter: UITextField!
    
    let formatter = DateFormatter()
    
    var spots: [ParkingSpot] = [] {
        didSet {
            spotNames = spots.map({ (spot) -> String in
                return spot.title
            })
            spotNames.insert("All Listings", at: 0)
        }
    }
    var filteredSpots: [ParkingSpot] = []
    
    var spotNames: [String] = []
    var filterIndex: Int = 0 {
        didSet {
            tfFilter.text = spotNames[filterIndex]
            
            if filterIndex == 0 {
                filteredContracts = contracts
                filteredSpots = spots
            } else {
                let spotID = self.spots[filterIndex-1].key
                
                filteredContracts = contracts.filter({$0.spotID == spotID})
                filteredSpots = spots.filter({$0.key == spotID})
            }
        }
    }
    
    var contracts: [BookContract] = []
    var filteredContracts: [BookContract] = [] {
        didSet {
            calendar.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setImageTitle()
        
        self.calendar.scrollToDate(Date(), triggerScrollToDateDelegate: true,
                                   animateScroll: false)
        
        self.calendar.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
        
        calendar.minimumInteritemSpacing = 0
        calendar.minimumLineSpacing = 0
        
        tfFilter.delegate = self
        tfFilter.text = "All Listings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadSpots()
        loadContracts()
    }
    
    func loadSpots() {
        guard let userID = thisUser?.userID else { return }
        
        ParkingSpot.loadSpots(for: userID) { (spots) in
            self.spots = spots
        }
    }
    
    func loadContracts() {
        guard let userID = thisUser?.userID else { return }
        
        BookContract.loadContractsFor(hostID: userID) { (contracts) in
            var i: Int = 0
            for contract in contracts {
                if i >= colors.count {
                    contract.color = UIColor(red: CGFloat((arc4random()%256)/255), green: CGFloat((arc4random()%256)/255), blue: CGFloat((arc4random()%256)/255), alpha: 1)
                } else {
                    contract.color = colors[i]
                }
                i += 1
            }
            self.contracts = contracts
            
            self.filterIndex = 0
        }
    }
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? CalendarCell  else { return }
        handleCellTextColor(view: cell, cellState: cellState)
        handleCellSelection(view: cell, cellState: cellState)
        handleCellEvents(view: cell, cellState: cellState)
    }
    
    func handleCellSelection(view: CalendarCell, cellState: CellState) {
        if cellState.isSelected {
            view.viDateBack.backgroundColor = primaryColor
            view.lblDate.textColor = UIColor.white
        } else {
            view.viDateBack.backgroundColor = UIColor.clear
            view.lblDate.textColor = UIColor.black
        }
    }
    
    func handleCellTextColor(view: CalendarCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            view.backgroundColor = UIColor.white
        } else {
            view.backgroundColor = UIColor.groupTableViewBackground
        }
    }
    
    func handleCellEvents(view: CalendarCell, cellState: CellState) {
        view.svEvents.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        
        
        var contractsForDay:[BookContract] = []
        for contract in filteredContracts {
            if (contract.dateFrom...contract.dateTo).contains(cellState.date) {
                contractsForDay.append(contract)
            }
        }
        
        for contract in contractsForDay {
            let label = UILabel()
            if contract.bookType == .daily {
                label.text = "24 hours"
            } else {
                label.text = "\(times[contract.hourFrom!])-\(times[contract.hourTo!])"
            }
            label.textColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 8)
            label.backgroundColor = contract.color
            
            view.svEvents.addArrangedSubview(label)
        }
        
        if contractsForDay.isEmpty {
            for spot in filteredSpots {
                if spot.isBlocked(date: cellState.date) {
                    let label = UILabel()
                    label.text = "Blocked"
                    
                    label.textColor = UIColor.white
                    label.font = UIFont.systemFont(ofSize: 8)
                    label.backgroundColor = UIColor.lightGray
                    
                    view.svEvents.addArrangedSubview(label)
                }
            }
        }
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = Calendar.current.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        // 0 indexed array
        let year = Calendar.current.component(.year, from: startDate)
        lblMonth.text = monthName + " " + String(year)
    }
    
    var iii: Date?
}

extension HostBookingsViewController : JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "calendarcc", for: indexPath) as! CalendarCell

        cell.lblDate.text = cellState.text
        
        configureCell(view: cell, cellState: cellState)
        
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        
        let startDate = formatter.date(from: "2017/01/01")!
        let endDate = formatter.date(from: "2030/02/01")!
        
        let parameters = ConfigurationParameters(startDate: startDate,endDate: endDate)
        print("configured \(startDate)-\(endDate)")
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
        
        var contractsForDay:[BookContract] = []
        for contract in filteredContracts {
            if (contract.dateFrom...contract.dateTo).contains(cellState.date) {
                contractsForDay.append(contract)
            }
        }
        
        if contractsForDay.isEmpty {
            self.alert(title: "Block", message: "Do you want to block this date?", okButton: "Yes", cancelButton: "No", okHandler: { (_) in
                //ok
                if self.filterIndex == 0 {
                    for spot in self.spots {
                        spot.block(date: cellState.date, completion: { (error) in
                            
                        })
                    }
                } else {
                    let spot = self.spots[self.filterIndex - 1]
                    spot.block(date: cellState.date, completion: { (error) in
                        
                    })
                }
                
                self.calendar.reloadData()
            }, cancelHandler: nil)
        } else {
            if contractsForDay.count == 1 {
                let vc = ContractDetailViewController.newInst(contract: contractsForDay[0])
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let alert = UIAlertController(title: nil, message: "Select booking", preferredStyle: .actionSheet)
                for contract in contractsForDay {
                    alert.addAction(UIAlertAction(title: contract.spotName, style: .default, handler: { (_) in
                        let vc = ContractDetailViewController.newInst(contract: contract)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }))
                }
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.present(self, animated: true, completion: nil)
            }
        }
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        calendar.viewWillTransition(to: size, with: coordinator, anchorDate: iii)
    }
}

extension HostBookingsViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == tfFilter {
            ActionSheetStringPicker.show(withTitle: "Select Parking Spot:", rows: spotNames, initialSelection: filterIndex, doneBlock: { (picker, index, origin) in
                self.filterIndex = index
            }, cancel: { (picker) in
                
            }, origin: self.view)
            return false
        }
        
        return true
    }
}
