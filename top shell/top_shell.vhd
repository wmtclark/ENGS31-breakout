----------------------------------------------------------------------------------
-- Company:         Engs 31 / CoSc 56 20X
-- Engineer:       Thomas Clark
-- 
-- Create Date:     8/25/20
-- Design Name:     Final Project
-- Module Name:     top-level-shell
-- Project Name:     Final Project
-- Target Devices:  Artix7 / Basys3
-- Tool Versions:   Vivado 2016.4
-- Description:     Wires together all of the components 
-- for the engs 31 final project
--                  
-- 
-- Dependencies: v1_debouncer.vhd, v1_monopulser.vhd, vga_lut, game_State_controller, vga_sync_controller 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- modeled after lab 4 shell from 20x engs 31 course
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;			-- needed for arithmetic
use ieee.math_real.all;				-- needed for automatic register sizing

library UNISIM;						-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

entity final_shell is
port (mclk		    : in std_logic;	    -- FPGA board master clock (100 MHz)
	-- SPI bus interface to Pmod AD1
      left_button   : in std_logic;
      right_button  : in std_logic;
	  center_button : in std_logic;
      vga_red       : out std_logic_vector(3 downto 0);
      vga_blue       : out std_logic_vector(3 downto 0);
      vga_green      : out std_logic_vector(3 downto 0);
      h_sync         : out std_logic;
      v_sync         : out std_logic);
end final_shell; 

architecture Behavioral of final_shell is

-- COMPONENT DECLARATIONS
-- Multiplexed seven segment display
component debouncer is
   port (clk:		in	std_logic;
         button: 	in  std_logic;
         --input button
         button_db:	out std_logic );
         --output debounced signal
end component;

component game_loop_controller is
    port (clk             :	in std_logic; 
        left_button     : 	in std_logic;--input button
        right_button    :  	in std_logic; --input button
        center_button   :   in std_logic;--input button
        game_over       :   in std_logic; --input button
        game_on         :   out std_logic; --game is running
        reset           :   out std_logic ); --game is being reset 
end component;

component monopulser is
	port(clk: in  std_logic; --comment for offline testing
   	    x:	  in  std_logic;
        --button input
        y:	  out std_logic);
        --output is a single pulse
end component;


-- THESE ARE NOT YET WRITTEN
component vga_sync_controller is 
    port(
        clk: in std_logic; --input 
        reset: in std_logic;
        h_sync: out std_logic;
        v_sync: out std_logic;
        video_on: out std_logic;
		column		:	OUT	INTEGER;		--horizontal pixel coordinate
		row			:	OUT	INTEGER		--vertical pixel coordinate
    );
end component;

component game_state_controller IS
	PORT(
		mclk	:	IN		STD_LOGIC;	
        reset_game		:	IN		STD_LOGIC;
        game_on         :   IN      STD_LOGIC;	
		left,right		:	IN	STD_LOGIC;	
        column,row      :   IN STD_LOGIC_VECTOR (9 downto 0);
        color_value		:	OUT	STD_LOGIC_VECTOR(1 downto 0);
        uball_x,uball_y   :   OUT STD_LOGIC_VECTOR(9 downto 0);
        game_over         :     OUT STD_LOGIC;
        upaddle_x   :   OUT STD_LOGIC_VECTOR(9 downto 0)
		);
end component;

component vga_lut is
    port (
          color_in      : in std_logic_vector(1 downto 0); --takes in a color to interpret
          vga_red       : out std_logic_vector(3 downto 0); --outputs for the vga to display
          vga_blue       : out std_logic_vector(3 downto 0);
          vga_green      : out std_logic_vector(3 downto 0) );
end component; 

-------------------------------------------------
-- SIGNAL DECLARATIONS 
-- Signals for the clock divider, which divides the 100 MHz clock down to 25 MHz
constant VCLK_DIVIDER_VALUE: integer := 4 / 2;
constant COUNT_LEN: integer := integer(ceil( log2( real(VCLK_DIVIDER_VALUE) ) ));
signal vclkdiv: unsigned(COUNT_LEN-1 downto 0) := (others => '0');  -- clock divider counter
signal vclk_unbuf: std_logic := '0';    -- unbuffered vlck clock 
signal vclk: std_logic := '0';          -- internal vide clock
-------------------------------------------------

-- Signals for the debouncing and monopulsing of buttons
signal c_but_db: std_logic := '0';
signal c_but_mp: std_logic := '0';
signal l_but_db:std_logic:= '0';
signal r_but_db:std_logic := '0';
-------------------------------------------------

-- Signals for vga sync and looking up colors 
signal irow, icolumn :std_logic_vector(9 downto 0):="0000000000";
signal controller_color: std_logic_vector(11 downto 0);
signal video_on: std_logic:='0';
signal introw, intcolumn: integer;
signal color_value_for_lut: std_logic_vector (1 downto 0) := "00";
signal uball_x_for_collision, uball_y_for_collision,upaddle_x_for_collision : std_logic_vector(9 downto 0) := (others=>'0');

--------------------------------------------------

-- Signals for the main state controller
signal game_over, game_on, reset: std_logic := '0';


begin
-- Clock buffer for video clock
-- The BUFG component puts the signal onto the FPGA clocking network
Slow_clock_buffer: BUFG
	port map (I => vclk_unbuf,
		      O => vclk );
    
-- clock divider to take the system clock down to 25Mhz
video_clock_divider: process(mclk)
begin
	if rising_edge(mclk) then
	   	if vclkdiv = VCLK_DIVIDER_VALUE-1 then 
			vclkdiv <= (others => '0');
			vclk_unbuf <= NOT(vclk_unbuf);
		else
			vclkdiv <= vclkdiv + 1;
		end if;
	end if;
end process video_clock_divider;

row_converter: process(irow,icolumn)
begin
    
    irow <= std_logic_vector(to_unsigned(introw,10));
    icolumn <= std_logic_vector(to_unsigned(intcolumn,10));
end process row_converter;
-- =========================================================================
-- Add your take sample generator here and connect it to the logic analyzer.
-- =========================================================================


-- =========================================================================
-- PORT MAPS FOR YOUR CODE GO HERE
-- =========================================================================


vga_controller: vga_sync_controller port map(
    clk => vclk,
    reset => '0',
    h_sync => h_sync,
    v_sync => v_sync,
    video_on => video_on,
    row => introw,
    column => intcolumn
    );

game_controller: game_state_controller port map(
    mclk => mclk,
    reset_game => reset,
    game_on => game_on,	
    left => l_but_db,
    right => l_but_db,
    column => icolumn, 
    row => irow,
    color_value	=> color_value_for_lut,
    uball_x => uball_x_for_collision,
    uball_y => uball_y_for_collision,
    game_over => game_over,
    upaddle_x => upaddle_x_for_collision
    ); --adding comment

vga_lut_module: vga_lut port map(
        color_in  => color_value_for_lut,
        vga_red  => vga_red,
        vga_blue => vga_blue,
        vga_green => vga_green );

left_db: debouncer port map(
		clk => mclk,
       button => left_button,
       button_db => l_but_db );

right_db: debouncer port map(
       clk => mclk,
       button => right_button,
       button_db => r_but_db );

center_db: debouncer port map(
       clk => mclk,
       button => center_button,
       button_db => c_but_db );

center_mp: monopulser port map(
       clk => mclk,
       x => c_but_db,
       y => c_but_mp );
       
main_controller: game_loop_controller port map(
        clk => mclk,
        left_button => l_but_db,
        right_button  => r_but_db,
        center_button => c_but_mp,
        game_over => game_over,
        game_on  => game_on,
        reset => reset ); --game is being reset
        

end Behavioral; 