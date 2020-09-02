----------------------------------------------------------------------------------
-- Company:         Engs 31 / CoSc 56 20X
-- Engineer:       Thomas Clark
-- 
-- Create Date:     8/27/20
-- Design Name:     loop controller
-- Module Name:     main datapath
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
        game_over       :   in std_logic; -- game is over signal
        game_on         :   out std_logic --game is running
         ); 
        
end game_loop_controller;


architecture FSM of game_loop_controller is
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
FSM_comb: process(center_button, curr_state, game_over)
begin 
    --default
    next_state <= curr_state;
    game_on <= '0';
    --cases
    case curr_state is 
    	when startScreen =>  -- beginning screeen
        	if center_button = '1' then -- start game on '1'
            	next_state <= play;
            end if;
        when play => -- play mode 
            game_on <= '1';
            if center_button = '1' then -- pause on c_but
            	next_state <= pause;
            elsif game_over = '1' then -- reset on game over
            	next_state <= startScreen;
            end if;
        when pause =>  -- paused mode 
        	if center_button = '1' then -- press c_but to resume
                next_state <= play;
           	end if;
    end case;
end process FSM_comb;

end FSM;