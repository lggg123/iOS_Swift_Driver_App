//
//  Extensions.swift
//  Driveway
//
//  Created by imac on 4/28/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Foundation
import UIKit
import Photos
import Cosmos
import SVProgressHUD

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UIImage {
    func crop(toRect rect:CGRect) -> UIImage{
        let imageRef:CGImage = self.cgImage!.cropping(to: rect)!
        let cropped:UIImage = UIImage(cgImage:imageRef)
        return cropped
    }

    func resized(toWidth width: CGFloat) -> UIImage{
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    func resized(toWidth width: CGFloat, toHeight height: CGFloat) -> UIImage{
        let canvasSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}


extension UIColor {

    convenience init(hex: String) {
        self.init(hex: hex, alpha:1)
    }

    convenience init(hex: String, alpha: CGFloat) {
        var hexWithoutSymbol = hex
        if hexWithoutSymbol.hasPrefix("#") {
            hexWithoutSymbol = String(hex.dropFirst())
        }

        let scanner = Scanner(string: hexWithoutSymbol)
        var hexInt:UInt32 = 0x0
        scanner.scanHexInt32(&hexInt)

        var r:UInt32!, g:UInt32!, b:UInt32!
        switch (hexWithoutSymbol.count) {
        case 3: // #RGB
            r = ((hexInt >> 4) & 0xf0 | (hexInt >> 8) & 0x0f)
            g = ((hexInt >> 0) & 0xf0 | (hexInt >> 4) & 0x0f)
            b = ((hexInt << 4) & 0xf0 | hexInt & 0x0f)
            break;
        case 6: // #RRGGBB
            r = (hexInt >> 16) & 0xff
            g = (hexInt >> 8) & 0xff
            b = hexInt & 0xff
            break;
        default:
            // TODO:ERROR
            break;
        }

        self.init(
            red: (CGFloat(r)/255),
            green: (CGFloat(g)/255),
            blue: (CGFloat(b)/255),
            alpha:alpha)
    }
}

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }

    var length: Int {
        return self.count
    }

    var containsSpecialCharacter: Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ")
        if self.rangeOfCharacter(from: characterset.inverted) != nil {
            return true
        } else {
            return false
        }
    }

    var containsLetter: Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        if self.rangeOfCharacter(from: characterset) != nil {
            return true
        } else {
            return false
        }
    }

    var containsUppercase: Bool {
        let characterset = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        if self.rangeOfCharacter(from: characterset) != nil {
            return true
        } else {
            return false
        }
    }

    var containsLowercase: Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
        if self.rangeOfCharacter(from: characterset) != nil {
            return true
        } else {
            return false
        }
    }

    var containsNumber: Bool {
        let characterset = CharacterSet(charactersIn: "0123456789")
        if self.rangeOfCharacter(from: characterset) != nil {
            return true
        } else {
            return false
        }
    }

    var hasLettersAndSpacesOnly: Bool {
        let nameRegex = "[A-Za-z\\s]*"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return nameTest.evaluate(with: self)
    }

    var hasNumbersOnly: Bool {
        let nameRegex = "[0-9\\.]*"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return nameTest.evaluate(with: self)
    }

    var validPrice: Bool {
        let floatRegEx = "^([0-9]+)?(\\.([0-9])?([0-9])?)?$"

        let floatExPredicate = NSPredicate(format:"SELF MATCHES %@", floatRegEx)

        return floatExPredicate.evaluate(with: self)
    }
}

extension UIStackView {
    func imagesCount() -> Int{
        var count = 0

        for view in self.subviews {
            if let imageView = view as? UIImageView, let _ = imageView.image {
                count += 1
            }
        }
        return count
    }
}

extension UIView {
    class func fromNib<T : UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

extension Double {
    func toTime()->String {
        let time = self as TimeInterval
        let date = Date.init(timeIntervalSince1970: time/1000)

        return date.toReadableString()
    }

    func toDate()->Date {
        let time = self as TimeInterval
        let date = Date.init(timeIntervalSince1970: time/1000)

        return date
    }
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1)  == 0 ? String(self) : String(format: "%.2f", self)
    }

}

extension Date {
    func toReadableString() -> String {
        return toString(format: "MMMM dd, yyyy HH:mm:ss")
    }

    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    func toKey() -> String {
        return toString(format: "yyyy/MM/dd")
    }
}


public extension Date {

    //MARK: - Time Ago

    /**
     *  Takes in a date and returns a shortened string with the most convenient unit of time representing
     *  how far in the past that date is from now.
     *
     *  - parameter date: Date to be measured from now
     *
     *  - returns String - Formatted return string
     */
    public static func shortTimeAgo(since date:Date) -> String {
        return date.shortTimeAgo(since:Date())
    }

    public static func longTimeAgo(since date:Date) -> String {
        return date.longTimeAgo(since:Date())
    }

    /**
     *  Returns a shortened string with the most convenient unit of time representing
     *  how far in the past that date is from now.
     *
     *  - returns String - Formatted return string
     */
    public var shortTimeAgoSinceNow: String {
        return self.shortTimeAgo(since:Date())
    }
    public var longTimeAgoSinceNow: String {
        return self.longTimeAgo(since:Date())
    }



    public func shortTimeAgo(since date:Date) -> String {
        let calendar = NSCalendar.current
        let unitFlags = Set<Calendar.Component>([.second,.minute,.hour,.day,.weekOfYear,.month,.year])
        let earliest = self.earlierDate(date)
        let latest = (earliest == self) ? date : self //Should pbe triple equals, but not extended to Date at this time


        let components = calendar.dateComponents(unitFlags, from: earliest, to: latest)

        let diffInSec = -self.timeIntervalSinceNow;
        let diffInHours = diffInSec / 3600;
        let diffInDays = Double(diffInHours) / 24;


        if (components.year! >= 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@y", value: components.year!)
        }
        else if (components.month! >= 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@M", value: components.month!)
        }
        else if (components.weekOfYear! >= 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@w", value: components.weekOfYear!)
        }
        else if (diffInDays >= 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@d", value: components.day!)
        }
        else if (components.hour! >= 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@h", value: components.hour!)
        }
        else if (components.minute! >= 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@m", value: components.minute!)
        }
        else if (components.second! >= 3) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@s", value: components.second!)
        }
        else {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@s", value: components.second!)
            //return DateToolsLocalizedStrings(@"Now"); //string not yet translated 2014.04.05
        }
    }

    public func longTimeAgo(since date:Date) -> String {
        let calendar = NSCalendar.current
        let unitFlags = Set<Calendar.Component>([.second,.minute,.hour,.day,.weekOfYear,.month,.year])
        let earliest = self.earlierDate(date)
        let latest = (earliest == self) ? date : self //Should pbe triple equals, but not extended to Date at this time


        let components = calendar.dateComponents(unitFlags, from: earliest, to: latest)

        let diffInSec = -self.timeIntervalSinceNow;
        let diffInHours = diffInSec / 3600;
        let diffInDays = Double(diffInHours) / 24;


        if (components.year! > 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@ years ago", value: components.year!)
        } else if (components.year! == 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@ year ago", value: components.year!)
        }
        else if (components.month! > 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@ months ago", value: components.month!)
        }
        else if (components.month! == 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@ month ago", value: components.month!)
        }
        else if (components.weekOfYear! > 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@ weeks ago", value: components.weekOfYear!)
        }
        else if (components.weekOfYear! == 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@ week ago", value: components.weekOfYear!)
        }
        else if (diffInDays > 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@ days ago", value: components.day!)
        }
        else if (diffInDays == 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@ day ago", value: components.day!)
        }
        else if (components.hour! > 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@ hours ago", value: components.hour!)
        }
        else if (components.hour! == 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@ hour ago", value: components.hour!)
        }
        else if (components.minute! > 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@ minutes ago", value: components.minute!)
        }
        else if (components.minute! == 1) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@ minute ago", value: components.minute!)
        }
        else if (components.second! >= 3) {
            return self.logicalLocalizedStringFromFormat(format: "%%d%@ seconds ago", value: components.second!)
        }
        else {
            return "Now"
            //            return self.logicalLocalizedStringFromFormat(format: "%%d%@s", value: components.second!)
            //            return DateToolsLocalizedStrings(@"Now"); //string not yet translated 2014.04.05
        }
    }


    private func logicalLocalizedStringFromFormat(format: String, value: Int) -> String{
        #if os(Linux)
            let localeFormat = String.init(format: format, getLocaleFormatUnderscoresWithValue(Double(value)) as! CVarArg)  // this may not work, unclear!!
        #else
            let localeFormat = String.init(format: format, getLocaleFormatUnderscoresWithValue(Double(value)))
        #endif

        return String.init(format: localeFormat, value)
    }


    private func getLocaleFormatUnderscoresWithValue(_ value: Double) -> String{
        let localCode = Bundle.main.preferredLocalizations[0]
        if (localCode == "ru" || localCode == "uk") {
            let XY = Int(floor(value).truncatingRemainder(dividingBy: 100))
            let Y = Int(floor(value).truncatingRemainder(dividingBy: 10))

            if(Y == 0 || Y > 4 || (XY > 10 && XY < 15)) {
                return ""
            }

            if(Y > 1 && Y < 5 && (XY < 10 || XY > 20))  {
                return "_"
            }

            if(Y == 1 && XY != 11) {
                return "__"
            }
        }

        return ""
    }


    // MARK: - Date Earlier/Later

    /**
     *  Return the earlier of two dates, between self and a given date.
     *
     *  - parameter date: The date to compare to self
     *
     *  - returns: The date that is earlier
     */
    public func earlierDate(_ date:Date) -> Date{
        return (self.timeIntervalSince1970 <= date.timeIntervalSince1970) ? self : date
    }

    /**
     *  Return the later of two dates, between self and a given date.
     *
     *  - parameter date: The date to compare to self
     *
     *  - returns: The date that is later
     */
    public func laterDate(_ date:Date) -> Date{
        return (self.timeIntervalSince1970 >= date.timeIntervalSince1970) ? self : date
    }

}

extension UIViewController {
    func setImageTitle() {
        let imageView = UIImageView(image:#imageLiteral(resourceName: "ic_nav_title"))
        self.navigationItem.titleView = imageView
    }
    
    func alertOk(title: String, message: String, cancelButton: String, cancelHandler: ((UIAlertAction) -> ())?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: cancelButton, style: .default, handler: cancelHandler)

        let attributedString = NSAttributedString(string: title, attributes: [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15), //your font here
            NSAttributedStringKey.foregroundColor : primaryColor
            ])

        alertController.addAction(cancelAction)

        alertController.setValue(attributedString, forKey: "attributedTitle")
        alertController.view.tintColor = UIColor.darkGray

        present(alertController, animated: true, completion: nil)
    }
    func alert(title: String, message: String, okButton: String, cancelButton: String, okHandler: ((UIAlertAction) -> ())?, cancelHandler: ((UIAlertAction) -> ())?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: okButton, style: .default, handler: okHandler)
        let cancelAction = UIAlertAction(title: cancelButton, style: .cancel, handler: cancelHandler)

        let attributedString = NSAttributedString(string: title, attributes: [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15), //your font here
            NSAttributedStringKey.foregroundColor : primaryColor
            ])

        alertController.view.tintColor = UIColor.darkGray
        alertController.setValue(attributedString, forKey: "attributedTitle")

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    static func takePhoto<T: UIViewController>(viewController: T) where T: UINavigationControllerDelegate, T: UIImagePickerControllerDelegate {
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)

        switch cameraAuthorizationStatus {
        case .denied: fallthrough
        case .restricted:
            viewController.alert(title: "Camera", message: "You are restricted using the camera. Go to settings to enable it.", okButton: "Go to Settings", cancelButton: "Cancel", okHandler: { (_) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }, cancelHandler: nil)
            break
        case .authorized:
            doTakePhoto(viewController: viewController)
            break


        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted {
                    doTakePhoto(viewController: viewController)
                } else {

                }
            }
        }



    }

    static func doTakePhoto<T: UIViewController>(viewController: T) where T: UINavigationControllerDelegate, T: UIImagePickerControllerDelegate {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            viewController.alert(title: "Camera", message: "You are restricted using the camera. Go to settings to enable it.", okButton: "Go to Settings", cancelButton: "Cancel", okHandler: { (_) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }, cancelHandler: nil)
            return
        }

        let picker = UIImagePickerController()
        picker.delegate = viewController
        picker.allowsEditing = true
        picker.sourceType = .camera

        viewController.present(picker, animated: true, completion: nil)
    }

    static func loadFromGallery<T: UIViewController>(viewController: T) where T: UINavigationControllerDelegate, T: UIImagePickerControllerDelegate{
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            //handle authorized status
            doLoadFromGallery(viewController: viewController)
            break

        case .denied, .restricted :
            //handle denied status

            viewController.alert(title: "Camera", message: "You are restricted using photo gallery. Go to settings to enable it.", okButton: "Go to Settings", cancelButton: "Cancel", okHandler: { (_) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }, cancelHandler: nil)

            return
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    doLoadFromGallery(viewController: viewController)
                    // as above
                    break
                case .denied, .restricted:
                    // as above
                    break
                case .notDetermined:
                    // won't happen but still
                    break
                }
            }
        }
    }

    static func doLoadFromGallery<T: UIViewController>(viewController: T) where T: UINavigationControllerDelegate, T: UIImagePickerControllerDelegate {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            viewController.alert(title: "Camera", message: "You are restricted using photo gallery. Go to settings to enable it.", okButton: "Go to Settings", cancelButton: "Cancel", okHandler: { (_) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }, cancelHandler: nil)

            return
        }

        let picker = UIImagePickerController()
        picker.delegate = viewController
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary

        viewController.present(picker, animated: true, completion: nil)
    }

}

protocol AvatarTouchDelegate {
    func onTapAvatar(for userID: String)
}

extension UIViewController : AvatarTouchDelegate {
    func onTapAvatar(for userID: String) {
        User.loadUser(userID: userID) { (user) in
            if let user = user {
                DispatchQueue.main.async {
                    self.gotoProfileView(for: user)
                }
            }
        }

    }

    func gotoProfileView(userID: String) {
        User.loadUser(userID: userID) { (user) in
            if let user = user {
                DispatchQueue.main.async {
                    self.gotoProfileView(for: user)
                }
            }
        }
    }

    func gotoProfileView(for user: User) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if user.type == .customer {
            let vc = storyboard.instantiateViewController(withIdentifier: "profilevc") as! ProfileViewController
            vc.theUser = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func gotoChatRoom(userID: String) {
        MsgChannel.loadChannel(userID: curid()!, channelID: userID) { (channel) in
            SVProgressHUD.dismiss()
            if let channel = channel {
                DispatchQueue.main.async {
                    let vc = ChatViewController.newInst(channel: channel)

                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                MsgChannel.createChannels(senderID: curid()!, receiverID: userID, completion: { (error) in
                    if let error = error {
                        self.alertOk(title: "", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                        return
                    } else {
                        MsgChannel.loadChannel(userID: curid()!, channelID: userID) { (channel) in
                            if let channel = channel {
                                DispatchQueue.main.async {
                                    let vc = ChatViewController.newInst(channel: channel)

                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    }
                })
            }
        }
    }
}

extension UIImageView {
    func loadImageFor(userID: String) {
        self.image = nil

        if let url = userImages[userID] {
            self.sd_setImage(with: URL(string: url)!, completed: nil)
        } else {
            User.loadUser(userID: userID) { (user) in
                if let user = user, let url = user.photoURL {
                    userImages[userID] = url
                    userNames[userID] = user.displayName
                    userRatings[userID] = user.rating

                    //DispatchQueue.main.async {
                    self.sd_setImage(with: URL(string: url)!, completed: nil)
                    //}
                }
            }
        }
    }
}

extension UILabel {
    func setNameFor(userID: String, prefix: String) {
        self.text = ""
        if let name = userNames[userID] {
            self.text = prefix + name
        } else {
            User.loadUser(userID: userID) { (user) in
                DispatchQueue.main.async {
                    if let user = user {
                        if let url = user.photoURL {
                            userImages[userID] = url
                        }
                        userNames[userID] = user.displayName
                        userRatings[userID] = user.rating

                        self.text = prefix +  user.displayName
                    }
                }

            }
        }
    }
}

extension CosmosView {
    func setRatingFor(userID: String) {
        self.rating = 5
        if let rating = userRatings[userID] {
            self.rating = rating
        } else {
            User.loadUser(userID: userID) { (user) in
                if let user = user {
                    if let url = user.photoURL {
                        userImages[userID] = url
                    }
                    userNames[userID] = user.displayName
                    userRatings[userID] = user.rating

                    self.rating = user.rating
                }
            }
        }
    }
}


