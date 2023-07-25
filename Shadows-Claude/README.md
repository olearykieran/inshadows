# IN SHADOWS

#### Video Demo: [https://youtu.be/6nbjPk06PIc](https://youtu.be/6nbjPk06PIc)

I wrote this game in 5 days using the Lua programming language for the Love application. My main sources of inspiration were the legend of Zelda & Dark Souls. 

It is an action-adventure game in which the player needs to beat 3 different mazes. The first maze is a simple one. An enemy is introduced in the 2nd maze, and the final boss is in the 3rd maze. 

I wrote and recorded the music for the game as well. It was so much fun making this little game, and I will most likely try to turn it into a larger-scaled playable game over time.

Breakdown of the code:
1) I saved the 3 different mazes in a separate lua file and drew out the mazes and different characters and design pieces using # and letters.  This is the maze_data.lua file
2) loaded in the music to my music folder and images to the images folder and loaded them into the game where necessary.
3) In main.lua I declared all global variables I was going to use  throughout my code.  In hindsight I should have also saved these to a different file to save space on main, but lesson learned!
4) I wrote a generate maze function, which makes sure some boolean variables are correct, determines dimensions of the maze & makes sure the game is on the correct level.  It stores the maze as a string and as a grid for different uses.
5) The load funciton initially loads assets into the game
6) The reset game function determines what should happen when the player dies, runs out of lives, or wins the game
7) The isCelleInVisibilityRange function helpes create a circle of light around the player to make the game more challenging.
8) The manhattanDistance function equation helps with enemy ai and tracking the player.
9) The update function runs various different tools that happen during frames of gameplay
10) A few more functions for animations
11) The draw function draws everything into the playable game area
12) The move player function delcares the behavior of the character when moving in the board
13) The keypressed, keyreleased, and mousepressed functions accept different inputs from the plaayer to control the character 14) A big challenge while creating this game was scoping out what features I wanted to include/exclude based on the nature of the project.  If I was planning on working on this project for months or even years I think I would have worked differently.  I most likely would have written out an entire story and plot to start with.  Than add all features that I wanted in the game from the very start.  I would have to storyboard out the entire game in it's full complexity before starting to code.  In this iteration, I came up with a few main ideas that I thought I could implement with relative ease and few lines of code and then iterated over them until they were at a place that I deemed acceptable.  It is good to have a timeline, as I could probably work on this forever.  2 Things that I struggled with towards the end were enemy AI tracking the player exactly how I wanted, and the visual of the light circle that follows the player.  I wanted the light circle to be prettier, and I think I will challenge myself to make that after I submit the project.
15) The circle of flames was a fun and challenging thing to create. 
    initializeFlames(): This function sets up the initial state of each flame. It creates a number of flames equal to flameCount. Each flame is represented by a table (or an object in other programming languages) with one property: angle. The angle is calculated so that the flames are distributed evenly in a circle.

    updateFlames(dt): This function updates the angle of each flame. It makes the flames rotate around the circle by adding a small angle (which is proportional to the time passed, dt) to the current angle of each flame. The new angle is then brought into the range of 0 to 2π using the modulus operator %. This ensures that the angle stays within the typical range used to represent angles in a circle, i.e., from 0 to 2π radians.

    drawFlames(dt): This function draws each flame on the screen. It determines which sprite to use for each flame based on whether the index i is even or odd. It then calculates the width and height of the sprite and its position. The position is determined such that the flames form a circle with the titleX + gameTitleWidth / 2 and titleY as the center, and radius as the radius. Each flame is then drawn at its calculated position, and its angle is updated similarly to updateFlames(dt) function.
16) The music I made on garageband.  I wanted it to be a spooky theme in the levels and more of a cool triumphant theme on the title screen.  I made the characters using adobe photoshop and adobe express.  I was happy to be able to bring the creative elements and ideas I had into life during this project.  Looking forward to expanding on this game and working on the next one! 
15) Hope you enjoy!!