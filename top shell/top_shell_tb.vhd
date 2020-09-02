----------------------------------------------------------------------------------
-- Company:         Engs 31 / Cosc 56 20X
-- Engineer:       Thomas Clark
-- 
-- Create Date:     8/26/20
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
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_shell_tb is
end top_shell_tb;

architecture testbench of top_shell_tb is

component final_shell is
port (mclk		    : in std_logic;	    -- FPGA board master clock (100 MHz)
      left_button   : in std_logic;     -- button inputs 
      right_button  : in std_logic;
	  center_button : in std_logic;
      vga_red       : out std_logic_vector(3 downto 0); --VGA color outputs
      vga_blue       : out std_logic_vector(3 downto 0);
      vga_green      : out std_logic_vector(3 downto 0);
      seg            : out std_logic_vector(0 to 6);  -- for 7seg
      dp             : out std_logic;                 -- decimal for 7seg
      an             : out std_logic_vector(3 downto 0); --anode for 7seg
      h_sync         : out std_logic;       -- h_sync and v_sync signal for VGA 
      v_sync         : out std_logic);
end component; 

signal mclk: std_logic := '0';
signal left_button, right_button, center_button: std_logic  := '0';
signal left_button_led, right_button_led, center_button_led: std_logic := '0';
signal h_sync, v_sync: std_logic := '0';
signal vga_red, vga_blue, vga_green: std_logic_vector(3 downto 0) := "0000";
signal seg: std_logic_vector(0 to 6) := "0000000";
signal dp: std_logic := '0';
signal an: std_logic_vector(3 downto 0) := "0000";

constant clk_period : time := 10ns;

begin

uut: final_shell port map(    
      mclk => mclk,
      left_button => left_button,
      right_button => right_button,
      center_button => center_button,
      h_sync => h_sync,
      v_sync => v_sync, 
      vga_red => vga_red,
      vga_blue => vga_blue,
      vga_green => vga_green,
      dp => dp,
      an => an,
      seg => seg
);
      
clk_proc: process
begin
   mclk <= '0';
   wait for clk_period/2;
   mclk <= '1';
   wait for clk_period/2;
end process clk_proc;

stimulus: process
  begin
 	  center_button <= '0';
      wait for 5*clk_period;
      center_button <= '1';
      wait for 30 * clk_period;
      center_button <= '0';
      wait for 10000.5*clk_period;
      center_button <= '1';
      wait for 30 * clk_period;
      center_button <= '0';
      wait;
  end process stimulus;

end testbench; 