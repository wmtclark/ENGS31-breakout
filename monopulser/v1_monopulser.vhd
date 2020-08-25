----------------------------------------------------------------------------------
-- Company:         Engs 31 / CoSc 56 20X
-- Engineer:       Thomas Clark
-- 
-- Create Date:     8/25/20
-- Design Name:     Final Project
-- Module Name:     monopulser
-- Project Name:     Final Project
-- Target Devices:  Artix7 / Basys3
-- Tool Versions:   Vivado 2016.4
-- Description:     takes a button signal and turns it into a single pulse
--                  
-- 
-- Dependencies:    none
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- modeled after an in-class FSM monopulser
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity monopulser is
	port(clk: in  std_logic;
    	 x:	  in  std_logic;
         --button input
         y:	  out std_logic);
         --output is a single pulse
end monopulser;

architecture behavior of monopulser is
-- State vars (only three states)
	type state_type is (waitpress, pulse1, waitrelease);
    signal curr_state, next_state: state_type;  
begin

-- combination logic for the FSM
fsm_logic:	process(x, curr_state)
begin
	-- Default values for output and next state
	y <= '0';				
    next_state <= curr_state;
    
	-- case statement implements logic
    case curr_state is
    	when waitpress =>  --waits for an input
            if x='1' then
            	next_state <= pulse1;
            end if;
            
        when pulse1 => --pulses for one clock cycle, one cycle delay from the input 
        	y<='1';
            next_state <=waitrelease;
            
        when waitrelease => --waits for the button release
            if x='0' then
            	next_state <= waitpress;
            end if;
    end case;
end process fsm_logic;

-- State register update
fsm_update: process(clk)
begin
	if rising_edge(clk) then
    	curr_state <= next_state;
    end if;
end process fsm_update;

end behavior;