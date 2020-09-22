//
//  BruteForceOperation.swift
//  Week3TestWork
//
//  Created by cladendas on 06.09.2020.
//  Copyright © 2020 E-legion. All rights reserved.
//

import Foundation

class BruteForceOperation: Operation {
    
    var result = String()
    
    private let characterArray = Consts.characterArray
    
    private var password = ""
    
    private var startIndexArray = [Int]()
    private var endIndexArray = [Int]()
    private var maxIndexArray = 0
    
    private var startString: String
    private var endString: String
    
    init(password: String, startString: String, endString: String) {
        self.password = password
        self.startString = startString
        self.endString = endString
    }
    
    override func main() {
        result = bruteForce(startString: startString, endString: endString) ?? "Error"
    }
    
    // Возвращает подобранный пароль
    private func bruteForce(startString: String, endString: String) -> String? {
        
        let inputPassword = password
        var startIndexArray = [Int]()
        var endIndexArray = [Int]()
        let maxIndexArray = characterArray.count
        
        // Создает массивы индексов из входных строк
        for char in startString {
            for (index, value) in characterArray.enumerated() where value == "\(char)" {
                startIndexArray.append(index)
            }
        }
        for char in endString {
            for (index, value) in characterArray.enumerated() where value == "\(char)" {
                endIndexArray.append(index)
            }
        }
        
        var currentIndexArray = startIndexArray
        
        // Цикл подбора пароля
        while true {
            
            //Проверка статуса
            if isCancelled {
                return nil
            }
            
            // Формируем строку проверки пароля из элементов массива символов
            let currentPass = self.characterArray[currentIndexArray[0]] + self.characterArray[currentIndexArray[1]] + self.characterArray[currentIndexArray[2]] + self.characterArray[currentIndexArray[3]]
            
            // Выходим из цикла если пароль найден, или, если дошли до конца массива индексов
            if inputPassword == currentPass {
                return currentPass
            } else {
                if currentIndexArray.elementsEqual(endIndexArray) {
                    break
                }
                
                // Если пароль не найден, то происходит увеличение индекса. Для этого в цикле, начиная с последнего элемента осуществляется проверка текущего значения. Если оно меньше максимального значения (61), то индекс просто увеличивается на 1.
                //Например было [0, 0, 0, 5] а станет [0, 0, 0, 6]. Если же мы уже проверили последний индекс, например [0, 0, 0, 61], то нужно сбросить его в 0, а "старший" индекс увеличить на 1. При этом далее в цикле проверяется переполение "старшего" индекса тем же алгоритмом.
                //Таким образом [0, 0, 0, 61] станет [0, 0, 1, 0]. И поиск продолжится дальше:  [0, 0, 1, 1],  [0, 0, 1, 2],  [0, 0, 1, 3] и т.д.
                for index in (0 ..< currentIndexArray.count).reversed() {
                    guard currentIndexArray[index] < maxIndexArray - 1 else {
                        currentIndexArray[index] = 0
                        continue
                    }
                    currentIndexArray[index] += 1
                    break
                }
            }
        }
        return nil
    }
}
