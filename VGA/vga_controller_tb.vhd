---------------------------------------------------------------------------------
-- Company:         Engs 31 / CoSc 56 20X
-- Engineer:       Nathan Schneider
-- 
-- Create Date:     8/25/20
-- Design Name:     vga sync controller
-- Module Name:     vga 
-- Project Name:     Final Project
-- Target Devices:  Artix7 / Basys3
-- Tool Versions:   Vivado 2016.4
-- Description:    outputs pixels in the correct speed to the lut
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

entity vga_controller_tb is
end vga_controller_tb;

architecture testbench of vga_controller_tb is
component vga_sync_controller
PORT(
    clk	:	IN		STD_LOGIC;	--pixel clock 
    reset		:	IN		STD_LOGIC;	--active high asycnchronous reset
    h_sync		:	OUT	STD_LOGIC;	--horiztonal sync pulsez
    v_sync		:	OUT	STD_LOGIC;	--vertical sync pulse
    video_on		:	OUT	STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
    column		:	OUT	INTEGER;		--horizontal pixel coordinate
    row			:	OUT	INTEGER		--vertical pixel coordinate
    );
end component;

signal clk: std_logic := '0';
signal reset: std_logic:='0';	
signal h_sync: std_logic:='0';	
signal v_sync: std_logic:='0';	
signal video_on: std_logic:='0';	
signal column: integer:=0;
signal row: integer:=0;

constant clk_period : time := 100us;

begin

uut: vga_sync_controller port map(    
      clk => clk,
      reset => reset,
      h_sync => h_sync,
      v_sync => v_sync,
      video_on => video_on,
      column => column,
      row => row
);
      
clk_proc: process
begin
   clk <= '0';
   wait for clk_period/2;
   clk <= '1';
   wait for clk_period/2;
end process clk_proc;

stimulus: process
  begin
      wait;
  end process stimulus;

end testbench; 