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


