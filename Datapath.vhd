library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;
use work.all;
use work.CoeffPak.all;

entity DataPath is
	generic (
		N: integer := 8;
		K: integer := 1;
		datawidth: integer :=8;
		decimal_width: integer :=4
	);
	port (
		X: In std_logic_vector(datawidth-1 downto 0);
		Output: Out std_logic_vector(datawidth-1 downto 0);
		Counter: In std_logic_vector(integer(ceil(log2(real(N))))-1 downto 0);
		clk, reset, n_ready: In std_logic
		--n_ready: Out std_logic	--Optional
	);
end DataPath;

architecture behave of DataPath is
	--Reg Array and Weight Coeff.
	--package subpak is new work.CoeffPak generic map(N => N, K => K, datawidth => datawidth, decimal_width=>decimal_width);
	--signal RegF :subpak.DataArray;
	signal RegF :DataArray;
	
	--Input Wires
	--signal X_in, W_in, C_reg, AdderResult: subpak.DataBus;
	--signal Output_For_Full_Parallel: subpak.Data;
	signal X_in, W_in, C_reg, AdderResult: DataBus := (OTHERS => (OTHERS => '0'));
	signal Output_For_Full_Parallel: Data := (OTHERS => '0');
	
	begin
		--MAU Generator
		Gen: for i in 0 to K-1 generate
			--For pure-sequential: 
			-- Gen_Single: if (K=1) generate
				-- U_MAU_One: entity work.MAU(behave)
					-- generic map(datawidth, decimal_width)
					-- port map(X_in, W_in, C_reg, AdderResult);
			-- end generate Gen_Single;
			
			--For K-way parallel: 
			Gen_K_Parallel: if ((K>=1) and (K<N)) generate
				U_MAU: entity work.MAU(behave)
					generic map(datawidth, decimal_width)
					port map (
						A => X_in(i),
						B => W_in(i),
						C => C_reg(i), 
						Output => AdderResult(i)
					);
			end generate Gen_K_Parallel;
			
			--For Full Parallel:
			Gen_Full_Paralell: if K=N generate
				Gen_Normal_Full: if i < N-1 generate
					MAU_Normal_Full : entity work.MAU(behave)
						port map (
							--A => subpak.Weight(i),
							A => Weight(i),
							B => RegF(i),
							C => AdderResult(i), 
							Output => AdderResult(i+1)
						);
				end generate Gen_Normal_Full;
				
				Gen_Output_Full: if i = N-1 generate
					MAU_Fin_Full : entity work.MAU(behave)
						port map (
							--A => subpak.Weight(i),
							A => Weight(i),
							B => RegF(i),
							C => AdderResult(i), 
							Output => Output_For_Full_Parallel
						);
				end generate Gen_Output_Full;
			end generate Gen_Full_Paralell;
		end generate Gen;
		
		process(clk, reset) 
			--variable Output_Buffer: subpak.Data;
			variable Output_Buffer: Data;
			begin
			case reset is
				when '1' =>
					RegF <= (others => (others => '0'));
					C_reg <= (others => (others =>'0'));
					
				when others =>
					if(rising_edge(clk)) then
						case not(n_ready) is
							when '0' =>	--Initialize Reg pool
								for i in N-1 downto 1 loop
									RegF(i) <= RegF(i-1);
								end loop;
								RegF(0) <= X;
							when others =>
								case to_integer(unsigned(Counter)) is
									when N/K-1 =>
										for i in N-1 downto 1 loop
											RegF(i) <= RegF(i-1);
										end loop;
										RegF(0) <= X;
									--when 0 =>	
										--Add up all final results as output
										if (K<N) then --For K-way Parallel
											Output_Buffer := (others => '0');
											for i in 0 to K-1 loop
												Output_Buffer := std_logic_vector(unsigned(Output_Buffer) + unsigned (AdderResult(i)));
											end loop;
											Output <= Output_Buffer;
										else --For Full Parallel
											Output <= Output_For_Full_Parallel;
										end if;
										
										C_reg <= (others => (others => '0'));
									when others =>
										C_reg <= AdderResult;
								end case;
						end case;
						
						if(K=N) then
							--X_in <= subpak.DataArray_to_DataBus(RegF);
							--W_in <= subpak.DataArray_to_DataBus(subpak.Weight);
							X_in <= DataArray_to_DataBus(RegF);
							W_in <= DataArray_to_DataBus(Weight);
						else 
							for i in 0 to K-1 loop
								X_in(i) <= RegF(to_integer(unsigned(Counter)) mod (N/K) + i * N / K);
								--W_in(i) <= subpak.Weight(to_integer(unsigned(Counter)) mod K + i * N / K);
								W_in(i) <= Weight(to_integer(unsigned(Counter)) mod (N/K) + i * N / K);
							end loop;
						end if;
					end if;
			end case;
		end process;
end behave;