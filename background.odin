package seusdl2

import "core:math/rand"
import SDL "vendor:sdl2"

backgroundX: i32
stars : [MAX_STARS]Star
background: ^SDL.Texture

initBackground :: proc() {

	background = loadTexture("gfx/background.png");
	backgroundX = 0;

}

initStarField :: proc() {

    for i:=1; i < MAX_STARS; i = i + 1 {
        stars[i].x = rand.int31_max(SCREEN_WIDTH)
        stars[i].y = rand.int31_max(SCREEN_HEIGHT)
        stars[i].speed = rand.int32_range(1,9)
    }
}

doBackground :: proc() {

    backgroundX -= 1

    if backgroundX < -SCREEN_WIDTH {

        backgroundX = 0
    }
}

doStarField :: proc() {

    for i := 0; i < MAX_STARS; i = i+1 {

        stars[i].x -= stars[i].speed

        if stars[i].x < 0 {
            stars[i].x = SCREEN_WIDTH + stars[i].x
        }
    }
}

drawBackground :: proc() {

    dest : SDL.Rect
    x: i32

    for x = backgroundX; x < SCREEN_WIDTH; x += SCREEN_WIDTH {
        dest.x = x
        dest.y = 0
        dest.w = SCREEN_WIDTH
        dest.h = SCREEN_HEIGHT

        SDL.RenderCopy(app.renderer, background, nil, &dest)
    }
}

drawStarfield :: proc() {

    i: i32
    color: u8

    for i = 0; i < MAX_STARS; i += 1 {

        color = u8(32 * stars[i].speed)

        SDL.SetRenderDrawColor(app.renderer, color, color, color, 255)

        SDL.RenderDrawLine(app.renderer, stars[i].x, stars[i].y, stars[i].x + 3, stars[i].y)
    }
}

