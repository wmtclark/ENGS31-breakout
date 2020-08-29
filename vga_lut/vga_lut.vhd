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

entity vga_lut is
    port (
          color_in      : in std_logic_vector(1 downto 0); --takes in a color to interpret
          vga_red       : out std_logic_vector(3 downto 0); --outputs for the vga to display
          vga_blue       : out std_logic_vector(3 downto 0);
          vga_green      : out std_logic_vector(3 downto 0) );
end vga_lut; 

architecture Behavioral of vga_lut is 
begin 

lut: process(color_in)
begin 
    if color_in = "11" then --color for bricks
        vga_red <= "1100";
        vga_blue <= "0000";
        vga_green <= "0000";
    elsif color_in = "10" then  --color for ball
        vga_red <="1100";
        vga_blue <= "1100";
        vga_green <= "1100";
    elsif color_in = "01" then  --color for paddle
        vga_red <= "0000";
        vga_blue <= "1100";
        vga_green <= "0000";
    else                        -- color for blank
        vga_red <= "0000";
        vga_blue <= "0000";
        vga_green <= "0000";
    end if;
end process lut;
end Behavioral;
