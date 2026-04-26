package seusdl2

import SDL "vendor:sdl2"

main :: proc() {

    then: i64
    remainder: f32    
    app.textureTail = &app.textureHead

    intitSDL()
    defer cleanup()

    initGame()

    initTitle()

    then = i64(SDL.GetTicks())

    remainder = 0

    for {

        prepareScene()

        doInput()

        app.delegate.logic()

        app.delegate.draw()

        presentScene()

        capFrameRate(&then, &remainder)

    }
}

@(private="file")
capFrameRate :: proc(then: ^i64, remainder: ^f32) {

    wait, frameTime : i64

    wait = i64(16 + remainder^)

    // remove the int part
    remainder^ -= f32(i64(remainder^))

    frameTime = i64(SDL.GetTicks()) - then^

    wait -= frameTime

    if wait < 1 {
        wait = 1
    }

    SDL.Delay(u32(wait))

    remainder^+= 0.667

    then^ = i64(SDL.GetTicks())
}
