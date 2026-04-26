package seusdl2

import "core:c"

import SDL "vendor:sdl2"
import SDL_IMG "vendor:sdl2/image"

prepareScene :: proc() {
    SDL.SetRenderDrawColor(app.renderer, 12, 12, 20, 255)
    SDL.RenderClear(app.renderer)
}

presentScene :: proc() {
    SDL.RenderPresent(app.renderer)
}

loadTexture :: proc(filepath: cstring) -> ^SDL.Texture {

    texture := getTexture(filepath)

    if texture == nil {
        SDL.LogInfo(c.int(SDL.LogCategory.APPLICATION), "Loading %s", filepath)
        texture = SDL_IMG.LoadTexture(app.renderer, filepath)
        assert(texture != nil, SDL.GetErrorString())
        addTextureToCache(filepath, texture)
    }

    return texture
}

blit :: proc(texture: ^SDL.Texture, x,y: i32) {
    dest : SDL.Rect

    dest.x = x
    dest.y = y
    SDL.QueryTexture(texture, nil, nil, &dest.w, &dest.h)
    SDL.RenderCopy(app.renderer, texture, nil, &dest)    
}

blitRect :: proc(texture: ^SDL.Texture, src: ^SDL.Rect, x, y: i32) {
    dest : SDL.Rect

    dest.x = x;
    dest.y = y;
    dest.w = src.w
    dest.h = src.h

    SDL.RenderCopy(app.renderer, texture, src, &dest)
}

@(private="file")
getTexture:: proc(name: cstring) -> ^SDL.Texture {
    t: ^Texture

    for t = app.textureHead.next; t != nil; t = t.next {
        if t.name == string(name) {            
            SDL.LogInfo(c.int(SDL.LogCategory.APPLICATION), "Restoring texture from cache: %s", name)
            return t.texture
        }
    }

    return nil
}

@(private="file")
addTextureToCache :: proc(path: cstring, sdlTexture: ^SDL.Texture) {
    
    texture := new(Texture)

    app.textureTail.next = texture
    app.textureTail = texture

    texture.name = string(path)
    texture.texture = sdlTexture
}
