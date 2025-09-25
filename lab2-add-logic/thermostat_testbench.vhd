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
                           A_C_ON => A_C_ON,
                           FURNACE_ON => FURNACE_ON);
process 
begin
--AC off, furnace on, temp_display= desired temperature 
 CURRENT_TEMP <= "0000000";
 DESIRED_TEMP <= "1111111";
 DISPLAY_SELECT <= '0';
 COOL <= '0';
 HEAT <= '1';
 wait for 10 ns;
 
 --AC ON , furnace off, temp_display= current temperature
 CURRENT_TEMP <= "1111100";
 DESIRED_TEMP <= "0000011";
 DISPLAY_SELECT <= '1';
 COOL <= '1';
 HEAT <= '0';
 wait for 10 ns;
 
 -- AC off , furnace off , temp_display= desired temperature
 CURRENT_TEMP <= "1111100";
 DESIRED_TEMP <= "0001111";
 DISPLAY_SELECT <= '0';
 COOL <= '0';
 HEAT <= '0';
 wait for 10 ns;
 
 -- Ac off , furnace ON , temp_display= current temperature
 CURRENT_TEMP <= "0001100";
 DESIRED_TEMP <= "1111000";
 DISPLAY_SELECT <= '1';
 COOL <= '1';
 HEAT <= '1';
 wait for 10 ns;
 
 -- Ac off , furnace off , temp_display= current temperature
 CURRENT_TEMP <= "1111111";
 DESIRED_TEMP <= "1111111";
 DISPLAY_SELECT <= '1';
 COOL <= '1';
 HEAT <= '1';
 wait for 10 ns;
 wait;
 end process;
end Behavioral;
