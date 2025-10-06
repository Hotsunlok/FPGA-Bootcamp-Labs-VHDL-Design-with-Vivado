library IEEE;
use IEEE.std_logic_1164.all;

package body math_package is

function AC_COUNTDOWN(curr_value : integer) return integer is
    variable temp_ac : integer;
begin
    if curr_value > 0 then
        temp_ac := curr_value - 1;
    else
        temp_ac := 0;
    end if;

    return temp_ac;
end function;

function FN_COUNTDOWN(curr_value : integer) return integer is 
    variable temp_fn : integer;
begin
    if curr_value > 0 then
        temp_fn := curr_value - 1;
    else
        temp_fn := 0;
    end if;

    return temp_fn;
end function;

end package body math_package;
