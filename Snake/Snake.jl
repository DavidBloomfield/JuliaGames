#=
Aim to write a complete game using GameZero as learning exercise.  SNAKE.  Not just a partial example
1. Need to improve movement control - because of sleep control feels laggy.  As speed increases, lag improves because sleep value reduced.  Plan is to loop round update with a smaller sleep value say 40 times.  
Bit agricultural but works much better - done
2. Also, wall collision made on a segment that is not displayed.  This is exacipated because segments are quite big.  Plan is to create a double wall and test collision with outer - done  Another solution is rather than 
test for wall collision, test for x,y.  This has the benefit of being more controllable
3. goodApple collision needs to remove apple once it has collided. Currently scoring multiple times - done
4. Need to add bad apple collision - done
5. Need to redraw apples when you eat good apple - done
6. Need to create a game end screen - done - used game_run flag and bypass test for keys and add_segement
7. Vary length and speed. Capture if sleepVal < 0 - done

+ves
1. Although not as good as Python, like ternary operator equivalent - if (sleepVal < 0) 0 else sleepVal end
2. liked inline push - push!(Walls, wTop, wRight, wLeft, wBottom)
3. GameZero implementation of text much easier than pygame 😃
4. List comprehension for collisions worked well
5. Gamezero implementation of draw very simple to use
6. quit() is less of a sledgehammer than exit()

-ves
1. convert float to int doesnt work if float isnt an int which seems to defeat the point
2. There are alot of global variables which I dont like.  This would normally be sorted with class
3. ****Because you run from repl - you cannot seem to use all debuging tools --ve also faff to re-run --ve****
4. Cannot figure out why there is a gap in the bottom right hand side of wall
5. missing end statements not obvious



=#

using Colors

WIDTH = 400
HEIGHT = 600
BACKGROUND=colorant"black"
MARGIN = 20
WALLWIDTH = 5
SNAKESECTION= 6
dir = "L"
snakeLength = 5
score = 0
sleepVal = 0.001
mytick = 40 # because I miss pygame tick
game_run = true

position = [convert(Int64, floor(rand(MARGIN*5:WIDTH-MARGIN*5))), convert(Int64, floor(rand(MARGIN*5:HEIGHT-MARGIN*5)))] # originally pos was a tuple - caused error
s_direction = Dict("U"=> (0,-SNAKESECTION*2), "D"=>(0, SNAKESECTION*2), "L"=>(-SNAKESECTION*2,0), "R"=>(SNAKESECTION*2,0))

#Rect(x,y,width,height)
wTop = Rect(0+MARGIN,0+MARGIN,WIDTH-2*MARGIN,WALLWIDTH)
wRight = Rect(WIDTH-MARGIN, 0+MARGIN,WALLWIDTH, HEIGHT-MARGIN*2) # dont understand !!!
wBottom = Rect(0+MARGIN,HEIGHT-MARGIN,WIDTH-(2 * MARGIN),WALLWIDTH)
wLeft = Rect(0+MARGIN,0+MARGIN,WALLWIDTH,HEIGHT-2*MARGIN)

Walls = []
push!(Walls, wTop, wRight, wLeft, wBottom)

Segment = []
S1 = Circle(position[1], position[2], SNAKESECTION)
push!(Segment, S1)

Apples = []

function add_apple()
    goodApplePos = convert(Int64, floor(rand(MARGIN*2:WIDTH-MARGIN*2))), convert(Int64, floor(rand(MARGIN*2:HEIGHT-MARGIN*2)))
    goodApple = Circle(goodApplePos[1], goodApplePos[2], SNAKESECTION)
    badApple = Circle(convert(Int64, floor(rand(MARGIN*2:WIDTH-MARGIN*2))), convert(Int64, floor(rand(MARGIN*2:HEIGHT-MARGIN*2))), SNAKESECTION)
    return goodApple, badApple
    
end

Apples = add_apple() # add initial apples - List of good and bad

function draw(g::Game)
    global score, sleepVal, game_run, position, dir
   
    for w in Walls # draw walls
        draw(w, colorant"red", fill=true)
    end

    for s in Segment # draw snake
        draw(s, colorant"green", fill=true)
    end 
    #txt = TextActor(string(position[1]) * " " * string(position[2]),"moonhouse")
    #txt.pos = (30,0)
    #draw(txt)
    txt1 = TextActor("Score: $score","moonhouse")
    txt1.pos = (250,0)
    draw(txt1)
    draw(Apples[1], colorant"chartreuse", fill=true)
    draw(Apples[2], colorant"red", fill=true)

    if !game_run
        txt_end1 = TextActor("Game Ended!!", "moonhouse")
        txt_end2 = TextActor("Your score is $score", "moonhouse")
        txt_end1.pos = (100,300)
        txt_end2.pos = (80, 320)
        draw(txt_end1)
        draw(txt_end2)
    end
end




#x,y = pos[1], pos[2]
function update(g::Game)
    global position, dir, sleepVal, mytick, game_run, score
    if game_run # check if game has ended
        for _ =1:if (mytick <0) 0 else mytick end
            if g.keyboard.DOWN   
                dir = "D"
                    
            elseif g.keyboard.UP
                dir = "U"
            elseif g.keyboard.RIGHT
                dir = "R"
        
            elseif g.keyboard.LEFT
                dir = "L"

            end
    #print(dir)
        sleep(if (sleepVal < 0) 0 else sleepVal end) #inline ternary - kept this is because I like it
        end
        add_segment()
   #schedule_once(add_segment, .15) - didt work as I wanted - didnt seemt to create any pause
    else
       
    end
end

function add_segment()
    global position , dir, score, Apples, sleepVal, snakeLength, mytick, game_run
    new_seg = s_direction[dir]
    position[1] += new_seg[1]
    position[2] += new_seg[2]
    #println(position)
    S = Circle(position[1], position[2], SNAKESECTION)
    collisionW = [collide(S, w) for w in Walls]  # collide with walls
    if 1 in collisionW
        #exit()   # horrible
        #quit()
        game_run = false
    end
    collisionS = [collide(S,seg) for seg in Segment] # collide with snake
    if 1 in collisionS
       #quit()
       game_run = false
    end
    if collide(S, Apples[1])
        score += 10
        Apples = add_apple()
        snakeLength += 2
        mytick -= 2
    end

    if collide(S, Apples[2])
        game_run = false
    end
    #println("collisions $(1 in collisions)")
    push!(Segment, S)
    if length(Segment)> snakeLength
        deleteat!(Segment,1)
    end
end


# to run from repl
#using GameZero
#GameZero.rungame("D:\\Data\\Julia\\Games\\Snake\\Snake.jl")