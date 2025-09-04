LIBRARY ieee;
USE ieee.std_logic_1164.all;
----------------Package-------------------------------------
package aux_package is
-------------------------- decoder -------------------------
	component decoder is
	generic( RegSize: integer:=4);
	port(	IROp : in std_logic_vector(RegSize-1 downto 0);
		st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge: out std_logic
	);
	end component;
---------------------- Bi-Dir Bus Line -----------------------
	component BidirPin is
	generic( width: integer:=16 );
	port(   Dout: 	in 		std_logic_vector(width-1 downto 0);
			en:		in 		std_logic;
			Din:	out		std_logic_vector(width-1 downto 0);
			IOpin: 	inout 	std_logic_vector(width-1 downto 0)
	);
	end component;
---------------------- Bi Direction Pin Basic -----------------------
	component BidirPinBasic is
	port(writePin: in std_logic;
	     readPin:  out std_logic;
	     bidirPin: inout std_logic
	);
	end component;	
---------------------- Data Memory -----------------------
	component dataMem is
	generic( Dwidth: integer:=16;
			 Awidth: integer:=6;
			 dept:   integer:=64);
	port(	clk,memEn: in std_logic;	
			WmemData:	in std_logic_vector(Dwidth-1 downto 0);
			WmemAddr,RmemAddr:	
						in std_logic_vector(Awidth-1 downto 0);
			RmemData: 	out std_logic_vector(Dwidth-1 downto 0)
	);
	end component;
---------------------- Full Adder -----------------------	
	component FA IS
	PORT (xi, yi, cin: IN std_logic;
			  s, cout: OUT std_logic);
	END component;
---------------------- Program Memory -----------------------
	component ProgMem is
	generic( Dwidth: integer:=16;
			 Awidth: integer:=6;
			 dept:   integer:=64);
	port(	clk,memEn: in std_logic;	
			WmemData:	in std_logic_vector(Dwidth-1 downto 0);
			WmemAddr,RmemAddr:	
						in std_logic_vector(Awidth-1 downto 0);
			RmemData: 	out std_logic_vector(Dwidth-1 downto 0)
	);
	end component;	
---------------------- Register File -----------------------
	component RF is
	generic( Dwidth: integer:=16;
			 Awidth: integer:=4);
	port(	clk,rst,WregEn: in std_logic;	
			WregData:	in std_logic_vector(Dwidth-1 downto 0);
			WregAddr,RregAddr:	in std_logic_vector(Awidth-1 downto 0);
			RregData: 	out std_logic_vector(Dwidth-1 downto 0)
	);
	end component;
----------------------- ALU --------------------------------
	component ALU is
	GENERIC (BusSize : INTEGER := 16);
  	PORT (A,B: IN STD_LOGIC_VECTOR (BusSize-1 DOWNTO 0);
	      ALUFN: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
              CFlag, Zflag, Nflag: OUT STD_LOGIC;
              C: OUT STD_LOGIC_VECTOR(BusSize-1 downto 0)
	);
	end component;
----------------------- IR --------------------------------
	component IR is 
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
	end component;
----------------------- PC --------------------------------
	component PC is
	GENERIC(AddrSize :INTEGER := 6;
		OffsetSize :INTEGER := 8);
	PORT(IRoffset :IN STD_LOGIC_VECTOR(OffsetSize-1 DOWNTO 0);
		PCsel :IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		PCin, clk :IN STD_LOGIC;
		PCout :OUT std_logic_vector(AddrSize-1 downto 0) := (others => '0')
		);
	end component;
---------------------- datapath -----------------------	
	component datapath is
		generic( 	BusSize: integer:=16;
				RegSize: integer:=4;
				m: 	  integer:=16;
				Awidth:  integer:=6;
				OffsetSize: integer := 8;
				ImmSize	: integer := 8;		 
				dept:    integer:= 64);
		port(
				st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge, Cflag, Zflag, Nflag : out std_logic;	
				IRin, Imm1_in, Imm2_in, PCin, RFout, RFin, DTCM_out, DTCM_wr, DTCM_addr_out, DTCM_addr_in, DTCM_addr_sel, Ain: in std_logic;
				ALUFN : in std_logic_vector(3 downto 0);
				PCsel, RFaddr_wr, RFaddr_rd : in std_logic_vector(1 downto 0);	
				ITCM_tb_wr, clk, rst : in std_logic;
				DTCM_tb_wr, TBactive : in std_logic;
				ITCM_tb_in: in std_logic_vector(m-1 downto 0);
				ITCM_tb_addr_in: in std_logic_vector(Awidth-1 downto 0);
				DTCM_tb_in: in std_logic_vector(BusSize-1 downto 0);
				DTCM_tb_out: out std_logic_vector(BusSize-1 downto 0);
				DTCM_tb_addr_in, DTCM_tb_addr_out: in std_logic_vector(Awidth-1 downto 0)
			);
	end component;
---------------------- control -----------------------	
	component control is
		PORT(
			st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge, Cflag, Zflag, Nflag : in std_logic;
			IRin, Imm1_in, Imm2_in, PCin, RFout, RFin, DTCM_out, DTCM_wr, DTCM_addr_out, DTCM_addr_in, DTCM_addr_sel, Ain: out std_logic;
			ALUFN : out std_logic_vector(3 downto 0);
			PCsel, RFaddr_wr, RFaddr_rd : out std_logic_vector(1 downto 0);	
			clk, rst, ena : in STD_LOGIC;
			done_FSM : out std_logic
		);
	end component;
---------------------- top -----------------------	
	component top is
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
	end component;
----------------------------------------------------	
end aux_package;



