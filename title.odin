package seusdl2

import SDL "vendor:sdl2"

import "core:math"

sdl2Texture : ^SDL.Texture
shooterTexture : ^SDL.Texture
title_timeout: i32
reveal: i32

initTitle :: proc() {

    app.delegate.logic = logic
    app.delegate.draw = draw

    app.keyboard = {}

    sdl2Texture = loadTexture("gfx/sdl2.png")
    shooterTexture = loadTexture("gfx/shooter.png")

    title_timeout = FPS * 5

}

@(private="file")
logic :: proc() {
    doBackground()

    doStarField()

    if reveal < SCREEN_HEIGHT {
        reveal += 1
    }

    title_timeout -= 1
    if title_timeout <= 0 {
        initHighscores()
    }

    if app.keyboard[SDL.SCANCODE_LCTRL] {
        initStage()
    }
    
}

draw :: proc() {

    drawBackground()

    drawStarfield()

    drawLogo()


    if title_timeout % 40 < 20 {
        drawText(SCREEN_WIDTH / 2, 600, 255, 255, 255, Text_Position.CENTER, "PRESS FIRE TO PLAY!")
    }
}

drawLogo :: proc() {

    r := SDL.Rect{}

    SDL.QueryTexture(sdl2Texture, nil, nil, &r.w, &r.h)

    r.h = math.min(reveal, r.h)    
    
    blitRect(sdl2Texture, &r, (SCREEN_WIDTH / 2) - (r.w /2), 100)

    SDL.QueryTexture(shooterTexture, nil, nil, &r.w, &r.h)

    r.h = math.min(reveal, r.h)

    blitRect(shooterTexture, &r, (SCREEN_WIDTH / 2) - (r.w / 2), 250)

}


