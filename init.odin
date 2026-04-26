package seusdl2

import SDL "vendor:sdl2"
import SDL_IMG "vendor:sdl2/image"
import SDL_MIX "vendor:sdl2/mixer"

app : App

intitSDL :: proc() {
    windowFlags: SDL.WindowFlags
    rendererFlags := SDL.RENDERER_ACCELERATED    

    assert(SDL.Init(SDL.INIT_VIDEO) == 0, SDL.GetErrorString())
    assert(SDL_IMG.Init(SDL_IMG.InitFlags{.PNG,.JPG}) != nil, SDL.GetErrorString())

    app.window = SDL.CreateWindow(
        "Odin SDL2 Shooter", SDL.WINDOWPOS_UNDEFINED, SDL.WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, windowFlags)

    assert(app.window != nil, SDL.GetErrorString())

    SDL.SetHint(SDL.HINT_RENDER_SCALE_QUALITY, "linear")
    app.renderer = SDL.CreateRenderer(app.window, -1, rendererFlags)

    assert(app.renderer != nil, SDL.GetErrorString())

    SDL.ShowCursor(0)

    assert(SDL_MIX.OpenAudio(44100, SDL_MIX.DEFAULT_FORMAT, 2, 1024)!=-1, "Could not initialize SDL Mixer!\n")

    SDL_MIX.AllocateChannels(MAX_SND_CHANNELS)
}

cleanup :: proc() {
    SDL.Quit()
    SDL.DestroyWindow(app.window)
    SDL.DestroyRenderer(app.renderer)
}

initGame :: proc() {

    initBackground()

    initStarField()

    initSounds()

    initFonts()

    initHighscoreTable()

    loadMusic("music/Mercury.ogg")

    playMusic(true)

}