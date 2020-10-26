//
//  CameraViewController.swift
//  Instagram
//
//  Created by Mina Kim on 10/18/20.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.becomeFirstResponder()

        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = UIColor.black.cgColor
        commentTextView.layer.cornerRadius = 15
        
        submitButton.layer.cornerRadius = 10
    }
    
    @IBAction func didTapSubmit(_ sender: Any) {
        let post = PFObject(className: "Posts")
        
        post["caption"] = commentTextView.text
        post["user"] = PFUser.current()
        
        //Saves image in database
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(data: imageData!)
        post["image"] = file
        
        post.saveInBackground { (success, error) in
            if success{
                //Not dismissing?
                self.dismiss(animated: true, completion: nil)
                print("Saved post")
            } else {
                print("Could not save post: \(error)")
            }
        }
    }
    
    @IBAction func didTapImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func didTapView(_ sender: Any) {
        commentTextView.resignFirstResponder()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        //Adjusts size of image
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageAspectScaled(toFill: size)
        
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
