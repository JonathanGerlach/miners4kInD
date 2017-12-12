module dminers;

import std.stdio;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

struct Game
{
	private static bool[] keys = new bool[65536];
	private static int xMouse, yMouse, mouseButton;
	
	enum GameState
	{
		Stopped,
		Started,
		Quitting,
	};
	
	GameState gameState;
	
	void start()
	{		
		gameState = GameState.Started;
		
		while (gameState == GameState.Started)
		{
			debug writeln("Starting gamestate");

	        // The end-line comments are there to prevent eclipse's auto formating
	        // from messing up the sprite data.	        
	        import std.conv;
	        auto SPRITES = [//
	        		"" ~ //
	                " !!!!  " ~ //
	                " !oooo " ~ //
	                " !oooo " ~ //
	                "  **   " ~ //
	                "  **XX " ~ //
	                "  o*XX " ~ //
	                "  **   " ~ //
	                "  **   " ~ //
	                "  **   " ~ //
	                "  ooo  " ~ //
	
	                "  !    " ~ //
	                " !!!!  " ~ //
	                " !oooo " ~ //
	                "  oooo " ~ //
	                "  **XXX" ~ //
	                "  *oXXX" ~ //
	                "  **** " ~ //
	                " ** ** " ~ //
	                "**   oo" ~ //
	                "oo     " ~ //
	
	                "  !!!  " ~ //
	                " !oooo " ~ //
	                "!!oooo " ~ //
	                "  ** XX" ~ //
	                "  ***oX" ~ //
	                "  ** XX" ~ //
	                "  ***  " ~ //
	                " ***** " ~ //
	                "o** ** " ~ //
	                "o    oo" ~ //
	
	                " !!!!  " ~ //
	                "!!oooo " ~ //
	                " !oooo " ~ //
	                "  **   " ~ //
	                "  **XXX" ~ //
	                "  *oXXX" ~ //
	                "  **   " ~ //
	                " o***  " ~ //
	                "  o**  " ~ //
	                "    oo " ~ //
	
	                "       " ~ //
	                "       " ~ //
	                " !!!!  " ~ //
	                " !oooo " ~ //
	                " !oooo " ~ //
	                "  **   " ~ //
	                "  **XX " ~ //
	                "  o*XX " ~ //
	                " #*# # " ~ //
	                "  ###  " ~ //
	
	                "       " ~ //
	                "       " ~ //
	                "       " ~ //
	                "       " ~ //
	                "       " ~ //
	                "   #   " ~ //
	                "#!!!! #" ~ //
	                " !oooo " ~ //
	                " #o#o# " ~ //
	                " ##### " ~ //
	
	                "       " ~ //
	                "       " ~ //
	                "       " ~ //
	                "       " ~ //
	                "       " ~ //
	                "       " ~ //
	                "       " ~ //
	                "       " ~ //
	                "   #   " ~ //
	                "#     #"//
	        ].to!(char[]);
	        
	        // TODO(Jon): Set up a window with SDL			
			SDL_Init(SDL_INIT_VIDEO);
			scope (exit) SDL_Quit();
			
			SDL_Window* window;
			SDL_Renderer* renderer;
			SDL_CreateWindowAndRenderer(640, 500, SDL_WINDOW_RESIZABLE, &window, &renderer);
				        
// 	        // Create the window
// 	        A a = new A();
// 	        a.setSize(640, 500);
// 	        a.setResizable(false);
// 	        a.enableEvents(KeyEvent.KEY_PRESSED | MouseEvent.MOUSE_DRAGGED | MouseEvent.MOUSE_MOVED | MouseEvent.MOUSE_PRESSED | MouseEvent.MOUSE_RELEASED);
// 	        a.setVisible(true);
// 	
// 	        // Set up the graphics objects we'll need
// 	        Graphics gr = a.getGraphics();
// 	        BufferedImage img = new BufferedImage(640, 480, BufferedImage.TYPE_INT_RGB);
// 	        int[] pixels = ((DataBufferInt)img.getRaster().getDataBuffer()).getData();
			int[] pixels = new int [640 * 480];
// 	
// 	        Image img2 = a.createImage(640, 480);
// 	        Graphics gr2 = img2.getGraphics();
// 	        gr2.setColor(new Color(255, 255, 255));

			import std.random;
			auto gen = Random(unpredictableSeed);
 	        int[] level = new int[1024 * 2048];
 	
 	        // Level data. Defining arrays like this takes up a lot of space, so
 	        // this can be optimised
 	        string[] levelNames = ["Level 1: Miners4k", "Level 2: Rocks", "Level 3: Descent", "Level 4: Slime", "Level 5: Massive", "Level 6: Riiiight", "You won!"];
 	        string[] infoStrings = ["Bring the gold home!", "Rocks are impenetrable.", "Use arrow keys to scroll.", "Slime explodes on contact!", "Wide level!", "Timekiller!", "Bonus level!"];
 	        int[] slimes = [0, 0, 0, 6, 10, 25, 0];
 	
 	        int current_level = 0;
 	
 	        // Loop until escape is pressed.
 	        // First set up the level, then run the main game loop.
 	        // The main game loop ends when the level is over or when escape is pressed
 	        while (!keys[27] || this.gameState == GameState.Quitting)
 	        {
 	            // First set up the variables for the current level
 	            int level_width = current_level / 4 * 384 + 640;
 	            int level_height = current_level>1?1024:480;
 	            int level_rocks = (current_level - 1) / 2 * 100;
 	            int level_target = current_level * 500;
 	            int level_diggers = current_level * current_level * 50;
 	            int level_goldLumps = current_level * current_level * 50;
 	            
 	            // Special levels that don't conform to the formulas
 	            if (current_level == 0)
 	            {
 	                level_rocks = 0;
 	                level_target = 100;
 	                level_diggers = 50;
 	                level_goldLumps = 10;
 	            }
 	            if (current_level == 1)
 	            {
 	                level_rocks = 10;
 	                level_target = 200;
 	                level_goldLumps = 30;
 	            }
 	            if (current_level == 2) level_rocks = 50;
 	            if (current_level == 6)
 	            {
 	                level_height = 2048;
 	                level_target = 99999;
	                level_diggers = 800;
	            }
	            
	            // Jon: The is in seconds
	            int level_timeLimit = level_target * 2;
	
	            // Create the heightmap for the surface by subdivision
	            level[0] = 200;
	            level[512] = 200;
	            for (int i = 512; i > 1; i /= 2)
	            {
	                for (int p = 0; p < 1024; p += i)
	                {
	                    int d0 = level[p];
	                    int d1 = level[(p + i) & 1023];
	                    auto random = uniform(0, i, gen);
	                    level[p + i / 2] = (d0 + d1) / 2 + (random - i / 2) / 4;
	                }
	            }
	
	            // Create the platforms for gold-dumping
	            for (int x = 0; x < 88; x++)
	            {
	                level[x] = level[88] - 2;
	                level[level_width - x - 1] = level[level_width - 88 - 1] - 2;
	            }
	
	            // Render the level graphics
	            for (int y = 1; y < level_height; y++)
	                for (int x = 0; x < level_width; x++)
	                {
	                    int i = x | y << 10;
						
						auto r1 = uniform(0.0f, 1.0f, gen);
						auto r2 = uniform(0.0f, 1.0f, gen);
						auto r3 = uniform(0.0f, 1.0f, gen);
	                    double br = 1.2 - (r1 - 0.5) * r2 * r3 * 0.6;
	                    br *= (1 - i / (1024 * 6048.0));
	
	                    if (x < 8 || x >= level_width - 8 || y >= level_height - 8) // Rock on the edges
	                    {
	                        int c = cast(int)(180 * br);
	                        level[i] = c << 16 | c << 8 | c;
	                    }
	                    else if (y < level[i % 1024]) // Nothing on top of the level
	                    {
	                        level[i] = 0;
	                    }
	                    else
	                    // Dirt and grass
	                    {
	                        int r = cast(int)(111 * br);
	                        int g = cast(int)(92 * br);
	                        int b = cast(int)(51 * br);
	                        if (y < level[x] + 4) // Grass if it's the top four pixels
	                        {
	                            r = cast(int)(44 * br);
	                            g = cast(int)(148 * br);
	                            b = cast(int)(49 * br);
	                            if (x < 88 || x > level_width - 89)
	                            {
	                                r = b = g;
	                            }
	                        }
	                        level[i] = r << 16 | g << 8 | b;
	                    }
	
	                    if (y >= level_height - 10 && slimes[current_level] > 0)
	                    {
	                        level[i] = 0x00ff00;
	                    }
	                }
	
	            // Add all gold, rocks and slime blobs to the level graphics
	            for (int i = 0; i < level_goldLumps + level_rocks + slimes[current_level]; i++)
	            {
	                // Pick a position, but favor deeper positions
	                int x = uniform(0, level_width - 40, gen) + 20;
	                int y0 = uniform(0, level_height - 240, gen) + 200;
	                int y1 = uniform(0, level_height - 240, gen) + 200;
	                int y2 = uniform(0, level_height - 240, gen) + 200;
	                int y = y1 > y0 ? y1 : y0;
	                if (y2 > y) y = y2;
	
	                // Determine the type and size in the ugliest way possible
	                int type = 0;
	                int size = uniform(0, 8, gen) + 4;
	                if (i >= level_goldLumps) // If it's not gold lumps, then it's rocks
	                {
	                    size = uniform(0, 32, gen) + 8;
	                    type = 1;
	                    if (i - level_goldLumps >= level_rocks) // Of course, it might be slime
	                    {
	                        type = 2;
	                        size = 6;
	                    }
	                }
	
	                // Render the blob
	                for (int xx = x - size; xx <= x + size; xx++)
	                    for (int yy = y - size; yy <= y + size; yy++)
	                    {
	                        int d = (xx - x) * (xx - x) + (yy - y) * (yy - y);
	                        if (xx >= 0 && yy >= 0 && xx < 1024 && yy < 2048 && d < size * size)
	                        {
	                            if (type == 1)
	                            {
	                                // Rocks (type 1) have a cool gradient
	                                int d2 = cast(int)(((xx - x + size / 3.0) * (xx - x + size / 3.0) / size / size + (yy - y + size / 3.0) * (yy - y + size / 3.0) / size / size) * 64);
	                                int c = 200 - d2 - uniform(0, 16, gen);
	                                if (level[xx | yy << 10] != 0) level[xx | yy << 10] = c << 16 | c << 8 | c;
	                            }
	                            else
	                            {
	                                // Slime and gold are monocolored
	                                if (level[xx | yy << 10] != 0) level[xx | yy << 10] = (type * 128 - type / 2) << 16 ^ 0xffff00;
	                            }
	                        }
	                    }
	            }
	
	            // Set up the miners as a 2d array. Each miner has 8 variables.
	            // Jon: I made a real struct here for sanity's sake.
	            struct Miner
	            {
	            	int x_position;
	            	int y_position;
	            	int direction; // Either -1 or 1
	            	int walk_animation_step; // Between 0 and 15
	            	int jump_velocity; // Between -1 and 16. -1 = on ground, 0 = falling, 1-8 = jumping straight, 9-16 = jumping one pixel up.
	            	int carrying_gold; // 1 or 0
	            	int alive; // 1 or 0
	            	int distance_fallen; // 0 if the miner is on the ground
	            }
	            Miner[] miners = new Miner[level_diggers];
	            // miners[i][0] = x position
	            // miners[i][1] = y position
	            // miners[i][2] = direction (-1 or 1)
	            // miners[i][3] = walk animation step, between 0 and 15
	            // miners[i][4] = jump velocity, between -1 and 16. -1 = on ground, 0 = falling, 1-8 = jumping straight, 9-16 = jumping one pixel up.
	            // miners[i][5] = 1 if the miner is carrying a gold lump, 0 otherwise
	            // miners[i][6] = 0 if the miner is alive, otherwise it's the death animation frame
	            // miners[i][7] = distance the miner has fallen. 0 if the miner is on the ground.
	            for (int i = 0; i < miners.length; i++)
	            {
	                miners[i].x_position = uniform(0, 88 - 24 - 16, gen) + 24;
	                if (i < miners.length / 2) miners[i].x_position = level_width - miners[i].x_position;
	                miners[i].y_position = -uniform(0, 400, gen);
	                miners[i].direction = uniform(0, 2, gen) * 2 - 1;
	                miners[i].distance_fallen = -640;
	            }
	
	            // Last known mouse positions
	            int xMo = 0;
	            int yMo = 0;

	            mouseButton = 1;
	
	            // Camera position
	            int xo = 0;
	            int yo = 0;
	
	            // Various variables
	            int score = 0;
	            bool levelOver = false;
	            bool levelStarted = false;
	            
	            import std.datetime;
	            long roundsStartTime = Clock.currStdTime;
	            long lastTime = roundsStartTime;
	
 	            // Run main loop until the level is over and another level needs to be created, or until escape is pressed
 	            while (!levelOver && !keys[27])
 	            {
	                // First calculate the mouse positions
	                // xM = current mouse position
	                // xMo = old mouse position
	                int xM = xMouse + xo;
	                int yM = yMouse + yo;
	
	                // Handle painting only if the level is started
	                if (levelStarted && mouseButton > 0)
	                {
	                    // Draw a line by interpolating between the old mouse
	                    // positon and the new position, one pixel at a time
	                    import std.math;
	                    // TODO(Jon): Is this right?
	                    int d = cast(int)sqrt(cast(double)(xM - xMo) * (xM - xMo) + (yM - yMo) * (yM - yMo)) + 1;
	                    for (int i = 0; i < d; i++)
	                    {
	                        int xm = xM + (xMo - xM) * i / d;
	                        int ym = yM + (yMo - yM) * i / d;
	
	                        // Draw a box with the corners missing around each position
	                        for (int xx = -3; xx <= 3; xx++)
	                            for (int yy = -3; yy <= 3; yy++)
	                            {
	                                if ((xx != -3 && xx != 3) || (yy != -3 && yy != 3)) // Missing corners
	                                {
	                                    int x = xm + xx;
	                                    int y = ym + yy;
	                                    if (x >= 0 && y >= 0 && x < 1024 && y < 2048)
	                                    {
	                                        if (mouseButton == 3 || keys[17]) // Right mouse button, or shift pressed
	                                        {
	                                            int r = level[x | y << 10] >> 16 & 0xff;
	                                            int g = level[x | y << 10] >> 8 & 0xff;
	                                            int b = level[x | y << 10] >> 0 & 0xff;
	
	                                            // Only clear the terrain if it isn't gold (r and g equal),
	                                            // rock (r, g and b equal) or slime (r and b equal)
	                                            if (r != g && r != b) level[x | y << 10] = 0;
	                                        }
	                                        else
	                                        {
	                                            // Only add dirt if there's no terrain on the pixel
	                                            if (level[x | y << 10] == 0)
	                                            {
	                                                double br = 1.6 - (uniform(0.0f, 1.0f, gen) - 0.5) * uniform(0.0f, 1.0f, gen) * uniform(0.0f, 1.0f, gen) * 0.6;
	                                                br *= (1 - (x | y << 10) / (1024 * 6048.0));
	                                                int r = cast(int)(111 * br);
	                                                int g = cast(int)(92 * br);
	                                                int b = cast(int)(51 * br);
	
	                                                level[x | y << 10] = r << 16 | g << 8 | b;
	                                            }
	                                        }
	                                    }
	                                }
	                            }
	                    }
	                }
	                // Set the last known mouse position to the current mouse position
	                xMo = xM;
	                yMo = yM;
	
	                // Blit the terrain data to the screen buffer.
	                for (int yPixel = 0; yPixel < 480; yPixel++)
	                {
	                    // This method call can be replaced by a smaller for-loop, but this is way faster
	                    
	                    // public static void arraycopy(Object src, int srcPos, Object dest, int destPos, int length)
	                    //System.arraycopy(level, xo | (yo + yPixel) << 10, pixels, yPixel * 640, 640);
						
						// Jon: In D we can use slice operators to copy the arrays
	                    size_t start  = xo | (yo + yPixel) << 10;
	                    size_t pixelStart = yPixel * 640;
	                    pixels[pixelStart .. pixelStart + 640] = level[start .. start + 640];
	                }
					
					// Jon: Here's some red, for testing.
// 					for (int yPixel = 0; yPixel < 480; yPixel++)
// 					{
// 						for (int xPixel = 0; xPixel < 640; xPixel++)
// 						{
// 							pixels[(yPixel * 640) + xPixel] = 0x000000FF;
// 						}
// 					}
					
					debug writeln("Rendering miners");
					
	                // Render all miners
	                for (int i = 0; i < miners.length; i++)
	                {
	                    // Only render the miner if the death animation hasn't finished playing
	                    if (miners[i].alive < 4 * 4)
	                    {
	                        for (int xx = -3; xx <= 3; xx++)
	                            for (int yy = -8; yy <= 1; yy++)
	                            {
	                                // Flip the x position if the miner is facing left by multiplying the
	                                // x position by the direction
	                                int x = miners[i].x_position - xo + xx * miners[i].direction;
	                                int y = miners[i].y_position - yo + yy;
	                                // If the pixel is onscreen
	                                if (x >= 0 && y >= 0 && x < 640 && y < 480)
	                                {
	                                    // Get the character from the animation data
	                                    char ch = SPRITES[(xx + 3) + (yy + 8) * 7 + (miners[i].walk_animation_step / 4) * 7 * 10];
	                                    if (miners[i].alive > 0) // Get ANOTHER character if the death animation is playing
	                                    {
	                                        ch = SPRITES[(xx + 3) + (yy + 8) * 7 + (miners[i].alive / 4 + 3) * 7 * 10];
	                                    }
	
	                                    if (ch == 'X' && miners[i].carrying_gold == 1) pixels[x + y * 640] = 0xffff00; // Gold. Only render if the miner is holding gold
	                                    if (ch == 'o') pixels[x + y * 640] = 0xDB8EaF; // Skin
	                                    if (ch == '!') pixels[x + y * 640] = 0x00FF00; // Hair
	                                    if (ch == '*') pixels[x + y * 640] = 0x0000FF; // Clothes
	                                    if (ch == '#') pixels[x + y * 640] = 0xFF0000; // Blood
	                                }
	                            }
	                    }
	                }
	                
	                debug writeln("Finished rendering miners");
	
	                // Game logic. Is run once every 25 ms by making sure the lastTime variable is at least as big as
	                // currentTimeMillis, and increasing it by 25 every time the loop is run.
	                while (levelStarted && lastTime < Clock.currStdTime)
	                {
	                	import std.conv;
	                	debug writeln("Current time is: " ~ Clock.currStdTime.to!string);
	                    lastTime += 25 * 1_000 * 10; // Convert to hecto-nanoseconds
	                    debug writeln("Last time is now: " ~ lastTime.to!string);
	
	                    // Slime spreading. Pick 400 random pixels, and if they're slime, spread slime
	                    // around them in a random direction.
	                    for (int i = 0; i < 400; i++)
	                    {
	                        int x = uniform(0, 1021, gen) + 1;
	                        int y = uniform(0, 1021, gen) + 1;
	                        int x2 = x + uniform(0, 3, gen) - 1;
	                        int y2 = y + uniform(0, 3, gen) - 1;
	                        if (level[x2 | y2 << 10] == 0x00ff00)
	                        {
	                            // A small box around the slime helps it spread slightly faster, and makes
	                            // it look a bit better
	                            for (int xx = -1; xx <= 1; xx++)
	                                for (int yy = -1; yy <= 1; yy++)
	                                {
	                                    level[(x + xx) | (y + yy) << 10] = 0x00ff00;
	                                }
	                        }
	                    }
	                     	
	                    // Miner logic
	                    for (int i = 0; i < miners.length; i++)
	                    {
	                        // Only run logic if the miner isn't dead.
	                        if (miners[i].alive == 0)
	                        {
	                            if (miners[i].jump_velocity > 1 && miners[i].y_position > 1) // If the miner is jumping and isn't above the screen
	                            {
	                                // If the pixel he's trying to reach is cleared
	                                if ((level[(miners[i].x_position + miners[i].direction) | (miners[i].y_position - miners[i].jump_velocity / 8) << 10]) == 0)
	                                {
	                                    // Move him there, and decrease the falling time
	                                    miners[i].x_position += miners[i].direction;
	                                    miners[i].y_position -= miners[i].jump_velocity / 8;
	                                    miners[i].walk_animation_step = (miners[i].walk_animation_step + 1) & 15; // Animation
	                                    miners[i].jump_velocity--;
	                                }
	                                else
	                                {
	                                    // Stop jumping
	                                    miners[i].jump_velocity = 0;
	                                }
	                            }
	                            else
	                            {
	                                // If the miner is inside gold, move him up one pixel
	                                if (miners[i].y_position > 0 && level[miners[i].x_position | miners[i].y_position << 10] == 0xffff00)
	                                    miners[i].y_position--;
	                                
	                                // If the miner is on top of a black pixel, or if the miner is above the screen
	                                if (miners[i].y_position < 4 || level[(miners[i].x_position) | (miners[i].y_position + 1) << 10] == 0)
	                                {
	                                    // 66% chance of jumping if the miner is on the ground
	                                    if (miners[i].jump_velocity == -1 && uniform(0, 3, gen) != 0)
	                                    {
	                                        miners[i].jump_velocity = 16;
	                                    }
	                                    else
	                                    {
	                                        // Otherwise, fall up to three pixels down and increase the distance fallen
	                                        for (int j = 0; j < 2; j++)
	                                            if (miners[i].y_position < 4 || level[(miners[i].x_position) | (miners[i].y_position + 1) << 10] == 0)
	                                            {
	                                                miners[i].y_position++;
	                                                miners[i].jump_velocity = 0;
	                                                miners[i].distance_fallen++;
	                                            }
	                                    }
	                                }
	                                else
	                                // If the miner isn't on top of a black pixel
	                                {
	                                    // If the miner has fallen more than 100 pixels, kill him.
	                                    if (miners[i].distance_fallen > 100)
	                                    {
	                                        miners[i].alive = 1;
	                                        level_diggers--;
	                                        miners[i].x_position -= miners[i].direction;
	                                    }
	
	                                    // Miner hasn't fallen, and is on the ground
	                                    miners[i].distance_fallen = 0;
	                                    miners[i].jump_velocity = -1;
	
	                                    // There's a 1/20 chance each tick that a miner will stand still.
	                                    // This breaks up piles of miners, and makes them feel more dynamic
	                                    if (uniform(0, 20, gen) != 0)
	                                    {
	                                        // Assume the miner has hit a wall
	                                        bool hit = true;
	
	                                        // The miner can walk up slopes 4 pixels high, and down slopes two pixels deep, so check for free pixels in that range
	                                        for (int y = 2; y >= -4; y--)
	                                        {
	                                            if ((level[(miners[i].x_position + miners[i].direction) | (miners[i].y_position + y) << 10]) == 0)
	                                            {
	                                                miners[i].x_position += miners[i].direction;
	                                                miners[i].y_position += y;
	                                                miners[i].walk_animation_step = (miners[i].walk_animation_step + 1) & 15;
	                                                hit = false;
	                                                break;
	                                            }
	                                        }
	
	                                        // 1/10 chance the miner will turn around if he's hit a wall
	                                        // 1/4000 chance the miner will turn around if he didn't hit a wall
	                                        if (uniform(0, hit ? 10 : 4000, gen) == 0)
	                                        {
	                                            miners[i].direction *= -1;
	                                            if (hit)
	                                            {
	                                                // 66% chance the miner will jump when he turns around if he hit a wall
	                                                if (uniform(0, 3, gen) != 0) miners[i].jump_velocity = 16;
	                                            }
	                                        }
	                                    }
	                                }
	                            }
	
	                            // Check if the miner should drop gold.
	                            // A miner drops gold if he's holding gold, is above ground, and is directly on top of either gold pile
	                            if (miners[i].carrying_gold == 1 && miners[i].y_position <= level[miners[i].x_position] && (miners[i].x_position == 8 + 32 || miners[i].x_position == level_width - 8 - 32))
	                            {
	                                score++;
	                                // Slide four pixel of gold diagonally down until they hit ground
	                                for (int j = 0; j < 4; j++)
	                                {
	                                    int xx = miners[i].x_position;
	                                    int yy = miners[i].y_position - 5;
	                                    bool done = false;
	                                    while (!done)
	                                    {
	                                        if (level[(xx + 0) | (yy + 1) << 10] == 0) // Straight down
	                                        {
	                                            yy++;
	                                        }
	                                        else if (level[(xx - 1) | (yy + 1) << 10] == 0) // Diagonally to the left
	                                        {
	                                            xx--;
	                                            yy++;
	                                        }
	                                        else if (level[(xx + 1) | (yy + 1) << 10] == 0) // Diagonally to the right
	                                        {
	                                            xx++;
	                                            yy++;
	                                        }
	                                        else
	                                        // No more falling!
	                                        {
	                                            done = true;
	                                        }
	                                    }
	                                    // If the resulting position is above ground, add the gold pixel
	                                    if (yy < level[xx]) level[xx | yy << 10] = 0xfefe00;
	                                }
	
	                                // Clear the carrying gold flag
	                                miners[i].carrying_gold = 0;
	                            }
	
	                            // Check the rendered pixels to see if the miner hits gold or slime
	                            // This check was originally embedded in the rendering loop to save space,
	                            // but the fixed time fix forced me to separate them.
 	                            for (int xx = -3; xx <= 3; xx++)
	                                for (int yy = -8; yy <= 1; yy++)
	                                {
	                                    int x = miners[i].x_position + xx * miners[i].direction;
	                                    int y = miners[i].y_position + yy;
	                                    if (x >= 0 && y >= 0 && x < level_width && y < level_height)
	                                    {
 	                                        // If the pixel was rendered
 	                                        if (SPRITES[(xx + 3) + (yy + 8) * 7 + (miners[i].walk_animation_step / 4) * 7 * 10] != ' ')
 	                                        {
	                                            // If the pixel is slime, blow up the miner
	                                            if (level[x | y << 10] == 0x00ff00)
	                                            {
	                                                miners[i].alive = 1;
	                                                level_diggers--;
	
	                                                // Render a black sphere of radius 16 to the level
	                                                int s = 16;
	                                                for (int xxb = -s; xxb <= +s; xxb++)
	                                                    for (int yyb = -s; yyb <= +s; yyb++)
	                                                    {
	                                                        int dd = xxb * xxb + yyb * yyb;
	                                                        int xxa = xxb + miners[i].x_position;
	                                                        int yya = yyb + miners[i].y_position - 4;
	                                                        // This destroys everything except the level borders
	                                                        if (xxa >= 4 && yya >= 4 && xxa < level_width - 4 && yya < level_height - 4 && dd < s * s)
	                                                        {
	                                                            level[xxa | yya << 10] = 0x000000;
	                                                        }
	                                                    }
	                                            }
	                                            // If the miner isn't carrying gold, and the pixel is gold
	                                            if (miners[i].carrying_gold == 0 && level[x | y << 10] == 0xffff00)
	                                            {
	                                                // Remove a box of gold from the level
	                                                for (int xxx = -1; xxx <= 1; xxx++)
	                                                    for (int yyy = -1; yyy <= 1; yyy++)
	                                                    {
	                                                        if (level[(x + xxx) & 1023 | ((y + yyy) & 1023) << 10] == 0xffff00) level[(x + xxx) & 1023 | ((y + yyy) & 1023) << 10] = 0x000000;
	                                                    }
	
	                                                // Add it to the miner
	                                                miners[i].carrying_gold = 1;
	                                            }
 	                                        }
	                                    }
	                                }
	                        }
	                        else
	                        {
	                            // If the miner is dead, increase the miner death
	                            // animation one step
	                            if (miners[i].alive < 4 * 4) miners[i].alive++;
	                        }
	                    }
	
	                    // Move the camera if the left, right, up or down arrow keys are pressed
	                    if (keys[37] && xo > 8) xo -= 8;
	                    if (keys[39] && xo < level_width - 640) xo += 8;
	                    if (keys[38] && yo > 8) yo -= 8;
	                    if (keys[40] && yo < level_height - 480) yo += 8;
	                }
	
	                // Draw the rendered graphics to our offscreen image
	                // TODO(Jon): Figure out drawing text
// 	                gr2.drawImage(img, 0, 0, null);
					SDL_RenderClear(renderer);
					
					SDL_Texture* texture;
					{
						uint rmask, gmask, bmask, amask;
						
						version (LittleEndian)
						{
							rmask = 0x00ff0000;
							gmask = 0x0000ff00;
							bmask = 0x000000ff;
							amask = 0x00000000;
						}
						version (BigEndian)
						{
							rmask = 0x00ff0000;
							gmask = 0x0000ff00;
							bmask = 0x000000ff;
							amask = 0x00000000;
						}
						
						SDL_Surface* surface = SDL_CreateRGBSurfaceFrom(cast(void*)pixels, 640, 480, 32, 4 * 640, rmask, gmask, bmask, amask);
						import std.exception : enforce;
						texture = enforce(SDL_CreateTextureFromSurface(renderer, surface));
						SDL_FreeSurface(surface);
					}
					
					SDL_Rect sourceRect;
					sourceRect.x = 0;
					sourceRect.y = 0;
					sourceRect.w = 640;
					sourceRect.h = 480;
					SDL_Rect destinationRect = sourceRect;
					SDL_RenderCopy(renderer, texture, &sourceRect, &destinationRect);
					SDL_RenderPresent(renderer);
					
					SDL_DestroyTexture(texture);
	
	                // If the level hasn't started yet, display the level information and wait for a mouse click
	                if (!levelStarted)
	                {
	                	// TODO(Jon): Figure out drawing text
// 	                    gr2.setFont(new Font("Sans-Serif", Font.BOLD, 30));
// 	                    gr2.drawString(levelNames[current_level], 200, 100);
// 	                    gr2.setFont(new Font("Sans-Serif", Font.PLAIN, 12));
// 	                    gr2.drawString(infoStrings[current_level], 200, 116);
// 	                    gr2.drawString("(click to start)", 200, 132);
	                    if (mouseButton > 0)
	                    {
	                        levelStarted = true;
	                        mouseButton = 0;
	                    }
	                    roundsStartTime = Clock.currStdTime;
	                    lastTime = roundsStartTime;
	                }
	
	                // Render game stats
	                // Jon: Instead of ms, we're using hnsec, which is 10_000_000ths of a second
	                long passedTime = (Clock.currStdTime - roundsStartTime) / 10_000_000;
	                // TODO(Jon): Figure out drawing text
// 	                gr2.drawString("Miners: " + level_diggers, 10, 36);
// 	                gr2.drawString("Gold: " + score + " / " + level_target, 10, 48);
// 	                gr2.drawString("Time left: " + (level_timeLimit - passedTime), 10, 60);
// 	                gr.drawImage(img2, 0, 0, null);
	
					import core.thread;
	
	                // If the level was won, show splash, wait two seconds, then end main game loop
	                if (score >= level_target)
	                {
	                	debug writeln("Level passed");
	                	
	                    // Only increase the current level if we're not on the last level
	                    if (current_level < 6)
	                    {
	                        current_level++;
	                    }
	                    // TODO(Jon): Figure out drawing text
// 	                    gr2.setFont(new Font("Sans-Serif", Font.BOLD, 30));
// 	                    gr2.drawString("LEVEL PASSED!", 200, 100);
// 	                    gr.drawImage(img2, 0, 0, null);
	                    Thread.sleep(2000.dur!("msecs"));
	                    levelOver = true;
	                }
	                
					import std.conv;
	                debug writeln("Level passedTime: " ~ passedTime.to!string ~ " of limit: " ~ level_timeLimit.to!string);
	
	                // If the level was lost, show splash, wait two seconds, then end main game loop
	                // The level can be lost by losing all miners, running out of time, or pressing 'k'
	                if (level_diggers <= 0 || (level_timeLimit - passedTime) <= 0 || keys[75])
	                {
	                	debug if (level_diggers <= 0) writeln("Level failed because all diggers are dead.");
	                	import std.conv;
	                	debug if ((level_timeLimit - passedTime) <= 0) writeln("Level failed because time ran out. passedTime: " ~ passedTime.to!string ~ " of limit: " ~ level_timeLimit.to!string);
	                	
	                	// TODO(Jon): Figure out drawing text
// 	                    gr2.setFont(new Font("Sans-Serif", Font.BOLD, 30));
// 	                    gr2.drawString("LEVEL FAILED!", 200, 100);
// 	                    gr.drawImage(img2, 0, 0, null);
	                    Thread.sleep(2000.dur!("msecs"));
	                    levelOver = true;
	                }
	
	                // A small sleep prevents the game from eating all the cpu power
					Thread.sleep(10.dur!("msecs"));
					
					this.pumpEvents;
				}
 	            
 	            this.pumpEvents;
	        }
	        
	        // System.exit(0) makes sure nothing is left in the background
			import core.stdc.stdlib;
			exit(0);
		}
	}
	
	void pumpEvents()
	{
		// Pump events
		SDL_Event event;
		while (SDL_PollEvent(&event))
		{
			switch (event.type)
			{
				case SDL_QUIT:
				{
					// System.exit(0) makes sure nothing is left in the background
					import core.stdc.stdlib;
					exit(0);
				} break;
				case SDL_MOUSEBUTTONDOWN:
				case SDL_MOUSEBUTTONUP:
				{
					debug writeln("Mouse button pressed! " ~ (event.type == SDL_MOUSEBUTTONUP ? "Up" : "Down"));
					if (event.type == SDL_MOUSEBUTTONDOWN)
					{
						if (event.button.button == SDL_BUTTON_LEFT)
						{
							mouseButton = 1;
						}
						else if (event.button.button == SDL_BUTTON_RIGHT)
						{
							mouseButton = 3;
						}
					}
					else
					{
						mouseButton = 0;
					}
				} break;
				case SDL_KEYDOWN:
				case SDL_KEYUP:
				{
					// If the key pressed was ESC
					if (event.key.keysym.sym == SDLK_ESCAPE)
					{
						keys[27] = true;
					}
					else if (event.key.keysym.sym == SDLK_RSHIFT)
					{
						
					}
				} break;
				case SDL_MOUSEMOTION:
				{
					xMouse = event.motion.x;
					yMouse = event.motion.y;
					import std.conv;
					debug writeln("Mouse was moved! x: " ~ xMouse.to!string ~ " y: " ~ yMouse.to!string);
				} break;
				default: break;
			}
		}
	}
}

void main()
{
	debug writeln("Starting Dminers");
	
	// Load the SDL 2 library.
	DerelictSDL2.load();
	DerelictSDL2Image.load();
	
	auto game = Game();
	game.start;
	
	debug writeln("Finishing Dminers");
}
