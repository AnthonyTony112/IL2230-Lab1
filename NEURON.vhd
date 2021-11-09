library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;
use work.all;

entity NEURON is
	generic (
		N: integer := 8;
		K: integer := 2;
		datawidth: integer :=8;
		decimal_width: integer :=4
	);
	port (
		X: In std_logic_vector(datawidth-1 downto 0);
		Output: Out std_logic_vector(datawidth-1 downto 0);
		clk, reset: In std_logic;
		ready: Out std_logic	--Optional
	);
end NEURON;


---------------------------------------------------------------------------------
--New Version
---------------------------------------------------------------------------------
architecture AllInOne of NEURON is
	signal Counter: std_logic_vector(integer(ceil(log2(real(N))))-1 downto 0);
	signal n_ready: std_logic;
	begin
		U_Datapath: entity work.DataPath(behave)
			generic map(N, K, datawidth, decimal_width)
			port map(X, Output, Counter, clk, reset, n_ready);
		
		U_Controller: entity work.Controller(behave)
			generic map(N, K)
			port map(clk, reset, Counter, n_ready);
			
		ready <= not(n_ready);
end AllInOne;
