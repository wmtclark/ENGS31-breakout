----------------------------------------------------------------------------------
-- Company:         Engs 31 / CoSc 56 20X
-- Engineer:       Nathan Schneider
-- 
-- Create Date:     8/25/20
-- Design Name:     Final Project
-- Module Name:     game_state_controller
-- Project Name:     Final Project
-- Target Devices:  Artix7 / Basys3
-- Tool Versions:   Vivado 2016.4
-- Description:     holds and controls the game state 
-- for the engs 31 final project
--                  
--
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- modeled after lab 4 shell from 20x engs 31 course
----------------------------------------------------------------------------------
LIBRARY ieee;
use IEEE.numeric_std.ALL;
USE ieee.std_logic_1164.all;
USE ieee.math_real.ALL;

ENTITY game_state_controller IS
	PORT(
		mclk	:	IN		STD_LOGIC;	
        game_on         :   IN      STD_LOGIC;	
		left,right		:	IN	STD_LOGIC;	
        column,row      :   IN STD_LOGIC_VECTOR (9 downto 0);
        color_value		:	OUT	STD_LOGIC_VECTOR(3 downto 0);
        game_over         :   OUT STD_LOGIC;
        score       :   OUT STD_LOGIC_VECTOR(9 downto 0)
		);
		
END game_state_controller;
ARCHITECTURE behavior OF game_state_controller IS

--game sizes
CONSTANT game_width 	:	INTEGER := 640;    	
CONSTANT game_height	 	:	INTEGER := 480;		
CONSTANT paddle_width	 	:	INTEGER := 100;		
CONSTANT paddle_height	 	:	INTEGER := 5;		
CONSTANT ball_radius        :   INTEGER := 1;


--defines the framerate and the counter that regularly increases difficulty
constant framerate:integer:=60;
signal diff_counter: integer:=0;
constant difficulty_seconds:integer:=15;
constant diff_threshold: integer:=difficulty_seconds*framerate;



--frame clock divider
--constant fclk_DIVIDER_VALUE: integer :=   100000000/framerate / 2;
constant fclk_DIVIDER_VALUE: integer := 100 / 2; -- framerate for testbenches

constant COUNT_LEN: integer := integer(ceil( log2( real(fclk_DIVIDER_VALUE) ) ));
signal fclkdiv: unsigned(COUNT_LEN-1 downto 0) := (others => '0');  -- clock divider counter
signal fclk: std_logic := '0';          -- internal frame clock


--signals for tracking the ball
signal ball_x: INTEGER := 320;
signal ball_y: INTEGER := 400;
signal ball_v_x: INTEGER:= -1;
signal ball_v_y: INTEGER:= 1;


--signals for tracking paddle
signal paddle_x: INTEGER:= 100;
constant paddle_y: INTEGER:= game_height - paddle_height;
constant paddle_speed: integer:=5;

--constants for the brick layout
constant brick_buffer_x: INTEGER := 20;
constant brick_buffer_y: INTEGER := 60;
constant brick_space_x,brick_space_y: INTEGER := 5;
constant brick_width: INTEGER := 59;
constant brick_height: INTEGER := 27;
constant num_brick_x:INTEGER:= 9;
constant num_brick_y: INTEGER:= 8;
constant right_offset:integer:=10;


--setup for storing the frame of bricks
type frame_store is array (num_brick_y-1 downto 0,num_brick_x-1 downto 0) of std_logic;
signal frame : frame_store:=(others=>(others=>'1'));

--signals for the row and column needed for VGA
signal irow,icolumn: integer:=0;


--signals for tracking and resetting store
signal score_reset_enable: std_logic := '0';
signal int_score: integer:=0;

BEGIN


--clock divivdef for the game frame
frame_clock_divider: process(mclk)
begin
	if rising_edge(mclk) then
	   	if fclkdiv = fclk_DIVIDER_VALUE-1 then 
			fclkdiv <= (others => '0');
			fclk <= NOT(fclk);
		else
			fclkdiv <= fclkdiv + 1;
		end if;
	end if;
end process frame_clock_divider;

--helper function to pass converted values
converter: process(row,column,int_score)
begin
    irow <= to_integer(unsigned(row));
    icolumn <= to_integer(unsigned(column));
    score <= std_logic_vector(to_unsigned(int_score,10));
    
end process converter;


--main game loop for updating the new state
game_update: process(fclk)
begin
    if rising_edge(fclk) then
        game_over <= '0';
          -- if the game should be running
         if game_on = '1' then
            ball_y <= ball_y + ball_v_y; -- move the ball
            ball_x <= ball_x + ball_v_x;
            
            if (diff_counter >= diff_threshold) then -- increases speed every 15 seconds
                if ball_v_y > 0 then
                    ball_v_y <= ball_v_y +1;
                else 
                    ball_v_y <= ball_v_y -1;
                end if;
                diff_counter <= 0;
            else
                diff_counter <= diff_counter + 1;
            end if;
            
            
            --manages inputs for the paddles to  move them
            if (left ='1' and right='0') and (paddle_x >= 0) then --limit check
                paddle_x <= paddle_x - paddle_speed;
            elsif (left ='0' and right='1') and (paddle_x + paddle_width <= game_width-right_offset) then --limit check
                paddle_x <= paddle_x +  paddle_speed;
            end if;
            -- top boundary
            if ball_y + ball_v_y<= ball_radius  then
                ball_v_y <= -1 * ball_v_y;
            end if;
            -- boundaries for the horizontal walls 
            if ball_x >= game_width - ball_radius - ball_v_x - right_offset or ball_x + ball_v_x <= ball_radius  then
                ball_v_x <= -1 * ball_v_x;
            end if;
            
            -- collision detection for the bottom paddle, checks for plus radius AND minus radius
            if (ball_y + ball_v_y + ball_radius >= game_height - paddle_height) and
               ( (ball_x + ball_v_x + ball_radius >= paddle_x) or
                (ball_x + ball_v_x - ball_radius >= paddle_x)   ) and
               ( (ball_x + ball_v_x + ball_radius <= paddle_x + paddle_width) or 
               (ball_x + ball_v_x - ball_radius <= paddle_x + paddle_width)  ) then
               
               
               --divides the ball into five sections, with outcome velocity dependent on which section you hit
               if  (ball_x + ball_v_x - paddle_x > 4*paddle_width/5) then
                    ball_v_x <= 2;
               elsif  (ball_x + ball_v_x - paddle_x > 3*paddle_width/5) then
                    ball_v_x <= 1;
               elsif  (ball_x + ball_v_x - paddle_x > 2*paddle_width/5) then
                    ball_v_x <= 0;
               elsif  (ball_x + ball_v_x - paddle_x > 1*paddle_width/5) then
                    ball_v_x <= -1;
               else  
                    ball_v_x <= -2;
               end if;
               ball_v_y <= -1 * abs(ball_v_y);
               
            -- check bottom 'wall', if it hits, reset the signals
            elsif ball_y >= game_height - ball_radius - ball_v_y then
                game_over <= '1';
                ball_v_y <= -1 * ball_v_y;
                ball_x <= 320;
                ball_y <= 400;
                score_reset_enable <= '1';
                paddle_x <= 340;
                ball_v_x <= -1;
                ball_v_y <= 1;
                diff_counter <= 0;
                frame <= (others=>(others=>'1'));  
            end if; 
            
            --brick collision detection for x direction, adds x velocity to the position, but not y, see report for explanation why
            if  (ball_x + ball_v_x - brick_buffer_x < ( num_brick_x * (brick_width + brick_space_x))) and 
                (ball_x + ball_v_x  > (brick_buffer_x)) and
               ((ball_x + ball_v_x - brick_buffer_x )mod (brick_width +brick_space_x)<brick_width) and --checks bounds for x bricks
               
                (ball_y - brick_buffer_y < ( num_brick_y * (brick_height + brick_space_y))) and
                (ball_y  > (brick_buffer_y)) and
               ((ball_y - brick_buffer_y )mod (brick_height +brick_space_y)<brick_height) and --checks boudns for y bricks
               
                 (frame( 
                (ball_y - brick_buffer_y) / (brick_height+brick_space_y),
                  (ball_x + ball_v_x -brick_buffer_x) / (brick_width+brick_space_x)) --makes sure the THIS brick exists
                ='1') 
                then
                    frame(
                  (ball_y  - brick_buffer_y) / (brick_height+brick_space_y),
                  (ball_x + ball_v_x -brick_buffer_x) / (brick_width+brick_space_x)) <= '0'; --remove the brick
                  ball_v_x <= -1 * ball_v_x; --bounce
                  int_score <= int_score + 8 - (ball_y-brick_buffer_y) / (brick_height+brick_space_y) ; --add points depending on row
            end if;
                
            --brick collision detection for y direction, adds y velocity to the position, but not x
            if  (ball_y + ball_v_y - brick_buffer_y < ( num_brick_y * (brick_height + brick_space_y))) and
                (ball_y + ball_v_y  > (brick_buffer_y)) and
               ((ball_y + ball_v_y - brick_buffer_y )mod (brick_height +brick_space_y)<brick_height) and --checks boudns for y bricks

                (ball_x - brick_buffer_x < ( num_brick_x * (brick_width + brick_space_x))) and
                (ball_x  > (brick_buffer_x)) and
               ((ball_x - brick_buffer_x )mod (brick_width +brick_space_x)<brick_width) and --checks bounds for x bricks
               
                (frame(
                (ball_y + ball_v_y - brick_buffer_y) / (brick_height+brick_space_y),
                  (ball_x -brick_buffer_x) / (brick_width+brick_space_x)) --makes sure the THIS brick exists
                ='1') 
                then
                    frame(
                  (ball_y + ball_v_y - brick_buffer_y) / (brick_height+brick_space_y),
                  (ball_x -brick_buffer_x) / (brick_width+brick_space_x)) <= '0';  --remove the brick
                  ball_v_y <= -1 * ball_v_y;
                  int_score <= int_score + 8 - (ball_y-brick_buffer_y) / (brick_height+brick_space_y) ; --add points depending on row
            end if;
            -- resetting the score for a new round 
            if score_reset_enable = '1' then 
                int_score <= 0;
                score_reset_enable <= '0'; 
            end if;
        end if;

    end if;
end process game_update;




color_lookup: process(icolumn,irow) 
begin
     -- check if the pixel is out of bounds
    if (irow > game_height OR irow < 0 or icolumn > game_width OR icolumn < 0) then
        color_value <= "0000"; --out of bounds
        
     --check if the pixel lies within the paddle
    elsif ((irow > paddle_y) AND (icolumn < paddle_x + paddle_width) AND (icolumn > paddle_x)) then
        color_value <= "0001";
        
     --check if the pixel lies within the ball
    elsif (irow >= ball_y and irow <= ball_y +ball_radius and icolumn >= ball_x and icolumn <=ball_x + ball_radius) then
        color_value <= "0010";  --ball
        
    elsif ( --same method as above, check if the pixel lies within a brick
     (irow  < (brick_buffer_y + num_brick_y * (brick_height + brick_space_y))) and 
     (irow  > (brick_buffer_y)) and
     ((irow -  brick_buffer_y)mod(brick_height+brick_space_y)<brick_height)and
     
     (icolumn  < (brick_buffer_x+ num_brick_x * (brick_width + brick_space_x))) and
     (icolumn  > (brick_buffer_x)) and
     ((icolumn-brick_buffer_x)mod(brick_width +brick_space_x)<brick_width) and
      (frame(
      (irow-brick_buffer_y) / (brick_height+brick_space_y),
      (icolumn-brick_buffer_x) / (brick_width+brick_space_x))
      ='1')
      ) then
        if (irow-brick_buffer_y) / (brick_height+brick_space_y)=0 then  --assign a color based on the row
            color_value <= "1000";
        elsif(irow-brick_buffer_y) / (brick_height+brick_space_y)=1 then 
            color_value <= "1001";
        elsif(irow-brick_buffer_y) / (brick_height+brick_space_y)=2 then 
            color_value <= "1010";
        elsif(irow-brick_buffer_y) / (brick_height+brick_space_y)=3 then 
            color_value <= "1011";
        elsif(irow-brick_buffer_y) / (brick_height+brick_space_y)=4 then 
            color_value <= "1100";
        elsif(irow-brick_buffer_y) / (brick_height+brick_space_y)=5 then 
            color_value <= "1101";
        elsif(irow-brick_buffer_y) / (brick_height+brick_space_y)=6 then 
            color_value <= "1110";
        elsif(irow-brick_buffer_y) / (brick_height+brick_space_y)=7 then 
            color_value <= "1111";
        end if;
    else
    
        color_value <="0000"; --catchall
    end if;
end process color_lookup;



END behavior;