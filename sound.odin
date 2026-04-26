package seusdl2

import SDL_MIX "vendor:sdl2/mixer"

sounds: [Sound_Effect.MAX]^SDL_MIX.Chunk
music: ^SDL_MIX.Music

initSounds :: proc() {

    sounds = {}

    loadSounds()

    SDL_MIX.Volume(i32(Sound_Channel.PLAYER), SDL_MIX.MAX_VOLUME / 8)
    SDL_MIX.Volume(i32(Sound_Channel.ALIEN_FIRE), SDL_MIX.MAX_VOLUME / 8)
    SDL_MIX.Volume(i32(Sound_Channel.POINTS), SDL_MIX.MAX_VOLUME / 8)
    SDL_MIX.Volume(i32(Sound_Channel.ANY), SDL_MIX.MAX_VOLUME / 8)

    SDL_MIX.VolumeMusic(SDL_MIX.MAX_VOLUME / 8)

}

@(private="file")
loadSounds :: proc() {

    sounds[Sound_Effect.PLAYER_FIRE] = SDL_MIX.LoadWAV("sound/334227__jradcoolness__laser.ogg")
    sounds[Sound_Effect.ALIEN_FIRE] = SDL_MIX.LoadWAV("sound/196914__dpoggioli__laser-gun.ogg")
    sounds[Sound_Effect.PLAYER_DIE] = SDL_MIX.LoadWAV("sound/245372__quaker540__hq-explosion.ogg")
    sounds[Sound_Effect.ALIEN_DIE] = SDL_MIX.LoadWAV("sound/10 Guage Shotgun-SoundBible.com-74120584.ogg")
    sounds[Sound_Effect.POINTS] = SDL_MIX.LoadWAV("sound/342749__rhodesmas__notification-01.ogg")
}

loadMusic :: proc(filename: cstring) {

    if music != nil {
        SDL_MIX.HaltMusic()
        SDL_MIX.FreeMusic(music)
        music = nil
    }

    music = SDL_MIX.LoadMUS(filename)
}

playMusic :: proc(loop : bool) {

    SDL_MIX.PlayMusic(music, -1 if loop else 0)
}

playSound :: proc(id, channel: i32) {

    SDL_MIX.PlayChannel(channel, sounds[id], 0)
}