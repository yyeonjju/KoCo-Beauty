//
//  ViewModelType.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation
import Combine

protocol ViewModelType : AnyObject, ObservableObject {
    associatedtype Input
    associatedtype Output

    var cancellables : Set<AnyCancellable> {get set}
    
    var input : Input{get set}
    var output : Output{get set}
    
    func transform ()
}
