package seusdl2

import "core:fmt"
import SDL "vendor:sdl2"

GLYPH_HEIGHT :: 28
GLYPH_WIDTH :: 18

fontTexture : ^SDL.Texture
drawTextBuffer: [MAX_LINE_LENGTH]u8

initFonts :: proc() {
    fontTexture = loadTexture("gfx/font.png")    
}

drawText :: proc(x, y, r, g, b: i32, align: Text_Position, format: string, args: ..any) {

    text := fmt.bprintf(drawTextBuffer[:], format, ..args)
    length := len(text)    

    px := x

    #partial switch align {
        case .RIGHT:
            px -= i32(length * GLYPH_WIDTH)
        case .CENTER:
            px -= i32( (length * GLYPH_WIDTH) / 2 )
    }

    rect := SDL.Rect {
        w = GLYPH_WIDTH,
        h = GLYPH_HEIGHT,
        y = 0,
    }

    SDL.SetTextureColorMod(fontTexture, u8(r), u8(g), u8(b))    

    for c in text {

        if c >= ' ' && c <= 'Z' {

            rect.x = i32(c - ' ') * GLYPH_WIDTH
            blitRect(fontTexture, &rect, px, y)
            px += GLYPH_WIDTH
        }

    }    
}
