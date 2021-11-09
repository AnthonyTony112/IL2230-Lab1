library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;

entity Controller is
	Generic(
		N: integer := 8;
		K: integer := 1
	);
	port(
		clk, reset: In std_logic;
		Counter: Out std_logic_vector(integer(ceil(log2(real(N))))-1 downto 0);
		n_ready: Out std_logic
	);
end Controller;

architecture behave of Controller is
	signal n_ready_buff, reg_wait: std_logic := '0';
	signal Counter_buff: std_logic_vector(integer(ceil(log2(real(N))))-1 downto 0);
	begin
		n_ready <= n_ready_buff;
		Counter <= Counter_buff;
		process(clk, reset) begin
			case reset is
				when '1' =>
					reg_wait <= '1';
					n_ready_buff <= '1';
					Counter_buff <= (others => '0');
				when others =>
					if(rising_edge(clk)) then
						case n_ready_buff is
							when '1' =>
								if((to_integer(unsigned (Counter_buff))=N-1)) then
									Counter_buff <= (others => '0');
									n_ready_buff <= '0';
								else
									Counter_buff <= std_logic_vector(unsigned(Counter_buff)+1);
									n_ready_buff <= '1';
								end if;
							when others =>
								if((to_integer(unsigned(Counter_buff)) = N/K-1) or(K=N)) then
									Counter_buff <= (others => '0');
								else
									Counter_buff <= std_logic_vector(unsigned(Counter_buff)+1);
								end if;
						end case;
					end if;
			end case;
		end process;
end behave;