package seusdl2

import SDL"vendor:sdl2"

Delegate :: struct {
    logic: proc(),
    draw:  proc(),
}

Texture :: struct {
    name: string,
    texture: ^SDL.Texture,
    next: ^Texture,
}

App :: struct {
    renderer: ^SDL.Renderer,
    window: ^SDL.Window,
    delegate: Delegate,
    keyboard : [MAX_KEYBOARD_KEYS]bool,
    textureHead: Texture,
    textureTail: ^Texture,
    inputText: [MAX_LINE_LENGTH]u8,
}

Entity:: struct {
    x,y: f32,
    w, h: i32,    
    dx, dy: f32,    
    health: i32,
    reload: i32,
    texture: ^SDL.Texture,
    next: ^Entity,
    side: int,
}

Explosion :: struct {
    x, y: f32,
    dx, dy: f32,
    r,g,b,a: u8,
    next : ^Explosion,
}

Debris :: struct {
    x, y: f32,
    dx, dy: f32,
    rect: SDL.Rect,
    texture: ^SDL.Texture,
    life: i32,
    next: ^Debris,
}

Stage:: struct {
    fighterHead, bulletHead, pointsHead: Entity,
    fighterTail, bulletTail, pointsTail: ^Entity,
    explosionHead : Explosion,
    explosionTail : ^Explosion,
    debrisHead : Debris,
    debrisTail : ^Debris,
    score: u32,
}

Star :: struct {
    x, y, speed: i32,
}

Highscore :: struct {
    score: u32,
    recent: bool,
    name: [MAX_SCORE_NAME_LENGTH]u8,
}

Highscores :: struct {    
    highscore : [NUM_HIGHSCORES]Highscore,
}
