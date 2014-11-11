pulldownmenu = {};

function pulldownmenu:make()
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Create a new pull down menu
   -- -- -- -- -- -- -- -- -- -- -- -- -- --

   --initialize
   local frame = {};

   --default settings
   frame.size = {300, 20};
   frame.position = {30, 30};
   frame.color = {185, 185, 185, 255};
   frame.object_type = "pull-down-box";
   frame.arrow = {};
   frame.arrow.color = {85, 85, 85, 255};
   frame.arrow.position = {frame.position[1] + frame.size[1]*0.95, frame.position[2] + 0};
   frame.arrow.size = {frame.size[1]*0.05, frame.size[2]};
   frame.expanded = false;
   frame.list = {"Heal", "Fireball", "Iceblast", "Protect", "Lightning"};
   frame.selected_index = 1;


   --functional callbacks
   frame.setPosition = function(x, y) pulldownmenu:setPosition(x, y, frame); end
   frame.setColor = function(c1, c2, c3, c4) pulldownmenu:setColor(c1, c2, c3, c4, frame); end
   frame.setArrowboxColor = function(c1, c2, c3, c4) pulldownmenu:setArrowboxColor(c1, c2, c3, c4, frame); end
   frame.setList = function(list) pulldownmenu:setList(list, frame); end

   frame.getSelectedItem = function() return pulldownmenu:getSelectedItem(frame); end

   --callbacks
   frame.mousereleased = function(x, y, button) pulldownmenu:mouserelease_event(x, y, button, frame); end
   frame.mousepressed = function(x, y, button) pulldownmenu:mousepressed_event(x, y, button, frame); end
   frame.draw = function() pulldownmenu:draw_event(frame); end

   --return it
   return frame;
end


function pulldownmenu:draw_event(f)

   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- What to Draw
   -- -- -- -- -- -- -- -- -- -- -- -- -- --

   --draw the main frame of the pulldownmenu
   love.graphics.setColor(unpack(f.color));
   love.graphics.rectangle('fill', f.position[1], f.position[2], f.size[1], f.size[2]);

   --draw a border around the main frame
   love.graphics.setColor(150, 150, 150, 255);
   love.graphics.rectangle('line', f.position[1], f.position[2], f.size[1], f.size[2]);

   --if the pulldownmenu is expanded, draw the dropdown and each entry
   if (f.expanded) then
	  for i,v in ipairs(f.list) do
	     --background of the item entry
		 love.graphics.setColor(unpack(f.color));
		 love.graphics.rectangle('fill', f.position[1], f.position[2] + i*f.size[2], f.size[1], f.size[2]);

		 --print the text for the item entry
		 love.graphics.setColor(20, 0, 180, 255);
		 love.graphics.print(v, f.position[1] + 3, f.position[2] + i*f.size[2] + 3);
	  end
   end

   --draw the box for the drop-down arrow
   love.graphics.setColor(unpack(f.arrow.color));
   love.graphics.rectangle('fill', f.arrow.position[1], f.arrow.position[2]+1, f.arrow.size[1]-1, f.arrow.size[2]-2);

   --draw the arrow within the drop-down arrowbox
   love.graphics.setColor(20, 20, 20, 255);
   local triangle = {};
   triangle[1] = {x = (f.arrow.position[1] + (f.arrow.size[1] - (f.arrow.size[1]*0.50))*0.50),
				  y = (f.arrow.position[2] + (f.arrow.size[2] - (f.arrow.size[2]*0.50))*0.50)};
   triangle[2] = {x = (triangle[1].x + (f.arrow.size[1]*0.50)),
				  y = triangle[1].y};
   triangle[3] = {x = (triangle[1].x + (f.arrow.size[1]*0.50)*0.50),
				  y = (triangle[1].y + (f.arrow.size[2]*0.50))};
   love.graphics.polygon('fill', triangle[1].x, triangle[1].y, triangle[2].x, triangle[2].y,triangle[3].x, triangle[3].y);

   --print the selected entry
   love.graphics.setColor(20, 0, 180, 255);
   love.graphics.print(f.list[f.selected_index], f.position[1]+3, f.position[2]+3);
end

function pulldownmenu:mouserelease_event(x, y, button, f)
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- What happens when a mouse button is released
   -- -- -- -- -- -- -- -- -- -- -- -- -- --

end

function pulldownmenu:mousepressed_event(x, y, button, f)

   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- What happens when a mouse button is pressed
   -- -- -- -- -- -- -- -- -- -- -- -- -- --

  if not (f.expanded) then
	 --clicked on arrow to expand
	 if (x >= f.arrow.position[1]) and (x <= (f.arrow.position[1] + f.arrow.size[1])) and
	   (y >= f.arrow.position[2]) and (y <= (f.arrow.position[2] + f.arrow.size[2])) then
		f.expanded = true;
		f.arrow.color = {85, 85, 85, 255};
	 end
  elseif (f.expanded) then
	 --clicked on arrow to unexpand
	 if (x >= f.arrow.position[1]) and (x <= (f.arrow.position[1] + f.arrow.size[1])) and
		(y >= f.arrow.position[2]) and (y <= (f.arrow.position[2] + f.arrow.size[2])) then
		f.expanded = false;
		f.arrow.color = {85, 85, 85, 255};
	 end

	 --clicked on an item in the list
	 if (x >= f.position[1]) and (x <= (f.position[1] + f.size[1])) then
		for i,v in ipairs(f.list) do
		   if (y >= (f.position[2] + f.size[2]*i) and y <= (f.position[2] + f.size[2]*(i+1))) then
			  f.selected_index = i;
			  f.expanded = false;
			  break;
		   end
		end
	 end
  end
end

function pulldownmenu:setColor(c1, c2, c3, c4, f)
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Change color of the main frame
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   f.color = {c1, c2, c3, c4};
end

function pulldownmenu:setArrowboxColor(c1, c2, c3, c4, f)
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Change color of the arrowbox button
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   f.arrow.color = {c1, c2, c3, c4};
end

function pulldownmenu:setPosition(x, y, f)
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Affix position of the object
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   f.position = {x, y};

   --update arrowbox relative
   f.arrow.position = {f.position[1] + f.size[1]*0.95, f.position[2] + 0};
end

function pulldownmenu:setList(list, f)
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Set the list with this list
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   f.list = {};
   for i,v in ipairs(list) do table.insert(f.list, v); end
end

function pulldownmenu:addToList(item, f)
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Add an item to the list
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   table.insert(f.list, item);
end

function pulldownmenu:getSelectedItem(f)
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Get the selected item
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   return f.list[f.selected_index];
end

function pulldownmenu:getSelectedIndex(f)
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Get the selected index
   -- -- -- -- -- -- -- -- -- -- -- -- -- --
   return f.selected_index;
end
