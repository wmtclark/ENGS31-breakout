-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_test_pattern_tb is
end vga_test_pattern_tb;

architecture testbench of vga_test_pattern_tb is

component final_shell
port (mclk		    : in std_logic;	    -- FPGA board master clock (100 MHz)
	-- SPI bus interface to Pmod AD1
      left_button   : in std_logic;
      right_buttom  : in std_logic;
	  center_button : in std_logic;
      vga_red       : out std_logic_vector(3 downto 0);
      vga_blue       : out std_logic_vector(3 downto 0);
      vga_green      : out std_logic_vector(3 downto 0);
      h_sync         : out std_logic;
      v_sync         : out std_logic);
end component;

signal mclk: std_logic := '0';
signal right_buttom: std_logic:='0';	
signal left_button: std_logic:='0';	
signal center_button: std_logic:='0';	
signal h_sync: std_logic:='0';	
signal v_sync: std_logic:='0';	

signal vga_red: std_logic_vector(3 downto 0):="0000";
signal vga_green: std_logic_vector(3 downto 0):="0000";
signal vga_blue: std_logic_vector(3 downto 0):="0000";

constant clk_period : time := 1us;

begin

uut: final_shell port map(    
      mclk => mclk,
      right_buttom => right_buttom,
      left_button => left_button,
      center_button => center_button,
      h_sync => h_sync,
      v_sync => v_sync,
      vga_red => vga_red,
      vga_blue => vga_blue,
      vga_green => vga_green
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
      wait;
  end process stimulus;

end testbench; 