-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_state_tb is
end game_state_tb;

architecture testbench of game_state_tb is

component game_state_controller
PORT(
    mclk	:	IN		STD_LOGIC;	
    reset_game		:	IN		STD_LOGIC;	
    left,right		:	IN	STD_LOGIC;	
    column,row      :   IN STD_LOGIC_VECTOR (11 downto 0);
    color_value		:	OUT	STD_LOGIC_VECTOR(1 downto 0);
    uball_x,uball_y   :   OUT STD_LOGIC_VECTOR(9 downto 0);
    upaddle_x   :   OUT STD_LOGIC_VECTOR(9 downto 0)
    );
end component;

signal mclk: std_logic := '0';
signal reset_game		:STD_LOGIC:='0';	
signal left,right		:STD_LOGIC:='0';	

signal column,row: std_logic_vector(11 downto 0):="000000000000";
signal color_value: std_logic_vector(1 downto 0):="10";
signal uball_x,uball_y: std_logic_vector(9 downto 0):="0000000000";
signal upaddle_x: std_logic_vector(9 downto 0):="0000000000";
constant clk_period : time := 100us;

begin

uut: game_state_controller port map(    
      mclk => mclk,
      reset_game => reset_game,
      left => left,
      right => right,
      column => column,
      row => row,
      uball_x => uball_x,
      uball_y => uball_y,
      upaddle_x => upaddle_x,
      color_value => color_value
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
      wait for 3*clk_period;
      reset_game <= '1';
       wait for clk_period;
      reset_game <= '0';
      wait for 3*clk_period;
        row <=    "000000110111";
        column <= "000000110111";
        wait for 5*clk_period;
      wait;
  end process stimulus;

end testbench; 