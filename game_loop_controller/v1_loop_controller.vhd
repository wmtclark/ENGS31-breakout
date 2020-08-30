----------------------------------------------------------------------------------
-- Company:         Engs 31 / CoSc 56 20X
-- Engineer:       Thomas Clark
-- 
-- Create Date:     8/27/20
-- Design Name:     loop controller
-- Module Name:     debouncer
-- Project Name:     Final Project
-- Target Devices:  Artix7 / Basys3
-- Tool Versions:   Vivado 2016.4
-- Description:     controls the game loop
--                  
-- 
-- Dependencies:    none
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- modeled off previous FSM done in class
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_loop_controller is
  port (clk             :	in std_logic; 
  		left_button     : 	in std_logic;--input button
        right_button    :  	in std_logic; --input button
        center_button   :   in std_logic;--input button
        game_over       :   in std_logic; --input button
        game_on         :   out std_logic; --game is running
        reset           :   out std_logic ); --game is being reset
        
end game_loop_controller;

architecture FSM of game_loop_controller is
	--stuff for timer friend
	constant maxcount: integer := 50; --written so that this is the multiple of the clock period you want to debounce for (ie a count of 10 with 1us period debounces for 10us)
	signal ucount:	unsigned(5 downto 0) := "000000";
    signal tc: std_logic :='0';
    --FSM states
    type state_type is (startScreen,play,pause); 
    signal curr_state,next_state: state_type;
    
begin

--FSM state update
FSM_update: process(clk)
begin 
    if rising_edge(clk) then
        curr_state <= next_state;
    end if;
end process FSM_update;

--FSM logic
FSM_comb: process(center_button, curr_state,tc, game_over)
begin 
    --default
    next_state <= curr_state;
    game_on <= '0';
    reset <= '1';
    --cases
    case curr_state is 
    	when startScreen => 
        	if center_button = '1' then
            	next_state <= play;
            end if;
        when play =>
            reset <= '0';
            game_on <= '1';
            if center_button = '1' then
            	next_state <= pause;
            elsif game_over = '1' then
            	next_state <= startScreen;
            end if;
        when pause =>
            reset <= '0';
        	if tc = '1' then
                next_state <= startScreen;
            elsif center_button = '1' then
                next_state <= play;
           	end if;
    end case;
end process FSM_comb;
timer: process(clk, left_button, right_button)
begin
	if rising_edge(clk) then
    	if left_button = '0' or right_button = '0' or tc ='1' then
        	ucount <= "000000";
            tc <='0';
        elsif ucount = maxcount-1 then 
            ucount <= "000000";
            tc <= '1';
        else 
            ucount <= ucount + 1;
            tc <= '0';
        end if;
	end if;
end process timer;
end FSM;