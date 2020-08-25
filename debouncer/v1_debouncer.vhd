----------------------------------------------------------------------------------
-- Company:         Engs 31 / CoSc 56 20X
-- Engineer:       Thomas Clark
-- 
-- Create Date:     8/25/20
-- Design Name:     Final Project
-- Module Name:     debouncer
-- Project Name:     Final Project
-- Target Devices:  Artix7 / Basys3
-- Tool Versions:   Vivado 2016.4
-- Description:     debounces a button signal on a 50us waiting period
--                  
-- 
-- Dependencies:    none
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- modeled after an in-class FSM debouncer
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
  port (clk:		in	std_logic;
  		button: 	in  std_logic;
        --input button
        button_db:	out std_logic );
        --output debounced signal
end debouncer;

architecture FSM of debouncer is
	--stuff for timer friend
	constant maxcount: integer := 50; --written so that this is the multiple of the clock period you want to debounce for (ie a count of 10 with 1us period debounces for 10us)
	signal ucount:	unsigned(5 downto 0) := "000000";
    signal timeout: std_logic :='0';
	signal reset: std_logic := '0';
    --FSM states
    type state_type is (waitpress,waitrelease,debounce); 
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
FSM_comb: process(button, curr_state,timeout)
begin 
    --default
    next_state <= curr_state;
    button_db <= '0';
    reset <= '1';
    --cases
    case curr_state is 
    	when waitpress => 
        	if button = '1' then
            	next_state <= debounce;
            end if;
        when debounce =>
        	reset <= '0';
            if timeout = '1' then
            	next_state <= waitrelease;
            elsif button = '0' then
            	next_state <= waitpress;
            end if;
        when waitrelease =>
        	button_db <= '1';
        	if button = '0' then
            	next_state <= waitpress;
           	end if;
    end case;
end process FSM_comb;
timer: process(reset, clk)
begin
	if rising_edge(clk) then
    	if reset = '1' then
        	ucount <= "000000";
            timeout <='0';
        else 
        	if ucount = maxcount-3 then 
            	timeout <= '1';
            else 
            	timeout <= '0';
            end if;
			if ucount = maxcount-2 then
            	ucount <= "000000";
            else
            	ucount <= ucount+1;
        	end if;
        end if;
	end if;
end process timer;
end FSM;