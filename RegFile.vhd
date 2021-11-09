library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity RegFile is
  generic(M, N: integer); --M for address length, N for data width
  port(
    --Input ports
    WD: In std_logic_vector(N-1 downto 0);
    reset, clk: In std_logic;
    
    --Output ports
    Output: Out std_logic_vector(N-1 downto 0);
	n_ready: Out std_logic	--Active low, '0' when data prepared
  );
end RegFile;

architecture behave of RegFile is
  --Reg Array
  type RegArray is array(0 to 2**M-1) of std_logic_vector(N-1 downto 0);
  signal RegF :RegArray :=(others=>(others=>'0'));
  
  begin
	Output<=RegF(2**M-1);
    process(reset, clk)
    begin
      if(reset='1') then 
        --Clear array data
        RegF<=(others=>(others=>'0'));
		n_ready<='1';
      else
        if(rising_edge(clk)) then
			for i in 2**M-1 to 1 loop
				RegF(i) <= RegF(i-1);
			end loop;
            RegF(0) <= WD;
			n_ready<='0';
        end if;
      end if;
    end process;
end behave;
