library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
--use std.env.stop;
use work.CoeffPak.all;
use work.all;


Architecture semipara of test is
    
    signal X1t: std_logic_vector(7 downto 0):=(others=>'0');
    signal Outputt: std_logic_vector(7 downto 0):=(others=>'0');
    signal clkt, resett: std_logic := '0';
    signal readyt: std_logic :='0';
    constant N:integer:=8;

    
    begin
    
        CLK_GEN: process begin
        clkt<=not(clkt);
        wait for 5 ns;
        end process;

        DUT: entity work.NEURON(AllInOne)
        generic map(N)
        port map(
            X=>X1t,
            Output => Outputt,
            clk=> clkt,
            reset =>resett,
            ready =>readyt
        );
    
        TEST: process
        variable begin_TIME : time := 0 ns;
        variable now_TIME : time := 0 ns;
        variable clk_TIME : time := 10 ns;
        begin
            resett<='1';
            wait for 4 ns;
            resett<='0';
            wait until falling_edge(clkt);
            begin_TIME := now;
            for i in 0 to 50 loop
                wait until rising_edge(clkt);
                now_TIME := now;
                X1t<=Signal_Gen(begin_TIME,now_TIME,Clk_TIME);
                --wait until rising_edge(clkt);
            end loop;
            
            --stop;
        end process;
    
    
        
end semipara;
