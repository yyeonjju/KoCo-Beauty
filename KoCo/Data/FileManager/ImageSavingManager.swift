//
//  ImageSavingManager.swift
//  KoCo
//
//  Created by 하연주 on 11/12/24.
//

import Foundation
import UIKit

final class ImageSavingManager  {

    static func saveImageToDocument(image: UIImage?, filename: String) {
        
        guard let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else { return }
        
        //이미지를 저장할 경로(파일명) 지정
        let fileURL = documentDirectory.appendingPathComponent("\(filename).jpg")
        print("fileURL - ", fileURL)
        
        //이미지 압축
        guard let image,let data = image.jpegData(compressionQuality: 0.5) else { return }
        
        //이미지 파일 저장
        do {
            try data.write(to: fileURL)
        } catch {
            print("file save error", error)
        }
    }
    
    
    
    static func loadImageFromDocument(filename: String) -> UIImage? {
           
          guard let documentDirectory = FileManager.default.urls(
              for: .documentDirectory,
              in: .userDomainMask).first else { return nil }
           
          let fileURL = documentDirectory.appendingPathComponent("\(filename).jpg")
          
          //이 경로에 실제로 파일이 존재하는 지 확인
          if FileManager.default.fileExists(atPath: fileURL.path()) {
              return UIImage(contentsOfFile: fileURL.path())
          } else {
              return nil
          }
          
      }
    
    
    
    
    
    static func removeImageFromDocument(filename: String) {
        guard let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else { return }

        let fileURL = documentDirectory.appendingPathComponent("\(filename).jpg")
        print(fileURL)
        if FileManager.default.fileExists(atPath: fileURL.path()) {
            
            do {
                try FileManager.default.removeItem(atPath: fileURL.path())
            } catch {
                print("file remove error", error)
            }
            
        } else {
            print("file no exist")
        }
        
    }
}

