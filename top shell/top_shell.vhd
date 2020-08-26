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
-- Dependencies: v1_debouncer.vhd, v1_monopulser.vhd
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
      right_buttom  : in std_logic;
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
--component debouncer is
--    port (clk:		in	std_logic;
--          button: 	in  std_logic;
--          --input button
--          button_db:	out std_logic );
--          --output debounced signal
--end component;

--component monopulser is
--	port(clk: in  std_logic;
--    	 button:	  in  std_logic;
--         --button input
--         button_mp:	  out std_logic);
--         --output is a single pulse
--end component;


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

component vga_test_pattern is 
	port(	row, column			: in  std_logic_vector( 9 downto 0);
			color				: out std_logic_vector(11 downto 0) );
end component;

component game_state_controller IS
	PORT(
		mclk	:	IN		STD_LOGIC;	
		reset_game		:	IN		STD_LOGIC;	
		left,right		:	IN	STD_LOGIC;	
        column,row      :   IN STD_LOGIC_VECTOR (9 downto 0);
        color_value		:	OUT	STD_LOGIC_VECTOR(1 downto 0);
        uball_x,uball_y   :   OUT STD_LOGIC_VECTOR(9 downto 0);
        upaddle_x   :   OUT STD_LOGIC_VECTOR(9 downto 0)
		);
end component;

-------------------------------------------------
-- SIGNAL DECLARATIONS 
-- Signals for the clock divider, which divides the 100 MHz clock down to 25 MHz
constant VCLK_DIVIDER_VALUE: integer := 4 / 2;
constant COUNT_LEN: integer := integer(ceil( log2( real(VCLK_DIVIDER_VALUE) ) ));
signal vclkdiv: unsigned(COUNT_LEN-1 downto 0) := (others => '0');  -- clock divider counter
signal vclk_unbuf: std_logic := '0';    -- unbuffered vlck clock 
signal vclk: std_logic := '0';          -- internal vide clock

-- Signals for the debouncing and monopulsing of buttons
signal c_but_db: std_logic := '0';
signal c_but_mp: std_logic := '0';
--signal l_but_db := '0';
--signal r_but_db := '0';
-------------------------------------------------
signal irow, icolumn :std_logic_vector(9 downto 0):="0000000000";
signal controller_color: std_logic_vector(11 downto 0);
signal video_on: std_logic:='0';
signal introw, intcolumn: integer;
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

color_splitter: process(controller_color)
begin
      vga_red <= controller_color(11 downto 8);
      vga_green <= controller_color(7 downto 4);
      vga_blue <= controller_color(3 downto 0);
end process color_splitter;

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

test_pattern: vga_test_pattern port map(
    row => irow,
    column => icolumn,
    color => controller_color
);

vga_controller: vga_sync_controller port map(
    clk => vclk,
    reset => '0',
    h_sync => h_sync,
    v_sync => v_sync,
    video_on => video_on,
    row => introw,
    column => intcolumn
    );

--left_db: debouncer port map(
--		clk => mclk,
--        button => left_button,
--        button_db => l_but_db );

--right_db: debouncer port map(
--        clk => mclk,
--        button => right_button,
--        button_db => r_but_db );

center_db: debouncer port map(
       clk => mclk,
       button => center_button,
       button_db => c_but_db );

center_mp: debouncer port map(
       clk => mclk,
       button => c_but_db
       button_mp => c_but_mp );

    

            
		
end Behavioral; 