library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MAU is
	generic (N: integer := 8; float_bit: integer := 4);
	port (
		A, B, C: In std_logic_vector(N-1 downto 0);
		Output: Out std_logic_vector(N-1 downto 0)
	);
end MAU;

architecture behave of MAU is
	signal MULT: std_logic_vector (2*N-1 downto 0):=(others=>'0');
	signal trunked: std_logic_vector (2*N-1 downto 0):=(others=>'0');
	signal buffer_output: std_logic_vector (N-1 downto 0):=(others=>'0');
	begin
		MULT <= std_logic_vector(unsigned(A)*unsigned(B));
		trunked <= (2*N-1 downto 2*N-float_bit=>'0') & MULT(2*N-1 downto float_bit);
		Output <= std_logic_vector(unsigned(trunked(N-1 downto 0))+unsigned(C));
end behave;

architecture behave_old of MAU is
	signal MULT: std_logic_vector (2*N-1 downto 0);
	signal trunked: unsigned (2*N-1 downto 0);
	begin
		Multiplier: process(A, B) begin
			MULT <= std_logic_vector(unsigned(A)*unsigned(B));
		end process;
		
		Trunk: process(MULT) begin
			trunked <= shift_right(unsigned(MULT), float_bit);
		end process;
		
		Set_Output: process(trunked, C)begin
			Output <= std_logic_vector(trunked(N-1 downto 0)+unsigned(C));
		end process;
end behave_old;

