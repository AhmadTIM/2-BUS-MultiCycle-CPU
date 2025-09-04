LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use work.aux_package.all;
----------------------------------------
entity IR is 
	generic(BusSize	: integer := 16;
		RegSize : integer := 4;
		OffsetSize : integer := 8;
		ImmSize : integer := 8
	);
	port(dataOutProg : in  std_logic_vector(BusSize-1 downto 0);
		IRin : in  std_logic;
		RFaddr_rd : in  std_logic_vector(1 downto 0);
		RFaddr_wr : in  std_logic_vector(1 downto 0);
		RAddrRF : out std_logic_vector(RegSize-1 downto 0);
		WAddrRF : out std_logic_vector(RegSize-1 downto 0);
		Offset_addr : out std_logic_vector(OffsetSize-1 downto 0);
		Imm : out std_logic_vector(ImmSize-1 downto 0);
		IROp : out std_logic_vector(RegSize-1 downto 0)
	);
end IR;
-----------------------------------------
ARCHITECTURE dlf OF IR IS
	signal IR_reg	: std_logic_vector(BusSize-1 downto 0); 
begin 

	IR_reg <= dataOutProg when IRin = '1' else unaffected;  -- entering the instruction into the IR


	IROp <= IR_reg(4*RegSize-1 downto 3*RegSize);  -- OPC of the instruction


	with RFaddr_rd select  -- read address MUX
		RAddrRF <= IR_reg(RegSize-1 downto 0)  when "00", -- R[c]
			   IR_reg(2*RegSize-1 downto RegSize) when "01", -- R[b]
			   IR_reg(3*RegSize-1 downto 2*RegSize) when "10", -- R[a]
			   unaffected when others;

	with RFaddr_wr select  -- write address MUX
		WAddrRF <= IR_reg(RegSize-1 downto 0)  when "00", -- R[c]
			   IR_reg(2*RegSize-1 downto RegSize) when "01", -- R[b]
			   IR_reg(3*RegSize-1 downto 2*RegSize) when "10", -- R[a]
			   unaffected when others;
						
-- For jump type instructions
Offset_addr <= IR_reg(OffsetSize-1 downto 0);
-- For immidiate type instructions
Imm <= IR_reg(ImmSize-1 downto 0);


end dlf;











