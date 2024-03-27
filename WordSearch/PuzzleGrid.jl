#=
Plan is to build it seperately from GameZero part to make it easier to debug
This will return a word search puzzel in an array/list
Plan is to eventually have a resource file for the words
Also to cater for different languages
There is a v good article https://medium.com/@msgold/creating-a-word-search-puzzle-b499533e938 written in python 

Errors
1. for (i, (r, c)) in (enumerate(zip(row:-1:row-length(word), col:col+length(word))))  - needed to match (i,(r,c)) with (enumerate(zip(row:-1:row-length(word), col:col+length(word)))) - done
2. Debugging list comprehensions - tricky
3. length returns length as if 1D size(array, 2) - cols, size(array, 1) rows
4. "-" ≠ '-'
5. pwd() print working directory

=#
module PuzzleGrid
    export displayGrid, words, createEmptyGrid, placeWord, board, placed, one, two, three, four, five, six, seven, eight
    using Colors
    using Crayons

    words = ["ADVENTURE", "DESTINATION", "PASSPORT", "EXPLORE", "TOURIST", 
            "JOURNEY", "FLIGHT", "CRUISE", "LUGGAGE", "TICKET"]

    board = []
    puzzel_size = 13

    function createEmptyGrid(size)
        return [['-' for _ in 1:size] for _ in 1:size]
    end

    function displayGrid(board)
        for i in 1:length(board)
            println(Crayon(foreground = :red), board[i])
        end

    end


    # Helper functions 
    function one(board, word)
        return rand(1:size(board, 1))
    end

    function two(board, word)
        return rand(1: size(board, 1)-length(word))
    end

    function three(board, word)
        return rand(length(word):size(board, 1))
    end

    function four(board, word)
        return rand(1:size(board, 1)-length(word)) 
    end

    function five(board, word, row, col)
        return all([board[row][c]=='-' || board[row][c] == word[i] for (i, c) in enumerate(col:col+length(word)-1)]), enumerate(col:col+length(word)-1)
    end

    function six(board, word, row, col)
        return all([board[r][col]=='-' || board[r][col] == word[i] for (i, r) in enumerate(row:row+length(word)-1)]), enumerate(row:row+length(word)-1)
    end

    function seven(board, word, row, col)
        return all([board[r][c]=='-'  || board[r][c]==word[i] for (i, (r, c)) in (enumerate(zip(row:row+length(word)-1, col:col+length(word)-1)))]), 
                enumerate(zip(row:row+length(word)-1, col:col+length(word)-1))
    end

    function eight(board, word, row, col)
        return all([board[r][c]=='-'  || board[r][c]==word[i] for (i, (r, c)) in (enumerate(zip(row:-1:row-length(word)+1, col:col+length(word)-1)))]),
                enumerate(zip(row:-1:row-length(word)+1, col:col+length(word)-1))
    end
    
    functDict = Dict(
                "1" => (one, two, five),     # horizontal
                "2" => (two,one, six),    # vertical
                "3" => (four, four, seven), # diagonal top left to bottom right
                "4" => (three, four, eight)
    )


    function placeWord(board, word::String)
        wordDirection = rand(1:4)
        #wordDirection = 4
        word = rand(0:1) == 0 ? word : reverse(word)
        placed = false
        attempts = 0
        while !placed && attempts < 300
            attempts +=1
            row = functDict[string(wordDirection)][1](board, word)
            col = functDict[string(wordDirection)][2](board, word)
           # println("row is $row, col is $col, attempts is $attempts")
            if wordDirection == 1 || wordDirection == 2 # horizontal or verticel
                spaceAvailableAndEnumeration = functDict[string(wordDirection)][3](board, word, row, col)  #all([board[row][c]=='-' || board[row][c] == word[i] for (i, c) in enumerate(col:col+length(word)-1)])
                if spaceAvailableAndEnumeration[1]
                    for (i, rc) in spaceAvailableAndEnumeration[2] #enumerate(col:col+length(word)-1)
                        if wordDirection == 1 board[row][rc] = word[i] else board[rc][col] = word[i] end
                        placed = true
                    end
                end 
            
            else  #wordDirection == 3 or 4  # diagonal 
                spaceAvailableAndEnumeration = functDict[string(wordDirection)][3](board, word, row, col)  #all([board[r][c]=='-'  || board[r][c]==word[i] for (i, (r, c)) in (enumerate(zip(row:row+length(word)-1, col:col+length(word)-1)))])
                if spaceAvailableAndEnumeration[1]
                    for (i, (r, c)) in spaceAvailableAndEnumeration[2]    #enumerate(zip(row:row+length(word)-1, col:col+length(word)-1))
                        board[r][c] = word[i]
                        placed = true
                    end
                end      
                    
            
            end

        end
        return placed
    end
    #=
    for word in words
        placeWord(x,word)
    end

    displayGrid(x)
    =#
    
end