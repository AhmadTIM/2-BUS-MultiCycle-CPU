library ieee;
use ieee.std_logic_1164.all;
use work.aux_package.all;
---------------------------------------------------------------
ENTITY top IS
	generic(BusSize: integer:=16;	-- Bus Size
		RegSize: integer:=4; 	-- Register Size
		m: 	  integer:=16;  -- Program Memory In Data Size
		Awidth:  integer:=6;  -- Address Size
		OffsetSize: integer := 8;
		ImmSize	: integer := 8;		 
		dept:    integer:= 64  	-- Address Size
	);

	PORT(   clk, rst, ena  : in STD_LOGIC;
		done_FSM : out std_logic;	
		
		-- Test Bench
		ITCM_tb_in  : in std_logic_vector(m-1 downto 0);
		DTCM_tb_in  : in std_logic_vector(BusSize-1 downto 0);
		DTCM_tb_out : out std_logic_vector(BusSize-1 downto 0);
		TBactive    : in std_logic;
		ITCM_tb_wr, DTCM_tb_wr : in std_logic;
		ITCM_tb_addr_in, DTCM_tb_addr_in, DTCM_tb_addr_out : in std_logic_vector(Awidth-1 downto 0)
	);

end top;
---------------------------------------------------------------
ARCHITECTURE dfl OF top IS

signal		st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge, Cflag, Zflag, Nflag:  std_logic;
signal		IRin, Imm1_in, Imm2_in, PCin, RFout, RFin, DTCM_out, DTCM_wr, DTCM_addr_out, DTCM_addr_in, DTCM_addr_sel, Ain:  std_logic;
signal		ALUFN :  std_logic_vector(3 downto 0);
signal 		PCsel, RFaddr_wr, RFaddr_rd :  std_logic_vector(1 downto 0);

BEGIN
ControlUnit: Control 	port map(st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge, Cflag, Zflag, Nflag, 
				IRin, Imm1_in, Imm2_in, PCin, RFout, RFin, DTCM_out, DTCM_wr, DTCM_addr_out, 
				DTCM_addr_in, DTCM_addr_sel, Ain, ALUFN, PCsel, RFaddr_wr, RFaddr_rd , clk, rst, ena, done_FSM);

DataPathUnit: Datapath  generic map(BusSize, RegSize, m, Awidth, OffsetSize, ImmSize, dept)  
			port map(st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge, Cflag, Zflag, Nflag,
				 IRin, Imm1_in, Imm2_in, PCin, RFout, RFin, DTCM_out, DTCM_wr, DTCM_addr_out, DTCM_addr_in, DTCM_addr_sel,
				 Ain, ALUFN, PCsel, RFaddr_wr, RFaddr_rd, ITCM_tb_wr, clk, rst, DTCM_tb_wr, TBactive, ITCM_tb_in,
				 ITCM_tb_addr_in, DTCM_tb_in, DTCM_tb_out, DTCM_tb_addr_in, DTCM_tb_addr_out);

end dfl;











