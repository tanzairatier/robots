function love.load()
   -- -- -- -- -- -- -- -- -- -- -- --
   -- External Files
   -- -- -- -- -- -- -- -- -- -- -- --
   require 'graphics';

   -- -- -- -- -- -- -- -- -- -- -- --
   -- Game Parameters
   -- -- -- -- -- -- -- -- -- -- -- --
   iWORLD_HEIGHT = 45;
   iWORLD_WIDTH = 80;
   iNUM_ROBOTS = 30;
   bFLOCKING_MODE = false;
   iFLOCK_RADIUS = 20;

   -- -- -- -- -- -- -- -- -- -- -- --
   -- Direction Grid
   -- -- -- -- -- -- -- -- -- -- -- --
   aDIRECTION_GRID = {	q = -iWORLD_WIDTH - 1, 	w = -iWORLD_WIDTH, 		e = -iWORLD_WIDTH +1,
				a = -1,		s = 0,		d = 1,
				z = iWORLD_WIDTH - 1, 	x = iWORLD_WIDTH, 		c = iWORLD_WIDTH+1};

   -- -- -- -- -- -- -- -- -- -- -- --
   -- Shake the dice
   -- -- -- -- -- -- -- -- -- -- -- --
   math.randomseed(os.time());

   -- -- -- -- -- -- -- -- -- -- -- --
   -- Initialize Graphics (one time call)
   -- -- -- -- -- -- -- -- -- -- -- --
   initialize_graphics();

   -- -- -- -- -- -- -- -- -- -- -- --
   -- Let's start a new game
   -- -- -- -- -- -- -- -- -- -- -- --
   new_game();
end

function new_game()
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Initiate Player Position
   -- -- -- -- -- -- -- -- -- -- -- --
   iPLAYER_POSITION = random_location();
   aROBOT_POSITIONS = {};

   --Set the Robots at random locations
   for i=1, iNUM_ROBOTS do table.insert(aROBOT_POSITIONS, random_location()); end
end

function is_all_scrapped()
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Determine if all robots are dead
   -- -- -- -- -- -- -- -- -- -- -- --
   for i, v in ipairs(aROBOT_POSITIONS) do
      if not (count(aROBOT_POSITIONS, v) > 1) then return false; end
   end
   return true; --can only get here if all are scrapped
end

function count(list, item)
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Count occurences of item in array-list
   -- -- -- -- -- -- -- -- -- -- -- --
   local cnt = 0;
   for k = 1, iNUM_ROBOTS do
      if (list[k] == item) then cnt = cnt + 1; end
   end

   return cnt;
end

function random_direction()
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Generate random direction in grid
   -- -- -- -- -- -- -- -- -- -- -- --
   local rand_num = math.random(9);
   local index = 1;

   --since pairs aren't indexed, we do it ourselves
   for i,v in pairs(aDIRECTION_GRID) do
      if (index == rand_num) then return i; end
	  index = index + 1;
   end
end

function get_best_direction(robot, player)
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Find best 'homing' direction for Robot to move in
   -- -- -- -- -- -- -- -- -- -- -- --
   local lowest = 999999999;
   local dist = lowest;
   local dir = 's';

   for i,v in pairs(aDIRECTION_GRID) do
      dist = manhattan_distance(robot + v, player);
      if (dist <= lowest) then lowest = dist; dir = i; end
   end

   return dir;
end

function choose_direction(robot, player)
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Choose a direction for Robot to move in
   -- -- -- -- -- -- -- -- -- -- -- --
   local dir = 's';

   if bFLOCKING_MODE then
      --flock to the player
	  dir = get_best_direction(robot, player);
   else
      --flock to the player only if close enough
      if (euclidean_distance(robot, player) < iFLOCK_RADIUS) then
	     dir = get_best_direction(robot, player);
      else
         repeat
            dir = random_direction();
         until not (outside_boundaries(robot + aDIRECTION_GRID[dir]));
      end
   end

   return dir;
end

function random_location()
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Generate a random safe location in the game world
   -- -- -- -- -- -- -- -- -- -- -- --
   local r = 0;
   repeat
      r = math.random(iWORLD_HEIGHT*iWORLD_WIDTH);
   until not (outside_boundaries(r));
   return r;
end

function outside_boundaries(location)
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Test if a location is inside the game world
   -- -- -- -- -- -- -- -- -- -- -- --
   local A = convert(location);
   if (A.x <= 1 or A.y <= 1 or A.x >= iWORLD_WIDTH-1 or A.y >= iWORLD_HEIGHT) then return true; else return false; end
end

function problems_with_movement(key)
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Test for problems with a particular movement direction
   -- -- -- -- -- -- -- -- -- -- -- --
   if (aDIRECTION_GRID[key] == nil) then return true;
   elseif (outside_boundaries((iPLAYER_POSITION + aDIRECTION_GRID[key]))) then return true;
   end

   return false; -- no problems
end

function teleport()
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Teleport to random (safe) location in game world
   -- -- -- -- -- -- -- -- -- -- -- --
   local pos = 0;

   repeat
      pos = random_location();
   until (count(aROBOT_POSITIONS, pos) == 0);

   return pos;
end
function love.keypressed(key, unicode)
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Keys that can be pressed
   -- -- -- -- -- -- -- -- -- -- -- --

   --teleport
   if key == 't' and not (count(aROBOT_POSITIONS, iPLAYER_POSITION) > 0) then
      iPLAYER_POSITION = teleport();

   --leave game
   elseif key == 'l' then
      player_exit();

   --play again
   elseif key == 'p' then
      new_game();

   --flocking mode toggler
   elseif key == 'f' then
      bFLOCKING_MODE = not(bFLOCKING_MODE);

   --movement keys
   elseif not (problems_with_movement(key)) and not (count(aROBOT_POSITIONS, iPLAYER_POSITION) > 0) then
      iPLAYER_POSITION = iPLAYER_POSITION + aDIRECTION_GRID[key];
	  robots_move();
   end
end

function player_exit()
   os.exit();
end

function robots_move()
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Move each robot
   -- -- -- -- -- -- -- -- -- -- -- --
   for i,v in ipairs(aROBOT_POSITIONS) do
      --Ignore scrap
      if not (count(aROBOT_POSITIONS, v) > 1) then aROBOT_POSITIONS[i] = aROBOT_POSITIONS[i] + aDIRECTION_GRID[choose_direction(v, iPLAYER_POSITION)]; end
   end
end

function manhattan_distance(p, q)
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Manhattan Distance
   -- -- -- -- -- -- -- -- -- -- -- --
   local A = convert(p);
   local B = convert(q);
   return math.abs(A.x- B.x) + math.abs(A.y - B.y);
end

function euclidean_distance(p, q)
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Euclidean Distance
   -- -- -- -- -- -- -- -- -- -- -- --
   local A = convert(p);
   local B = convert(q);
   return math.sqrt((A.x- B.x)^2+ (A.y - B.y)^2);
end

function convert(i)
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Convert between 2D coords and 1D
   -- -- -- -- -- -- -- -- -- -- -- --
   local D = {};
   D.x = math.mod(i, iWORLD_WIDTH);
   D.y = ((i - D.x)/iWORLD_WIDTH) + 1;
   return D;
end
