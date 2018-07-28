//
//  Meme.swift
//  MemeMe
//
//  Created by Sukumar Anup Sukumaran on 26/07/18.
//  Copyright © 2018 TechTonic. All rights reserved.
//

import UIKit


struct Meme {
    
    let topText: String?
    let bottomText: String?
    let originalImage: UIImage?
    let memedImage: UIImage?
    
    init?(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
        
    }
    
}
