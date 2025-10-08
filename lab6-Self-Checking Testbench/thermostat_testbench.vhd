library IEEE;
use IEEE.std_logic_1164.ALL;
entity thermostat_tb is

end thermostat_tb;

architecture Behavioral of thermostat_tb is

-- component's port name 
component THERMOSTAT
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
         FAN_ON       : out std_logic;
         TEMP_DISPLAY : out std_logic_vector(6 downto 0)
);

end component;

-- signal/ wires name 
signal CURRENT_TEMP   : std_logic_vector(6 downto 0) := (others => '0');
signal DESIRED_TEMP   : std_logic_vector(6 downto 0) := (others => '0');

signal DISPLAY_SELECT : std_logic := '0';
signal COOL           : std_logic := '0';
signal HEAT           : std_logic := '0';
signal CLK            : std_logic := '0';
signal RESET          : std_logic := '0';

signal FURNACE_HOT    : std_logic := '0';
signal AC_READY       : std_logic := '0';

signal A_C_ON : std_logic := '0';
signal FURNACE_ON : std_logic := '0';
signal FAN_ON : std_logic := '0';
signal TEMP_DISPLAY   : std_logic_vector(6 downto 0);

begin
-- port connects to wires
UUT: THERMOSTAT port map ( CURRENT_TEMP => CURRENT_TEMP,
                           DESIRED_TEMP => DESIRED_TEMP,
                           DISPLAY_SELECT => DISPLAY_SELECT,
                           COOL => COOL,
                           HEAT => HEAT,
                           CLK => CLK,
                           RESET => RESET,
                           FURNACE_HOT => FURNACE_HOT,
                           AC_READY => AC_READY,
                           A_C_ON => A_C_ON,
                           FURNACE_ON => FURNACE_ON,
                           FAN_ON => FAN_ON,
                           TEMP_DISPLAY => TEMP_DISPLAY
                           );


-- Clock generator: produces a square wave with 10 ns period
-- First 5 ns = '0', next 5 ns = '1', then repeats                           
CLK <= not CLK after 5 ns; 

process 
procedure ApplyInputs(
  signal CURRENT_TEMP   : out std_logic_vector(6 downto 0);
  signal DESIRED_TEMP   : out std_logic_vector(6 downto 0);
  signal DISPLAY_SELECT : out std_logic;
  signal COOL           : out std_logic;
  signal HEAT           : out std_logic;
  constant curr_val     : in std_logic_vector(6 downto 0);
  constant des_val      : in std_logic_vector(6 downto 0);
  constant disp_val     : in std_logic;
  constant cool_val     : in std_logic;
  constant heat_val     : in std_logic;
  constant delay_time   : in time
) is
begin
  CURRENT_TEMP   <= curr_val;
  DESIRED_TEMP   <= des_val;
  DISPLAY_SELECT <= disp_val;
  COOL           <= cool_val;
  HEAT           <= heat_val;
  wait for delay_time;
end procedure;


begin
assert false report "Starting Temperature Simulation" severity note;

-- Reset signal: stays '0' (active) for the first 10 ns,
-- then becomes '1' to release the reset
 RESET <= '0' , '1' after 10ns;
 
 ---------------------------------------------------------------------------
 
 assert false
report "At time 5ns IDLE state, AC=OFF, Furnace=OFF, Fan=OFF"
severity note;
--RESET IS '0' !!! (IDLE) CLK RISE EDGE AT 5NS : AC off, furnace off, temp_display= desired temperature(0000000) 
ApplyInputs(CURRENT_TEMP, DESIRED_TEMP, DISPLAY_SELECT, COOL, HEAT,
            "0000000", "1111111", '0', '0', '1', 10 ns);


-----------------------------------------------------------------------------


assert false
report "At time 25ns COOLON state, AC=ON, Furnace=OFF, Fan=OFF"
severity note;
--RESET IS '1' !!! (IDLE) CLK RISE EDGE AT 15NS, AC off , furnace off, temp_display= (0000000)
 -- (COOLON) CLK RISE EDGE AT 25NS , AC ON , FURNACE OFF, FAN OFF
ApplyInputs(CURRENT_TEMP, DESIRED_TEMP, DISPLAY_SELECT, COOL, HEAT,
            "1111100", "0000011", '1', '1', '0', 20 ns);


---------------------------------------------------------------------------- 
 
 
 
 --RESET IS '1' !!! (ACNOWREADY) CLK RISE EDGE AT 35NS , AC ON , FURNACE OFF, FAN ON
 AC_READY <='1';
 assert false
report "At time " & time'image(now) &
       "  ACNOWREADY state, AC=ON, Furnace=OFF, Fan=ON ,countdown_ac=20 "
severity note;
 wait for 10 ns;
 

---------------------------------------------------------------------------


assert false
report "At time 55ns ACDONE state, AC=OFF, Furnace=OFF, Fan=ON ,countdown_ac=19 "
severity note;

-- RESET IS '1'!!! (ACNOWREADY) CLK RISE EDGE AT 45NS : AC ON , FURNACE OFF, FAN ON
 -- RESET IS '1'!!! (ACDONE) CLK RISE EDGE AT 55NS : AC OFF, FURNACE OFF, FAN ON 
ApplyInputs(CURRENT_TEMP, DESIRED_TEMP, DISPLAY_SELECT, COOL, HEAT,
            "0001100", "1111000", '1', '0', '0', 20 ns);
                   
-----------------------------------------------------------------------------




 --RESET IS '1' !!! (IDLE) CLK RISE EDGE AT 265NS , AC OFF , FURNACE OFF, FAN OFF
 AC_READY <='0';
 wait for 205 ns;
 
 assert false
report "At time " & time'image(now) &
       "  IDLE state, AC=OFF, Furnace=OFF, Fan=OFF ,countdown_ac=0 "
severity note;
 
 
assert false report " Simulation finished, System returned to IDLE" severity failure;

 wait;
 end process;
end Behavioral;
