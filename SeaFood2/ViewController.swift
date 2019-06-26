//
//  ViewController.swift
//  SeaFood2
//
//  Created by Rustam on 6/25/19.
//  Copyright © 2019 Rustam Duspayev. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ChameleonFramework

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()

    @IBOutlet weak var cameraButton: UIBarButtonItem!

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = userPickedImage
            guard let ciImage = CIImage(image: userPickedImage) else {fatalError("Couldn't convert UIImage to CIImage")}

            detect(image: ciImage)
        }

        imagePicker.dismiss(animated: true, completion: nil)
    }

    func detect(image: CIImage) {

        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {fatalError("Loading coreML model failed")}

        let request = VNCoreMLRequest(model: model) { (request, error) in

            guard let resuts = request.results as? [VNClassificationObservation] else {fatalError("Image processing failed")}

//            print(resuts)

            if resuts.first!.identifier.contains("hotdog") {
                self.updateNavBar(withColor: FlatMint(), text: "Hotdog!")
            } else {
                self.updateNavBar(withColor: FlatPinkDark(), text: "Not Hotdog!")
            }

        }

        let handler = VNImageRequestHandler(ciImage: image)

        do {
            try handler.perform([request])
        } catch {
            print("Error processing the request by model \(error)")
        }
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {

        present(imagePicker, animated: true, completion: nil)

    }

    func updateNavBar(withColor color: UIColor, text: String) {

        guard let navBar = navigationController?.navigationBar else {fatalError("No navigation bar found")}

        navigationItem.title = text

        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]

        navBar.barTintColor = color

        navBar.tintColor = ContrastColorOf(color, returnFlat: true)

    }

}

