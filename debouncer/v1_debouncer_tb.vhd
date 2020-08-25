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
-- Description:     testbench for debouncer
--                  
-- 
-- Dependencies:    none
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- modeled after an in-class FSM debouncer test
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--  A testbench has no ports.
entity debouncer_tb is
end debouncer_tb;

architecture testbench of debouncer_tb is
   --  Declaration of the component that will be instantiated.
   component debouncer is
  port (clk:		in	std_logic;
  		button: 	in  std_logic;
        button_db:	out std_logic );
end component;

-- Signals for connecting UUT to testbench
signal clk : std_logic := '1';
signal button : std_logic := '0';
signal button_db: std_logic := '0';


-- Clock period
constant clk_period: time := 1 us;	-- 1 MHz

begin
--  Component instantiation.
UUT: debouncer port map (
		clk => clk,
        button => button,
		button_db => button_db );

--  Clock process
clock_gen: process
begin
	wait for clk_period/2;
	clk <= not(clk);
end process clock_gen;
	
stim_proc: process 
begin 
	button <= '0';
    wait for 5*clk_period;
    for I in 0 to 9 loop
		button <= not(button);
        wait for clk_period;
	end loop;
    button <= '1';
    wait for 15*clk_period;
    button <= '0';
    wait;
end process;
end testbench;
