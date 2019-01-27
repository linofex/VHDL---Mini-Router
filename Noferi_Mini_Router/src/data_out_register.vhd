

library IEEE;
use IEEE.std_logic_1164.all;

use work.router_pkg.all; -- Use of link record and router_data_out

----------------------------------------------------------------
-- entity declaration	data_out_register                 |
----------------------------------------------------------------

entity data_out_register is
	port (
		in_data_out : in router_data_out;	
		clk	: in std_logic;
		rst	: in std_logic;
		out_data_out: out router_data_out
	);
end data_out_register;

----------------------------------------------------------------
-- architecture: data_out_register		 	    |
----------------------------------------------------------------
architecture bhv of data_out_register is
begin
	reg_p: process(clk)
		begin
			if (clk = '1' and clk'event) then -- every rising edge clk
			    if rst = '0' then -- synchronous reset active-low 
			        -- reset output
				    out_data_out.data_out <= (others => '0');
				    out_data_out.valid <= '0';
				else 
			        -- set output
				    out_data_out.data_out  <= in_data_out.data_out;
				    out_data_out.valid <= in_data_out.valid;
			    end if;
			end if;
		end process;
end bhv;			
	
