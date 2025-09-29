entity thermostat_tb is

end thermostat_tb;

architecture Behavioral of thermostat_tb is

-- component's port name 
component THERMOSTAT
 port ( CURRENT_TEMP : in bit_vector(6 downto 0);
         DESIRED_TEMP : in bit_vector(6 downto 0);
         DISPLAY_SELECT : in bit;
         COOL : in bit;
         HEAT : in bit;
         CLK  : in bit;
         RESET : in bit;
         A_C_ON : out bit;
         FURNACE_ON : out bit;
         TEMP_DISPLAY : out bit_vector(6 downto 0));
end component;

-- signal/ wires name 
signal CURRENT_TEMP , DESIRED_TEMP  : bit_vector(6 downto 0);
signal TEMP_DISPLAY : bit_vector(6 downto 0);
signal DISPLAY_SELECT : bit;
signal COOL : bit;
signal HEAT : bit;
signal CLK : bit := '0';
signal RESET : bit := '0';
signal A_C_ON : bit;
signal FURNACE_ON : bit;
 
begin
-- port connects to wires
UUT: THERMOSTAT port map ( CURRENT_TEMP => CURRENT_TEMP,
                           DESIRED_TEMP => DESIRED_TEMP,
                           DISPLAY_SELECT => DISPLAY_SELECT,
                           TEMP_DISPLAY => TEMP_DISPLAY,
                           COOL => COOL,
                           HEAT => HEAT,
                           CLK => CLK,
                           RESET => RESET,
                           A_C_ON => A_C_ON,
                           FURNACE_ON => FURNACE_ON);


-- Clock generator: produces a square wave with 10 ns period
-- First 5 ns = '0', next 5 ns = '1', then repeats                           
CLK <= not CLK after 5 ns; 

process 
begin
-- Reset signal: stays '0' (active) for the first 10 ns,
-- then becomes '1' to release the reset
 RESET <= '0' , '1' after 10ns;
 
 
--RESET IS '0' !!! CLK RISE EDGE AT 5NS : AC off, furnace off, temp_display= desired temperature(0000000)
 CURRENT_TEMP <= "0000000";
 DESIRED_TEMP <= "1111111";
 DISPLAY_SELECT <= '0';
 COOL <= '0';
 HEAT <= '1';
 wait for 10 ns;
 
 --RESET IS '1' !!! CLK RISE EDGE AT 15NS : AC ON , furnace off, temp_display= (0000000)
 CURRENT_TEMP <= "1111100";
 DESIRED_TEMP <= "0000011";
 DISPLAY_SELECT <= '1';
 COOL <= '1';
 HEAT <= '0';
 wait for 10 ns;
 
 -- RESET IS '1' !!! CLK RISE EDGE AT 25NS : AC ON , furnace off , temp_display= (1111100)
 CURRENT_TEMP <= "1111100";
 DESIRED_TEMP <= "0001111";
 DISPLAY_SELECT <= '0';
 COOL <= '0';
 HEAT <= '0';
 wait for 10 ns;
 
 -- RESET IS '1'!!! CLK RISE EDGE AT 35NS : Ac off , furnace off , temp_display=  (0001111)
 CURRENT_TEMP <= "0001100";
 DESIRED_TEMP <= "1111000";
 DISPLAY_SELECT <= '1';
 COOL <= '1';
 HEAT <= '1';
 wait for 10 ns;
 
 -- -- RESET IS '1'!!! CLK RISE EDGE AT 45NS : Ac off , furnace on , temp_display= (0001100)
 CURRENT_TEMP <= "1111111";
 DESIRED_TEMP <= "1111111";
 DISPLAY_SELECT <= '1';
 COOL <= '1';
 HEAT <= '1';
 wait for 10 ns;
 
 -- -- RESET IS '1'!!! CLK RISE EDGE AT 55NS : Ac On , furnace on , temp_display= (1111111)
 wait;
 end process;
end Behavioral;
