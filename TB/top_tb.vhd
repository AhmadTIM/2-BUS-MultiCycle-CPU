library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
use std.textio.all;
use IEEE.STD_LOGIC_TEXTIO.all;
------------------------------------------------------------------------------------
-- testbench for checking how does the overall system handle instructions and states
------------------------------------------------------------------------------------
entity top_tb is
	constant BusSize: integer:=16;
	constant m: integer:=16;
	constant Awidth : integer:=6;	 
	constant RegSize: integer:=4;
	constant depth : integer:=64;
	constant OffsetSize: integer := 8;
	constant ImmSize: integer := 8;		

	constant dataMemResult:	 	string(1 to 58) :=    --reads path to data output
	"C:\Users\ahmad\OneDrive\Desktop\Ex6\output\DTCMcontent.txt";
	
	constant dataMemLocation: 	string(1 to 52) :=    --reads path to data input
	"C:\Users\ahmad\OneDrive\Desktop\Ex6\bin\DTCMinit.txt";
	
	constant progMemLocation: 	string(1 to 52) :=    --reads path to program input
	"C:\Users\ahmad\OneDrive\Desktop\Ex6\bin\ITCMinit.txt";
end top_tb;
---------------------------------------------------------
architecture rtb of top_tb is

	SIGNAL done_FSM: STD_LOGIC;
	SIGNAL rst        : STD_LOGIC;
	SIGNAL ena        : STD_LOGIC;
	SIGNAL clk        : STD_LOGIC;
	SIGNAL TBactive   : STD_LOGIC;
	SIGNAL ITCM_tb_wr : STD_LOGIC := '0';
	SIGNAL DTCM_tb_wr : STD_LOGIC := '0';
	SIGNAL DTCM_tb_in: STD_LOGIC_VECTOR (BusSize-1 downto 0) := (others => '0');
	SIGNAL DTCM_tb_out: STD_LOGIC_VECTOR (BusSize-1 downto 0) := (others => '0');
	SIGNAL ITCM_tb_in: STD_LOGIC_VECTOR (BusSize-1 downto 0) := (others => '0');
	SIGNAL DTCM_tb_addr_in, ITCM_tb_addr_in: STD_LOGIC_VECTOR (Awidth-1 DOWNTO 0) := (others => '0');
	SIGNAL DTCM_tb_addr_out:	STD_LOGIC_VECTOR (Awidth-1 DOWNTO 0) := (others => '0');
	SIGNAL ProgMemDone: BOOLEAN := false;
	SIGNAL DataMemDone: BOOLEAN := false;

begin
	TopUnit: top generic map(BusSize, RegSize, m, Awidth, OffsetSize, ImmSize, depth)
		     port map(clk, rst, ena, done_FSM, ITCM_tb_in, DTCM_tb_in, DTCM_tb_out, TBactive, ITCM_tb_wr, DTCM_tb_wr,
			      ITCM_tb_addr_in, DTCM_tb_addr_in, DTCM_tb_addr_out);
						
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
	
	ena <= '1' when (DataMemDone and ProgMemDone) else '0';

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

end architecture rtb;

