package seusdl2

import "core:os"
import SDL "vendor:sdl2"

doInput :: proc() {
    event : SDL.Event

    app.inputText = {}

    for SDL.PollEvent(&event) {    
        #partial switch event.type {
            case SDL.EventType.QUIT:
                os.exit(0)
            case SDL.EventType.KEYDOWN:
                doKeyDown(&event.key)
            case SDL.EventType.KEYUP:
                doKeyUp(&event.key)
            case SDL.EventType.TEXTINPUT:
                copy(app.inputText[:SDL.TEXTINPUTEVENT_TEXT_SIZE], event.text.text[:])
        }
    }
}

doKeyDown :: proc(event : ^SDL.KeyboardEvent) {
    if event.keysym.scancode == SDL.SCANCODE_ESCAPE {
        os.exit(0)
    }

    if event.repeat == 0 && i32(event.keysym.scancode) < MAX_KEYBOARD_KEYS {
        app.keyboard[event.keysym.scancode] = true
    }
}

doKeyUp :: proc(event : ^SDL.KeyboardEvent) {
    if event.repeat == 0 && i32(event.keysym.scancode) < MAX_KEYBOARD_KEYS {
        app.keyboard[event.keysym.scancode] = false
    }
}
