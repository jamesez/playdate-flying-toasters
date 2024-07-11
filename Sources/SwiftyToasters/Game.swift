import PlaydateKit

// MARK: - Game

final class Game: PlaydateGame {
    // MARK: Lifecycle

    init() {
        // turned off for testing
         Graphics.clear(color: .black)
        Graphics.setBackgroundColor(.black)
        for _ in 1...5 {
            let t = Toaster()
            toasters.append(t)
            t.addToDisplayList()
        }
    }

    // MARK: Internal

    var toasters: [Sprite.Sprite] = []

    func update() -> Bool {
        Sprite.updateAndDrawDisplayListSprites()
        System.drawFPS()
        
        if Int32(System.elapsedTime * 100) % 100 < 6 {
            var t: Sprite.Sprite

            if (rand() % 100 < 20) {
                t = Toast()
            } else {
                t = Toaster()
            }
            
            toasters.append(t)
            t.addToDisplayList()
        }
        
        // cull
        toasters.removeAll(where: { sprite in
            let pos = sprite.position
            if (pos.x < -65) || (Int32(pos.y) > Display.height + 65) {
                sprite.removeFromDisplayList()
                return true
            }
            return false
        })

        print("count: \(toasters.count)")

        return true
    }

    func gameWillPause() {
        print("Paused!")
    }
}

// MARK: - Toaster

class Toaster: Sprite.Sprite {
    
    var table: Graphics.BitmapTable?
    
    // each toaster has its own cycle of flapping
    var birthTime = rand() % 6 + 1
    var flapRate: Float = Float(rand() % 10 + 1)
    var dx: Float = 0.0
    var dy: Float = 0.0

    override init() {
        super.init()
        table = try! Graphics.BitmapTable(path: "toaster")
        image = table?.bitmap(at: 2)
        
        bounds = .init(x: Float(Display.width), 
                       y: -150 + Float(rand() % Display.height),
                       width: 64,
                       height: 64)
        
        dx = -1.5  + Float(rand() % 100) / 100.0
        dy =  0.25 + Float(rand() % 100) / 100.0
    }

    override func update() {
        // the draw order is 0, 1, 2, 3, 2, 1, 0 [repeat]
        let frameOffset = (Int32(System.elapsedTime * flapRate) + birthTime) % 6
        
        let frameToLoad = frameOffset <= 3 ? frameOffset : 6 - frameOffset
        
        image = table?.bitmap(at: frameToLoad)
        moveBy(dx: dx, dy: dy + sinf(System.elapsedTime * 4 + Float(birthTime)))
    }
}

class Toast: Sprite.Sprite {
    
    var dx: Float = 0.0
    var dy: Float = 0.0

    override init() {
        super.init()
        image = try! Graphics.Bitmap(path: "toast")
        
        bounds = .init(x: Float(Display.width),
                       y: -150 + Float(rand() % Display.height),
                       width: 64,
                       height: 64)

        dx = -1.5  + Float(rand() % 100) / 100.0
        dy =  0.25 + Float(rand() % 100) / 100.0
    }
    
    override func update() {
        moveBy(dx: dx, dy: dy)
    }

}
