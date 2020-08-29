---------------------------------------------------------------------------------
-- Company:         Engs 31 / CoSc 56 20X
-- Engineer:       Thomas Clark
-- 
-- Create Date:     8/25/20
-- Design Name:     Final Project
-- Module Name:     vga
-- Project Name:     Final Project
-- Target Devices:  Artix7 / Basys3
-- Tool Versions:   Vivado 2016.4
-- Description:     lut that ouputs the correct color for the ball and bricks
--
--                  
-- 
-- Dependencies: none
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--  A testbench has no ports.
entity vga_lut_tb is
end vga_lut_tb;

architecture testbench of vga_lut_tb is
   --  Declaration of the component that will be instantiated.
   component vga_lut is
  port (clk           : in std_logic;
          color_in      : in std_logic_vector(1 downto 0);
          vga_red       : out std_logic_vector(3 downto 0); --outputs for the vga to display
          vga_blue       : out std_logic_vector(3 downto 0);
          vga_green      : out std_logic_vector(3 downto 0) );
end component;

-- Signals for connecting UUT to testbench
signal clk : std_logic := '1';
signal color_in : std_logic_vector(1 downto 0) := "00";
signal vga_red : std_logic_vector(3 downto 0) := "0000";
signal vga_blue : std_logic_vector(3 downto 0) := "0000";
signal vga_green : std_logic_vector(3 downto 0) := "0000";


-- Clock period
constant clk_period: time := 1 us;	-- 1 MHz

begin
--  Component instantiation.
vga: vga_lut port map (
		clk => clk,
        color_in => color_in,
        vga_red => vga_red,
        vga_blue => vga_blue,
        vga_green => vga_green );

--  Clock process
clock_gen: process
begin
	wait for clk_period/2;
	clk <= not(clk);
end process clock_gen;
	
stim_proc: process 
begin 
	color_in <= "00";
    wait for 5*clk_period;
    color_in <= "01";
    wait for 5*clk_period;
    color_in <= "11";
    wait for 5*clk_period;
    color_in <= "10";
    wait;
end process;
end testbench;
