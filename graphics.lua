function initialize_graphics()
   -- -- -- -- -- -- -- -- -- -- -- --
   -- Game World Parameters
   -- -- -- -- -- -- -- -- -- -- -- --
   iCELL_WIDTH = 12;
   iCELL_HEIGHT = 12;
   iOFFSET = {x = (love.graphics.getWidth()-(iWORLD_WIDTH+2)*iCELL_WIDTH)*0.50, y = (love.graphics.getHeight()-(iWORLD_HEIGHT+1)*iCELL_HEIGHT)*0.70};

   -- -- -- -- -- -- -- -- -- -- -- --
   -- Defining colors for different objects
   -- -- -- -- -- -- -- -- -- -- -- --
   colors = {};
   colors["player"] = {255, 255, 0, 255};
   colors["robot"] = {255, 0, 0, 255};
   colors["robot scrap"] = {255, 255, 255, 255};
   colors["wall"] = {0, 255, 0, 255};
   colors["player loses"] = {0, 255, 255, 255};

   -- -- -- -- -- -- -- -- -- -- -- --
   -- Define images
   -- -- -- -- -- -- -- -- -- -- -- --
   images = {};
   images["title"] = love.graphics.newImage("images/robots_title.png");
   images["winner"] = love.graphics.newImage("images/winner.png");
   images["loser"] = love.graphics.newImage("images/loser.png");

   --Text Strings
   strings = {};
   strings["user options"] = "qwe/asd/zxc to move. (T)eleport. (L)eave. (P)lay Again/restart.  Change (F)locking mode.";
end

function love.draw()

   local function draw_sprite(sprite, location)
      local A = convert(location);
      love.graphics.draw(sprites[sprite], A.x * iCELL_WIDTH + iOFFSET.x, A.y * iCELL_HEIGHT + iOFFSET.y);
   end

   local function draw_square(name, location)
      local A = convert(location);
	  love.graphics.setColor(unpack(colors[name]));
	  love.graphics.rectangle("fill", A.x * iCELL_WIDTH + iOFFSET.x, A.y * iCELL_HEIGHT + iOFFSET.y, iCELL_WIDTH, iCELL_HEIGHT);
   end

   -- -- -- -- -- -- -- -- -- -- -- --
   -- Draw instructions and title
   -- -- -- -- -- -- -- -- -- -- -- --
   love.graphics.setColor(255, 255, 255, 255);
   love.graphics.print(strings["user options"], 50, ((love.graphics.getHeight()-16)*0.15)); --instructions on how to play//todo: use something graphical instead
   love.graphics.draw(images["title"], (love.graphics.getWidth()-640)*0.5, ((love.graphics.getHeight()-64)*0.05));

   -- -- -- -- -- -- -- -- -- -- -- --
   -- Legend
   -- -- -- -- -- -- -- -- -- -- -- --
   local names = {"player", "robot", "robot scrap", "player loses", "wall"};
   for i=1,5 do
      love.graphics.setColor(unpack(colors[names[i]]));
      love.graphics.rectangle("fill", (love.graphics.getWidth() - iCELL_WIDTH)*.85, (love.graphics.getHeight() - iCELL_HEIGHT)*0.05+((i-1)*16), iCELL_WIDTH, iCELL_HEIGHT);
	  love.graphics.print(names[i], 16+(love.graphics.getWidth() - iCELL_WIDTH)*.85, (love.graphics.getHeight() - iCELL_HEIGHT)*0.05+((i-1)*16));
   end

   -- -- -- -- -- -- -- -- -- -- -- --
   -- Draw Game World
   -- -- -- -- -- -- -- -- -- -- -- --
   love.graphics.setColor(255, 255, 255, 255);
   for i = 1, iWORLD_WIDTH do
      --draw a vertical line
	  local topcoord = {x = iOFFSET.x + i*iCELL_WIDTH, y = iOFFSET.y + ( 1)*iCELL_HEIGHT};
	  local botcoord = {x = iOFFSET.x + i*iCELL_WIDTH, y = iOFFSET.y + (iWORLD_HEIGHT+1)*iCELL_HEIGHT};
      love.graphics.line(topcoord.x, topcoord.y, botcoord.x, botcoord.y);
   end

   for j = 1, iWORLD_HEIGHT+1 do
      --draw a horizontal line
	  local leftcoord =  {x = iOFFSET.x + ( 1)*iCELL_WIDTH, y = iOFFSET.y + j*iCELL_HEIGHT};
	  local rightcoord = {x = iOFFSET.x + (iWORLD_WIDTH)*iCELL_WIDTH, y = iOFFSET.y + j*iCELL_HEIGHT};
	  love.graphics.line(leftcoord.x, leftcoord.y, rightcoord.x, rightcoord.y);
   end

   --Draw the upper wall
   for i = 1, (iWORLD_WIDTH-1) do
	  draw_square("wall", i);
   end

   --Draw the left wall
   for i = iWORLD_WIDTH+1, (iWORLD_HEIGHT*iWORLD_WIDTH - 1), iWORLD_WIDTH do
	  draw_square("wall", i);
   end

   --Draw the right wall
   for i = iWORLD_WIDTH-1, (iWORLD_HEIGHT*iWORLD_WIDTH), iWORLD_WIDTH do
	 draw_square("wall", i);
   end

   --Draw the bottom wall
   for i = (iWORLD_HEIGHT*iWORLD_WIDTH)-iWORLD_WIDTH + 1, ((iWORLD_HEIGHT*iWORLD_WIDTH)-1) do
	  draw_square("wall", i);
   end

   -- -- -- -- -- -- -- -- -- -- -- --
   -- Draw Robots
   -- -- -- -- -- -- -- -- -- -- -- --
   for i,v in ipairs(aROBOT_POSITIONS) do
      if (count(aROBOT_POSITIONS, v) > 1) then
		 draw_square("robot scrap", v);
      else
		 draw_square("robot", v);
      end
   end

   -- -- -- -- -- -- -- -- -- -- -- --
   -- Draw the Player
   -- -- -- -- -- -- -- -- -- -- -- --
   local player_sprite_width = 128;
   local player_sprite_height = 32;
   if (count(aROBOT_POSITIONS, iPLAYER_POSITION) > 0) then
      --game over
	  draw_square("player loses", iPLAYER_POSITION);
	  love.graphics.draw(images["loser"], (love.graphics.getWidth()-player_sprite_width)*0.05, (love.graphics.getHeight() - player_sprite_height)*0.985);
   else
	  draw_square("player", iPLAYER_POSITION);

      --Did you win?
      if (is_all_scrapped()) then love.graphics.draw(images["winner"],  (love.graphics.getWidth()-player_sprite_width)*0.05, (love.graphics.getHeight() - player_sprite_height)*0.985); end
   end

end
