entity THERMOSTAT is
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
end THERMOSTAT;

-- Assign different internal signal(wires) for connecting the output ports of different flip flop  
architecture BEHAV of THERMOSTAT is
signal INT_CURRENT_TEMP : bit_vector(6 downto 0);
signal INT_DESIRED_TEMP : bit_vector(6 downto 0);
signal INT_DISPLAY_SELECT : bit; 
signal INT_TEMP_DISPLAY : bit_vector(6 downto 0);
signal INT_COOL : bit;
signal INT_HEAT : bit;
signal INT_A_C_ON : bit;
signal INT_FURNACE_ON : bit;

begin
-----------------------------------
-- PROCESS 1: Input flip-flop for CURRENT_TEMP
-- Stores the current temperature input into an internal register
-- Reset clears it to 0000000
-----------------------------------
process (CLK,RESET)
begin
if RESET = '0' then 
INT_CURRENT_TEMP <= "0000000";
elsif CLK'event and CLK = '1' then 
INT_CURRENT_TEMP <= CURRENT_TEMP;
end if;
end process;

-----------------------------------
--PROCESS 2: Input flip-flop for DESIRED_TEMP
-- Stores the desired temperature input into an internal register
-- Reset clears it to 0000000
-----------------------------------
process (CLK,RESET)
begin
if RESET = '0' then 
INT_DESIRED_TEMP <= "0000000";
elsif CLK'event and CLK = '1' then
INT_DESIRED_TEMP <= DESIRED_TEMP;
end if;
end process;

-----------------------------------
-- PROCESS 3: Input flip-flop for DISPLAY_SELECT
-- Stores the display select bit into an internal register
-- Reset clears it to '0'
-----------------------------------
process (CLK,RESET)
begin
if RESET = '0' then 
INT_DISPLAY_SELECT <= '0';
elsif CLK'event and CLK = '1' then
INT_DISPLAY_SELECT <= DISPLAY_SELECT;
end if;
end process;


-----------------------------------
-- PROCESS 4: Combinational logic for TEMP_DISPLAY
-- Chooses which temperature should be shown:
-- If DISPLAY_SELECT = 1 → show CURRENT_TEMP
-- If DISPLAY_SELECT = 0 → show DESIRED_TEMP
-----------------------------------
process (INT_CURRENT_TEMP,INT_DESIRED_TEMP,INT_DISPLAY_SELECT)
begin
if INT_DISPLAY_SELECT = '1' then
INT_TEMP_DISPLAY <= INT_CURRENT_TEMP;
else
INT_TEMP_DISPLAY <= INT_DESIRED_TEMP;
end if;
end process;

-----------------------------------
-- PROCESS 5: Output flip-flop for TEMP_DISPLAY
-- Registers the chosen temperature into the final output
-- Reset clears it to 0000000
-----------------------------------
process (CLK,RESET)
begin
if RESET = '0' then 
TEMP_DISPLAY <= "0000000";
elsif CLK'event and CLK = '1' then 
TEMP_DISPLAY <= INT_TEMP_DISPLAY;
end if;
end process;

-----------------------------------
-- PROCESS 6: Input flip-flop for COOL bit
-- Stores the COOL control input into an internal register
-- Reset clears it to '0'
-----------------------------------
process (CLK,RESET)
begin
if RESET = '0' then 
INT_COOL <= '0';
elsif CLK'event and CLK = '1' then
INT_COOL <= COOL;
end if;
end process;


-----------------------------------
-- PROCESS 7: Input flip-flop for HEAT bit
-- Stores the HEAT control input into an internal register
-- Reset clears it to '0'
-----------------------------------
process (CLK,RESET)
begin
if RESET = '0' then 
INT_HEAT <= '0';
elsif CLK'event and CLK = '1' then
INT_HEAT <= HEAT;
end if;
end process;

-----------------------------------
-- PROCESS 8: Combinational logic for AC state
-- Turns AC ON when:
--   Desired temperature < Current temperature
--   AND COOL = 1
-- Otherwise, AC stays OFF
-----------------------------------
process (INT_CURRENT_TEMP,INT_DESIRED_TEMP,INT_COOL)
begin
if INT_DESIRED_TEMP < INT_CURRENT_TEMP and  INT_COOL = '1' then
INT_A_C_ON <= '1';
else
INT_A_C_ON <= '0';
end if;
end process;

-----------------------------------
-- PROCESS 9: Combinational logic for Furnace state
-- Turns Furnace ON when:
--   Desired temperature > Current temperature
--   AND HEAT = 1
-- Otherwise, Furnace stays OFF
-----------------------------------
process (INT_CURRENT_TEMP,INT_DESIRED_TEMP,INT_HEAT)
begin
if INT_DESIRED_TEMP > INT_CURRENT_TEMP and INT_HEAT = '1' then
INT_FURNACE_ON <= '1';
else
INT_FURNACE_ON <= '0';
end if;
end process;

-----------------------------------
-- PROCESS 10: Output flip-flop for A_C_ON
-- Registers the internal signal AC ON/OFF state into the final output
-- Reset clears it to '0'
-----------------------------------
process (CLK,RESET)
begin
if RESET = '0' then 
A_C_ON <= '0';
elsif CLK'event and CLK = '1' then 
A_C_ON <= INT_A_C_ON;
end if;
end process;


-----------------------------------
-- PROCESS 11: Output flip-flop for FURNACE_ON
-- Registers the internal signal Furnace ON/OFF state into the final output
-- Reset clears it to '0'
-----------------------------------
process (CLK,RESET)
begin
if RESET = '0' then 
FURNACE_ON <= '0';
elsif CLK'event and CLK = '1' then 
FURNACE_ON <= INT_FURNACE_ON;
end if;
end process;
end BEHAV;
