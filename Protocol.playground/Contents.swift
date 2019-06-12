import UIKit

//协议 属性要求
protocol SomeProtocol {
    //协议总是用var关键字来声明变量属性，在类型声明后面加上 set get 来表示属性是可读可写的
    var mustBeSettable: Int { get set }
    var doesNotNeedToBeSettable: Int { get }
    //协议中总是使用static关键字来声明类型属性；当类类型遵循协议时，除了static关键字，还可以使用class关键字来声明类型属性
    static var someTypeProperty: Int { get set }
}

protocol FullyNamed {
    var fullName: String { get }
}
struct Person: FullyNamed {
    var fullName: String
}
let jhon = Person(fullName: "John Appleseed")

class Startship: FullyNamed {
    var prefix: String?
    var name: String
    init(name: String,prefix: String?) {
        self.name = name
        self.prefix = prefix
    }
    //这里把fullname作为只读属性来实现
    var fullName: String {
        return (prefix != nil ? prefix! + " " : " ") + name
    }
}
var ncc1907 = Startship(name: "Enterprise", prefix: "USS")
print(ncc1907.fullName)

//协议 方法要求
protocol RandomNumberGenerator {
    func random() -> Double
}

class LinearCongruentialGenerator: RandomNumberGenerator {
    var lastRandom = 42.0
    let m = 1389.0
    let a = 3877.0
    let c = 286.3
    func random() -> Double {
        lastRandom = ((lastRandom * a + c).truncatingRemainder(dividingBy: m))
        return lastRandom / m
    }
}
let generator = LinearCongruentialGenerator()

protocol Togglable {
    mutating func toggle()
}

enum OnOffSwitch: Togglable {
    case off, on
    //由于enum是值类型，所以方法被标记为mutating 以满足协议的要求
    mutating func toggle() {
        switch self {
        case .off:
            self = .on
        case .on:
            self = .off
        }
    }
}
var lightSwitch = OnOffSwitch.off
lightSwitch.toggle()

//协议构造器要求
protocol InitProtocol {
    init(someParameter: Int)
}

//在x遵循协议的类中实现构造器，无论作为指定构造器，还是作为便利构造器，你都必须为构造器实现标上required修饰符
class SomeClass: InitProtocol {
    //使用required修饰符可以确保所有子类也必须提供此构造器实现，从而也能符合协议
    required init(someParameter: Int) {
        
    }
    //如果类被标记为final，那么不需要协议构造器的实现中使用required修饰符，因为final类不能有子类
}

//如果一个子类重写了父类的指定构造器，并且该构造器满足了某个协议的要求，那么该构造器需要同时标注required和override修饰符
protocol OtherProtocol {
    init()
}
class OtherSuperClass {
    init() {
        
    }
}

class SomeSubClass: OtherSuperClass, OtherProtocol {
    //因为遵循了协议，需要加上required
    //因为继承自父类，需要加上override
    required override init() {
        
    }
}

//协议作为类型
class Dice {
    let sides: Int
    var generator: RandomNumberGenerator
    init(sides: Int, generator: RandomNumberGenerator) {
        self.sides = sides
        self.generator = generator
    }
    func roll() -> Int {
        return Int(generator.random() * Double(sides)) + 1
    }
}

var d6 = Dice(sides: 6, generator: LinearCongruentialGenerator())
for _ in 1...5 {
    print("Random dice roll is \(d6.roll())")
}

//委托
protocol DiceGame {
    var dice: Dice { get }
    func play()
}
protocol DiceGameDelegate {
    func gameDidStart(_ game: DiceGame)
    func game(_ game: DiceGame,didStartNewTurnWithDiceRoll diceRoll: Int)
    func gameDidEnd(_ game: DiceGame)
}

class SnakesAndLadders: DiceGame {
    let finalSquare = 25
    let dice: Dice = Dice(sides: 6, generator: LinearCongruentialGenerator())
    var square = 0
    var board: [Int]
    init() {
        board = Array(repeating: 0, count: finalSquare + 1)
        board[03] = +08;board[06] = +11;board[09] = +09;board[10] = +02
    }
    var delegate:DiceGameDelegate?
    func play() {
        square = 0
        delegate?.gameDidStart(self)
        gameLoop: while square != finalSquare {
            let diceRoll = dice.roll()
            delegate?.game(self, didStartNewTurnWithDiceRoll: diceRoll)
            switch square + diceRoll {
            case finalSquare:
                break gameLoop
            case let newSquare where newSquare > finalSquare:
                continue gameLoop
            default:
                square += diceRoll
                square += board[square]
            }
        }
        delegate?.gameDidEnd(self)
    }
}

class DiceGameTracker: DiceGameDelegate {
    var numberOfTurns = 0
    func gameDidStart(_ game: DiceGame) {
        numberOfTurns = 0
        if game is SnakesAndLadders {
            print("Started a new game of Snakes and Ladders")
        }
        print("The game is using  a \(game.dice.sides)-sided dice")
    }
    func game(_ game: DiceGame, didStartNewTurnWithDiceRoll diceRoll: Int) {
        numberOfTurns += 1
        print("Rolled a \(diceRoll)")
    }
    func gameDidEnd(_ game: DiceGame) {
        print("The game lasted for \(numberOfTurns) turns")
    }
}

let tracker = DiceGameTracker()
let game = SnakesAndLadders()
game.delegate = tracker
game.play()

//在扩展里添加协议遵循 如果无法修改源码可以通过扩展已有类型遵循并符合协议，扩展可以为已有类型添加属性，方法，下标，以及构造器

protocol TextRepresentable {
    var textualDescription: String { get }
}

extension Dice: TextRepresentable {
    var textualDescription: String {
        return "A \(sides)-sided dice"
    }
}

//通过扩展遵循并采纳协议，和在原始定义中遵循并符合协议的效果完全相同
let d12 = Dice(sides: 12, generator: LinearCongruentialGenerator())
print(d12.textualDescription)

//同样SnakesAndLadders 类也可以通过扩展来采纳和遵循上面的协议
extension SnakesAndLadders: TextRepresentable {
    var textualDescription: String {
        return "A game of Snakes and Ladders with \(finalSquare) squares"
    }
}

print(game.textualDescription)

//有条件的遵循协议 conditionally-conforming-to-a-protocol
extension Array: TextRepresentable where Element: TextRepresentable {
    var textualDescription: String {
        let itemsAsText = self.map{ $0.textualDescription }
        return "[" + itemsAsText.joined(separator: ",") + "]"
    }
}

let myDice = [d6,d12]
print(myDice.textualDescription)


//在扩展里声明采纳协议
//当一个协议已经符合了，某个协议中的所有要求，却还没有声明采纳该协议时，可以通过空的扩展来让它采纳该协议
struct Hamster {
    var name: String
    var textualDescription: String {
        return "A hamster named \(name)"
    }
}
extension Hamster: TextRepresentable {}
//从现在起，hamster的实例可以作为TextRepresentable类型使用

let simonTheHamster = Hamster(name: "Simon")
let somethingTextRepresentable: TextRepresentable = simonTheHamster
print(somethingTextRepresentable.textualDescription)

//即使满足了协议的所有的要求，类型也不会自动遵循协议，必须显示地遵循协议

//协议类型可以在数组或字典这样的集合中使用，在协议类型提到了这样的用法
let things: [TextRepresentable] = [game,d12,simonTheHamster]
for thing in things {
    print(thing.textualDescription)
}


//协议的继承
protocol PrettyTextRepresentable: TextRepresentable {
    var prettyTextualDescription: String { get }
}

//扩展SnakesAndLadders
extension SnakesAndLadders: PrettyTextRepresentable {
    var prettyTextualDescription: String {
        var output = textualDescription + ":\n"
        for index in 1...finalSquare {
            switch board[index] {
            case let ladder where ladder > 0:
                output += "△"
            case let snake where snake < 0:
                output += "▽"
            default:
                output += "⭕️"
            }
        }
        return output
    }
}

print(game.prettyTextualDescription)

//类专属的协议 通过添加anyobject关键字到协议的继承序列，可以限制协议只能被类类型采纳
protocol SomeClassOnlyProtocol: AnyObject,SomeProtocol {
    
}
//上面的这个协议只能被类类型采纳，如果是结构体或枚举类型采纳就会导致编译时错误

//协议合成 要求一个类型同时遵循多个协议是很有用的
protocol Named {
    var name: String { get }
}
protocol Aged {
    var age: Int { get }
}
struct People:Named,Aged {
    var name: String
    var age: Int
}
//意味着任何同时遵循named和aged的协议，不关心参数的具体类型，只要参数符合这两个协议即可
func wishHappyBirthday(to celebrator: Named & Aged) {
    print("Happy birthday,\(celebrator.name),you are \(celebrator.age)!")
}
let birthdayPerson = People(name: "Michael", age: 21)
wishHappyBirthday(to: birthdayPerson)


//类 和 协议进行组合
//创建父类location
class Location {
    var latitude: Double
    var longitude: Double
    init(latitude: Double,longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

//继承location 并遵循named协议
class City: Location,Named {
    var name: String
    init(name: String, latitude: Double,longitude: Double) {
        self.name = name
        super.init(latitude: latitude, longitude: longitude)
    }
}

//意味着任何location的子类，并且遵循named协议参数都满足
func beginConcert(in location: Location & Named) {
    print("Hello,\(location.name)!")
}

let seattle = City(name: "Seattle", latitude: 47.5, longitude: -122.3)
beginConcert(in: seattle)


//协议的一致性
protocol HashArea {
    var area: Double { get }
}
class Circle: HashArea {
    let pi = 3.1415926
    var radius: Double
    var area: Double { return pi * radius * radius }
    init(radius: Double) {
        self.radius = radius
    }
}
class Country: HashArea {
    var area: Double
    init(area: Double) {
        self.area = area
    }
}
class Animal {
    var legs: Int
    init(legs: Int) {
        self.legs = legs
    }
}

// circle country animal并没有一个共同的基类，尽管如此，它们都是类，它们的实例都可以作为anyobject类型的值
let objects:[AnyObject] = [
    Circle(radius: 2.0),
    Country(area: 243_610),
    Animal(legs: 4)
]

//objects数组使用字面量初始化
for object in objects {
    if let objectWithArea = object as? HashArea {
        print("Area is \(objectWithArea)")
    } else {
        print("Something that doesn't have an area")
    }
}

//可选的协议要求
//@objc标记如此的协议只能被继承自objective-c类的类或者@objc类遵循，其他类以及结构体和枚举均不能遵循这种协议
@objc protocol CounterDataSource {
    //使用可选要求时，它们的类型会自动变成可选的
    @objc optional func increment(forCount count: Int) -> Int
    @objc optional var fixedIncrement: Int { get }
}

class Counter {
    var count = 0
    var dataSources: CounterDataSource?
    func increment() {
        if let amount = dataSources?.increment?(forCount: count) {
            count += amount
        } else if let amount = dataSources?.fixedIncrement {
            count += amount
        }
    }
}

class ThreeSource: NSObject,CounterDataSource {
    let fixedIncrement: Int = 3
}

var counter = Counter()
counter.dataSources = ThreeSource()
for _ in 1...4{
    counter.increment()
    print(counter.count)
}

class TowardsZeroSource: NSObject,CounterDataSource {
    func increment(forCount count: Int) -> Int {
        if count == 0 {
            return 0
        } else if count < 0 {
            return 1
        } else {
            return -1
        }
    }
}

counter.count = -4
counter.dataSources = TowardsZeroSource()
for _ in 1...5 {
    counter.increment()
    print(counter.count)
}

//为协议扩展添加限制条件
extension Collection where Element: Equatable{
    func allEqual() -> Bool {
        for element in self {
            if element != self.first {
                return false
            }
        }
        return true
    }
}

let equalNumbers = [100,100,100,100,100]
let differentNumbers = [100,100,200,100,200]

print(equalNumbers.allEqual())
print(differentNumbers.allEqual())











