library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;
use IEEE.numeric_std.all;

package CoeffPak is
	--generic (N: integer := 8; K: integer := 2; datawidth: integer := 8; decimal_width: integer := 4);
	
	--Local constants:(WARNING!!! THESE PARAMS MUST BE THE SAME TO THE PERIPHERALS)
	constant N: integer := 8;
	constant K: integer := 2; 
	constant datawidth: integer := 8; 
	constant decimal_width: integer := 5;
	
	constant SignalLUTLength: integer := 64;
	constant decimal_Shift_Coeff: integer := 2**decimal_width;
	
	--Type definition: 
	subtype Data is std_logic_vector(datawidth-1 downto 0);
	type DataArray is array(0 to N-1) of Data;
	type DataBus is array(0 to K-1) of Data;
	type SIG_LUT is array(0 to SignalLUTLength-1) of real;
	
	--Functions
	function DataArray_to_DataBus(X: DataArray) return DataBus;	--Type casting
	function Signal_Gen(begin_t: time; now_t: time; dt: time) return Data;	--Signal feed, for simulation only! 
	function float_to_fixed(X: real) return Data;
	
	--Datasheets
	constant Weight :DataArray := (
		"11111011",
		"00000010",
		"00001010",
		"00001110",
		"00001010",
		"00000010",
		"11111011",
		"11111111"	--1 in fixed-point style
		--List your coeff here below:
		
	);
	
	constant Signal_LUT: SIG_LUT := (
		--List your waveform table here:
		
		0=>0.211045,
		1=>0.000790,
		2=>0.013577,
		3=>0.193321,
		4=>0.806679,
		5=>0.986423,
		6=>0.999210,
		7=>0.999955,
		
		----------------------------------------
		others => 1.23
	);
	
end package CoeffPak;

package body CoeffPak is
	function DataArray_to_DataBus(X: DataArray) return DataBus is
		variable temp: DataBus;
	begin
		if(K<=N) then
			for i in 0 to K-1 loop
				temp(i) := X(i);
			end loop;
		else 
			for i in 0 to N-1 loop
				temp(i) := X(i);
			end loop;
		end if;
		return temp;
	end function;
	
	function float_to_fixed(X: real) return Data is
		variable fixed_point: signed (datawidth-1 downto 0);
	begin
		fixed_point := to_signed(integer(X*real(decimal_Shift_Coeff)), fixed_point'length);
		return std_logic_vector(fixed_point);
	end function;
	
	function Signal_Gen(begin_t: time; now_t: time; dt: time) return Data is
		variable count: natural;
		variable LUT_RETURN: Data;
	begin
		count := integer((now_t - begin_t) / dt);
		if(count >= SignalLUTLength) then
			LUT_RETURN := float_to_fixed(Signal_LUT(SignalLUTLength-1));
		else
			LUT_RETURN := float_to_fixed(Signal_LUT(count));
		end if;
		return LUT_RETURN;
	end function;
end package body CoeffPak;