#= Game #2
Aim to write a complete game using GameZero as learning exercise.  Not just a partial example.  This is 2nd program written in Julia
The objective for this game will generate a maze and then create a 3D projection to natigate around
For Maze generation I am using Oreestis Zekai article about Prims randomised algorithm - great article https://github.com/OrWestSide/python-scripts/blob/master/maze.py
For 3D projection I will use raycasting and make use of monkey king youtube tutorial -great video 
Please provide credit if you use my code 
To do
1. Detect end - can detect by y < MARGIN - done
2  Create game end screen - done
3. Change movement to rotate and forward/backward - done
4. Create toggle for maze colour so it can be hidden - done
5. Stop person from going below vertain y value and going out of maze wrong way - done
5. Create raycasting - done
6. Create 3d projection - done
7. create screen to select maze size - 3 phases of game - initialise, play, end -done
8. Create information text - done
9. Change flr to round in returnInt - done
10. Rect.x,y is top left hand - change to centre - done
11. Stop rays casting beyond maze and generating error - done
12. Issue with raycasting and detection of walls - not correct - Shoot me now - I am an idiot. I mixed up rows and cols in raycast/wall detection.  Still not totally resolved. Issue with rect middle and end - done
13. need to be able to visually identify exit.  - done
14. Create max height for 3D walls
15. Create structure of wall (hieght, colour and type) - linked to point 13  - done
16. Tidy global variable into structure
17. Create reward scheme - based on time with penalties for using map and display at the end.  Small issue - counter keeps ticking when game finished -done.  Also assist help count not working v well - done
18. Create Compass - done
19. Wire in create maze so it uses selected size - done
20. Rationalise global variables - use dictionary
21. Make exit criteria a function of height - done



Prims algorithm
1. Start with a grid full of walls
2. Pick a cell, mark it as part of the maze. Add the walls of the cell to the walls of the list
3. While there are walls in the list:
    3.1 Pick a random wall from the list. If only one of the two cells that the wall divides is visited, then:
        3.1.1 Make the wall a passage and mark the unvisited cell as part of the maze
        3.1.2 Add the neighboring walls of the cell to the wall list.
    3.2 Remove the wall from the list

Lessons
1. use ∈ for in 
2. use && for and
3. if you miss an end - debug wont even start - not great for complex flows
4. Julia index starts at 1 not 0 doh only got it wrong about 100 times
5. debuging wasnt easy as programme flow quite complicated
6. Great video frm doggo dot jl about GameZero.  Created a run file - much better. Although do need to activate directory 
7. Nice use of collision shapes for smooth movement
8. Kept getting dir error until created project dir with activate Cltr Shft P   in REPL cd("Games") in pkg activate .
9. Got strange Bug - couldnt move right or down.  Cause was when using speed 1 sin or cos is always < 1 and therefore gets rounded down.  Increased speed.  Need to change flr to round
10.  Cntl L clear repl screen
11. Lots of properties GZMazeWalls[1].centerx      https://github.com/aviks/GameZero.jl/blob/master/src/screen.jl
getPos(::Val{:left}, s::Rect) = s.x
getPos(::Val{:right}, s::Rect) = s.x+s.w
getPos(::Val{:top}, s::Rect) = s.y
getPos(::Val{:bottom}, s::Rect) = s.y+s.h
getPos(::Val{:pos}, s::Rect) = getPos(Val(:topleft), s)
getPos(::Val{:topleft}, s::Rect) = (s.x, s.y)
getPos(::Val{:topright}, s::Rect) = (s.x+s.w, s.y)
getPos(::Val{:bottomleft}, s::Rect) = (s.x, s.y+s.h)
getPos(::Val{:bottomright}, s::Rect) = (s.x+s.w, s.y+s.h)
getPos(::Val{:center}, s::Rect) = (s.x+s.w/2, s.y+s.h/2)
getPos(::Val{:centerx}, s::Rect) = s.x+s.w/2
getPos(::Val{:centery}, s::Rect) =  s.y+s.h/2
getPos(::Val{:centerleft}, s::Rect) = (s.x, s.y+s.h/2)
getPos(::Val{:centerright}, s::Rect) = (s.x+s.w, s.y+s.h/2)
getPos(::Val{:bottomcenter}, s::Rect) = (s.x+s.w/2, s.y+s.h)
getPos(::Val{:topcenter}, s::Rect) = (s.x+s.w/2, s.y)
12. Try Pyzero techniques - they will probably work - ie running update with dt
https://pygame-zero.readthedocs.io/en/stable/resources.html
13. sequence is draw update repeat
15. Often after errors have to re activate from REPL - quite annoying
16. fisheyeThus to remove the viewing distortion, the resulting distance obtained from equations in Figure 17 must be multiplied by cos(BETA); where BETA is the angle of the ray that is being cast relative to the viewing angle. Not perfect
On the figure above, the viewing angle (ALPHA) is 90 degrees because the player is facing straight upward. Because we have 60 degrees field of view, BETA is 30 degrees for the leftmost ray and it is -30 degrees for the rightmost ray.
17. instad of colorant"..." which is quite fussy and doesnt allow string concatination, you can use colour - RGB(0<float<1,(0<float<1,(0<float<1 )
18. txt.pos = ().  I keep forgetting the equals
19. placed a more discriminatory condition after a less discriminatory condition and ofcouse it dint trigger.  
20 too many global variables



=#


# to run from repl
#using GameZero
#GameZero.rungame("D:\\Data\\Julia\\Games\\juliaMaze\\JuliaMaze.jl")


# Maze Generator
using Colors
using Crayons




unvisited = 'u'
wall = "❎"
cell = "⬜"
maze_end = "O"

maze = []
#Raycasting GameZero
WIDTH = 1500
HEIGHT = 900
BACKGROUND=colorant"black"
MARGIN2D = 800
MARGIN = 20
WALLWIDTH = 5
TextToDisplay = ""



#Observer global pos
start_x = 0
start_y = 20
player_dir = 0 #π
speed = 1
FOV = π/3
RAYS = 240
RAY_ANGLE_INCREMENT = FOV/RAYS
SCALE = (WIDTH/2)/RAYS
ray_coll = []


ThreeDWallsDetails_coll = []
MapVisible = false
game_duration = nothing

#game_run = true
#initialise_game = false # to create initial game setup mod

space_pressed_last = false
lastkey = nothing

assist_count = 0
game_phases = ["Initialise", "Play", "End"]
game_phase = game_phases[1]
maze_level = 5



mutable struct wallProjection
    wall_rect
    wall_colour::Int64
    wall_type::String
end

function create_Empty_Maze(width::Int64, height::Int64)
    for i in 1:height
        line = []
        for j in 1:width
            push!(line, unvisited)
        end
        push!(maze, line)
    end
return maze
end

function print_Maze(maze) #DB
    for i in 1:length(maze)
        for j in 1:length(maze[1])
            if maze[i][j]==unvisited 
               print(Crayon(foreground = :white), unvisited)
                elseif maze[i][j]==cell
                print(Crayon(foreground = :green), cell)
                elseif maze[i][j]==wall
                print(Crayon(foreground = :red), wall)
                #elseif maze[i][j]==wallChar
                #print(Crayon(foreground = :red), wallChar)
                elseif maze[i][j]==maze_end
                print(Crayon(foreground = :yellow), maze_end)

            end
        end
        println("")
    end  
end

function countSurroundCells(rand_wall)#DB
    count_cells = 0
    if (maze[rand_wall[1]-1][rand_wall[2]] == cell)
        count_cells +=1
    end
    if (maze[rand_wall[1]+1][rand_wall[2]] == cell)
        count_cells +=1
    end
    if (maze[rand_wall[1]][rand_wall[2]-1] == cell)
        count_cells +=1
    end
    if (maze[rand_wall[1]][rand_wall[2]+1] == cell)
        count_cells +=1
    end
    return count_cells

end

function randTop(rand_wall)#DB
    if (rand_wall[1] != 1)    # top x-1
        if (maze[rand_wall[1]-1][rand_wall[2]] != cell)
            maze[rand_wall[1]-1][rand_wall[2]] = wall
        end
        if ([rand_wall[1]-1, rand_wall[2]] ∉ walls)
            push!(walls, [rand_wall[1]-1, rand_wall[2]])
        end
    end

end

function randBottom(rand_wall)#DB
    if (rand_wall[1] != height)    # bottom x+1
        if (maze[rand_wall[1]+1][rand_wall[2]] != cell)
            maze[rand_wall[1]+1][rand_wall[2]] = wall
        end
        if ([rand_wall[1]+1, rand_wall[2]] ∉ walls)
            push!(walls, [rand_wall[1]+1, rand_wall[2]])
        end
    end

end

function randLeft(rand_wall)#DB
    if (rand_wall[1] != 1)    # left 
        if (maze[rand_wall[1]][rand_wall[2]-1] != cell)
            maze[rand_wall[1]][rand_wall[2]-1] = wall
        end
        if ([rand_wall[1], rand_wall[2]-1] ∉ walls)
            push!(walls, [rand_wall[1], rand_wall[2]-1])
        end
    end

end

function randRight(rand_wall)#DB
    if (rand_wall[1] != width)    # right y+1
        if (maze[rand_wall[1]][rand_wall[2]+1] != cell)
            maze[rand_wall[1]][rand_wall[2]+1] = wall
        end
        if ([rand_wall[1], rand_wall[2]+1] ∉ walls)
            push!(walls, [rand_wall[1], rand_wall[2]+1])
        end
    end

end

function returnInt(val)::Int64
    #println("$val,  $(Int64(round(val)))")
    return Int64(round(val))
end



#height = 7
#width = 7
#maze = create_Maze(height,width)
#print_Maze(maze) 
function prim()
    global height, width, maze, walls, wall, cell, unvisited
    starting_height = rand(2:height-1)
    starting_width = rand(2:width-1)


    #Step 2 Mark it as cell and add surrounding walls to the list
    maze[starting_height][starting_width] = cell
    walls = [] # contains co-ordinates of walls
    push!(walls, [starting_height - 1, starting_width], [starting_height, starting_width - 1], [starting_height, starting_width + 1],[starting_height + 1, starting_width])
    # Denote walls in maze
    maze[starting_height-1][starting_width] = wall
    maze[starting_height][starting_width - 1] = wall
    maze[starting_height][starting_width + 1] = wall
    maze[starting_height + 1][starting_width] = wall

    while !isempty(walls)
        rand_wall = walls[rand(1:length(walls))] # pick randon wall from walls list of 4

        if (rand_wall[2] !=1) # vheck wall is not on left
            if (maze[rand_wall[1]][rand_wall[2]-1] == unvisited && maze[rand_wall[1]][rand_wall[2]+1] == cell)
                #how many surrounding cells
                surround_cells =  countSurroundCells(rand_wall)
                if surround_cells < 2
                    #3.1.1 make wall a passage
                    maze[rand_wall[1]][rand_wall[2]] = cell

                    # Create new walls and add to list
                    randTop(rand_wall)
                    randBottom(rand_wall)
                    randLeft(rand_wall)

                end
                # Delete wall
                for w in walls
                    if (w[1] == rand_wall[1] && w[2] == rand_wall[2])
                        deleteat!(walls, findall(x->x==w, walls))
                    end
            
                end

                continue
            end
        end



        if (rand_wall[1] !=1) # check wall is not on top
            if (maze[rand_wall[1]-1][rand_wall[2]] == unvisited && maze[rand_wall[1]+1][rand_wall[2]] == cell)
                #how many surrounding cells
                surround_cells =  countSurroundCells(rand_wall)
                if surround_cells < 2
                    #3.1.1 make wall a passage
                    maze[rand_wall[1]][rand_wall[2]] = cell

                    # Create new walls and add to list
                    randTop(rand_wall)
                    randLeft(rand_wall)
                    randRight(rand_wall)
            
                end
                # Delete wall
                for w in walls
                    if (w[1] == rand_wall[1] && w[2] == rand_wall[2])
                        deleteat!(walls, findall(x->x==w, walls))
                    end
                end

                continue
            end
        end

        if (rand_wall[1] !=height) # check wall is not on bottom 
            if (maze[rand_wall[1]+1][rand_wall[2]] == unvisited && maze[rand_wall[1]-1][rand_wall[2]] == cell)
                #how many surrounding cells
                surround_cells =  countSurroundCells(rand_wall)
                if surround_cells < 2
                    #3.1.1 make wall a passage
                    maze[rand_wall[1]][rand_wall[2]] = cell

                    # Create new walls and add to list
                
                    randBottom(rand_wall)
                    randLeft(rand_wall)
                    randRight(rand_wall)
                end
                # Delete wall
                for w in walls
                    if (w[1] == rand_wall[1] && w[2] == rand_wall[2])
                        deleteat!(walls, findall(x->x==w, walls))
                    end
                end

                continue
            end
        end

        if (rand_wall[2] !=width) # check wall is not on right
            if (maze[rand_wall[1]][rand_wall[2]+1] == unvisited && maze[rand_wall[1]][rand_wall[2]-1] == cell)
                #how many surrounding cells
                surround_cells =  countSurroundCells(rand_wall)
                if surround_cells < 2
                    #3.1.1 make wall a passage
                    maze[rand_wall[1]][rand_wall[2]] = cell

                    # Create new walls and add to list
                
                    randRight(rand_wall)
                    randBottom(rand_wall)
                    randLeft(rand_wall)
                end
                
                # Delete wall
                for w in walls
                    if (w[1] == rand_wall[1] && w[2] == rand_wall[2])
                        deleteat!(walls, findall(x->x==w, walls))
                    end
                end
                
                continue
            end
            
        end
        # Delete wall if captured by continue
        for w in walls
            if (w[1] == rand_wall[1] && w[2] == rand_wall[2])
                deleteat!(walls, findall(x->x==w, walls))
            end
        end
        
    end
    # Mark the remaining unvisited cells as walls
    for i in 1:height
        for j in range(1, width)
            if (maze[i][j] == unvisited)
                maze[i][j] = wall
            end
        end
    end

    # Set  exit
    for i in 1:width#DB - end
        if (maze[2][i] == cell)
            maze[1][i] = maze_end
            global maze_end_co_ord = (1,i)
            break
        end
    end
    # Set entrance
    for i in width: -1:1#DB - start
        if (maze[height-1][i] == cell)
            global start_x, square_size
            maze[height][i] = wall
            
            start_x = i 
            break
        end
    end    
end

function mazeStart()
    global GZMazeWalls, start_time, square_size, half_square_size, MAX_DEPTH, GZMazeWalls, GZWallExit, start_y, GZObs, GZOBs_Collision, exit_y
    start_time = time()
    square_size = Int64(floor(HEIGHT/(2 * height)))
    half_square_size = Int64(floor(square_size/2))
    MAX_DEPTH = square_size * height
    exit_y = [200,200,200,200,200,120,120,120,120,110,80,80,80,80,70,40,40,40,30,20,20,20,20,20][height] # set exit y pos by level

    GZMazeWalls = []

    for i = 1:height
        for j in 1:width
            if maze[i][j]==wall
                GZWall = Rect(j*square_size+MARGIN2D, i * square_size + MARGIN, square_size, square_size)
                push!(GZMazeWalls, GZWall)
            end
        end
    end

    GZWallExit =  Rect(maze_end_co_ord[2] *square_size+MARGIN2D, square_size + MARGIN, square_size, square_size) # define exit rect

    start_y = height - 1  # I want to start in the maze
    GZObs = Circle(start_x * square_size + MARGIN2D+half_square_size, start_y * square_size + MARGIN+ half_square_size, 5) # player
    GZOBs_Collision = Circle(start_x * square_size + MARGIN2D+half_square_size, start_y * square_size + MARGIN+ half_square_size, 6) # player collision shape
    #print(GZMazeWalls[1].centerx)
    #println("    startx = $start_x, starty= $start_y")
end

function raycast()
    global player_dir, FOV, RAYS, maze, MAX_DEPTH, square_size, RAY_ANGLE_INCREMENT, ray_coll, TextToDisplay, MARGIN, MARGIN2D, half_square_size, SCALE, HEIGHT, 
    ThreeDWallsDetails_coll, exit_y
    ray_angle = player_dir - FOV/2
    ray_coll = []

    
    ThreeDWallsDetails_coll = []
    for ray in 1:RAYS
        for depth in 1:returnInt(MAX_DEPTH)
            ray_endx, ray_endy = returnInt(GZObs.centerx - sin(ray_angle)* depth), returnInt(GZObs.centery - cos(ray_angle)* depth)
            
                
            #convert x,y to map col and row
            col, row = returnInt((ray_endx - MARGIN2D - half_square_size)/square_size), returnInt((ray_endy - MARGIN-half_square_size)/square_size)
            GZObsCol, GZObsRow = returnInt((GZObs.centerx - MARGIN2D)/square_size), returnInt((GZObs.centery  - MARGIN)/square_size)
            GZObsCol -=1
            col = col < 1 ? 1 : col
            col = col > width ? width : col
            row = row < 1 ? 1 : row    
            row = row > height ? height : row

            if maze[row][col] == wall || maze[row][col] == maze_end
                rayLine = Line(GZObs.centerx, GZObs.centery, ray_endx , ray_endy )
                push!(ray_coll, rayLine)
                player_dir_trunc = round(player_dir,digits=3)
                TextToDisplay = "Obx  is $GZObsCol and Oby  is $(GZObs.y)  Exit is $(exit_y)) depth is $depth    game_phase  $(game_phase)   $(ray_endy)   dir   $(player_dir_trunc)"
                
                colour = maze[row][col] == wall ? returnInt(255/(1+(depth^2)*0.00001)) : -1

                #fix fisheye

                depth *= cos( player_dir - ray_angle)
                
                ThreeDwall_height = returnInt(15000/(depth + 0.0001))<1.75 * height * square_size ? returnInt(15000/(depth + 0.0001)) : returnInt(1.75 * height * square_size) # 1.5 factor

                ThreeDWall = Rect(returnInt(MARGIN + (RAYS-ray)*SCALE), returnInt((HEIGHT/2)-ThreeDwall_height/2), returnInt(SCALE), ThreeDwall_height )
              
                ThreeDWallsDetails_coll_item = wallProjection(ThreeDWall, colour, maze[row][col] == wall ? wall : maze_end ) # wallProjection is Struct
                
                push!(ThreeDWallsDetails_coll, ThreeDWallsDetails_coll_item)
                break

            end

                        
        end
        ray_angle += RAY_ANGLE_INCREMENT 
        
    end

end

function hide_map() # function called by Scheduled_once to hide map after 0.5s
    global MapVisible = false
end



##########################DRAW########################################################################

function draw(g::Game)

    global game_run, TextToDisplay, ray_coll, MARGIN, MARGIN2D, height, width, square_size, SCALE, RAYS, ThreeDWallsDetails_coll, wall, MapVisible, start_time, game_duration, 
            game_phases, game_phase, maze_level
    if game_phase == game_phases[2]# play
        
        if MapVisible
            for GZWall  in GZMazeWalls # draw walls
                draw( GZWall, colorant"yellow")
            end
            draw(GZWallExit,  RGB(1.0, 0.55, 0) ) # draw exit
            draw(GZObs, colorant"red", fill=true) # player
            GZObsLine = Line(GZObs.x, GZObs.y, Int64(floor(GZObs.x - sin(player_dir)*50)), Int64(floor(GZObs.y - cos(player_dir)*10)))
            #draw(GZObsLine, colorant"red")
            draw(GZOBs_Collision, colorant"lightblue") # collision shape
            if length(ray_coll) > 1

                for ray in ray_coll
                    
                    draw(ray, colorant"lightblue") # rays

                end
                
            end
          
            
        end
        
        if length(ThreeDWallsDetails_coll)> 1
            ground = Rect(MARGIN,height*square_size, SCALE*RAYS, height*square_size-MARGIN)
            sky = Rect(MARGIN,MARGIN*3, SCALE*RAYS, height*square_size)
           
            draw(sky, colorant"skyblue", fill=true)
            draw(ground, colorant"gray79", fill=true)

            displayExit = true

            for _val in ThreeDWallsDetails_coll
    
                c =  _val.wall_type == wall ? RGB(_val.wall_colour/255, _val.wall_colour/255,_val.wall_colour/255) : RGB(1.0, 0.55, 0)
                
                draw(_val.wall_rect, c, fill=true)
                
                
                if _val.wall_type ≠ wall && displayExit
                    txtExit = TextActor("Exit", "moonhouse"; color = Int[255,0,0,255])
                    txtExit.pos = ((MARGIN2D-MARGIN)/2, 30)
                    draw(txtExit)
                    displayExit = false
                end
            end  
        end

        #Draw Compass
        compass = Circle(MARGIN2D + WIDTH/4, HEIGHT - 2 * MARGIN, 30)
        compassPointer1 = Line(MARGIN2D + WIDTH/4, HEIGHT - 2 * MARGIN,Int64(floor(MARGIN2D + WIDTH/4 + sin(player_dir)*20)), Int64(floor(HEIGHT - 2 * MARGIN - cos(player_dir)*20)) )
        NCompass = TextActor("N", "moonhouse")
        NCompass.centerx,  NCompass.centery = returnInt(MARGIN2D + WIDTH/4 + sin(player_dir)*30), returnInt(HEIGHT - 2 * MARGIN - cos(player_dir)*30)
        NCompass.angle = returnInt((360/2π)*player_dir)
        draw(compass, colorant"red")
        draw(compassPointer1, colorant"red")
        draw(NCompass)


        #=
        if TextToDisplay ≠ ""
           
            TTD = TextActor(TextToDisplay, "moonhouse")
            TTD.pos = (50,800)
            TTD.width = 100
            draw(TTD)
           
        end
        =#


    

    elseif game_phase == game_phases[1] # initialise game
        #= initialise_game
        1. draw frame 
        2. include instructions
        3. set maze size 
        =#
        # top, bottom, left, right
        Frames = [Rect(MARGIN, MARGIN, WIDTH-MARGIN, MARGIN +WALLWIDTH), Rect(MARGIN, HEIGHT-MARGIN, WIDTH-MARGIN ,HEIGHT-MARGIN +WALLWIDTH), Rect(MARGIN, MARGIN, MARGIN, HEIGHT - MARGIN +WALLWIDTH),
        Rect(WIDTH-MARGIN, MARGIN, WIDTH-MARGIN, HEIGHT - MARGIN+WALLWIDTH)]

        Instructions = [
            "Welcome to the Julia 3D Maze Game",
            "The object of the game is to find the exit as quickly as possible with as little help as possible",
            "The exit is orange.  Pass through the exit to complete the game",
            "To help there is a compass on the bottom right and you can briefly display a 2D maze", 
            "by pressing space bar.  You cannot keep pressing the space bar",
            "Your final score shows how many assists you required",
            "To start the game press either the left or right arrow",
            " ",
            " ",
            "On this page use the Up and Down arrow to alter the maze size from 5 (very easy) to 25 (hard)",
            "and then press space to select",
            " ",
            " ",
            " ",
            " ",
            "When in the maze, press either the left or right arrow to start",
            " ",
            " ",
            "Good Luck"
        ]
    
        for f in Frames
            draw(f, colorant"red", fill=true)
        end
        
        for Instruct in enumerate(Instructions)
            txt = TextActor(Instruct[2],"moonhouse")
            txt.pos=(50,(Int64(Instruct[1]) * 30 + 2 * MARGIN))
            draw(txt)
        end

        txtLevel = TextActor("Maze size is  $(maze_level) ", "moonhouse";
                font_size = 40, color = Int[255,255,255,255])
        txtLevel.pos = (MARGIN2D+3*MARGIN, 12 * 30 + 2 * MARGIN)
        draw(txtLevel)
            

    end
    
    if game_phase == game_phases[3]
        if game_duration == nothing  game_duration = time() - start_time end  # stop timer keep updating
        finTxt = TextActor("You Have Completed The Maze with a time of $(round(game_duration, digits = 1)) and $(assist_count)  helps","moonhouse";font_size = 30)    # ;font_size = 20, color = Int[0,0,0,255]
        finTxt.pos = (80,50)
        draw(finTxt)
        finTxt2 = TextActor("Press X in the corner to quit the game  ",  "moonhouse";
        font_size = 40, color = Int[255,255,255,255])
        finTxt2.pos = (80, 500)
        draw(finTxt2)
    end
end


################################UPDATE#################################################################################
function update(g::Game)
    global game_run, player_dir, speed, TextToDisplay, MapVisible, assist_count, space_pressed_last, game_phases, game_phase, maze_level, lastkey, height, width, exit_y
    #=
    if game_phase == game_phases[2] 
        println(GZObs.y ,exit_y, GZObs.y < exit_y, game_phase, game_phase == game_phases[2] && GZObs.y < exit_y)
    end
    =#

    if game_phase == game_phases[2] && GZObs.y < exit_y
        println("here ", exit_y)
        game_phase = game_phases[3]



    elseif game_phase == game_phases[2] # play 
        
          
            
            if g.keyboard.DOWN
                
          
                #GZOBs_Collision.y -=1
                GZOBs_Collision_Org = (GZOBs_Collision.x, GZOBs_Collision.y) # Save orignal pos incase of collision

                GZOBs_Collision.x, GZOBs_Collision.y = returnInt(GZOBs_Collision.x - sin(player_dir) * -speed), returnInt(GZOBs_Collision.y - cos(player_dir) * -speed)
                GZOBS_Coll = [collide(GZOBs_Collision,GZWall) for GZWall in GZMazeWalls]
                
                if (1 ∉ GZOBS_Coll)
                    #GZObs.y -=1
                    GZObs.x, GZObs.y = returnInt(GZObs.x - sin(player_dir) * -speed), returnInt(GZObs.y - cos(player_dir) * -speed)
                else
                    #println("collision player dir = $player_dir")
                    #GZOBs_Collision.y +=1
                    GZOBs_Collision.x = GZOBs_Collision_Org[1]
                    GZOBs_Collision.y = GZOBs_Collision_Org[2]
                end
                raycast()
                space_pressed_last = false
                    
            elseif g.keyboard.UP
               
                #GZOBs_Collision.y -=1
                GZOBs_Collision_Org = (GZOBs_Collision.x, GZOBs_Collision.y) # Save orignal pos incase of collision

                GZOBs_Collision.x, GZOBs_Collision.y = returnInt(GZOBs_Collision.x - sin(player_dir) * speed), returnInt(GZOBs_Collision.y - cos(player_dir) * speed)
                GZOBS_Coll = [collide(GZOBs_Collision,GZWall) for GZWall in GZMazeWalls]
                
                if (1 ∉ GZOBS_Coll)
                    #GZObs.y -=1
                    GZObs.x, GZObs.y = returnInt(GZObs.x - sin(player_dir) * speed), returnInt(GZObs.y - cos(player_dir) * speed)
                else
                    #println("collision player dir = $player_dir")
                    #GZOBs_Collision.y +=1
                    GZOBs_Collision.x = GZOBs_Collision_Org[1]
                    GZOBs_Collision.y = GZOBs_Collision_Org[2]
                end
                raycast()
                space_pressed_last = false
            elseif g.keyboard.RIGHT
               
               
                player_dir -=0.05
                raycast()
            elseif g.keyboard.LEFT
                
          
                player_dir +=0.05
                raycast()
                space_pressed_last = false
            
            elseif g.keyboard.SPACE
                
                if !space_pressed_last
                    MapVisible = true
                    assist_count +=1
                    space_pressed_last = true
                    schedule_once(hide_map, .5)
                end
                
               
            end
    elseif game_phase == game_phases[1] # game initiation
        if g.keyboard.DOWN && lastkey ≠ g.keyboard.DOWN # fiddly stuff so player needs to prevent repeats
            maze_level = maze_level > 5 ? maze_level - 1 : maze_level
            lastkey = g.keyboard.DOWN
            schedule_once(reset_lastkey, .5)
        elseif g.keyboard.UP && lastkey ≠ g.keyboard.UP
            maze_level = maze_level < 24 ? maze_level + 1 : maze_level
            lastkey = g.keyboard.UP
            schedule_once(reset_lastkey, .5)
        elseif g.keyboard.SPACE 

            height = width = maze_level
            
            MapVisible = false
            global maze = create_Empty_Maze(height,width)
            prim()
            mazeStart()
            game_phase = game_phases[2]
        end
        
   
    end
    
end

function reset_lastkey()
    global lastkey = nothing
end
#=
function on_key_down(g::Game, key)
    global game_run, player_dir, speed, TextToDisplay, MapVisible, assist_count, space_pressed_last
    if key == Keys.SPACE
        if !space_pressed_last
            MapVisible = true
            assist_count +=1
            space_pressed_last = true
            schedule_once(hide_map, 0.5)
        end
    end

end

=#