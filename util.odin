package seusdl2

import "core:math"

collision :: proc(x1, y1, w1, h1, x2, y2, w2, h2: i32) -> bool {
    return (math.max(x1, x2) < math.min(x1+w1, x2+w2)) && (math.max(y1, y2) < min(y1+h1, y2+h2))
}

calcSlope :: proc(x1, y1, x2, y2: i32, dx, dy: ^f32) {
    steps := math.max(math.abs(x1-x2), math.abs(y1-y2))

    if steps == 0 {
        dx^, dy^ = 0,0

        return
    }

    dx^ = f32(x1 - x2)
    dx^ = dx^ / f32(steps)

    dy^ = f32(y1 - y2)
    dy^ = dy^ / f32(steps)
}

strlen :: proc(s: []u8) -> int {

    for i in 0..<len(s) {
        if s[i] == 0 do return i
    }

    return len(s)
}