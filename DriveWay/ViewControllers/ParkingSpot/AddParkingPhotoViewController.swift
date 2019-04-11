//
//  AddParkingPhotoViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import ALCameraViewController
import SVProgressHUD
import SDWebImage

class AddParkingPhotoViewController : UIViewController {
    @IBOutlet weak var svPhotos: UIStackView!
    
    var spot: ParkingSpot!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        svPhotos.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        if spot.photosURLs.count > 0 {
            for url in spot.photosURLs {
                addImage(url: url)
            }
            
        }
    }
    
    static func newInst(spot: ParkingSpot) -> UIViewController {
        let vc = UIStoryboard(name: "ParkingSpot", bundle: nil).instantiateViewController(withIdentifier: "addparkingphotovc") as! AddParkingPhotoViewController
        
        vc.spot = spot
        
        return vc
    }
    
    @IBAction func onUploadPhoto(_ sender: Any) {
        
        if self.svPhotos.imagesCount() == 3 {
            self.alertOk(title: "Image Upload", message: "You can upload up to 3 photos", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        var minimumSize: CGSize = CGSize(width: 60, height: 60)
        
        var croppingParameters: CroppingParameters {
            return CroppingParameters(isEnabled: false, allowResizing: false, allowMoving: false, minimumSize: minimumSize)
        }
        
        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true) { [weak self] image, asset in
            if let image = image {
                self?.addImage(image: image)
            }
            self?.dismiss(animated: true, completion: nil)
//            self?.navigationController?.popViewController(animated: true)
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    func addImage(image: UIImage) {
        let imageView = UIImageView(image: image)
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTapPhoto(sender:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        
        self.svPhotos.addArrangedSubview(imageView)
    }
    
    func addImage(url: String) {
        let imageView = UIImageView()
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        imageView.sd_setImage(with: URL(string: url), completed: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTapPhoto(sender:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        
        self.svPhotos.addArrangedSubview(imageView)
    }
    
    @objc func onTapPhoto(sender: UITapGestureRecognizer) {
        if let view = sender.view, let imageView = view as? UIImageView {
            alert(title: "Remove Photo", message: "Are you sure remove the photo", okButton: "Yes", cancelButton: "No", okHandler: { (_) in
                imageView.removeFromSuperview()
            }, cancelHandler: nil)
        }
    }
    
    @IBAction func onNext(_ sender: Any) {
        var images:[UIImage] = []
        svPhotos.arrangedSubviews.forEach { (view) in
            
            if let imageView = view as? UIImageView, let image = imageView.image {
                images.append(image)
            }
        }
        self.spot.photos = images
        
        let vc = AddParkingPolicyViewController.newInst(spot: self.spot)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
