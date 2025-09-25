entity THERMOSTAT is
  port ( CURRENT_TEMP : in bit_vector(6 downto 0);
         DESIRED_TEMP : in bit_vector(6 downto 0);
         DISPLAY_SELECT : in bit;
         COOL : in bit;
         HEAT : in bit;
         A_C_ON : out bit;
         FURNACE_ON : out bit;
         TEMP_DISPLAY : out bit_vector(6 downto 0));
end THERMOSTAT;
architecture BEHAV of THERMOSTAT is
begin

-- showing temperature display
process (CURRENT_TEMP,DESIRED_TEMP,DISPLAY_SELECT)
begin
if DISPLAY_SELECT = '1' then
TEMP_DISPLAY <= CURRENT_TEMP;
else
TEMP_DISPLAY <= DESIRED_TEMP;
end if;
end process;

-- air conditioner state
process (CURRENT_TEMP,DESIRED_TEMP,COOL)
begin
if DESIRED_TEMP < CURRENT_TEMP and  COOL = '1' then
A_C_ON <= '1';
else
A_C_ON <= '0';
end if;
end process;

--furnace state
process (CURRENT_TEMP,DESIRED_TEMP,HEAT)
begin
if DESIRED_TEMP > CURRENT_TEMP and HEAT = '1' then
FURNACE_ON <= '1';
else
FURNACE_ON <= '0';
end if;
end process;
end BEHAV;
