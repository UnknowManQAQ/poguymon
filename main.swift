import Foundation

// 定義角色屬性
class Character {
    var name: String
    var level: Int
    var health: Int
    var attack: Int
    var defense: Int
    
    init(name: String, level: Int, health: Int, attack: Int, defense: Int) {
        self.name = name
        self.level = level
        self.health = health
        self.attack = attack
        self.defense = defense
    }
    
    func attack(target: Character) {
        let damage = max(0, attack - target.defense)
        target.health -= damage
        print("\(name) attacks \(target.name) for \(damage) damage!")
    }
}

// 定義怪物屬性
class Monster: Character {
    init(level: Int) {
        super.init(name: "Monster", level: level, health: 10 * level, attack: level, defense: level)
    }
}

// 定義玩家角色屬性
class Player: Character {
    var experience: Int
    var gold: Int
    
    init(name: String, level: Int, health: Int, attack: Int, defense: Int, experience: Int, gold: Int) {
        self.experience = experience
        self.gold = gold
        super.init(name: name, level: level, health: health, attack: attack, defense: defense)
    }
    
    // 玩家攻擊怪物時，擊敗怪物後獲得經驗值和金幣
    func attack(monster: Monster) {
        super.attack(target: monster)
        if monster.health <= 0 {
            experience += monster.level * 10
            gold += monster.level * 5
            print("\(name) defeated \(monster.name) and gained \(experience) experience and \(gold) gold!")
        }
    }
    
    // 玩家升級時，提高屬性值
    func levelUp() {
        level += 1
        health += 10
        attack += 2
        defense += 2
        print("\(name) leveled up to level \(level)!")
    }
    
    // 玩家經驗值達到一定值時升級
    func checkLevelUp() {
        if experience >= level * 50 {
            levelUp()
            experience -= level * 50
        }
    }
}

// 定義遊戲地圖
class Map {
    var size: Int
    var tiles: [[String]]
    var player: Player
    
    init(size: Int, player: Player) {
        self.size = size
        self.player = player
        tiles = Array(repeating: Array(repeating: " ", count: size), count: size)
        generateRandomMap()
    }
    
    // 隨機生成地圖，包括怪物和寶箱
    func generateRandomMap() {
        for i in 0..<size {
            for j in 0..<size {
                let randomInt = Int.random(in: 1...10)
                if randomInt == 1 {
                    tiles[i][j] = "M"
                } else if randomInt == 2 {
                    tiles[i][j] = "C"
                }
            }
        }
        tiles[0][0] = "P"
    }
    
    // 玩家移動時，檢查移動是否合法，如果合法，更新地圖和玩家位置
    func movePlayer(x: Int, y: Int) {
        let newX = playerX + x
        let newY = playerY + y
        if newX < 0 || newX >= size || newY < 0 || newY >= size {
            print("Invalid move!")
            return
        }
        let tile = tiles[newX][newY]
        if tile == "M" {
            let monster = Monster(level: player.level)
            while monster.health > 0 && player.health > 0 {
                player.attack(monster: monster)
                if monster.health > 0 {
                    monster.attack(target: player)
                }
            }
            if player.health <= 0 {
                print("\(player.name) was defeated by \(monster.name)!")
                return
            }
            tiles[playerX][playerY] = " "
            tiles[newX][newY] = "P"
            playerX = newX
            playerY = newY
            player.checkLevelUp()
        } else if tile == "C" {
            let gold = Int.random(in: 1...10) * player.level
            player.gold += gold
            print("\(player.name) found a chest and gained \(gold) gold!")
            tiles[playerX][playerY] = " "
            tiles[newX][newY] = "P"
            playerX = newX
            playerY = newY
            player.checkLevelUp()
        } else {
            tiles[playerX][playerY] = " "
            tiles[newX][newY] = "P"
            playerX = newX
            playerY = newY
        }
    }
}

// 初始化遊戲
let player = Player(name: "Player", level: 1, health: 100, attack: 10, defense: 10, experience: 0, gold: 0)
let map = Map(size: 10, player: player)

// 遊戲主循環
var playerX = 0
var playerY = 0
while true {
    // 顯示地圖和玩家狀態
    for i in 0..<map.size {
        for j in 0..<map.size {
            if i == playerX && j == playerY {
                print("P", terminator: " ")
            } else {
                print(map.tiles[i][j], terminator: " ")
            }
        }
        print("")
    }
    print("Player: \(player.name) Level: \(player.level) Health: \(player.health) Attack: \(player.attack) Defense: \(player.defense) Experience: \(player.experience) Gold: \(player.gold)")
    
    // 讀取玩家輸入
    print("Enter move (w/a/s/d):")
    let input = readLine()!
    var dx = 0
    var dy = 0
    switch input {
    case "w":
        dx = -1
    case "a":
        dy = -1
    case "s":
        dx = 1
    case "d":
        dy = 1
    default:
        print("Invalid input!")
    }
    
    // 移動玩家
    map.movePlayer(x: dx, y: dy)
    
    // 檢查是否達成結束條件
    if playerX == map.size - 1 && playerY == map.size - 1 {
        print("You win!")
        break
    }
}