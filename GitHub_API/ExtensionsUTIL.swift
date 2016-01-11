//
//  ExtensionsUTIL.swift
//  GitHub_API
//
//  Created by Túlio Bazan da Silva on 11/01/16.
//  Copyright © 2016 TulioBZ. All rights reserved.
//

import Foundation

extension Array {
    
    /** This appends all the objects from an array into another one.
     Usage: arrayA.appendAll(arrayB)
     */
    mutating func appendAll(array: Array<Element>) {
        for element in array {
            self.append(element)
        }
    }
}