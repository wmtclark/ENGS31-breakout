LIBRARY ieee;
use IEEE.numeric_std.ALL;
USE ieee.std_logic_1164.all;
USE ieee.math_real.ALL;
ENTITY game_state_controller IS
	PORT(
		mclk	:	IN		STD_LOGIC;	
        reset_game		:	IN		STD_LOGIC;
        game_on         :   IN      STD_LOGIC;	
		left,right		:	IN	STD_LOGIC;	
        column,row      :   IN STD_LOGIC_VECTOR (9 downto 0);
        color_value		:	OUT	STD_LOGIC_VECTOR(1 downto 0);
        uball_x,uball_y   :   OUT STD_LOGIC_VECTOR(9 downto 0);
        game_over         :   OUT STD_LOGIC;
        upaddle_x   :   OUT STD_LOGIC_VECTOR(9 downto 0)
		);
END game_state_controller;
ARCHITECTURE behavior OF game_state_controller IS
CONSTANT game_width 	:	INTEGER := 640;    	
CONSTANT game_height	 	:	INTEGER := 480;		
CONSTANT paddle_width	 	:	INTEGER := 100;		
CONSTANT paddle_height	 	:	INTEGER := 10;		
CONSTANT ball_radius        :   INTEGER := 1;

constant fclk_DIVIDER_VALUE: integer :=   1111111 / 2;
--constant fclk_DIVIDER_VALUE: integer := 3333333 / 2;
--constant fclk_DIVIDER_VALUE: integer := 100 / 2;

constant COUNT_LEN: integer := integer(ceil( log2( real(fclk_DIVIDER_VALUE) ) ));
signal fclkdiv: unsigned(COUNT_LEN-1 downto 0) := (others => '0');  -- clock divider counter
signal fclk_unbuf: std_logic := '0';    -- unbuffered vlck clock 
signal fclk: std_logic := '0';          -- internal vide clock



signal ball_x: INTEGER := 320;
signal ball_y: INTEGER := 400;
signal ball_v_x: INTEGER:= -1;
signal ball_v_y: INTEGER:= 1;
constant speed_factor: INTEGER:=2;

signal game_ready: std_logic:= '0';
signal paddle_x: INTEGER:= 100;
constant paddle_y: INTEGER:= game_height - paddle_height;
constant brick_buffer_x: INTEGER := 20;
constant brick_buffer_y: INTEGER := 60;
constant brick_space_x,brick_space_y: INTEGER := 14;
constant brick_width: INTEGER := 50;

constant brick_height: INTEGER := 18;
constant num_brick_x,num_brick_y: INTEGER:= 8;

type frame_store is array (num_brick_y-1 downto 0,num_brick_x-1 downto 0) of std_logic;
signal frame : frame_store:=(others=>(others=>'1'));
signal irow,icolumn: integer:=0;
constant paddle_speed: integer:=10;
BEGIN

video_clock_divider: process(mclk)
begin
	if rising_edge(mclk) then
	   	if fclkdiv = fclk_DIVIDER_VALUE-1 then 
			fclkdiv <= (others => '0');
			fclk <= NOT(fclk);
		else
			fclkdiv <= fclkdiv + 1;
		end if;
	end if;
end process video_clock_divider;

converter: process(row,column)
begin
    irow <= to_integer(unsigned(row));
    icolumn <= to_integer(unsigned(column));
end process converter;

game_update: process(fclk, reset_game)
begin
    if rising_edge(fclk) then
         if reset_game = '1' then
            ball_x <= 320;
            ball_y <= 40;
            paddle_x <= 340;
        elsif game_on = '1' then
            ball_y <= ball_y + ball_v_y;
            ball_x <= ball_x + ball_v_x;
            if (left ='1' and right='0') and (paddle_x >= 0) then
                paddle_x <= paddle_x + paddle_speed;
                
            elsif (left ='0' and right='1') and (paddle_x <= game_width) then
                paddle_x <= paddle_x - paddle_speed;
            end if;
            -- check bottom 'wall'
            if ball_y >= game_height - ball_radius - ball_v_y then
                game_over <= '1';
                ball_v_y <= -1 * ball_v_y; -- will this cause a latch?
            end if; 
            -- top boundary
            if ball_y + ball_v_y<= ball_radius  then
                ball_v_y <= -1 * ball_v_y; -- will this cause a latch?
            end if;
            --add boundaries for the horizontal walls 
            if ball_x >= game_width - ball_radius - ball_v_x or ball_x + ball_v_x <= ball_radius  then
                ball_v_x <= -1 * ball_v_x;
            end if;
            
            -- collision detection for the bottom paddle
            if (ball_y + ball_v_y + ball_radius >= game_height - paddle_height) and
               ( (ball_x + ball_v_x + ball_radius >= paddle_x) or
                (ball_x + ball_v_x - ball_radius >= paddle_x)   ) and
               ( (ball_x + ball_v_x + ball_radius <= paddle_x + paddle_width) or 
               (ball_x + ball_v_x - ball_radius <= paddle_x + paddle_width)  ) then
               ball_v_x <= (((ball_x + ball_v_x - paddle_x)- (paddle_width/2))/paddle_width) * speed_factor;
               ball_v_y <= -1 * abs(ball_v_y);
            end if;
            
            
            --brick collision detection for x direction
            if  (ball_x + ball_v_x - brick_buffer_x < ( num_brick_x * (brick_width + brick_space_x))) and
                (ball_x + ball_v_x  > (brick_buffer_x)) and
               ((ball_x + ball_v_x - brick_buffer_x )mod (brick_width +brick_space_x)<brick_width) and
               
                (ball_y - brick_buffer_y < ( num_brick_y * (brick_height + brick_space_y))) and
                (ball_y  > (brick_buffer_y)) and
               ((ball_y - brick_buffer_y )mod (brick_height +brick_space_y)<brick_height) and
               
                 (frame(
                (ball_y - brick_buffer_y) / (brick_height+brick_space_y),
                  (ball_x + ball_v_x -brick_buffer_x) / (brick_width+brick_space_x))
                ='1') 
                then
                    frame(
                  (ball_y  - brick_buffer_y) / (brick_height+brick_space_y),
                  (ball_x + ball_v_x -brick_buffer_x) / (brick_width+brick_space_x)) <= '0';
                  ball_v_x <= -1 * ball_v_x;
            end if;
                
----            brick collision detection for y direction
            if  (ball_y + ball_v_y - brick_buffer_y < ( num_brick_y * (brick_height + brick_space_y))) and
                (ball_y + ball_v_y  > (brick_buffer_y)) and
               ((ball_y + ball_v_y - brick_buffer_y )mod (brick_height +brick_space_y)<brick_height) and

                (ball_x - brick_buffer_x < ( num_brick_x * (brick_width + brick_space_x))) and
                (ball_x  > (brick_buffer_x)) and
               ((ball_x - brick_buffer_x )mod (brick_width +brick_space_x)<brick_width) and
               
                (frame(
                (ball_y + ball_v_y - brick_buffer_y) / (brick_height+brick_space_y),
                  (ball_x -brick_buffer_x) / (brick_width+brick_space_x))
                ='1') 
                then
                    frame(
                  (ball_y + ball_v_y - brick_buffer_y) / (brick_height+brick_space_y),
                  (ball_x -brick_buffer_x) / (brick_width+brick_space_x)) <= '0';
                  ball_v_y <= -1 * ball_v_y;
            end if;
        end if;
        
    end if;
end process game_update;

color_lookup: process(icolumn,irow) 
begin
    if (irow > game_height OR irow < 0 or icolumn > game_width OR icolumn < 0) then
        color_value <= "00"; --out of bounds
    elsif ((irow > paddle_y) AND (icolumn < paddle_x + paddle_width) AND (icolumn > paddle_x)) then
        color_value <= "01";
         -- paddle
    elsif (irow >= ball_y and irow <= ball_y +ball_radius and icolumn >= ball_x and icolumn <=ball_x + ball_radius) then
        color_value <= "10";  --ball
    elsif (
     (irow  < (brick_buffer_y + num_brick_y * (brick_height + brick_space_y))) and
     (irow  > (brick_buffer_y)) and
     ((irow -  brick_buffer_y)mod(brick_height+brick_space_y)<brick_height)and
     
     (icolumn  < (brick_buffer_x+ num_brick_x * (brick_width + brick_space_y))) and
     (icolumn  > (brick_buffer_x)) and
     ((icolumn-brick_buffer_x)mod(brick_width +brick_space_x)<brick_width) and
      (frame(
      (irow-brick_buffer_y) / (brick_height+brick_space_y),
      (icolumn-brick_buffer_x) / (brick_width+brick_space_x))
      ='1')
      ) then
    
        color_value <= "11"; --theres a brick at that pixel
    else
    
        color_value <="00"; --catchall
    end if;
end process color_lookup;
PROCESS(mclk)
	BEGIN
        IF(rising_edge(mclk) and reset_game = '1') THEN	
              game_ready <= '1';
        END IF;
	END PROCESS;
END behavior;