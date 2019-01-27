
library IEEE;
use IEEE.std_logic_1164.all;
use work.router_pkg.all; -- Use of link record and router_data_out


----------------------------------------------------------------
-- entity declaration	mini router_tb 			      							 |
----------------------------------------------------------------

entity Mini_router_comb_tb is   -- The testbench has no interfacewhatever

end Mini_router_comb_tb;

----------------------------------------------------------------
-- architecture: mini_router_tb          		       						 |
----------------------------------------------------------------

architecture bhv of Mini_router_comb_tb is -- Testbench architecture declaration
	-----------------------------------------------------------------------------------
	-- Testbench constants																														|
	-----------------------------------------------------------------------------------
	constant T_CLK   : time := 10 ns; -- Clock period
	constant T_RESET : time := 25 ns; -- Period before the reset deassertion
	-----------------------------------------------------------------------------------
  -- Testbench signals																															|
  -----------------------------------------------------------------------------------
	signal clk_tb : std_logic := '0'; -- clock signal, intialized to '0' 
	signal rst_tb  : std_logic := '0'; -- reset signal
	-- mini router signals
	signal rr_in_tb : std_logic := '0';
	signal rr_out_tb : std_logic;

	signal link_1_tb	: link;
	signal link_2_tb	: link;
	signal router_out_tb	: router_data_out;
	signal grant_1_tb : std_logic;
	signal grant_2_tb : std_logic;

	signal end_sim : std_logic := '1'; -- signal to use to stop the simulation when there is nothing else to test
	-----------------------------------------------------------------------------------
	-- Component to test (DUT) declaration																						|
	-----------------------------------------------------------------------------------
	component mini_router_comb is      -- be careful, it is only a component declaration. The component shall be instantiated after the keyword "begin" by linking the gates with the testbench signals for the test
		port (
			-- inputs
			link_1  : in link; -- record with data and req signals
			link_2  : in link; -- record with data and req signals
			rr_in 	: in std_logic;
			rr_out 	: out std_logic;
			-- outputs
			grant_1     : out std_logic; 
			grant_2     : out std_logic;
			router_out : out router_data_out  -- record with output data and valid signals 
			);
	end component;
	
	begin
	
	  clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2;  -- The clock toggles after T_CLK / 2 when end_sim is high. When end_sim is forced low, the clock stops toggling and the simulation ends.
	  rst_tb <= '1' after T_RESET; -- Deasserting the reset after T_RESET nanosecods (remember: the reset is active low).
	  
	  test_mini_router: mini_router_comb  -- mini_router instantiation
	   	port map(
			link_1      => link_1_tb,
			link_2      => link_2_tb,
			rr_in => rr_in_tb,
			rr_out => rr_out_tb,
			grant_1 		=> grant_1_tb,
			grant_2 		=> grant_2_tb,
			router_out 	=> router_out_tb
      );
	  
	  TB_process: process(clk_tb) -- process used to make the testbench signals change synchronously with the rising edge of the clock
			variable t : integer := 0; -- variable used to count the clock cycle after the reset
			begin
				if(rst_tb = '0') then
							t := 0;
				elsif(rising_edge(clk_tb)) then
					case(t) is   -- specifying the mini router inputs signals and end_sim depending on the value of t (and so on the number of the passed clock cycles).
						when 1 => -- same priority, RR starts at 0, so link_1.data will be forwarded
							link_1_tb.data <= "1000000001";
							link_1_tb.req <= '1';
							link_2_tb.data <= "1100000001";
							link_2_tb.req <= '1';
							rr_in_tb <= '0';						
						when 2 => -- link_2 has higher priority, so link_2.data will be forwarded
							
							link_1_tb.data <= "0011111010";
							link_1_tb.req <= '1';
							link_2_tb.data <= "0011111011";
							link_2_tb.req <= '1';
			
						when 3 => -- both with req = 0, so valid is 0
							link_1_tb.data <= "1000000011";
							link_1_tb.req <= '0';
							link_2_tb.data <= "0011111011";
							link_2_tb.req <= '0';
							rr_in_tb <= '1';
					
						when 6 => -- same priority, RR starts at 1 (after case t = 1), so link_2.data will be forwarded first
											-- the next clock RR will be 0, so link_1.data will be forwarded, and so on
							link_1_tb.data <= "1111111110";
							link_1_tb.req <= '1';
							link_2_tb.data <= "0000000110";
							link_2_tb.req <= '1';
							rr_in_tb <= '1';	
						when 14 => -- same priority, RR starts at 1 (after case t = 1), so link_2.data will be forwarded first
							   -- the next clock RR will be 0, so link_1.data will be forwarded, and so on
							link_1_tb.data <= "1111111110";
							link_1_tb.req <= '1';
							link_2_tb.data <= "1000000010";
							link_2_tb.req <= '0';		
						--when 5 => 
						--when 6 => 
						--when 7 => 
						when 20 => end_sim <= '0'; -- This command stops the simulation when t = 10
											when others => null; -- Specifying that nothing happens in the other cases 

					end case;
					t := t + 1;
				end if;
	  end process;
	
end bhv;
