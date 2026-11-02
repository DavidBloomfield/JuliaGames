#=
increment x +=1
[ st    status   st -m status of manifest
[  rm remove package
 readdir("..\\GameZero")

Project.toml   - packages
Manifest.toml  - The manifest file is an absolute record of the state of the packages in the environment. It includes exact information about (direct and indirect) dependencies of the project

repl   read, eval, print, loop

music needs to be in music

https://docs.juliahub.com/GameZero/tTDGf/0.3.1/
https://github.com/aviks/GameZero.jl/blob/master/src/screen.jl
need to know where spaceships are so row and col should be x and y
Do the same with ship 
Rect doent use position.x - uses x and y
sequence of keyboard tests important as cannot fire when moving
using Images
img_square = imresize(img_source, (224, 224))
List of valid keys  https://www.libsdl.org/release/SDL-1.2.15/docs/html/sdlkey.html

png Aliens  https://www.cleanpng.com/png-clip-art-portable-network-graphics-cartoon-image-a-7319881/download-png.html


need another approach for left to right length
    make ship explosion last more frames
add lives to aliens
 bug - if shot reverses direction because .img1 position is still at 0.  
 - change picture based on life 
 alien1 lives 1 img jittery
implement shield

to do
- parametering everything

- implement spaceship with sound
- implement fast bomb
=#

using Colors
using Dates
using Random
using StatsBase
using Logging

WIDTH = 1500
HEIGHT = 600

BACKGROUND = colorant"black"
ALIENOFFSETINCREMENT = WIDTH/300
MARGIN = 40
MARGINTOP = 50
BONUSSHIPINCREMENTX = floor(ALIENOFFSETINCREMENT * 1.3)
SPACESHIPSPEED = floor(ALIENOFFSETINCREMENT * 1.8)
LASERSPEED = ALIENOFFSETINCREMENT * 3
BOMBSPEED = ALIENOFFSETINCREMENT *2
MAXNUMBEROFBULLETS = 4
FIRECOOLDOWN = .5
BOMBCOOLDOWN = .2
MAXNUMBEROFBOMBS = 10
BOMBSEACHFRAME = 2
GAMESTATES = ["start", "play", "end"]
SHIELDCOOLOFFTIME = 10
SHIELDACTIVATIONTIME = 2

play_sound("explosionSmall.mp3")
play_sound("laserSmall.wav")

mutable struct Alien
    img1::Actor 
    lives::Int
    y::Int
    x::Int
end

mutable struct Ship
    img1::Actor # ship
    img2::Actor # shild
    lives::Int64
end

mutable struct DispText
    txt::Actor #Interesting
    t::DateTime
    d::Int64
end

global_logger(ConsoleLogger(stderr, Logging.Debug))

SpaceShip = Ship(Actor("ship_pic_1.png"), 
                Actor("shield70.png"),
                3)


BonusShip = Alien(Actor("Spaceship1.png"),
                    1,1,WIDTH - MARGIN )   # lives, row, x

ex = Actor("explosion_1.png")

shieldIndicatortxt = TextActor("Shield Ready", "moonhouse")
shieldIndicatortxt.pos = (10,10)
shieldIndicator = Circle(shieldIndicatortxt.position.w + 30,20,10)

function initialiseNewGame()
    global left2right = true
    global aliens=[]
    global shipLasers=[]
    global alienOffsetx = 0
    global alienOffsety = 0
    global bonusShipStartx = WIDTH - MARGIN
    global bonusShip = false
    global timeLastFrame = time()
    global tickPause = 0
    global flipImgage = true
    global gameRun = true # set game state
    global lastFireTime = now()
    global lastbombTime = now()
    global bombs = []
    global score = 0
    global gameState = GAMESTATES[2]
    global stage = 0 # level
    global bol_directionchange = false
    global TextToDisplay = []
    global shipExploding = false
    global activateShield = false
    global lastShieldTime = now()


    ####Levels#################################################
    global levels = 
    [
        [    
        [2,1,1]
        ],
        
        [    
        [3,1,1,1]
        ],

        [    
        [4,1,1,1]
        ],

        [    
        [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [2,1,1,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,1,1],
        [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
        ]
    ]



    schedule_once(startBonusShip, returnRandomTime())

    SpaceShip.img1.position.x = WIDTH/2
    SpaceShip.img1.position.centery = HEIGHT - 50
    SpaceShip.img2.position.centery = HEIGHT - 50
end


function show(A::Alien)
    println("row is $(A.y)  and column is $(A.x)")
end



function loadLevels(level)
    row = 0
   
    for z in 1:length(level)
        for y in 1:level[z][1]
            row +=1
            for x in 2:length(level[z])
                if level[z][x] == 1
                    newalien = Alien(
                            Actor("alien1-1lives-s1.png"),
                            2,row,x)
                                
                    push!(aliens, newalien)
                elseif level[z][x] == 2
                    newalien = Alien(
                        Actor("alien2-1lives-s1.png"),
                        1,row,x)
                            
                        push!(aliens, newalien)

                end
            end
        end
    end
    
end

function returnRandomTime()
    return rand(20:60)
end

function startBonusShip()
    global bonusShipStartx, bonusShip
    bonusShipStartx = WIDTH -MARGIN
    BonusShip.x =  bonusShipStartx
    

    bonusShip = true
    play_music("ufo_lowpitch.wav")

end



initialiseNewGame()


function layerCompleted()
    global aliens, stage, levels, TextToDisplay, alienOffsetx, alienOffsety


     if length(aliens) == 0 # Has all aliens been shot
        stage +=1 
        loadLevels(levels[stage])
        alienOffsetx = 0
        alienOffsety = 0
        # display level
        txtLevel = TextActor("Level $(stage)", "moonhouse")
        txtLevel.pos = (WIDTH/2- txtLevel.w/2 ,HEIGHT/2)
        newtxt = DispText(txtLevel, now(), 2000)
        push!(TextToDisplay, newtxt)
    end

end

function bonusShipUpdate()
    global bonusShip, score
    BonusShip.img1.position.x =  BonusShip.x
    BonusShip.img1.position.y =  MARGINTOP/2
    BonusShip.img1.image = flipImgage ? "Spaceship1.png" : "Spaceship2.png"
    BonusShip.x -= BONUSSHIPINCREMENTX
    if BonusShip.x < MARGIN
        bonusShip = false
        schedule_once(startBonusShip, returnRandomTime())
        play_music("ufo_lowpitch.wav", 1)
    end
    collisionBonusShip = [collide(sL,BonusShip.img1) for sL in shipLasers]
    if (1 in collisionBonusShip)    
            idx = findall(x->x ==1, collisionBonusShip)
            deleteat!(shipLasers,idx[1])
            BonusShip.img1.image = "explosion_1.png"
            play_music("explosionSmall.mp3", 1)
            score +=100
            bonusShip = false
            schedule_once(startBonusShip, returnRandomTime())

    end


end



function draw(g::Game)
    global aliens, alienOffsetx, alienOffsety, left2right, timeLastFrame, tickPause, MARGIN, ALIENOFFSETINCREMENT, flipImgage, 
        SpaceShip, shipLasers,LASERSPEED, ex, score, lastbombTime, bombs, gameState, GAMESTATES, bol_directionchange, TextToDisplay, shipExploding, stage, 
        activateShield, bonusShip
   
    layerCompleted()     # is layer completed

    #draw bonusShip
    if bonusShip
      
        bonusShipUpdate()
        draw(BonusShip.img1)
    end
   
    updateAlien()   # update aliens
    for a in aliens
        if a.lives ≠ 0
            draw(a.img1)
        else
            ex.pos = a.img1.pos
            filter!(x->x != a, aliens)
            draw(ex)
            play_sound("explosionSmall.mp3")
            score +=10
        end
    end

    #draw ship
    if gameState == "play"
        draw(activateShield == false ? SpaceShip.img1 : SpaceShip.img2) # draw ship or shield
    end

    #draw Ship shipLaser  
    if length(shipLasers) > 0   # tried to use truthiness
        for sL in shipLasers
            draw(sL, colorant"red", fill=true)
            sL = updateSL(sL)
           
        end
    end

    if length(bombs) > 0
        for b in bombs
            draw(b, colorant"blue", fill=true)
            b = updateBomb(b)
           
        end
    end

    if shipExploding
        ex.position.x = SpaceShip.img1.position.x
        ex.position.y = SpaceShip.img1.position.y
        draw(ex)

    end


    if length(TextToDisplay) > 0
        for TA in TextToDisplay
            if Millisecond(now()-TA.t).value < TA.d
                draw(TA.txt)
                
            else
                filter!(x->x !=TA, TextToDisplay)
            end
        end
    end
    txt1 = TextActor("Score: $score","moonhouse")
    txt1.pos = (1300,50)
    draw(txt1)
    draw(shieldIndicatortxt)
    indicatorColour = Millisecond(now()-lastShieldTime).value > SHIELDCOOLOFFTIME*1000 && activateShield== false * 1000 ? RGB(0,1,0) : RGB(1, 0 ,0)
    draw(shieldIndicator, indicatorColour, fill=true)
end


function updateSL(sL)
    global shipLasers, aliens
    sL.y -= LASERSPEED
    if sL.y < 0 
        filter!(x -> x != sL, shipLasers)
    end
    collisionL1 = [collide(sL,AL.img1) for AL in aliens]
    if (1 in collisionL1)    #|| or
        idx = findall(x->x ==1, collisionL1)
        filter!(x -> x != sL, shipLasers)
        aliens[idx[1]].lives -= 1   # reduce life by one
        
    end 
    return sL
end

function updateBomb(b)
    global bombs, SpaceShip, TextToDisplay, activateShield, gameState, GAMESTATES, shipExploding
    b.y +=BOMBSPEED
    if b.y > HEIGHT
        filter!(x->x !=b, bombs)
        @debug"number of bombs $(length(bombs))"
    end
    if collide(SpaceShip.img1, b) && length(TextToDisplay) == 0  && activateShield == false # bit mean to lose another life if you have just lost one
        filter!(x->x !=b, bombs)
        shipExploding = true
        schedule_once(ceaseShipExploding, 1)
        play_sound("explosion.mp3")
        SpaceShip.lives -= 1
        if SpaceShip.lives > 0
            TA = TextActor("Life Lost!!!! Only $(SpaceShip.lives)  Remaining","moonhouse")
            TA.pos = (WIDTH/2-TA.w/2 ,HEIGHT/2)
            newtxt = DispText(TA, now(), 2000)
            push!(TextToDisplay, newtxt)

        else
            TA = TextActor("Game Over.  Thanks for Playing","moonhouse")
            TA.pos = (WIDTH/2-TA.w/2 ,HEIGHT/2)
            newtxt = DispText(TA, now(), 2000)
            push!(TextToDisplay, newtxt)
            schedule_once(endGame, 2)
            gameState = GAMESTATES[3]
        end

    end
    return b
end


function updateAlien()
    global timeLastFrame, flipImgage, tickPause, alienOffsetx, alienOffsety, bol_directionchange, left2right 
   
    elapsed_time = time()-timeLastFrame
    timeLastFrame = time()
    xpos = 20
    aliensToBomb = Dict()# contains lowest alien in column.  key is column value is row
    #draw aliens
    
    for a in aliens

        
        if haskey(aliensToBomb, a.x)  # find lowest aliens.  Is this a column which exists in the dictionary a.x is the column
            if a.y > aliensToBomb[a.x]  # if a.y row is greater row in dict then replace value with new row
                aliensToBomb[a.x] = a.y 
            end
        else
            aliensToBomb[a.x] = a.y  # column doesnt exist, create a new key pair
        end
    
        #switch directions
    
        if a.img1.position.x > WIDTH - (2* MARGIN)
            left2right = false
            bol_directionchange = true
        elseif a.img1.position.x < (2* MARGIN)
            left2right = true
            bol_directionchange = true

        end

    
    
        a.img1.position.x = xpos + a.x * MARGIN + alienOffsetx
        a.img1.position.y = a.y * MARGIN  + alienOffsety

        # draw aliens
        if flipImgage
                a.img1.image = a.lives == 1 ? "alien1-1lives-s1.png" : "alien1-2lives-s1.png"
            
        else
                a.img1.image = a.lives == 1 ? "alien1-1lives-s2.png" : "alien1-2lives-s2.png"
        end
        
        
        
    end
    left2right ? alienOffsetx +=ALIENOFFSETINCREMENT : alienOffsetx -=ALIENOFFSETINCREMENT
    if bol_directionchange 
        alienOffsety += ALIENOFFSETINCREMENT
        bol_directionchange = false
    end
    
    if Millisecond(now()-lastbombTime).value > BOMBCOOLDOWN * 1000 # has minimum time elsapsed since last alien bomb

        idx = collect(keys(aliensToBomb))
        val = collect(values(aliensToBomb))
        normalised_weights = val ./ sum(val) # lower aliens to be more likely to bomb
        random_itemX = sample(idx, Weights(normalised_weights), BOMBSEACHFRAME)
        @debug"x is $random_itemX and xdx is $(idx)  "
       
        for x in random_itemX
            randAlienToBomb = aliensToBomb[x], x  #y,x
            fireAlienBomb(xpos + randAlienToBomb[2] *MARGIN +alienOffsetx, (randAlienToBomb[1]+1) * MARGIN  + alienOffsety)
        end
    end

    if elapsed_time < 1/20
        tickPause += 1/80
    else
        tickPause > 1/40 ? tickPause -= 1/80 : tickPause
    end
    sleep(tickPause)
    flipImgage =!flipImgage

end

function update(g::Game)
    global SpaceShip, gameRun, SPACESHIPSPEED, lastFireTime, FIRECOOLDOWN, activateShield, SHIELDACTIVATIONTIME, lastShieldTime
    if gameRun # check if game has ended
       
           
            if g.keyboard.RIGHT
                if SpaceShip.img1.position.centerx < WIDTH - MARGIN 
                    SpaceShip.img1.position.centerx +=SPACESHIPSPEED
                    SpaceShip.img2.position.centerx = SpaceShip.img1.position.centerx # move shield
                end
        
            elseif g.keyboard.LEFT
                if SpaceShip.img1.position.centerx > MARGIN 
                    SpaceShip.img1.position.centerx -=SPACESHIPSPEED
                    SpaceShip.img2.position.centerx = SpaceShip.img1.position.centerx # move shield
                end

            elseif g.keyboard.ESCAPE 
                exit()
            end

            if g.keyboard.SPACE
                current_time = now()
               
                if Millisecond(current_time-lastFireTime).value > FIRECOOLDOWN * 1000 && activateShield == false
                    fireShipLaser(SpaceShip.img1.position.centerx, SpaceShip.img1.position.y)
                    play_sound("laserSmall.wav")
                end
            end


            if g.keyboard.S
                current_time = now()

                if Millisecond(current_time-lastShieldTime).value >SHIELDCOOLOFFTIME * 1000
                    activateShield = true
                    schedule_once(deactivateShield, SHIELDACTIVATIONTIME)
                    play_sound("shield2s.mp3")
                end
            end
    #print(dir)
        end
end


function fireShipLaser(x,y)
    global shipLasers, MAXNUMBEROFBULLETS, lastFireTime
    if length(shipLasers) ≤ MAXNUMBEROFBULLETS
        newLaser = Rect(x-1, y-10,2,10)
        push!(shipLasers,newLaser)
        lastFireTime = now()
    end
end


function fireAlienBomb(x,y)
    global bombs, MAXNUMBEROFBOMBS, lastbombTime
    if length(bombs) ≤ MAXNUMBEROFBOMBS
        newBomb = Rect(x-1, y-10,2,10)
        push!(bombs,newBomb)
        lastbombTime = now()
    end
end

function deactivateShield()
    global activateShield, lastShieldTime
    activateShield = false
    lastShieldTime = now()
end



function endGame()
    exit()
end

function ceaseShipExploding()
    global shipExploding
    shipExploding = false
end