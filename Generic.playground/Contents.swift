import UIKit

//类型约束实践
func findIndex(ofString valueToFind: String, in array: [String]) -> Int? {
    for (index,value) in array.enumerated() {
        if value == valueToFind {
            return index
        }
    }
    return nil
}

let strings = ["cat","dog","llama","parakeet","terrapin"]
if let foundIndex = findIndex(ofString: "llama", in: strings) {
    print("The index of llama is \(foundIndex)")
}

//T泛型都必须Equatable 协议，否则无法使用== != 这些操作符
func findIndexGeneric<T: Equatable>(of valueToFind: T,in array:[T]) -> Int? {
    for (index,value) in array.enumerated() {
        if value == valueToFind {
            return index
        }
    }
    return nil
}

let doubleIndex = findIndexGeneric(of: 9.3, in: [3.1415926,0.1,0.25])
let stringIndex = findIndexGeneric(of: "Andrea", in: ["Mike","Malcolm","Andrea"])
print(stringIndex!)

//关联类型

protocol Container {
    //协议没有定义item是什么，这个信息留给遵从协议的类型来提供
    associatedtype Item
    mutating func append(_ item: Item)
    var count: Int { get }
    subscript(i: Int) -> Item { get }
}

struct IntStack: Container {
    //原始实现部分
    var items = [Int]()
    mutating func push(_ item: Int) {
        items.append(item)
    }
    mutating func pop() -> Int {
        return items.removeLast()
    }
    //遵从协议部分
    //指定item为int类型，从而将container协议中抽象的item类型转换为具体int类型
    typealias Item = Int
    mutating func append(_ item: Int) {
        self.push(item)
    }
    var count: Int {
        return items.count
    }
    subscript(i: Int) -> Int {
        return items[i]
    }
}

struct Stack<Element>: Container {
    var items = [Element]()
    mutating func push(_ item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
    
    mutating func append(_ item: Element) {
        self.push(item)
    }
    var count: Int {
        return items.count
    }
    subscript(i: Int) -> Element {
        return items[i]
    }
}

//给关联类型添加约束
protocol Containers {
    associatedtype Item: Equatable
    mutating func append(_ item: Item)
    var count: Int { get }
    subscript(i: Int) -> Item { get }
}

//类型约束 泛型where语句
//可以在函数体或者类型的大括号之前添加where子句
func allItemMatch<C1: Container, C2: Container> (_ someContainer: C1,_ anotherContainer: C2) -> Bool
    where C1.Item == C2.Item,C1.Item: Equatable {
        //检查两个容器含有相同数量的元素
        if someContainer.count != anotherContainer.count {
            return false
        }
        //检查每一对元素是否相等
        for i in 0..<someContainer.count {
            if someContainer[i] != anotherContainer[i] {
                return false
            }
        }
        //所有元素都匹配
        return true
}

//使用泛型where子句作为扩展的一部分
extension Stack where Element: Equatable {
    func isTop(_ item: Element) -> Bool {
        guard let topItem = items.last else {
            return false
        }
        return topItem == item
    }
}
