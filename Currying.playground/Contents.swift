import UIKit

//柯里化
//只能加1的函数
func addOne(num:Int) -> Int {
    return num + 1
}
//通用的函数，实现+2 +3 ....
func addTo(_ adder:Int) -> (Int) -> Int {
    return {
        num in
        return num + adder
    }
}

let addTwo = addTo(2)
let result = addTwo(6)

func greaterThan(_ comparer: Int) -> (Int) -> Bool {
    return { $0 > comparer }
}

let greaterThan10 = greaterThan(10)
greaterThan10(12)
greaterThan10(9)

//柯里化是量产相似方法的好办法，可以通过柯里化一个方法模板来避免写出很多重复的代码

//为自己的类型添加可以使用 for in的功能
//实现如下：先定义一个IteratorProtocol -> 定义sequence
//step one 自定义一个遵循迭代协议的迭代器
class ReverIterator<T>:IteratorProtocol {
    
    typealias Element = T
    
    var array: [Element]
    var currentIndex = 0
    
    init(array:[Element]) {
        self.array = array
        currentIndex = array.count - 1
    }
    
    func next() -> Element? {
        if currentIndex < 0 {
            return nil
        } else {
            let element = array[currentIndex]
            currentIndex -= 1
            return element
        }
    }
}

//step two 自定义一个序列结构体，并返回自定义的迭代器
struct ReverseSequence<T>:Sequence {
    var array: [T]
    
    init(array:[T]) {
        self.array = array
    }
    
    typealias Iterator = ReverIterator<T>
    
    func makeIterator() -> Iterator {
        return ReverIterator(array: self.array)
    }
}

let arr = [0,1,2,3,4,5]
for i in ReverseSequence(array: arr) {
    print("Index \(i) is \(arr[i])")
}

//多元数组
func swapMe<T>(a:inout T,b:inout T) {
    (a,b) = (b,a)
}

var aa = 1
var bb = 2
swapMe(a: &aa, b: &bb)
print("\(aa) \(bb)")

//@autoclosure and  ？？
func logIfTrue(_ predicate:()-> Bool) {
    if predicate() {
        print("True")
    }
}

logIfTrue { () -> Bool in
    return 2 > 1
}

logIfTrue({ return 2 > 1 })

//省略 return
logIfTrue({2 > 1})

//因为闭包是最后一个参数，所以可以直接使用尾随闭包方式把大括号拿出来，省略括号
logIfTrue{ 2 > 1 }

//@autoclosure 自动的把一句表达式封装为一个闭包
func logIfFalse(_ predicate:@autoclosure () -> Bool) {
    if predicate() {
        print("True")
    }
}

logIfFalse(2 > 1)

//swift中的？？ 操作符
var level:Int?
var startLevel = 1

var currentLevel = level ?? startLevel

//逃逸闭包
func doWork(block: ()->()) {
    block()
}

doWork {
    print("work")
}

func doWorkAsync(block:@escaping ()-> ()) {
    DispatchQueue.main.async {
        block()
    }
}

class S {
    var foo = "foo"
    
    func method() {
        doWork {
            print(foo)
        }
        foo = "bar"
    }
    
    func method2() {
        //n闭包引用了self，打印出的是bar
        doWorkAsync {
            print(self.foo)
        }
        foo = "bar"
    }
    
    //如果不希望引用self,使用weak self
    func method3() {
        doWorkAsync {
            [weak self] in
            print(self?.foo ?? "nil")
        }
        foo = "bar"
    }
}
S().method()
S().method2()
S().method3()

protocol P {
    func work(b:@escaping () -> ())
}
class C: P {
    func work(b: @escaping () -> ()) {
        DispatchQueue.main.async {
            print("IN C")
            b()
        }
    }
}
class C1: P {
    func work(b:()->()) {
        
    }
}

//可选链式调用
class Toy {
    let name: String
    init(name: String) {
        self.name = name
    }
}

extension Toy {
    //play方法没有返回，它和一对小括号()是等价的
    func play() {
        
    }
}

class Pet {
    var toy: Toy?
}

class Child {
    var pet: Pet?
}

var xiaoming = Child()
xiaoming.pet?.toy?.play()

//通用
let playClosure = {
    (child:Child) -> ()? in
    child.pet?.toy?.play()
}
if let result:() = playClosure(xiaoming) {
    print("好开心~")
} else {
    print("没有玩具可以玩了")
}

//操作符
struct Vector2D {
    var x = 0.0
    var y = 0.0
}
let v1 = Vector2D(x: 2.0, y: 3.0)
let v2 = Vector2D(x: 1.0, y: 4.0)

func + (left:Vector2D,right:Vector2D) -> Vector2D {
    return Vector2D(x: left.x + right.x, y: left.y + right.y)
}
let v4 = v1 + v2


//函数参数的修饰是具有传递限制的，就是说对于跨越层级的调用，我们需要保证同一参数的修饰是统一的
//
func makeIncrementor(addNumber: Int) -> ((inout Int) -> ()) {
    func incrementor(variable: inout Int) -> () {
        variable += addNumber
    }
    return incrementor
}

//字面量表达  使用string赋值来生产Person对象
class Person:ExpressibleByStringLiteral {
    let name: String
    init(name value: String) {
        self.name = value
    }
    required convenience init(stringLiteral value: String) {
        self.init(name:value)
    }
    required convenience init(extendedGraphemeClusterLiteral value: String) {
        self.init(name:value)
    }
    required convenience init(unicodeScalarLiteral value: String) {
        self.init(name:value)
    }
}

let p:Person = "kayouyou"
print(p.name)


//扩展数组使其支持数组下标
extension Array {
    subscript(input: [Int] ) -> ArraySlice<Element> {
        get {
            var result = ArraySlice<Element>()
            for i in input {
                assert(i < self.count,"Index out of range")
                result.append(self[i])
            }
            return result
        }
        
        set {
            for (index,i) in input.enumerated() {
                assert(i < self.count,"Index out of range")
                self[i] = newValue[index]
            }
        }
    }
}

































































