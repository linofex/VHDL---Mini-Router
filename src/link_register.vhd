
library IEEE;
use IEEE.std_logic_1164.all;

use work.router_pkg.all; -- Use of link record and router_data_out

----------------------------------------------------------------
-- entity declaration	link_register                     |
----------------------------------------------------------------

entity link_register	 is
	port (
		in_link : in link;	
		clk	: in std_logic;
		rst	: in std_logic;
		out_link: out link
	);
end link_register;

----------------------------------------------------------------
-- architecture: link_register		                 | 
----------------------------------------------------------------
architecture bhv of link_register is
begin
	reg_p: process(clk)
		begin
			if (clk = '1' and clk'event) then -- every rising edge clk
			    if rst = '0' then -- synchronous reset active-low 
			        -- reset output
				    out_link.data <= (others => '0');
				    out_link.req <= '0';
			    else
			        -- set output
				    out_link.data <= in_link.data;
				    out_link.req <= in_link.req;
			    end if;
			end if;
		end process;
end bhv;			
	
