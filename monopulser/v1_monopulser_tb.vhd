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
-- Description:     tb for monopulser
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

entity monopulser_tb is
end monopulser_tb;

architecture testbench of monopulser_tb is

component monopulser is
	port(clk: in  std_logic;
    	 x:	  in  std_logic;
         y:	  out std_logic);
end component;

constant clk_period: time := 100ns;
signal clk: std_logic := '0';
signal x: std_logic := '0';
signal y: std_logic;

begin

dut: monopulser port map(
		clk => clk,
        x => x,
        y => y );
        
clock_proc: process
begin
	clk <= not(clk);
    wait for clk_period/2;
end process clock_proc;

stim_proc: process
begin
	x <= '0';
    wait for 5* clk_period;
    x<='1';
    wait for 3*clk_period;
  	x<='0';
    wait for 3*clk_period;
    x<='1';
    wait for 5*clk_period;
    x<='0';
    wait;

end process stim_proc;

end testbench;