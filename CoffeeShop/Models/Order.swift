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
  var address:String
  var numberOfSimpleCoffees:Int
  var numberOfOreoCoffees:Int
  var numberOfKitKatCoffees:Int
  var numberOfToppingCoffees:Int
  
  init(name:String, address:String, numberOfSimpleCoffees:Int,
    numberOfOreoCoffees:Int, numberOfKitKatCoffees: Int,
    numberOfToppingCoffees:Int) {
    
    self.name = name
    self.address = address
    self.numberOfSimpleCoffees = numberOfSimpleCoffees
    self.numberOfOreoCoffees = numberOfOreoCoffees
    self.numberOfKitKatCoffees = numberOfKitKatCoffees
    self.numberOfToppingCoffees = numberOfToppingCoffees
  }
  
}
