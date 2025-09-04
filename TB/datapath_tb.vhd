library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
use std.textio.all;
use IEEE.std_logic_textio.all;
-------------------------------------------------------------------------------
-- testbench for checking how does the datatpath handle instructions and states
-------------------------------------------------------------------------------
entity datapath_tb is
	generic(BusSize : integer := 16;
			Awidth:  integer:=6;  	-- Address Size
			RegSize: integer:=4; 	-- Register Size
			m: 	  integer:=16  -- Program Memory In Data Size
	);
	constant dept      : integer:=64;
	
	constant dataMemResult:	 	string(1 to 62) :=
	"C:\Users\ahmad\OneDrive\Desktop\runcode\output\DTCMcontent.txt";
	
	constant dataMemLocation: 	string(1 to 56) :=
	"C:\Users\ahmad\OneDrive\Desktop\runcode\bin\DTCMinit.txt";
	
	constant progMemLocation: 	string(1 to 56) :=
	"C:\Users\ahmad\OneDrive\Desktop\runcode\bin\ITCMinit.txt";
end datapath_tb;
----------
architecture tb_behav of datapath_tb is

signal		st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge, Cflag, Zflag, Nflag:  std_logic := '0';
signal		IRin, Imm1_in, Imm2_in, PCin, RFout, RFin, DTCM_out, DTCM_wr, DTCM_addr_out, DTCM_addr_in, DTCM_addr_sel, Ain :  std_logic := '0';
signal          ALUFN : std_logic_vector(3 downto 0) := "1111";
signal		PCsel, RFaddr_wr, RFaddr_rd : std_logic_vector(1 downto 0) := "00";
signal		ITCM_tb_wr, clk, rst : std_logic := '0';
signal		DTCM_tb_wr, TBactive : std_logic := '0';
signal		ITCM_tb_in: std_logic_vector(m-1 downto 0) := (others => '0');
signal		ITCM_tb_addr_in: std_logic_vector(Awidth-1 downto 0) := (others => '0');
signal		DTCM_tb_in: std_logic_vector(BusSize-1 downto 0) := (others => '0');
signal		DTCM_tb_out: std_logic_vector(BusSize-1 downto 0) := (others => '0');
signal		DTCM_tb_addr_in, DTCM_tb_addr_out: std_logic_vector(Awidth-1 downto 0) := (others => '0');signal		done_FSM: std_logic := '0';
SIGNAL		ProgMemDone: BOOLEAN := false;
SIGNAL		DataMemDone: BOOLEAN := false;

begin 

DataPathUnit: Datapath generic map(BusSize)  
		       port map(st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge, Cflag, Zflag, Nflag,
				IRin, Imm1_in, Imm2_in, PCin, RFout, RFin, DTCM_out, DTCM_wr, DTCM_addr_out, DTCM_addr_in, DTCM_addr_sel, Ain, ALUFN, PCsel
                		, RFaddr_wr, RFaddr_rd ,ITCM_tb_wr, clk, rst ,DTCM_tb_wr, TBactive ,ITCM_tb_in, ITCM_tb_addr_in,DTCM_tb_in,DTCM_tb_out
                		, DTCM_tb_addr_in, DTCM_tb_addr_out);


	gen_rst : process  --reset
	begin
	  rst <='1','0' after 100 ns;
	  wait;
	end process;
	
	gen_clk : process  -- clk
	begin
	  clk <= '0';
	  wait for 50 ns;
	  clk <= not clk;
	  wait for 50 ns;
	end process;
	
	gen_TB : process  --TBactive is on only when we want to read or write files
        begin
		 TBactive <= '1';
		 wait until ProgMemDone and DataMemDone;  
		 TBactive <= '0';
		 wait until done_FSM = '1';  
		 TBactive <= '1';	
        end process;	

	LoadDataMem: process -- transfers data from file to DataMem
		file infile_Data : text open read_mode is dataMemLocation;
		variable good: boolean;
		variable connection: std_logic_vector(BusSize-1 downto 0);
		variable TempAddr: std_logic_vector(Awidth-1 downto 0) := (others => '0');
		variable L: line;
	begin
		while not endfile(infile_Data) loop
			readline(infile_Data,L);
			hread(L,connection,good);
			next when not good;
			DTCM_tb_addr_in <= TempAddr;
			DTCM_tb_in <= connection;
			DTCM_tb_wr <= '1';
			wait until rising_edge(clk);
			TempAddr := TempAddr +1;
		end loop ;
		DataMemDone <= true;
		DTCM_tb_wr <= '0';
		file_close(infile_Data);
		wait;
	end process;
		
	LoadProgramMem: process  -- transfers instruction from file to ProgMem
		file infile_Program : text open read_mode is progMemLocation;
		variable good: boolean;
		variable connection: std_logic_vector(BusSize-1 downto 0);
		variable TempAddr: std_logic_vector(Awidth-1 downto 0) := (others => '0');
		variable L: line;
	begin
		while not endfile(infile_Program) loop
			readline(infile_Program,L);
			hread(L,connection,good);
			next when not good;
			ITCM_tb_addr_in <= TempAddr;
			ITCM_tb_in <= connection;
			ITCM_tb_wr <= '1';
			wait until rising_edge(clk);
			TempAddr := TempAddr +1;
		end loop ;
		ProgMemDone <= true;
		ITCM_tb_wr <= '0';
		file_close(infile_Program);
		wait;
	end process;


--------- Start Test Bench ---------------------
StartTb : process
	begin
		wait until ProgMemDone and DataMemDone;  

------------- Reset ------------------------		
	 --reset
	       wait until clk'EVENT and clk='1';

	       ALUFN <= "1111";
	       RFaddr_rd <= "11";
	       RFaddr_wr <= "11";
	       PCsel <= "10";
	       PCin <= '1'; 
	       IRin <= '0';
	       Imm1_in <= '0';
               Imm2_in <= '0';
	       RFout <= '0';
	       RFin <= '0';
	       DTCM_out <= '0';
	       DTCM_wr <= '0';
	       DTCM_addr_out <= '0';
               DTCM_addr_in <= '0';
	       DTCM_addr_sel <= '0';
	       Ain <= '0';
		
---------------------- Instruction For ld - D104-----------------------------		
------------- Fetch ------------------------
	      wait until clk'EVENT and clk='1'; 
		ALUFN <= "1111";
		RFaddr_rd <= "11";
		RFaddr_wr <= "11";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '1';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
		ld <= '1';
------------- Decode ------------------------	
    	      wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';				
-------------------------------------
		wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '1';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '1';
-------------------------------------
		wait until clk'EVENT and clk='1'; 
                	ALUFN <= "0101";
			RFaddr_rd <= "01";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '0';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '1';
			RFout <= '0';
			RFin <= '0';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '1';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '0';
-------------------------------------
		wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
-------------------------------------
		wait until clk'EVENT and clk='1'; 
                	ALUFN <= "1111";
			RFaddr_rd <= "01";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '1';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '0';
			RFin <= '1';
			DTCM_out <= '1';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '0';
---------------------- Instruction For ld - D205 -----------------------------		
------------- Fetch ------------------------
		
	      wait until clk'EVENT and clk='1'; 
		ALUFN <= "1111";
		RFaddr_rd <= "11";
		RFaddr_wr <= "11";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '1';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
------------- Decode ------------------------	
    	      wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
-------------------------------------	
    	wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '1';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '1';		
-------------------------------------
		wait until clk'EVENT and clk='1'; 
                	ALUFN <= "0101";
			RFaddr_rd <= "01";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '0';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '1';
			RFout <= '0';
			RFin <= '0';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '1';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '0';
-------------------------------------
		wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
----------------------------------------
	       wait until clk'EVENT and clk='1';
			ld <= '0';
	       		ALUFN <= "1111";
			RFaddr_rd <= "01";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '1';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '0';
			RFin <= '1';
			DTCM_out <= '1';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '0';
---------------------- Instruction For mov - C31F -----------------------------		
------------- Fetch ------------------------
		
	      wait until clk'EVENT and clk='1'; 
		ALUFN <= "1111";
		RFaddr_rd <= "11";
		RFaddr_wr <= "11";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '1';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
		mov <= '1';
------------- Decode ------------------------	
    	      wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
-------------------------------------	
    	wait until clk'EVENT and clk='1'; 
		
			ALUFN <= "1111";
			RFaddr_rd <= "01";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '1';
			IRin <= '0';
			Imm1_in <= '1';
			Imm2_in <= '0';
			RFout <= '0';
			RFin <= '1';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '0';

---------------------- Instruction For mov - C401 -----------------------------		
------------- Fetch ------------------------
		
	      wait until clk'EVENT and clk='1'; 
		ALUFN <= "1111";
		RFaddr_rd <= "11";
		RFaddr_wr <= "11";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '1';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
------------- Decode ------------------------	
    	      wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
-------------------------------------	
    	wait until clk'EVENT and clk='1'; 
		
			ALUFN <= "1111";
			RFaddr_rd <= "01";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '1';
			IRin <= '0';
			Imm1_in <= '1';
			Imm2_in <= '0';
			RFout <= '0';
			RFin <= '1';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '0';
---------------------- Instruction For mov - C50E -----------------------------		
------------- Fetch ------------------------
		
	      wait until clk'EVENT and clk='1'; 
		ALUFN <= "1111";
		RFaddr_rd <= "11";
		RFaddr_wr <= "11";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '1';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
------------- Decode ------------------------	
    	      wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
-------------------------------------	
    	wait until clk'EVENT and clk='1'; 
		
			mov <= '0';
			ALUFN <= "1111";
			RFaddr_rd <= "01";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '1';
			IRin <= '0';
			Imm1_in <= '1';
			Imm2_in <= '0';
			RFout <= '0';
			RFin <= '1';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '0';
---------------------- Instruction For AND - 2113 -----------------------------		
------------- Fetch ------------------------
		
	      wait until clk'EVENT and clk='1'; 
		ALUFN <= "1111";
		RFaddr_rd <= "11";
		RFaddr_wr <= "11";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '1';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
		andOp <= '1';
------------- Decode ------------------------	
    	      wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';				


-------------------------------------	  	
            wait until clk'EVENT and clk='1';
               		ALUFN <= "1111";
			RFaddr_rd <= "01";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '0';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '1';
			RFin <= '0';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '1';			
-------------------------------------		
	       wait until clk'EVENT and clk='1';
			ALUFN <= "0010";
	       		RFaddr_rd <= "00";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '1';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '1';
			RFin <= '1';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '0';
---------------------- Instruction For AND - 2223 -----------------------------		
------------- Fetch ------------------------
		
	      wait until clk'EVENT and clk='1'; 
		ALUFN <= "1111";
		RFaddr_rd <= "11";
		RFaddr_wr <= "11";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '1';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
------------- Decode ------------------------	
    	      wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';				


-------------------------------------	  	
            wait until clk'EVENT and clk='1';
               		ALUFN <= "1111";
			RFaddr_rd <= "01";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '0';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '1';
			RFin <= '0';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '1';			
-------------------------------------		
	       wait until clk'EVENT and clk='1';
			andOp <= '0';
			ALUFN <= "0010";
	       		RFaddr_rd <= "00";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '1';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '1';
			RFin <= '1';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '0';
---------------------- Instruction For sub - 1621 -----------------------------		
------------- Fetch ------------------------
		
	      wait until clk'EVENT and clk='1'; 
		ALUFN <= "1111";
		RFaddr_rd <= "11";
		RFaddr_wr <= "11";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '1';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
		sub <= '1';
------------- Decode ------------------------	
    	      wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';				


-------------------------------------	  	
            wait until clk'EVENT and clk='1';
               		ALUFN <= "1111";
			RFaddr_rd <= "01";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '0';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '1';
			RFin <= '0';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '1';			
-------------------------------------		
	       wait until clk'EVENT and clk='1';
			sub <= '0';
			ALUFN <= "0001";
	       		RFaddr_rd <= "00";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '1';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '1';
			RFin <= '1';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '0';
---------------------- Instruction For JC - 8002 -----------------------------		
------------- Fetch ------------------------
		
	      wait until clk'EVENT and clk='1'; 
		ALUFN <= "1111";
		RFaddr_rd <= "11";
		RFaddr_wr <= "11";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '1';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
		jc <= '1';
------------- Decode ------------------------	
    	      wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';	
-------------------------------------------
wait until clk'EVENT and clk='1'; 
		
			jc <= '0';
			ALUFN <= "1111";
			RFaddr_rd <= "01";
			RFaddr_wr <= "10";
			PCsel <= "01";
			PCin <= '1';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '0';
			RFin <= '0';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '0';
---------------------- Instruction For add - 0600 -----------------------------		
------------- Fetch ------------------------
		
	      wait until clk'EVENT and clk='1'; 
		ALUFN <= "1111";
		RFaddr_rd <= "11";
		RFaddr_wr <= "11";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '1';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
		add <= '1';
------------- Decode ------------------------	
    	      wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';				


-------------------------------------	  	
            wait until clk'EVENT and clk='1';
            ALUFN <= "1111";
			RFaddr_rd <= "01";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '0';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '1';
			RFin <= '0';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '1';			
-------------------------------------		
	       wait until clk'EVENT and clk='1';
			add <= '0';
			ALUFN <= "0000";
	       	RFaddr_rd <= "00";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '1';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '1';
			RFin <= '1';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '0';

---------------------- Instruction For st - E650 -----------------------------		
------------- Fetch ------------------------
		
	      wait until clk'EVENT and clk='1'; 
		ALUFN <= "1111";
		RFaddr_rd <= "11";
		RFaddr_wr <= "11";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '1';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
		st <= '1';
------------- Decode ------------------------	
    	      wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';

---------------------------------------------------		
		
	      wait until clk'EVENT and clk='1'; 
			ALUFN <= "1111";
			RFaddr_rd <= "01";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '0';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '1';
			RFin <= '0';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '1';
-------------------------------------	
    	      wait until clk'EVENT and clk='1'; 
			ALUFN <= "0101";
			RFaddr_rd <= "10";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '0';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '1';
			RFout <= '0';
			RFin <= '0';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '1';
			DTCM_addr_sel <= '0';
			Ain <= '0';	
-------------------------------------
            wait until clk'EVENT and clk='1';
			st <= '0';	
			ALUFN <= "1111";
			RFaddr_rd <= "10";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '1';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '1';
			RFin <= '0';
			DTCM_out <= '0';
			DTCM_wr <= '1';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '0';	
---------------------- Instruction For done - F000 -----------------------------		
------------- Fetch ------------------------
		
	      wait until clk'EVENT and clk='1'; 
		ALUFN <= "1111";
		RFaddr_rd <= "11";
		RFaddr_wr <= "11";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '1';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
		done <= '1';
------------- Decode ------------------------	
    	      wait until clk'EVENT and clk='1'; 
		
		done <= '0';
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';	
		done_FSM <= '1';
---------------------- Instruction For nop - 0000 -----------------------------		
------------- Fetch ------------------------
		
	      wait until clk'EVENT and clk='1'; 
		ALUFN <= "1111";
		RFaddr_rd <= "11";
		RFaddr_wr <= "11";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '1';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
		add <= '1';
------------- Decode ------------------------	
    	      wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';				


-------------------------------------	  	
            wait until clk'EVENT and clk='1';
               		ALUFN <= "1111";
			RFaddr_rd <= "01";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '0';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '1';
			RFin <= '0';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '1';			
-------------------------------------		
	       wait until clk'EVENT and clk='1';
			add <= '0';
			ALUFN <= "0000";
	       		RFaddr_rd <= "00";
			RFaddr_wr <= "10";
			PCsel <= "00";
			PCin <= '1';
			IRin <= '0';
			Imm1_in <= '0';
			Imm2_in <= '0';
			RFout <= '1';
			RFin <= '1';
			DTCM_out <= '0';
			DTCM_wr <= '0';
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '0';
			DTCM_addr_sel <= '0';
			Ain <= '0';	
---------------------- Instruction For jmp - 70FE -----------------------------		
------------- Fetch ------------------------
		
	      wait until clk'EVENT and clk='1'; 
		ALUFN <= "1111";
		RFaddr_rd <= "11";
		RFaddr_wr <= "11";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '1';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
		jmp <= '1';
------------- Decode ------------------------	
    	      wait until clk'EVENT and clk='1'; 
		
		ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "00";
		PCin <= '0';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';	
-------------------------------------		
            wait until clk'EVENT and clk='1';
		jmp <= '0';
                ALUFN <= "1111";
		RFaddr_rd <= "01";
		RFaddr_wr <= "10";
		PCsel <= "01";
		PCin <= '1';
		IRin <= '0';
		Imm1_in <= '0';
		Imm2_in <= '0';
		RFout <= '0';
		RFin <= '0';
		DTCM_out <= '0';
		DTCM_wr <= '0';
		DTCM_addr_out <= '0';
		DTCM_addr_in <= '0';
		DTCM_addr_sel <= '0';
		Ain <= '0';
		wait;
		
	end process;	
	
	
	WriteToDataMem: process  -- transfers data from DataMem to file
		file outfile : text open write_mode is dataMemResult;
		variable good: boolean;
		variable connection: std_logic_vector(BusSize-1 downto 0);
		variable TempAddr: std_logic_vector(Awidth-1 downto 0) := (others => '0');
		variable L: line;
		variable C: integer := 1;
	begin 
		wait until done_FSM = '1';
		while (C < 64) loop
			DTCM_tb_addr_out <= TempAddr;
			wait until rising_edge(clk);
			wait until rising_edge(clk);
			if DTCM_tb_out /= (DTCM_tb_out'range => 'X') then
				hwrite(L,DTCM_tb_out);
				writeline(outfile,L);
				TempAddr := TempAddr + 1;
			end if;
			C := C + 1;
		end loop;
		file_close(outfile);
		wait;
	end process;


end tb_behav;
