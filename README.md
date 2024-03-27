**Snake - GAME 1**
Aim to write a complete game using GameZero as learning exercise.  SNAKE.  Not just a partial example

To Install

Copy Snake.jl

Create fonts subdir with moonhouse.tff

add Colors and GameZero package 

To run
From REPL type:

using GameZero

GameZero.rungame("D:\\..\\Julia\\..\\Snake\\Snake.jl")  


To Play

Use arrow keys to navigate snake to eat green apples and avoid red apples

Game ends if you collide with body of snake, walls or red apple

To replay - re-run


![image](https://github.com/DavidBloomfield/JuliaGames/assets/55062557/842d53af-5a21-4035-a3b5-1c2094a684cf)

**3D Maze - GAME 2**

In this game you navigate around a 3D maze using arrow keys.  The maze is procedurally generated (prims algorithm) and the size can be changed 

Create dir juliaMaze

Copy in 2 files.  

Create fonts subdir with moonhouse.tff

In REPL

cd("juliaMaze")

add Colors and GameZero package 

from package manager activate .     This will create a project directory.  If this step is missed, GameZero will not be able to find fonts

Execute the run file which implements GameZero and calls the JuliaMaze file.  Otherwise you can run the JuliaMaze file using the previous approach from the REPL

Start up screen with instructions and maze size selection

![StartUp](https://github.com/DavidBloomfield/JuliaGames/assets/55062557/76a5ea1d-5937-400c-b443-0bc00eb6bb70)

Gameplay 3D Maze

![Gameplay#1](https://github.com/DavidBloomfield/JuliaGames/assets/55062557/94bec9ea-d307-427d-a800-31ad38c72c4b)

If you press space bar a 2D map is displayed briefly.  Exit is in orange.  The light blue are raycasts and represent your field of view

![Gameplay#2](https://github.com/DavidBloomfield/JuliaGames/assets/55062557/96c1d153-1a73-4df6-b0fc-17e477bb54be)
