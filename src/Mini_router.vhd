-- author: Alessandro Noferi
-- 4 spaces per tab indentation

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;           

use work.router_pkg.all; -- Use of link record and router_data_out


----------------------------------------------------------------
-- entity declaration	mini router    			                     |
----------------------------------------------------------------

entity mini_router is
	port (
        -- inputs
        link_1  : in link; -- record with data and req signals
        link_2  : in link; -- record with data and req signals
        rst     : in std_logic; --  active-low
		clk	    : in std_logic;
        
        -- outputs
        grant_1     : out std_logic; -- record with output data and valid signals
        grant_2     : out std_logic;
        router_out : out router_data_out  -- record with output data and valid signals
	);
end mini_router;

----------------------------------------------------------------
-- architecture: mini_router            				                |
----------------------------------------------------------------
--use textio.all;
architecture bhv of mini_router is
	component link_register is
	port(
		in_link : in link;	
		clk	: in std_logic;
		rst	: in std_logic;
		out_link: out link
	);
	end component;
		
	component mini_router_comb
	port (
		-- inputs
		link_1  : in link; -- record with data and req signals
		link_2  : in link; -- record with data and req signals

		rr_in : in std_logic;
		rr_out : out std_logic;
			
		-- outputs
		grant_1     : out std_logic; -- record with output data and valid signals
		grant_2     : out std_logic;
		router_out : out router_data_out  -- record with output data and valid signals 
	);
	end component;
	
	component  data_out_register
	port (
		in_data_out : in router_data_out;	
		clk	: in std_logic;
		rst	: in std_logic;
		out_data_out: out router_data_out
	);
        end component;

        component Dff
	generic (Nbit : positive); -- used to set the bit length of the register
	port (
		d	: in std_logic_vector(Nbit downto 1);
		clk	: in std_logic;
		rst	: in std_logic;
		q 	: out std_logic_vector(Nbit downto 1)
	);
	end component;
    


    -- signals to interconnect the components (regisgters to mini router)
        signal reg_in_link_1	 : link;
	    signal reg_in_link_2	 : link;
	    signal out_reg_data_out : router_data_out;
        signal out_reg_grant_1    : std_logic;
        signal out_reg_grant_2    : std_logic;

        signal rr_in :  std_logic;  
        signal rr_out : std_logic;

	begin
	     --set input registers
			IN_LINK1_REG: link_register
			port map(
                 in_link => link_1, 
                 clk => clk, 
                 rst => rst, 
                 out_link => reg_in_link_1
			 );

			IN_LINK2_REG: link_register
			port map(
                 in_link => link_2, 
                 clk => clk, 
                 rst => rst, 
                 out_link => reg_in_link_2
            );
        -- set combinatorial logic
			MINI_ROUTER: mini_router_comb
			port map(
	            link_1  => reg_in_link_1,
                link_2  => reg_in_link_2,
                -- rr alg
                rr_in   =>  rr_in,
                rr_out  =>  rr_out,
                -- outputs
                grant_1 => out_reg_grant_1,
                grant_2 => out_reg_grant_2,
                router_out => out_reg_data_out
			);
		--set output register	
			OUT_REG: data_out_register
            port map(
                in_data_out => out_reg_data_out,
                clk => clk, 
                rst =>rst, 
                out_data_out => router_out
            );
		--set grants	

            GRANT1_REG: Dff
			generic map(Nbit => 1)
	   		port map(
			 	d(1)    => out_reg_grant_1,
				clk     => clk,
				rst 	=> rst,
				q(1)	=> grant_1
    		);

			GRANT2_REG: Dff
			generic map(Nbit => 1)
	   		port map(
			 	d(1)    => out_reg_grant_2,
				clk     => clk,
				rst 	=> rst,
				q(1)	=> grant_2
    		);
            -- set round robin register
            RR_REG: Dff
			generic map(Nbit => 1)
	   		port map(
			 	d(1)    => rr_out,
				clk     => clk,
				rst 	=> rst,
				q(1)	=> rr_in
    		);
end bhv;
