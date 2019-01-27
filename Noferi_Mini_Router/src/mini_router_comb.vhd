-- author: Alessandro Noferi
-- 4 spaces per tab indentation

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;           

use work.router_pkg.all;	-- Use of link record and 
                          	-- router_data_out

-- This component is the core of the architecture. It chooses which link forward
-- according to the request signal and priority bits (last two bits of the data)
-- and a Round Robin algorithm that select the link in case of same priority 
-- (and req high)


----------------------------------------------------------------
-- entity declaration	mini router_comb  			      		 |
----------------------------------------------------------------

entity mini_router_comb is
	port (
        -- inputs
        link_1  : in link; -- record with data and req signals
        link_2  : in link; -- record with data and req signals
        -- rr alg
        rr_in     : in std_logic;
        rr_out 	  : out std_logic;
        -- outputs
        grant_1     : out std_logic; -- record with output data and valid signals
        grant_2     : out std_logic;
        router_out : out router_data_out  -- record with output data and valid signals 
	);
end mini_router_comb;

----------------------------------------------------------------
-- architecture: mini_router_comb            		    		 |
----------------------------------------------------------------

architecture bhv of mini_router_comb is
    begin	
        -- router valid signal is 1 when: link_1.req is 1 and link_2.req is 0 OR
        --                                link_1.req is 0 and link_2.req is 1 OR
        --                                link_1.req is 1 and link_2.req is 1 and link_1. priority > link_2.priority OR
        --                                link_1.req is 1 and link_2.req is 1 and link_1. priority < link_2.priority OR
        --                                link_1.req is 1 and link_2.req is 1 and link_1. priority = link_2.priority
                                                      
        router_out.valid <= '1' when ((link_1.req = '1' and link_2.req = '0') or 
                                     (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_1.data(1 downto 0))) > to_integer(unsigned(link_2.data(1 downto 0)))) or 
                                     (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_1.data(1 downto 0))) = to_integer(unsigned(link_2.data(1 downto 0))) and rr_in  = '0')) else
                            '1' when ((link_2.req = '1' and link_1.req = '0') or 
                                     (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_2.data(1 downto 0))) > to_integer(unsigned(link_1.data(1 downto 0)))) or 
                                     (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_1.data(1 downto 0))) = to_integer(unsigned(link_2.data(1 downto 0))) and rr_in  = '1')) else 
		                    '0';
        -- router output signal is link_1 data when: link_1.req is 1 and link_2.req is 0 OR
        --                                           link_1.req is 1 and link_2.req is 1 and link_1. priority > link_2.priority OR
        --                                           link_1.req is 1 and link_2.req is 1 and link_1. priority = link_2.priority and rr is 0
        
        -- router output signal is link_2 data when: link_2.req is 1 and link_1.req is 0 OR
        --                                           link_2.req is 1 and link_1.req is 1 and link_1. priority < link_2.priority OR
        --                                           link_2.req is 1 and link_1.req is 1 and link_1. priority = link_2.priority and rr is 1
        
	    router_out.data_out <=  link_1.data(9 downto 2) when ((link_1.req = '1' and link_2.req = '0') or 
	                                                         (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_1.data(1 downto 0))) > to_integer(unsigned(link_2.data(1 downto 0)))) or 
	                                                         (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_1.data(1 downto 0))) = to_integer(unsigned(link_2.data(1 downto 0))) and rr_in  = '0' )) else 
                                link_2.data(9 downto 2) when ((link_2.req = '1' and link_1.req = '0') or 
                                                             (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_2.data(1 downto 0))) > to_integer(unsigned(link_1.data(1 downto 0)))) or 
                                                             (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_1.data(1 downto 0))) = to_integer(unsigned(link_2.data(1 downto 0))) and rr_in  = '1')) else 
                                (others => '0');
        
        -- router grant_1 signal is 1 when: link_1.req is 1 and link_2.req is 0 OR                
        --                                  link_1.req is 1 and link_2.req is 1 and link_1. priority > link_2.priority OR
        --                                  link_1.req is 1 and link_2.req is 1 and link_1. priority = link_2.priority and rr is 0
        grant_1 <= '1' when ((link_1.req = '1' and link_2.req = '0') or 
                            (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_1.data(1 downto 0))) > to_integer(unsigned(link_2.data(1 downto 0)))) or 
                            (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_1.data(1 downto 0))) = to_integer(unsigned(link_2.data(1 downto 0))) and rr_in  = '0')) else      		  
        	       '0';  			    	
        -- '0' when ((link_2.req = '1' and link_1.req = '0') or 
        --                  (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_2.data(1 downto 0))) > to_integer(unsigned(link_1.data(1 downto 0)))) or 
        --                  (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_1.data(1 downto 0))) = to_integer(unsigned(link_2.data(1 downto 0))) and rr_in  = '1'))
                            
	    -- router grant_2 signal is 1 when: link_2.req is 1 and link_1.req is 0 OR                
        --                                  link_2.req is 1 and link_1.req is 1 and link_2. priority > link_1.priority OR
        --                                  link_2.req is 1 and link_1.req is 1 and link_2. priority = link_1.priority and rr is 1
	    grant_2 <= '1' when (link_2.req = '1' and link_1.req = '0') or 
	                        (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_2.data(1 downto 0))) > to_integer(unsigned(link_1.data(1 downto 0)))) or
                            (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_1.data(1 downto 0))) = to_integer(unsigned(link_2.data(1 downto 0))) and rr_in ='1') else
                   '0';

        -- rr_out is 1 when rr_in is 0 and there is same priority for both links
        --        is 0 when rr_in is 1 and there is same priority for both links
        --        rr_in and there is not same priority for both links        
   	    rr_out  <= '0' when (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_1.data(1 downto 0))) = to_integer(unsigned(link_2.data(1 downto 0))) and rr_in  = '1') else
	               '1' when (link_1.req = '1' and link_2.req = '1' and to_integer(unsigned(link_1.data(1 downto 0))) = to_integer(unsigned(link_2.data(1 downto 0))) and rr_in  = '0') else
		           rr_in;
                
 
	
end bhv;    
