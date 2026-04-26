package seusdl2

import "core:math"
import "core:math/rand"
import SDL"vendor:sdl2"

stage: Stage
player : ^Entity

bulletTexture: ^SDL.Texture
enemyTexture: ^SDL.Texture
playerTexture : ^SDL.Texture

alienBulletTexture : ^SDL.Texture
explosionTexture: ^SDL.Texture
pointsTexture: ^SDL.Texture

enemySpawnTimer: i32
stageResetTimer: i32

highscore : u32

initStage :: proc() {
    app.delegate.logic = logic
    app.delegate.draw = draw
    
    stage.fighterTail = &stage.fighterHead
    stage.bulletTail = &stage.bulletHead
    stage.explosionTail = &stage.explosionHead
    stage.debrisTail = &stage.debrisHead

    bulletTexture = loadTexture("gfx/playerBullet.png")
    alienBulletTexture = loadTexture("gfx/alienBullet.png");
    enemyTexture = loadTexture("gfx/enemy.png")    
    playerTexture = loadTexture("gfx/player.png")
    explosionTexture = loadTexture("gfx/explosion.png")
    pointsTexture = loadTexture("gfx/points.png")

    resetStage()
}

@(private="file")
initPlayer :: proc() {
    player = new(Entity)

    stage.fighterTail.next = player
    stage.fighterTail = player

    player.health = 1
    player.x = 100
    player.y = 100
    player.texture = playerTexture
    SDL.QueryTexture(player.texture, nil, nil, &player.w, &player.h)

    player.side = SIDE_PLAYER
}

@(private="file")
logic :: proc() {

    doBackground()

    doStarField()

    doPlayer()

    doEnemies()

    doFighters()

    doBullets()

    doExplosions()

    doDebris()

    doPointsPods()

    spawnEnemies()

    clipPlayer()
    
    if player == nil {

        stageResetTimer -= 1

        if stageResetTimer <= 0 {

            addHighscore(stage.score)

            initHighscores()
        }
    }
}

@(private="file")
draw :: proc() {

    drawBackground()

    drawStarfield()

    drawPointsPods()

    drawFighters()

    drawBullets()

    drawDebris()

    drawExplosions()

    drawHud()

}

@(private="file")
doPlayer :: proc() {

    if player != nil {

        player.dx = 0
        player.dy = 0

        if player.reload > 0 {
            player.reload -= 1
        }

        if app.keyboard[SDL.SCANCODE_UP] {
            player.dy = -PLAYER_SPEED
        }

        if app.keyboard[SDL.SCANCODE_DOWN] {
            player.dy = PLAYER_SPEED
        }

        if app.keyboard[SDL.SCANCODE_LEFT] {
            player.dx = -PLAYER_SPEED
        }

        if app.keyboard[SDL.SCANCODE_RIGHT] {
            player.dx = PLAYER_SPEED
        }

        if app.keyboard[SDL.SCANCODE_LCTRL] && player.reload <= 0 {
            playSound(i32(Sound_Effect.PLAYER_FIRE), i32(Sound_Channel.PLAYER))
            fireBullet()            
        }
    }
}

@(private="file")
doEnemies :: proc() {
    e : ^Entity

    for e = stage.fighterHead.next; e != nil; e = e.next {
        
        if e != player {

            e.y = math.min( math.max(e.y, 0), f32(SCREEN_HEIGHT - e.h) ) 
            
            e.reload -= 1            
            if player != nil && e.reload <= 0 {

                fireAlienBullet(e)
                playSound(i32(Sound_Effect.ALIEN_FIRE), i32(Sound_Channel.ALIEN_FIRE))

            }
        }
    }
}

@(private="file")
fireBullet :: proc() {

    bullet : ^Entity
    bullet = new(Entity)    

    stage.bulletTail.next = bullet
    stage.bulletTail = bullet

    bullet.x = player.x
    bullet.y = player.y
    bullet.dx = PLAYER_BULLET_SPEED
    bullet.health = 1
    bullet.texture = bulletTexture
    bullet.side = SIDE_PLAYER    
    SDL.QueryTexture(bullet.texture, nil, nil, &bullet.w, &bullet.h)        

    // Adjust bullet to appear aligned with the player sprite
    bullet.y += f32( (player.h/2) - (bullet.h /2) )
    player.reload = 8
}

@(private="file")
doFighters :: proc() {
    entity, prev: ^Entity

    prev = &stage.fighterHead

    for entity = stage.fighterHead.next; entity != nil; entity = entity.next {

        entity.x += entity.dx
        entity.y += entity.dy

        if entity != player && i32(entity.x) < -entity.w {
            entity.health = 0
        }

        if (entity.health == 0) {

            if (entity == player) {
                player = nil
            }

            if entity == stage.fighterTail {
                stage.fighterTail = prev
            }

            prev.next = entity.next
            free(entity)
            entity = prev
        }

        prev = entity
    }
}

@(private="file")
doBullets :: proc() {
    b, prev: ^Entity

    prev = &stage.bulletHead

    for b = stage.bulletHead.next; b!=nil; b=b.next {
        b.x += b.dx
        b.y += b.dy

        if (bulletHitFighter(b) || b.x < -f32(b.w) || b.y < -f32(b.h) || b.x > SCREEN_WIDTH || b.y > SCREEN_HEIGHT) {
            if (b == stage.bulletTail) {
                stage.bulletTail = prev
            }

            prev.next = b.next
            free(b)
            b = prev
        }

        prev = b        
    }
}

@(private="file")
spawnEnemies :: proc() {
    enemy : ^Entity

    enemySpawnTimer -= 1
    if enemySpawnTimer <= 0 {

        enemy = new(Entity)
        stage.fighterTail.next = enemy
        stage.fighterTail = enemy

        enemy.x = SCREEN_WIDTH
        enemy.texture = enemyTexture
        SDL.QueryTexture(enemy.texture, nil, nil, &enemy.w, &enemy.h)
        enemy.y = f32(rand.int32_range(0, SCREEN_HEIGHT-enemy.h))

        enemy.dx = f32(-rand.int_range(2, 6))
        
        enemy.dy = f32(-100 + rand.int31_max(200))
        enemy.dy /= 100

        enemy.side = SIDE_ALIEN
        enemy.health = 1
        enemy.reload = FPS * (rand.int31_max(3)+1)

        enemySpawnTimer = rand.int32_range(30, 90)
      
    }
}

@(private="file")
bulletHitFighter :: proc(bullet : ^Entity) -> bool {

    e : ^Entity

    for e = stage.fighterHead.next; e != nil; e = e.next {

        if e.side != bullet.side && collision(i32(bullet.x), i32(bullet.y), bullet.w, bullet.h, i32(e.x), i32(e.y), e.w, e.h) {

            if e == player {

                playSound(i32(Sound_Effect.PLAYER_DIE), i32(Sound_Channel.PLAYER))

            } else {

                addPointsPod(e.x + f32(e.w/2), e.y + f32(e.h/2))

                playSound(i32(Sound_Effect.ALIEN_DIE), i32(Sound_Channel.ANY))
                
                stage.score = stage.score + 1

                highscore = math.max(stage.score, highscore)
            }

            bullet.health = 0
            e.health = 0

            addExplosions(i32(e.x), i32(e.y), 32)

            addDebris(e)

            return true
        }
    }

    return false
}

@(private="file")
resetStage :: proc() {

    entity: ^Entity
    explosion: ^Explosion
    debris: ^Debris
    points: ^Entity

    for stage.fighterHead.next != nil  {

        entity = stage.fighterHead.next
        stage.fighterHead.next = entity.next
        free(entity)    
    }

    for stage.bulletHead.next != nil {

        entity = stage.bulletHead.next
        stage.bulletHead.next = entity.next
        free(entity)
    }

    for stage.explosionHead.next != nil {
        explosion = stage.explosionHead.next
        stage.explosionHead.next = explosion.next
        free(explosion)
    }

    for stage.debrisHead.next != nil {

        debris = stage.debrisHead.next
        stage.debrisHead.next = debris.next
        free(debris)

    }

    for stage.pointsHead.next != nil {

        points = stage.pointsHead.next
        stage.pointsHead.next = points.next
        free(points)

    }

    stage = Stage{}

    stage.bulletTail = &stage.bulletHead
    stage.fighterTail = &stage.fighterHead
    stage.explosionTail = &stage.explosionHead
    stage.debrisTail = &stage.debrisHead
    stage.pointsTail = &stage.pointsHead

    initPlayer()

    initStarField()

    enemySpawnTimer = 0

    stageResetTimer = FPS * 3

    stage.score = 0
}

@(private="file")
fireAlienBullet :: proc(e : ^Entity) {

    bullet : ^Entity

    bullet = new(Entity)
    stage.bulletTail.next = bullet
    stage.bulletTail = bullet

    bullet.x = e.x
    bullet.y = e.y
    bullet.health = 1
    bullet.texture = alienBulletTexture
    bullet.side = SIDE_ALIEN
    SDL.QueryTexture(bullet.texture, nil, nil, &bullet.w, &bullet.h)

    bullet.x += f32(e.w / 2) - f32(bullet.w / 2)
    bullet.y += f32(e.h / 2) - f32(bullet.h / 2)

    calcSlope(i32(player.x) + (player.w / 2), i32(player.y) + (player.h / 2), i32(e.x), i32(e.y), &bullet.dx, &bullet.dy)

    bullet.dx *= ALIEN_BULLET_SPEED
    bullet.dy *= ALIEN_BULLET_SPEED

    e.reload = rand.int31_max(FPS) * 2
}

@(private="file")
clipPlayer :: proc() {

    if player != nil {

        if player.x < 0 {

            player.x = 0
        }

        if player.y < 0 {

            player.y = 0
        }

        if player.x > SCREEN_WIDTH / 2 {

            player.x = SCREEN_WIDTH / 2
        }

        if i32(player.y) > SCREEN_HEIGHT - player.h {

            player.y = f32(SCREEN_HEIGHT - player.h)
        }
    }
}

@(private="file")
doExplosions :: proc() {

    explosion, prev: ^Explosion

    prev = &stage.explosionHead

    for explosion = stage.explosionHead.next; explosion != nil; explosion = explosion.next {

        explosion.x += explosion.dx
        explosion.y += explosion.dy

        explosion.a -= 1
        if explosion.a <= 0 {
            if explosion == stage.explosionTail {
                stage.explosionTail = prev
            }

            prev.next = explosion.next
            free(explosion)
            explosion = prev
        }
        prev = explosion
    }    
}

@(private="file")
doDebris :: proc() {

    debris, prev: ^Debris

    prev = &stage.debrisHead

    for debris = stage.debrisHead.next; debris != nil; debris = debris.next {

        debris.x += debris.dx
        debris.y += debris.dy

        debris.dy += 0.5

        debris.life -= 1
        if debris.life <= 0 {

            if debris == stage.debrisTail {
                stage.debrisTail = prev
            }

            prev.next = debris.next
            free(debris)
            debris = prev
        }
        prev = debris
    }
}

@(private="file")
doPointsPods :: proc() {

    entity, prev : ^Entity

    prev = &stage.pointsHead

    for entity = stage.pointsHead.next; entity != nil; entity=entity.next {

        if entity.x < 0 {

            entity.x = 0
            entity.dx = -entity.dx            

        }

        if i32(entity.x) + entity.w > SCREEN_WIDTH {

            entity.x = f32(SCREEN_WIDTH - entity.w)
            entity.dx = -entity.dx

        }

        if entity.y < 0 {

            entity.y = 0
            entity.dy = -entity.dy

        }

        if i32(entity.y) + entity.h  > SCREEN_HEIGHT {

            entity.y = f32(SCREEN_HEIGHT - entity.h)
            entity.dy = -entity.dy

        }

        entity.x += entity.dx
        entity.y += entity.dy

        if player != nil &&  collision(i32(entity.x), i32(entity.y), entity.w, entity.h, i32(player.x), i32(player.y), player.w, player.h) {

            entity.health = 0

            stage.score += 1

            highscore = math.max(stage.score, highscore)

            playSound(i32(Sound_Effect.POINTS), i32(Sound_Channel.POINTS))

        }

        entity.health -= 1

        if entity.health <= 0 {

            if entity == stage.pointsTail {

                stage.pointsTail = prev
            }
            
            prev.next = entity.next
            free(entity)
            entity = prev

        }

        prev = entity

    }

}

@(private="file")
addExplosions :: proc(x, y, num: i32) {

    explosion: ^Explosion
    
    for i : i32 = 0; i < num; i=i+1 {

        explosion = new(Explosion)

        stage.explosionTail.next = explosion
        stage.explosionTail = explosion

        explosion.x = f32(x + rand.int31_max(32) - rand.int31_max(32))
        explosion.y = f32(y + rand.int31_max(32) - rand.int31_max(32))

        explosion.dx = f32(rand.int31_max(10) - rand.int31_max(10))
        explosion.dy = f32(rand.int31_max(10) - rand.int31_max(10))

        explosion.dx /= 10
        explosion.dy /= 10

        switch rand.int31_max(4) {
            case 0:
                explosion.r = 255

            case 1:
                explosion.r = 255
                explosion.g = 128

            case 2:
                explosion.r = 255
                explosion.g = 255
            case:
                explosion.r = 255
                explosion.g = 255
                explosion.b = 255
        }
        explosion.a = u8(rand.int31_max(FPS) * 3)
    }
}

@(private="file")
addDebris :: proc(entity: ^Entity) {

    debris : ^Debris
    x, y, w, h: i32

    w = entity.w / 2
    h = entity.h / 2

    // Quarter the entity to throw four pieces of debris.
    for y = 0; y <= h; y += h {

        for x = 0; x <= w; x += w {

            debris = new(Debris)

            stage.debrisTail.next = debris
            stage.debrisTail = debris

            debris.x = entity.x + f32(entity.w / 2)
            debris.y = entity.y + f32(entity.h / 2)
            
            debris.dx = f32(rand.int31_max(5) - rand.int31_max(5))
            debris.dy = -f32(5 + rand.int31_max(12))
            debris.life = FPS * 2
            debris.texture = entity.texture

            debris.rect.x = x
            debris.rect.y = y
            debris.rect.w = w
            debris.rect.h = h
        } 
    }
}

@(private="file")
addPointsPod :: proc(x, y: f32) {

    entity := new(Entity)

    stage.pointsTail.next = entity
    stage.pointsTail = entity

    entity.x = x
    entity.y = y
    entity.dx = f32(-rand.int31_max(5))
    entity.dy = f32(rand.int31_max(5) - rand.int31_max(5))
    entity.health = FPS * 10
    entity.texture = pointsTexture

    SDL.QueryTexture(entity.texture, nil, nil, &entity.w, &entity.h)

    entity.x -= f32(entity.w/2)
    entity.y -= f32(entity.h/2)
}

@(private="file")
drawFighters :: proc() {
    entity: ^Entity
    for entity = stage.fighterHead.next; entity != nil; entity = entity.next {
        blit(entity.texture, i32(entity.x), i32(entity.y))
    }
}

@(private="file")
drawBullets :: proc() {

    for b := stage.bulletHead.next; b != nil; b = b.next {
            blit(b.texture, i32(b.x), i32(b.y))
    }
}

@(private="file")
drawDebris :: proc() {

    debris: ^Debris

    for debris = stage.debrisHead.next; debris != nil; debris = debris.next {

        blitRect(debris.texture, &debris.rect, i32(debris.x), i32(debris.y))
    }
}

@(private="file")
drawExplosions :: proc() {

    explosion : ^Explosion

    SDL.SetRenderDrawBlendMode(app.renderer, SDL.BlendMode.ADD)
    SDL.SetTextureBlendMode(explosionTexture, SDL.BlendMode.ADD)

    for explosion = stage.explosionHead.next; explosion != nil; explosion = explosion.next {

        SDL.SetTextureColorMod(explosionTexture, explosion.r, explosion.g, explosion.b)
        SDL.SetTextureAlphaMod(explosionTexture, explosion.a)

        blit(explosionTexture, i32(explosion.x), i32(explosion.y));
    }

    SDL.SetRenderDrawBlendMode(app.renderer, SDL.BlendMode.NONE)
}

@(private="file")
drawHud :: proc() {

    drawText(10, 10, 255, 255, 255, Text_Position.LEFT, "SCORE: %03d", stage.score)

    if stage.score < highscores.highscore[0].score {

        drawText(SCREEN_WIDTH-10, 10, 255, 255, 255, Text_Position.RIGHT, "HIGH SCORE: %03d", highscores.highscore[0].score)

    } else {

        drawText(SCREEN_WIDTH-10, 10, 0, 255, 0, Text_Position.RIGHT, "HIGH SCORE: %03d", stage.score)

    }
}

@(private="file")
drawPointsPods :: proc() {

    entity : ^Entity

    for entity = stage.pointsHead.next; entity != nil; entity = entity.next {

        if entity.health > FPS * 2 || entity.health % 12 < 6 {
            blit(entity.texture, i32(entity.x), i32(entity.y))
        }        
    }
}