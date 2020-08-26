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
-- Description:     Final Project controller test
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
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY vga_sync_controller IS
	PORT(
		clk	:	IN		STD_LOGIC;	--pixel clock 
		reset		:	IN		STD_LOGIC;	--active high asycnchronous reset
		h_sync		:	OUT	STD_LOGIC;	--horiztonal sync pulse
		v_sync		:	OUT	STD_LOGIC;	--vertical sync pulse
		video_on		:	OUT	STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		column		:	OUT	INTEGER;		--horizontal pixel coordinate
		row			:	OUT	INTEGER		--vertical pixel coordinate
		);
END vga_sync_controller;

ARCHITECTURE behavior OF vga_sync_controller IS

CONSTANT h_pulse 	:	INTEGER := 2;    	--horiztonal sync pulse width in pixels
CONSTANT h_bp	 	:	INTEGER := 29;		--horiztonal back porch width in pixels
CONSTANT h_pixels	:	INTEGER := 640;		--horiztonal display width in pixels
CONSTANT h_fp	 	:	INTEGER := 128;		--horiztonal front porch width in pixels

CONSTANT v_pulse 	:	INTEGER := 2;			--vertical sync pulse width in rows
CONSTANT v_bp	 	:	INTEGER := 29;			--vertical back porch width in rows
CONSTANT v_pixels	:	INTEGER := 480;		--vertical display height in rows
CONSTANT v_fp	 	:	INTEGER := 10;			--vertical front porch width in rows

CONSTANT	h_period	:	INTEGER :=800;
CONSTANT	v_period	:	INTEGER := 521;
signal h_count  :   INTEGER := 0;  --horizontal counter (counts the columns)
signal v_count	:	INTEGER := 0;  --vertical counter (counts the rows)

BEGIN
	
PROCESS(clk, reset)
	BEGIN

		IF(reset = '1') THEN		--reset asserted
			h_count <= 0;				--reset horizontal counter
			v_count <= 0;				--reset vertical counter
			h_sync <= '1';		--deassert horizontal sync
			v_sync <= '1';		--deassert vertical sync
			video_on <= '0';			--disable display
			column <= 0;				--reset column pixel coordinate
			row <= 0;					--reset row pixel coordinate
			
		ELSIF(rising_edge(clk)) THEN

			IF(h_count < h_period - 1) THEN		--horizontal counter (pixels)
				h_count <= h_count + 1;
			ELSE
				h_count <= 0;
				IF(v_count < v_period - 1) THEN	--veritcal counter (rows)
					v_count <= v_count + 1;
				ELSE
					v_count <= 0;
				END IF;
			END IF;

			--horizontal sync signal
			IF( h_count >= 655 and h_count < 751) THEN
				h_sync <= '1';		--deassert horiztonal sync pulse
			ELSE
				h_sync <= '0';			--assert horiztonal sync pulse
			END IF;
			
			--vertical sync signal
			IF(v_count >= 489 AND v_count < 491) THEN
				v_sync <= '1';		--deassert vertical sync pulse
			ELSE
				v_sync <= '0';			--assert vertical sync pulse
			END IF;
			
			--set pixel coordinates
			IF(h_count < h_pixels) THEN  	--horiztonal display time
				column <= h_count;			--set horiztonal pixel coordinate
			END IF;
			IF(v_count < v_pixels) THEN	--vertical display time
				row <= v_count;				--set vertical pixel coordinate
			END IF;

			--set display enable output
			IF(h_count < h_pixels AND v_count < v_pixels) THEN  	--display time
                video_on <= '1';											 	--enable display
			ELSE																	--blanking time
                video_on <= '0';												--disable display
			END IF;

		END IF;
	END PROCESS;

END behavior;