library IEEE;
use IEEE.std_logic_1164.all;

library WORK;

----------------------------------------------------------------
-- entity declaration	Dff				                               |
----------------------------------------------------------------

entity Dff is
	generic ( Nbit : positive); -- used to set the bit length of the register
	port (
		d	: in std_logic_vector(Nbit downto 1);
		clk	: in std_logic;
		rst	: in std_logic;
		q 	: out std_logic_vector(Nbit downto 1)
	);
end Dff;

----------------------------------------------------------------
-- architecture: Dff  as                             		       |
----------------------------------------------------------------
architecture bhv of Dff is

signal out_dff : std_logic_vector (Nbit downto 1);
signal out_rca : std_logic_vector (Nbit downto 1);

begin
	dff_p: process(clk)
		begin
	        if (clk = '1' and clk'event) then -- every rising edge clk
			    if rst = '0' then -- synchronous reset active-low 
				    q <= (others => '0');
			    else
				    q <= d;  -- output is the input
			    end if;
			 end if;
		end process;
end bhv;			
	
