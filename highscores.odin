package seusdl2

import "core:relative"
import "core:sort"

import SDL "vendor:sdl2"

highscores: Highscores
newHighscore: ^Highscore
cursorBlink: u32
highscore_timeout: i32

initHighscoreTable :: proc() {

    for i := 0; i < NUM_HIGHSCORES; i+=1 {

        highscores.highscore[i].score = u32(NUM_HIGHSCORES - i)
        copy_from_string(highscores.highscore[i].name[:], "ANONYMOUS")        

    }

    newHighscore = nil
    cursorBlink = 0
}

initHighscores :: proc() {
    app.delegate.logic = logic
    app.delegate.draw = draw    
    app.keyboard = {}

    highscore_timeout = FPS * 5
}

addHighscore :: proc(score: u32) {

    newHighscores : [NUM_HIGHSCORES + 1]Highscore

    for i:=0; i < NUM_HIGHSCORES; i+=1 {
        newHighscores[i] = highscores.highscore[i]
        newHighscores[i].recent = false
    }

    newHighscores[NUM_HIGHSCORES].score = score
    newHighscores[NUM_HIGHSCORES].recent = true

    sort.quick_sort_proc(newHighscores[:], proc(a, b: Highscore) -> int {
        if a.score > b.score do return -1 // a before b
        if a.score < b.score do return 1  // b before a

        return 0        
    })

    newHighscore = nil

    for i:=0; i < NUM_HIGHSCORES; i+=1 {
        highscores.highscore[i] = newHighscores[i]

        if highscores.highscore[i].recent {
            newHighscore = &highscores.highscore[i]
        }
    }
}

@(private="file")
logic :: proc() {

    doBackground()

    doStarField()

    if (newHighscore != nil) {

        doNameInput()

    } else {

        highscore_timeout -= 1

        if highscore_timeout <= 0{

            initTitle()

        }

        if app.keyboard[SDL.SCANCODE_LCTRL] {

            initStage()
        }
    }

    cursorBlink += 1

    if cursorBlink >= FPS {

        cursorBlink = 0

    }
}

@(private="file")
draw :: proc() {
    
    drawBackground()

    drawStarfield()

    if newHighscore != nil {

        drawNameInput()

    } else {

        drawHighscores()

        if highscore_timeout % 40 < 20 {

            drawText(SCREEN_WIDTH / 2, 600, 255, 255, 255, Text_Position.CENTER, "PRESS FIRE TO PLAY!")

        }

    }
}

@(private="file")
drawHighscores :: proc() {

    y : i32 = 150

    drawText(SCREEN_WIDTH / 2, 70, 255, 255, 255, Text_Position.CENTER, "HIGHSCORES")

    for i:=0; i < NUM_HIGHSCORES; i=i+1 {

        r :i32= 255
        g :i32= 255
        b :i32= 255

        if highscores.highscore[i].recent {

            b = 0

        }

        name_slice := highscores.highscore[i].name[:strlen(highscores.highscore[i].name[:])]
        drawText(
            SCREEN_WIDTH / 2, y, 
            r, g, b, 
            Text_Position.CENTER, "#%d. %-15s ...... %03d", (i + 1), 
            name_slice,
            highscores.highscore[i].score
        )

        y += 50
    }
}

@(private="file")
doNameInput :: proc() {

    n := strlen(newHighscore.name[:])

    for i :=0; i < strlen(app.inputText[:]); i += 1 {

        c := app.inputText[i]

        if c >= 'a' && c <= 'z' do c -=32 // To upper case

        if n < MAX_SCORE_NAME_LENGTH-1 && c >= ' ' && c <= 'Z' {
            newHighscore.name[n] = c
            n += 1
        }
    }

    if n > 0 && app.keyboard[SDL.SCANCODE_BACKSPACE] {

        n -= 1

        newHighscore.name[n] = 0

        app.keyboard[SDL.Scancode.BACKSPACE] = false
    }

    if app.keyboard[SDL.SCANCODE_RETURN] {

        if strlen(newHighscore.name[:]) == 0 {
            copy_from_string(newHighscore.name[:], "ANONYMOUS")
        }

        newHighscore = nil
    }
}

@(private="file")
drawNameInput :: proc() {

    r: SDL.Rect

    name_slice := newHighscore.name[:strlen(newHighscore.name[:])]

    drawText(SCREEN_WIDTH / 2, 70, 255, 255, 255, Text_Position.CENTER, "CONGRATULATIONS, YOU'VE GAINED A HIGHSCORE!")

    drawText(SCREEN_WIDTH / 2, 120, 255, 255, 255, Text_Position.CENTER, "ENTER YOUR NAME BELOW:")

    drawText(SCREEN_WIDTH / 2, 250, 128, 255, 128, Text_Position.CENTER, string(name_slice))

    if cursorBlink < FPS / 2 {        

        r.x = i32( ((SCREEN_WIDTH / 2) + (strlen(name_slice) * GLYPH_WIDTH / 2)  ) + 5 );        
        r.y = 250
        r.w = GLYPH_WIDTH
        r.h = GLYPH_HEIGHT

        SDL.SetRenderDrawColor(app.renderer, 0, 255, 0, 255)
        SDL.RenderFillRect(app.renderer, &r)
    }   

    drawText(SCREEN_WIDTH / 2, 625, 255, 255, 255, Text_Position.CENTER, "PRESS RETURN WHEN FINISHED")
}