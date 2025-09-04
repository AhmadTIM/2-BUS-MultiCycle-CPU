library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
USE work.aux_package.all;
---------------------------------------------------------------
entity decoder is
	generic( RegSize: integer:=4);
	port(	IROp : in std_logic_vector(RegSize-1 downto 0);
		st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge: out std_logic
);
end decoder;
---------------------------------------------------------------
architecture dec of decoder is

begin
-- choose operation that is corresponding to the opc of IR
add  	<=	'1' when IROp = "0000" else '0';
sub  	<=	'1' when IROp = "0001" else '0';
andOp   <=      '1' when IROp = "0010" else '0';
orOp    <=      '1' when IROp = "0011" else '0';
xorOp   <=      '1' when IROp = "0100" else '0';
merge   <=      '1' when IROp = "0110" else '0';
jmp  	<=	'1' when IROp = "0111" else '0';
jc   	<=	'1' when IROp = "1000" else '0';
jnc  	<=	'1' when IROp = "1001" else '0';
mov  	<=	'1' when IROp = "1100" else '0';
ld   	<=  	'1' when IROp = "1101" else '0';
st   	<=	'1' when IROp = "1110" else '0';
done    <=  	'1' when IROp = "1111" else '0';




end dec;