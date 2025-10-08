library IEEE;
use IEEE.std_logic_1164.ALL;
use work.math_package.all;

entity THERMOSTAT is
  port (
    CURRENT_TEMP    : in std_logic_vector(6 downto 0);
    DESIRED_TEMP    : in std_logic_vector(6 downto 0);
    DISPLAY_SELECT  : in std_logic;
    COOL            : in std_logic;
    HEAT            : in std_logic;
    CLK             : in std_logic;
    RESET           : in std_logic;
    FURNACE_HOT     : in std_logic;
    AC_READY        : in std_logic;
    A_C_ON          : out std_logic;
    FURNACE_ON      : out std_logic;
    FAN_ON          : out std_logic; 
    TEMP_DISPLAY    : out std_logic_vector(6 downto 0)
  );
end THERMOSTAT;

architecture BEHAV of THERMOSTAT is

  signal INT_CURRENT_TEMP    : std_logic_vector(6 downto 0);
  signal INT_DESIRED_TEMP    : std_logic_vector(6 downto 0);
  signal INT_DISPLAY_SELECT  : std_logic; 
  signal INT_TEMP_DISPLAY    : std_logic_vector(6 downto 0);
  signal INT_COOL            : std_logic;
  signal INT_HEAT            : std_logic;
  signal INT_A_C_ON          : std_logic;
  signal INT_FURNACE_ON      : std_logic;

  type STATE_TYPE is (IDLE, HEATON, FURNACENOWHOT, FURNACECOOL, COOLON, ACNOWREADY, ACDONE);
  signal CURRENT_STATE, NEXT_STATE : STATE_TYPE;

  signal countdown_ac : integer range 0 to 20 := 0;
  signal countdown_fn : integer range 0 to 20 := 0;

begin

--------------------------------------------------
-- PROCESS 1: CURRENT_TEMP register
--------------------------------------------------
process (CLK, RESET)
begin
  if RESET = '0' then
    INT_CURRENT_TEMP <= (others => '0');
  elsif rising_edge(CLK) then
    INT_CURRENT_TEMP <= CURRENT_TEMP;
  end if;
end process;

--------------------------------------------------
-- PROCESS 2: DESIRED_TEMP register
--------------------------------------------------
process (CLK, RESET)
begin
  if RESET = '0' then
    INT_DESIRED_TEMP <= (others => '0');
  elsif rising_edge(CLK) then
    INT_DESIRED_TEMP <= DESIRED_TEMP;
  end if;
end process;

--------------------------------------------------
-- PROCESS 3: DISPLAY_SELECT register
--------------------------------------------------
process (CLK, RESET)
begin
  if RESET = '0' then
    INT_DISPLAY_SELECT <= '0';
  elsif rising_edge(CLK) then
    INT_DISPLAY_SELECT <= DISPLAY_SELECT;
  end if;
end process;

--------------------------------------------------
-- PROCESS 4: TEMP_DISPLAY combinational
--------------------------------------------------
process (INT_CURRENT_TEMP, INT_DESIRED_TEMP, INT_DISPLAY_SELECT)
begin
  if INT_DISPLAY_SELECT = '1' then
    INT_TEMP_DISPLAY <= INT_CURRENT_TEMP;
  else
    INT_TEMP_DISPLAY <= INT_DESIRED_TEMP;
  end if;
end process;

--------------------------------------------------
-- PROCESS 5: TEMP_DISPLAY output register
--------------------------------------------------
process (CLK, RESET)
begin
  if RESET = '0' then
    TEMP_DISPLAY <= (others => '0');
  elsif rising_edge(CLK) then
    TEMP_DISPLAY <= INT_TEMP_DISPLAY;
  end if;
end process;

--------------------------------------------------
-- PROCESS 6: COOL input register
--------------------------------------------------
process (CLK, RESET)
begin
  if RESET = '0' then
    INT_COOL <= '0';
  elsif rising_edge(CLK) then
    INT_COOL <= COOL;
  end if;
end process;

--------------------------------------------------
-- PROCESS 7: HEAT input register
--------------------------------------------------
process (CLK, RESET)
begin
  if RESET = '0' then
    INT_HEAT <= '0';
  elsif rising_edge(CLK) then
    INT_HEAT <= HEAT;
  end if;
end process;

--------------------------------------------------
-- PROCESS 8: AC combinational logic
--------------------------------------------------
process (INT_CURRENT_TEMP, INT_DESIRED_TEMP, INT_COOL)
begin
  if INT_DESIRED_TEMP < INT_CURRENT_TEMP and INT_COOL = '1' then
    INT_A_C_ON <= '1';
  else
    INT_A_C_ON <= '0';
  end if;
end process;

--------------------------------------------------
-- PROCESS 9: Furnace combinational logic
--------------------------------------------------
process (INT_CURRENT_TEMP, INT_DESIRED_TEMP, INT_HEAT)
begin
  if INT_DESIRED_TEMP > INT_CURRENT_TEMP and INT_HEAT = '1' then
    INT_FURNACE_ON <= '1';
  else
    INT_FURNACE_ON <= '0';
  end if;
end process;

--------------------------------------------------
-- PROCESS 10: A_C_ON output register
--------------------------------------------------
process (CLK, RESET)
begin
  if RESET = '0' then
    A_C_ON <= '0';
  elsif rising_edge(CLK) then
    A_C_ON <= INT_A_C_ON;
  end if;
end process;

--------------------------------------------------
-- PROCESS 11: FURNACE_ON output register
--------------------------------------------------
process (CLK, RESET)
begin
  if RESET = '0' then
    FURNACE_ON <= '0';
  elsif rising_edge(CLK) then
    FURNACE_ON <= INT_FURNACE_ON;
  end if;
end process;

--------------------------------------------------
-- PROCESS 12: State register
--------------------------------------------------
process (CLK, RESET)
begin
  if RESET = '0' then
    CURRENT_STATE <= IDLE;
  elsif rising_edge(CLK) then
    CURRENT_STATE <= NEXT_STATE;
  end if;
end process;

--------------------------------------------------
-- PROCESS 13: State transition logic
--------------------------------------------------
process (CURRENT_STATE, INT_HEAT, INT_COOL, INT_CURRENT_TEMP, INT_DESIRED_TEMP, FURNACE_HOT, AC_READY, countdown_ac, countdown_fn)
begin
  case CURRENT_STATE is

    when IDLE =>
      if INT_HEAT = '1' and INT_CURRENT_TEMP < INT_DESIRED_TEMP then
        NEXT_STATE <= HEATON;
      elsif INT_COOL = '1' and INT_CURRENT_TEMP > INT_DESIRED_TEMP then
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
      if INT_HEAT = '0' or INT_CURRENT_TEMP > INT_DESIRED_TEMP then
        NEXT_STATE <= FURNACECOOL;
      else
        NEXT_STATE <= FURNACENOWHOT;
      end if;

    when FURNACECOOL =>
      if FURNACE_HOT = '0' and countdown_fn = 0 then
        NEXT_STATE <= IDLE;
      else
        NEXT_STATE <= FURNACECOOL;
      end if;

    when COOLON =>
      if AC_READY = '1' then
        NEXT_STATE <= ACNOWREADY;
      else
        NEXT_STATE <= COOLON;
      end if;

    when ACNOWREADY =>
      if INT_COOL = '0' or INT_CURRENT_TEMP < INT_DESIRED_TEMP then
        NEXT_STATE <= ACDONE;
      else
        NEXT_STATE <= ACNOWREADY;
      end if;

    when ACDONE =>
      if AC_READY = '0' and countdown_ac = 0 then
        NEXT_STATE <= IDLE;
      else
        NEXT_STATE <= ACDONE;
      end if;

  end case;
end process;

--------------------------------------------------
-- PROCESS 14: Countdown for AC
--------------------------------------------------
process (CLK, RESET)
begin
  if RESET = '0' then
    countdown_ac <= 0;
  elsif rising_edge(CLK) then
    if CURRENT_STATE = ACNOWREADY and NEXT_STATE = ACDONE then
      countdown_ac <= 20;
    elsif CURRENT_STATE = ACDONE then
      countdown_ac <= AC_COUNTDOWN(countdown_ac);
    end if;

    report "Countdown = " & integer'image(countdown_ac);
  end if;
end process;

--------------------------------------------------
-- PROCESS 15: Countdown for Furnace
--------------------------------------------------
process (CLK, RESET)
begin
   if RESET = '0' then
       countdown_fn <= 0;
   elsif rising_edge(CLK) then
       -- When transitioning into FURNACECOOL, load 10
       if CURRENT_STATE = FURNACENOWHOT and NEXT_STATE = FURNACECOOL then
           countdown_fn <= 10;
       -- While remaining in FURNACECOOL, decrement
       elsif CURRENT_STATE = FURNACECOOL then
           countdown_fn <= FN_COUNTDOWN(countdown_fn);
       end if;

       report "Furnace Countdown = " & integer'image(countdown_fn);
   end if;
end process;

--------------------------------------------------
-- PROCESS 16: Output logic by state
--------------------------------------------------
process (CURRENT_STATE)
begin
  case CURRENT_STATE is
    when IDLE =>
      FURNACE_ON <= '0';
      A_C_ON <= '0';
      FAN_ON <= '0';

    when HEATON =>
      FURNACE_ON <= '1';
      A_C_ON <= '0';
      FAN_ON <= '0';

    when FURNACENOWHOT =>
      FURNACE_ON <= '1';
      A_C_ON <= '0';
      FAN_ON <= '1';

    when FURNACECOOL =>
      FURNACE_ON <= '0';
      A_C_ON <= '0';
      FAN_ON <= '1';

    when COOLON =>
      FURNACE_ON <= '0';
      A_C_ON <= '1';
      FAN_ON <= '0';

    when ACNOWREADY =>
      FURNACE_ON <= '0';
      A_C_ON <= '1';
      FAN_ON <= '1';

    when ACDONE =>
      FURNACE_ON <= '0';
      A_C_ON <= '0';
      FAN_ON <= '1';
  end case;
end process;

end BEHAV;
