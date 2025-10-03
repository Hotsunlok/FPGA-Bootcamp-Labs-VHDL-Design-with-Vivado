library IEEE;
use IEEE.std_logic_1164.ALL;

entity THERMOSTAT is
  port ( CURRENT_TEMP : in std_logic_vector(6 downto 0);
         DESIRED_TEMP : in std_logic_vector(6 downto 0);
         DISPLAY_SELECT : in std_logic;
         COOL : in std_logic;
         HEAT : in std_logic;
         CLK  : in std_logic;
         RESET : in std_logic;
         FURNACE_HOT : in std_logic;
         AC_READY : in std_logic;
         A_C_ON : out std_logic;
         FURNACE_ON : out std_logic;
         FAN_ON: out std_logic; 
         TEMP_DISPLAY : out std_logic_vector(6 downto 0));
end THERMOSTAT;

-- Assign different internal signal(wires) for connecting the output ports of different flip flop  
architecture BEHAV of THERMOSTAT is
signal INT_CURRENT_TEMP : std_logic_vector(6 downto 0);
signal INT_DESIRED_TEMP : std_logic_vector(6 downto 0);
signal INT_DISPLAY_SELECT : std_logic; 
signal INT_TEMP_DISPLAY : std_logic_vector(6 downto 0);
signal INT_COOL : std_logic;
signal INT_HEAT : std_logic;
signal INT_A_C_ON : std_logic;
signal INT_FURNACE_ON : std_logic;
type STATE_TYPE is (IDLE, HEATON, FURNACENOWHOT, FURNACECOOL, COOLON, ACNOWREADY, ACDONE);
signal CURRENT_STATE, NEXT_STATE: STATE_TYPE;

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

-----------------------------------
-- state diagram part--------------
-- process 12: flip flop is used to update the output current_state based on the input next_state when it is clock-edge.
-----------------------------------
process (CLK,RESET)
begin
if RESET = '0' then
CURRENT_STATE <= IDLE;
elsif  CLK'event and CLK = '1' then
CURRENT_STATE <= NEXT_STATE;
end if;
end process;

-----------------------------------
-- state diagram part--------------
-- process 13: all of the transitions are shown below for different state.
-----------------------------------
process (CURRENT_STATE, INT_HEAT, INT_COOL, INT_CURRENT_TEMP, INT_DESIRED_TEMP, FURNACE_HOT, AC_READY)
begin
case CURRENT_STATE is 
     when IDLE =>
          if INT_HEAT='1' and INT_CURRENT_TEMP < INT_DESIRED_TEMP then 
             NEXT_STATE <= HEATON;
          elsif INT_COOL='1' and INT_CURRENT_TEMP > INT_DESIRED_TEMP then
             NEXT_STATE <= COOLON;
          else
             NEXT_STATE <= IDLE;
          end if;
          
      when HEATON =>                
          if FURNACE_HOT = '1' then 
             NEXT_STATE <= FURNACENOWHOT;
          else
             NEXT_STATE <= HEATON;
          end if;
          
      when FURNACENOWHOT =>
           if INT_HEAT='0' or INT_CURRENT_TEMP > INT_DESIRED_TEMP then
             NEXT_STATE <= FURNACECOOL;
           else
             NEXT_STATE <=  FURNACENOWHOT;
           end if;
           
           
      when FURNACECOOL =>
           if FURNACE_HOT = '0' then
              NEXT_STATE <=  IDLE;
           else
              NEXT_STATE <= FURNACECOOL;
           end if;
      
      
      when COOLON =>
           if AC_READY ='1' then
              NEXT_STATE <= ACNOWREADY;
           else
              NEXT_STATE <= COOLON;
           end if;
           
           
      when ACNOWREADY =>
           if INT_COOL='0' or INT_CURRENT_TEMP < INT_DESIRED_TEMP then
              NEXT_STATE <= ACDONE;
           else
              NEXT_STATE <= ACNOWREADY;
           end if;
       
       
       when ACDONE =>
            if AC_READY ='0' then
               NEXT_STATE <= IDLE;
            else
               NEXT_STATE <= ACDONE;
            end if;
            end case;
  end process;

-------------------------------------------
--state diagram part-----------------------
-- process 14: otuput of different state are shown below
--------------------------------------------------------
process (CURRENT_STATE)
begin 
     case CURRENT_STATE is 
         when IDLE =>
              FURNACE_ON <='0';
              A_C_ON <='0';
              FAN_ON <='0';
              
              
         when HEATON =>
              FURNACE_ON <='1';
              A_C_ON <='0';
              FAN_ON <='0';
              
              
         when FURNACENOWHOT =>
              FURNACE_ON <='1';
              A_C_ON <='0';
              FAN_ON <='1';
              
         when FURNACECOOL =>     
              FURNACE_ON <='0';
              A_C_ON <='0';
              FAN_ON <='1';
         
         
         when COOLON =>
              FURNACE_ON <='0';
              A_C_ON <='1';
              FAN_ON <='0';
              
              
         when ACNOWREADY =>
              FURNACE_ON <='0';
              A_C_ON <='1';
              FAN_ON <='1';
              
              
         when ACDONE =>
              FURNACE_ON <='0';
              A_C_ON <='0';
              FAN_ON <='1';    
      end case;
      end process;      
end BEHAV;


