#=
Game #3
Aim to write a complete game using GameZero as learning exercise.  Not just a partial example.  This is 3rd program written in Julia
Game Objectives - create a wordsearch game which players will have to find spanish words when they are given english words
Learning Objectives
1. Less global variables
2. Use module
3. Try to find way to run debugger on GameZero
4. Improve structure

Please provide credit if you use my code 

Learnings
1. Need to include file with ./   
2. Using . module name
3. Variables accessible via modulename.variable name
4. Function accesses PuzzleGrid.displayGrid(PuzzleGrid.x)
5. Couldnt make TextActor outline work, so will create Rect
6. To change colour of text, had to re-create textActor.  However, this is very slow so need another approach.  Used time().  Plan is to assume white then only 
re-create if another colour required.  This should dramaticall improve time
7. Added timer - text blurry - suspect this is because background not refreshing sufficiently.  Will add rect - fixed
8. Creating TextActor in draw function siginificantly slows down.  Need to find another approach.  Used a timer to only update on each second.  Had to make textActor global
so it could be printed when not updated - otherwise it flickers
9. ***If you pass an empty string to draw TextActor it seems to crash in a very unhelpful way

 ToDo 
 add rewards scheme - timer and display results - done
  Add gamephases and instructions -done
 Add load words by text file - done
 Change so that display doesnt have to be the same as search word (for different languages)
 Add helper



=#


game_include("./PuzzleGrid.jl")

using StatsBase # to allow weighted sampling
using Colors
using DelimitedFiles
using .PuzzleGrid



WIDTH = 800
HEIGHT = 600
BACKGROUND=colorant"black"
MARGIN = 30
MARGINWORDSX = 500
MARGINWORDSY = 200
WALLWIDTH = 5
SIZE = 25
tiles = []
wordsplaced = []
randWords = []
numberOfWordsToGuess = 15
arrDict = [".\\WordSearch\\words\\Dictionary.txt", ".\\WordSearch\\words\\SpanishExample.txt"]


alphabet = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
            'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
alphabetWeights = [0.085, 0.02, 0.045, 0.034, 0.11, 0.018, 0.025, 0.03, 0.075, 0.002, 0.011, 0.055, 0.03, 0.066,
            0.072, 0.031, 0.002, 0.075, 0.057, 0.07, 0.036, 0.01, 0.012, 0.003, 0.018, 0.003]

puzzleSize = 15
game_phases = ["Initialise", "Play", "End"]
game_phase = game_phases[1]
posActText = "row, col"

mutable struct Tile
    txtA
    rect
    searchWord::Bool
    selected::Bool
    revealed::Bool
    txt::Char
end

mutable struct SearchWord
    txtA
    txt::String
    txt2::String
    rect
    found::Bool
end

selecttedTile = nothing
timeAct = nothing
clockTick = time()

#instructions
open(".\\WordSearch\\Instructions.txt") do f
    global instructions = readlines(f)
    
end

#Create WordSearch

startRecDict1 = Rect(MARGIN*3, HEIGHT - 3 * MARGIN, 3 * MARGIN, MARGIN)
startTextADict1 = TextActor("English","bold"; font_size = 20, color = Int[255, 255, 255, 255])
startTextADict1.pos = (MARGIN*3, HEIGHT - 3 * MARGIN)
startRecDict2 = Rect(MARGIN*10, HEIGHT - 3 * MARGIN, 3 * MARGIN, MARGIN)
startTextADict2 = TextActor("Spanish","bold"; font_size = 20, color = Int[255, 255, 255, 255])
startTextADict2.pos = (MARGIN*10, HEIGHT - 3 * MARGIN)

function createTile(r, c, letter)
    tileTxt = TextActor(string(letter),"bold"; font_size = 20, color = Int[255, 255, 255, 255])
    tileTxt.centerx, tileTxt.centery = c * SIZE + SIZE//2,  r * SIZE + SIZE//2 +2
    tileRect = Rect(c * SIZE, r * SIZE, SIZE, SIZE)
    tile = Tile(tileTxt, tileRect, false , false, false, letter)
    return tile
end

function returnInt(val)::Int64
    #println("$val,  $(Int64(round(val)))")
    return Int64(round(val))
end

function convertPos(x,y) # return r,c
    return (returnInt(y/SIZE + SIZE//2)-13, returnInt(x/SIZE+SIZE//2)-13)
end

function deselectTiles()
    for tile in tiles
        tile.selected = false
    end

end


####################START 
function startGame()
    global count, startPuzzle, dictPath, arrDict
    open(dictPath) do f #  ".\\WordSearch\\words\\SpanishExample.txt" or ".\\WordSearch\\words\\Dictionary.txt"
        wordDict = readdlm(f, ',', String)

        #global randWords = [strip.(wordDict[j,1:2]) for j in [rand(1:size(wordDict,1)) for i in 1:numberOfWordsToGuess]]   # nb strip. applies to each element of array
        #println(randWords)
        for i in 1:numberOfWordsToGuess
            global randWords
            idx = rand(1:size(wordDict,1))    # 1 is columns 2 is rows
            push!(randWords,wordDict[idx, :])
            wordDict = wordDict[[j ≠ idx for j in 1:size(wordDict,1)],:]
           
        end


    end


    myboard =  createEmptyGrid(puzzleSize)
    count=0
    startPuzzle = time()
    for w in randWords
        
        success = placeWord(myboard,w[1])
        if success
            global count +=1
            wordAct = TextActor(string(w[2]),"bold"; font_size = 20, color = Int[255, 255, 255, 255])
            wordrect = Rect(MARGINWORDSX, (count * MARGIN)+MARGIN -2 , 200, 40)
            wordAct.pos = (MARGINWORDSX, (count * MARGIN)+MARGIN)
            global searchWord = SearchWord(wordAct, w[1], w[2], wordrect, false)
            push!(wordsplaced,  searchWord)
        end
    end
    #displayGrid(myboard) # uncomment to display grid in REPL

    

    for r in 1:length(myboard) # create tile grid with words and choose random weighted letter for remainder 
        for c in 1:length(myboard[1])
            if myboard[r][c] ≠'-' 
                tile = createTile(r,c,myboard[r][c])
                tile.searchWord = true
            else
                tile = createTile(r,c,uppercase(sample(alphabet, Weights(alphabetWeights)))) # random letters weighted depending on typical letter frequencies
            end
            push!(tiles, tile)
        end

    end
end

function draw(g::Game)
    t = time()
    global posActText, clockTick, timeAct, instructions, game_phase, game_phases, count, txtFinish
    if game_phase == game_phases[2] # run    
        for mytile in tiles
            if mytile.selected == true
                draw(mytile.rect, colorant"bisque2", fill = true)
                #=
                txtColor = Int[0,0,0,255] 
                origTilepos = mytile.txtA.pos # because color is part of TextActor, I cannot see how it can be changed so I recreate object.  This is so ugly
                mytile.txtA = TextActor(string(mytile.txt),"bold"; font_size = 20, color = txtColor)
                mytile.txtA.pos = origTilepos
                =#
                
            elseif mytile.revealed == true
                draw(mytile.rect, colorant"lightsteelblue2", fill = true)
            else
                draw(mytile.rect, colorant"cornflowerblue", fill = true)

            end
            draw(mytile.txtA) 
            if time()-clockTick > 1
                timeRect = Rect(MARGINWORDSX, MARGIN, 200, MARGIN)
                #draw(timeRect, colorant"black", fill = true)
                timeAct = TextActor(string(round(time()-startPuzzle)), "bold"; font_size = 20, color = Int[255, 255, 255, 255])
                timeAct.pos =  (MARGINWORDSX, MARGIN)
                draw(timeAct)
                clockTick = time()
            else
                try # initially timeAct is undefined
                    draw(timeAct)
                catch e
                    #println(e)
                end            
            end
        end

        for w in wordsplaced
            if w.found == false
                draw(w.rect, colorant"cornflowerblue", fill = true)
            
            else
                draw(w.rect,colorant"lightsteelblue2", fill = true)
                
            end
            draw(w.txtA)
            #Position Info
            #posAct = TextActor(posActText, "bold"; font_size = 20, color = Int[255, 255, 255, 255]) 
            #posAct.pos = (MARGINWORDSX-200, 500)
            #draw(posAct)
        end
        #println("draw  ", time()-t, " ", time())
    elseif game_phase == game_phases[1] # start
        #display instructions
        rpos = 1
        for txtLine in instructions
            if txtLine ≠ ""
                lineAct = TextActor(txtLine, "bold"; font_size = 15, color = Int[255, 255, 255, 255])
                lineAct.pos = (MARGIN, MARGIN * rpos)
                draw(lineAct)
                rpos +=1
            end
        end

        draw(startRecDict1, colorant"red", fill = true)
        draw(startRecDict2,  colorant"red", fill = true)
        draw(startTextADict1)
        draw(startTextADict2)

    else # end
  
        if count ≠ 0      # poor programming, but didnt want ANOTHER global.  Reusing global variable to only run this line once
            global txtFinish = "Congratulations you finished the puzzel in $(string(round(time()-startPuzzle))) seconds.  Close the window to end the game"
            count = 0
        end
        FinishAct = TextActor(txtFinish, "bold"; font_size = 15, color = Int[255, 255, 255, 255])
        FinishAct.pos = (MARGIN, MARGIN)
        draw( FinishAct)
    end
end

#= Didnt work correctly - couldnt discern key presssed 
function on_key_down(g::Game)
    global game_phase, game_phases, dictPath, arrDict
    while g.keyboard.K_1 ≠ true
    if g.keyboard.K_1
        dictPath = arrDict[1]
    elseif g.keyboard.Up
        dictPath = arrDict[2]
    else
        dictPath = arrDict[1]
    end

    println("keyboard  $(g.keyboard)")
    end 

    game_phase = game_phases[2] # run
    println("HERE")
    println(dictPath, arrDict)
    startGame()
    
end
=#

function on_mouse_down(g::Game, pos)
    global selecttedTile, posActText, game_phase, game_phases, dictPath, arrDict
    t1 = time()
    x,y = pos
    
    if game_phase == game_phases[2]
       
        r,c = convertPos(x, y)
        if r < 16 && c < 16 
            posActText = "row is $r col is $c tile selected $(val = selecttedTile == nothing ? "Noth" : selecttedTile.txt)"
            
            deselectTiles()
            #println("Grid $(r),$(c), Collection is $((r - 1) * puzzleSize + c), Text is $(tiles[(r - 1) * puzzleSize + c].txt)")
            tiles[(r - 1) * puzzleSize + c].selected = true
            if selecttedTile ≠ nothing # check whether 2nd selection is valid selection
                x₁, y₁ = selecttedTile.txtA.pos
                r₁, c₁ = convertPos(x₁, y₁) # 😃  \ _ 1 tab
                #println("First selection pos row, col = $(r₁), $(c₁),    Second selection pos row, col = $(r), $(c)")
                if (abs(r₁-r)==abs(c₁-c) || r₁ == r || c₁ == c) #&& ((r₁ ≠ r) && (c₁ ≠ c)) 
                    
                    highlightSelection(selecttedTile,tiles[(r - 1) * puzzleSize + c] )
                    tiles[(r - 1) * puzzleSize + c].selected = false
                    selecttedTile.selected = false
                    selecttedTile = nothing # 
                else
                selecttedTile.selected = false
                selecttedTile = nothing # 
                tiles[(r - 1) * puzzleSize + c].selected = false
                end
            else
                
                selecttedTile = tiles[(r - 1) * puzzleSize + c]
            end
        end
       # println("on mouse down  ", time()-t1)
    elseif game_phase == game_phases[1]
        if collide(startRecDict1, (x,y))
            dictPath = arrDict[1]
            game_phase = game_phases[2]
            startGame()
            
        elseif collide(startRecDict2, (x,y))
            dictPath = arrDict[2]
            game_phase = game_phases[2]
            startGame()
           
        end
    end
end

function highlightSelection(firstTile, secondTile)
    global wordsplaced, game_phase, game_phases
    #workout orientation
    wordGuess = ""
    deselectTiles()
    rngSelected = nothing
    x₁, y₁ = firstTile.txtA.pos
    r₁, c₁ = convertPos(x₁, y₁)
    x, y = secondTile.txtA.pos
    r, c = convertPos(x, y)
    #println("first tile $(r₁), $(c₁)   second tile $(r), $(c)")
    #return selected tiles
    if r == r₁ 
        rngSelected = c < c₁ ?  [(r,c₂) for c₂ in c:c₁] :  [(r,c₂) for c₂ in c₁:c]
    elseif c == c₁
        rngSelected = r < r₁ ? [(r₂,c) for r₂ in r:r₁] : [(r₂,c) for r₂ in r₁:r]
    elseif c < c₁
        rngSelected = r < r₁ ? [(r₂, c₂) for (r₂,c₂) in zip((r:r₁), (c:c₁))] : [(r₂, c + c₁ - c₂) for (r₂,c₂) in zip((r₁:r), (c:c₁))] # c + c₁ - c₂ to fix selection diagonals switching on cols
    else # c₁ < c
        rngSelected = r < r₁ ? [(r₂, c + c₁ - c₂) for (r₂,c₂) in zip((r:r₁), (c₁:c))] : [(r₂, c₂) for (r₂,c₂) in zip((r₁:r), (c₁:c))]
    end

    colSelected = [(r-1)*puzzleSize + c for (r,c) in rngSelected]
    #println(rngSelected, "  collection number $(colSelected)")
    for ix in colSelected
       tiles[ix].selected = true
       wordGuess = string(wordGuess, tiles[ix].txt)
    end
    
    for w in wordsplaced
        if wordGuess == w.txt || reverse(wordGuess)==w.txt
            w.found = true
            for ix in colSelected
                tiles[ix].revealed = true
                
            end

        end

    end
    #println(sum([ w.found == false for w in wordsplaced]))
    if sum([ w.found == false for w in wordsplaced]) == 0 # all words found 
        game_phase = game_phases[3]

    end
    deselectTiles()

end