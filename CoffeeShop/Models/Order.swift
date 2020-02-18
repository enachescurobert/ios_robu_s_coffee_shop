//
//  Order.swift
//  CoffeeShop
//
//  Created by Robert Enachescu on 18/02/2020.
//  Copyright © 2020 Enachescu Robert. All rights reserved.
//

import Foundation

struct Order {
  var name:String
  var phone:String
  var address:String
  var numberOfSimpleCoffees:Int
  var numberOfOreoCoffees:Int
  var numberOfKitKatCoffees:Int
  var numberOfToppingCoffees:Int
  
  init(name:String, phone:String, address:String, numberOfSimpleCoffees:Int,
    numberOfOreoCoffees:Int, numberOfKitKatCoffees: Int,
    numberOfToppingCoffees:Int) {
    
    self.name = name
    self.phone = phone
    self.address = address
    self.numberOfSimpleCoffees = numberOfSimpleCoffees
    self.numberOfOreoCoffees = numberOfOreoCoffees
    self.numberOfKitKatCoffees = numberOfKitKatCoffees
    self.numberOfToppingCoffees = numberOfToppingCoffees
  }
  
  func getDictionaryForFirebase() -> [String:String] {
       let firebaseDict = ["name": self.name,
                   "phone": self.phone,
                   "address": self.address,
                   "numberOfSimpleCoffees": String(self.numberOfSimpleCoffees),
                   "numberOfOreoCoffees": String(self.numberOfOreoCoffees),
                   "numberOfKitKatCoffees": String(self.numberOfKitKatCoffees),
                   "numberOfToppingCoffees": String(self.numberOfToppingCoffees)]

    return firebaseDict
  }
  
}
