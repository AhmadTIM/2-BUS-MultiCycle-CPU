LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.aux_package.all;

ENTITY ALU IS
  GENERIC (BusSize : INTEGER := 16);
  PORT (A,B: IN STD_LOGIC_VECTOR (BusSize-1 DOWNTO 0);
	ALUFN: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        Cflag, Zflag, Nflag: OUT STD_LOGIC;
        C: OUT STD_LOGIC_VECTOR(BusSize-1 downto 0));
END ALU;
---------ALU Architecture--------------------
ARCHITECTURE dfl OF ALU IS
	SIGNAL reg : std_logic_vector(BusSize-1 DOWNTO 0) := (others => '0');
	SIGNAL A_temp, B_temp: std_logic_vector(BusSize-1 DOWNTO 0);
	SIGNAL cin : std_logic;
	SIGNAL S_arth,S_logic,S_merge,C_out : std_logic_vector(BusSize-1 DOWNTO 0) := (others => '0');
	SIGNAL MSB, LSB : std_logic_vector(7 DOWNTO 0);
	constant Z_vec : std_logic_vector(BusSize-1 downto 0) := (others => '0');
BEGIN
----------------------------------------------------------------------------------------------
	cin <= '1' WHEN (ALUFN = "0001") ELSE '0';
	
	A_temp <= A;

	-- 2,s compiliment of B when sub operation, else don'e change
	B_tmp: for i in 0 to BusSize-1 generate
			B_temp(i) <= (B(i) xor '1') WHEN (ALUFN = "0001") ELSE
			B(i);							
	end generate;
	
	-- First FA operation to ALU
	first: FA port map(A_temp(0), B_temp(0), cin, S_arth(0), reg(0));
	
	-- Make the rest of the FA operations
	rest : for i in 1 to BusSize-1 generate
		chain : FA port map(A_temp(i), B_temp(i), reg(i-1), S_arth(i), reg(i));
	end generate;
---------------------------------------------------------------------------------------------
	BOOL_CALC : FOR i IN 0 TO BusSize-1 GENERATE
			S_logic(i) <= (A(i) OR B(i))        WHEN ALUFN = "0011" ELSE  -- or operation
				      (A(i) AND B(i))       WHEN ALUFN = "0010" ELSE  -- and operation
				      (A(i) XOR B(i))       WHEN ALUFN = "0100";      -- xor operation
	END GENERATE;
---------------------------------------------------------------------------------------------
	-- merge calculation
	MSB <= A(15 Downto 8);
	LSB <= B(7 downto 0);
	S_merge <= MSB&LSB;
---------------------------------------------------------------------------------------------
	C_out <= S_arth  when (ALUFN = "0000" or ALUFN = "0001" or ALUFN = "0101") else 
		 S_logic when (ALUFN = "0010" or ALUFN = "0011" or ALUFN = "0100") else
		 S_merge;   -- chooses right output
	-- flags
	Cflag <= reg(BusSize-1) when (ALUFN = "0000" or ALUFN = "0001") else    -- Cflag
		 unaffected;
	Nflag <= C_out(BusSize-1) when (ALUFN = "0000" or ALUFN = "0001" or ALUFN = "0010" or ALUFN = "0011" or ALUFN = "0100" or ALUFN = "0110") else -- Nflag
		 unaffected;
	Zflag <= '1' when (C_out = Z_vec and (ALUFN = "0000" or ALUFN = "0001" or ALUFN = "0010" or ALUFN = "0011" or ALUFN = "0100" or ALUFN = "0110")) else -- Zflag
		 '0' when (C_out /= Z_vec and (ALUFN = "0000" or ALUFN = "0001" or ALUFN = "0010" or ALUFN = "0011" or ALUFN = "0100" or ALUFN = "0110")) else
		 unaffected;
	C <= B when ALUFN = "1111" else C_out;   -- either move B to C or move output to C that is corresponding to the currnet operation
END dfl;














