-- author: Alessandro Noferi
-- 4 spaces per tab indentation

library ieee;
use ieee.std_logic_1164.all;

-- This package let u

package router_pkg is
    type link is record
      data  : std_logic_vector(9 downto 0); -- data signal 10 bits (8 data + 2 priority)
      req : std_logic;                      -- req signal 1 bit
    end record  link;  

    type router_data_out is record
      data_out  : std_logic_vector(7 downto 0); -- output data signal 8 bits (input data wo 2 priority bits)
      valid : std_logic;                        -- valid signal 1 bit
    end record router_data_out;  
end package router_pkg;
