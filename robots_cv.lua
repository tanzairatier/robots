function robots()

   --Game Constants
   _H = 16;	--height of game world
   _W = 64;	--width of gasme world
   _N = 10;	--number of robots
   
   --Define movement keys
   directions = {	q = -_W - 1, 	w = -_W, 		e = -_W +1,
				a = -1,		s = 0,		d = 1,
				z = _W - 1, 	x = _W, 		c = _W+1};


   --Shake the dice
   math.randomseed(os.time());
   
   --Init Game Parameters
   POS = 544;	--player's position
   R = {};		--robot's position
   
   --Set the Robots at random locations
   for i=1, _N do table.insert(R, math.random(_H * _W)); end
   

--Main Game stuff
---------------------------------------------------------
   local function MainGame()
   
      --Draw the Game World -- Console Version
      for i=1, _H do
         for j=1, _W do
	    if (i == 1 or i == _H or j == 1 or j == _W) then io.write("-");
	    elseif (i*_W + j == POS) then io.write("P");
	    elseif (scrap_here(i,j)) then io.write("#");
	    elseif (robot_here(i,j)) then io.write("!");
	    else io.write(" "); end
	 end
	 print("");
      end
      
      --UI --Console Version
      print("qwe/asd/zxc to move, (t)eleport, (l)eave");
      
      --Gather Input --Console Version
      input = io.read();
      
      --Parse Input --Console Version
      if (input == "l") then return "You have left the game.  Thanks for Playing.";
      elseif (input == "t") then POS = math.random(_H * _W);
      elseif not (directions[input] == nil) then 
         if (POS + directions[input] > 0 and POS+directions[input] < 1025) then POS = POS + directions[input]; end
      end
      
      --Robots move towards the player
      for i,v in ipairs(R) do
	 --if a robot isn't scrapped, then it can move in a direction closer to the player
         if not (count(R, v) > 1) then R[i] = R[i] + directions[choose_direction(v, POS)]; end
      end
      
      --Bad news if player in same spot as a robot
     if (count(R, POS) > 0) then bad_news(); end
     
     --Good news if all robots are scrapped
     if (is_all_scrapped()) then good_news(); end
      
      --Recursive/next game turn
      MainGame();
   end
---------------------------------------------------------
   
   --Run the Game and print the Result
   print(MainGame());
end

function bad_news()
   print("Oh noes!  Game Over!");
end

function good_news()
   print("Yay! You've won!");
end

function is_all_scrapped()
   --Determines if all robots are scrapped
   for i, v in ipairs(R) do
      if not (count(R, v) > 1) then return false; end
   end
   return true;
end

function scrap_here(i, j)
   --For Console Version; determines if there is scray at this 2d coordinate
   if (count(R, get_robot(i, j)) > 1) then return true; else return false; end
end

function count(list, item)
   --Count number of items in this list
   cnt = 0;
   for k = 1, _N do
      if (list[k] == item) then cnt = cnt + 1; end
   end
   
   return cnt;
end

function get_robot(i, j)
   --For Console Version; finds the robot (if any) located at this 2d coordinate
   for k = 1, _N do
      if (R[k] == (i*_W + j)) then return R[k]; end
   end
   return -1; -- on fail
end

function robot_here(i, j)
   --For Console Version; determines if a robot is in this 2d coordinate
   for k = 1, _N do
      if ((i*64 + j) == R[k]) then return true; end
   end
   return false;
end

function largest_fixnum()
   return 999999999;
end

function choose_direction(robot, player)
   --Try each direction and choose the one with minimal distance to the player
   lowest = largest_fixnum();
   
   for i,v in pairs(directions) do
      dist = manhattan_distance(robot + v, player);
      if (dist < lowest) then lowest = dist; dir = i; end
   end

   return dir;
end

function manhattan_distance(p, q)
   --Calculates manhattan distance between two locations
   A = convert(p);
   B = convert(q);
   return math.abs(A.x- B.x) + math.abs(A.y - B.y);
end

function convert(i)
   --Convert single integer location to 2d-coordinates
   D = {};
   D.x = math.mod(i, _W);
   D.y = ((i - D.x)/_W) + 1;
   return D;
end

function demo_robots()
   robots();
end
   
--Run the Game
demo_robots();