library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.aux_package.all;

--------------------------------------------------------------
entity Datapath is
generic( 	BusSize: integer:=16;
		RegSize: integer:=4;
		m: 	  integer:=16;
		Awidth:  integer:=6;
		OffsetSize: integer := 8;
		ImmSize	: integer := 8;		 
		dept:    integer:=64);
port(
		st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge, Cflag, Zflag, Nflag : out std_logic := '0';	
		IRin, Imm1_in, Imm2_in, PCin, RFout, RFin, DTCM_out, DTCM_wr, DTCM_addr_out, DTCM_addr_in, DTCM_addr_sel, Ain: in std_logic := '0';
		ALUFN : in std_logic_vector(3 downto 0) := (others => '0');
		PCsel, RFaddr_wr, RFaddr_rd : in std_logic_vector(1 downto 0) := (others => '0');	
		ITCM_tb_wr, clk, rst : in std_logic := '0';
		DTCM_tb_wr, TBactive : in std_logic := '0';
		ITCM_tb_in: in std_logic_vector(m-1 downto 0) := (others => '0');
		ITCM_tb_addr_in: in std_logic_vector(Awidth-1 downto 0) := (others => '0');
		DTCM_tb_in: in std_logic_vector(BusSize-1 downto 0) := (others => '0');
		DTCM_tb_out: out std_logic_vector(BusSize-1 downto 0) := (others => '0');
		DTCM_tb_addr_in, DTCM_tb_addr_out: in std_logic_vector(Awidth-1 downto 0) := (others => '0'));

end Datapath;
--------------------------------------------------------------
architecture behav of Datapath is
	signal dataOutProgMem, dataOutDataMem, dataInDataMem : std_logic_vector(BusSize-1 downto 0) := (others => '0');
	signal ReadAddrProgMem, WriteAddrDataMem, ReadAddrDataMem : std_logic_vector(Awidth-1 downto 0) := (others => '0');
	signal WrAddrDataMemMuxOut, RdAddrDataMemMuxOut	: std_logic_vector(Awidth-1 downto 0) := (others => '0');
	signal WrenDataMem : std_logic := '0';
	signal ReadDataRF, A : std_logic_vector(BusSize-1 downto 0) := (others => '0');
	signal ReadAddrRF, WriteAddrRF, IROp: std_logic_vector(RegSize-1 downto 0) := (others => '0');
	signal IR_OffsetAddr : std_logic_vector(OffsetSize-1 downto 0) := (others => '0');
	signal IR_Imm: std_logic_vector(ImmSize-1 downto 0) := (others => '0');
	signal Immidiate1, Immidiate2, DataBusA, DataBusB, DTCM_MUX_Rd, DTCM_MUX_Wr: std_logic_vector(BusSize-1 downto 0) := (others => '0');

begin 
-- passint signed extended values of imm value from the IR
Immidiate1 <= SXT(IR_Imm, BusSize);
immidiate2 <= SXT(IR_Imm(RegSize-1 downto 0), BusSize);

-- reg A
ALU_Register: process(clk) 
begin
	if (clk'event and clk='1') then
		if (Ain = '1') then
			A <= DataBusA;
		end if;
	end if;		
end process;

-- DTCM MUXs
DTCM_MUX_Rd <= DataBusA when DTCM_addr_sel = '0' else DataBusB;
DTCM_MUX_Wr <= DataBusA when DTCM_addr_sel = '0' else DataBusB;

-- Reading from Data Memory
DataMem_Read: process(clk) 
begin
	if (clk'event and clk='1') then
		if (DTCM_addr_out = '1') then
			ReadAddrDataMem <= DTCM_MUX_Rd(Awidth-1 downto 0);
		end if;
	end if;
end process;

-- Write into Data Memory
DataMem_Write: process(clk) 
begin
	if (clk'event and clk='1') then
		if (DTCM_addr_in = '1') then
			WriteAddrDataMem <= DTCM_MUX_WR(Awidth-1 downto 0);
		end if;
	end if;		
end process;
----- Data Memory MUXs --------
WrenDataMem      	<= DTCM_tb_wr		  	when TBactive = '1' 	else DTCM_wr;
dataInDataMem    	<= DTCM_tb_in			when TBactive = '1' 	else DataBusB;
WrAddrDataMemMuxOut     <= DTCM_tb_addr_in 		when TBactive = '1' 	else WriteAddrDataMem;
RdAddrDataMemMuxOut     <= DTCM_tb_addr_out 		when TBactive = '1' 	else ReadAddrDataMem;
DTCM_tb_out	 	<= dataOutDataMem;
--------------- connected different modules together -----------------------------
progMemMod: progMem generic map(BusSize, Awidth, dept) 
		    port map(clk, ITCM_tb_wr, ITCM_tb_in, ITCM_tb_addr_in, ReadAddrProgMem, dataOutProgMem);
datMemMod:  dataMem generic map(BusSize, Awidth, dept) 
		    port map(clk, WrenDataMem, dataInDataMem, WrAddrDataMemMuxOut, RdAddrDataMemMuxOut, dataOutDataMem);
RFMod:      RF 	    generic map(BusSize, RegSize)       
       		    port map(clk, rst, RFin, DataBusA, WriteAddrRF, ReadAddrRF, ReadDataRF);
ALUMod:     ALU     generic map(BusSize)               
		    port map(A, DataBusB, ALUFN, Cflag, Zflag, Nflag, DataBusA);
decoderMod: decoder generic map(RegSize)               
		    port map(IROp, st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge);
PCMod:      PC      generic map(Awidth, OffsetSize)    
		    port map(IR_OffsetAddr, PCsel, PCin, clk, ReadAddrProgMem);
IRMod:      IR      generic map(BusSize, RegSize, OffsetSize, ImmSize) 
		    port map(dataOutProgMem, IRin, RFaddr_rd, RFaddr_wr, ReadAddrRF, WriteAddrRF, IR_OffsetAddr, IR_Imm, IROp);

----------------------------------------- Tri-state Buffers ------------------------------------------
DataBusB <= ReadDataRF when(RFout='1') else (others => 'Z');
DataBusB <= dataOutDataMem when(DTCM_out='1') else (others => 'Z');
DataBusB <= Immidiate1 when(Imm1_in='1') else (others => 'Z');
DataBusB <= Immidiate2 when(Imm2_in='1') else (others => 'Z');

end behav;