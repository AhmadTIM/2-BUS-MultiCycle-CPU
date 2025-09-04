library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
--------------------------------------------------------------------------------------
-- A test bench which checks if each instruction works as intended in the control unit
--------------------------------------------------------------------------------------
entity Control_tb is

end Control_tb;
---------------------------------------------------------
architecture Contb of Control_tb is
	signal		clk, rst, ena, st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge, Cflag, Zflag, Nflag:  std_logic;
	signal		IRin, Imm1_in, Imm2_in, PCin, RFout, RFin, DTCM_out, DTCM_wr, DTCM_addr_out, DTCM_addr_in, DTCM_addr_sel, Ain :  std_logic;
	signal		ALUFN :  std_logic_vector(3 downto 0);
	signal 		PCsel, RFaddr_wr, RFaddr_rd :  std_logic_vector(1 downto 0);
	SIGNAL 		done_FSM:	STD_LOGIC;
	
---------------------------------------------------------
begin
ControlUnit: Control 	port map(st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge, Cflag, Zflag, Nflag, 
				IRin, Imm1_in, Imm2_in, PCin, RFout, RFin, DTCM_out, DTCM_wr, DTCM_addr_out, 
				DTCM_addr_in, DTCM_addr_sel, Ain, ALUFN, PCsel, RFaddr_wr, RFaddr_rd , clk, rst, ena, done_FSM);


		gen_rst : process	-- reset
        begin
		  rst <='1','0' after 100 ns;
		  wait;
        end process; 
		
		
        gen_clk : process	-- Clk generation
        begin
		  clk <= '1';
		  wait for 50 ns;
		  clk <= not clk;
		  wait for 50 ns;
        end process;
		
		ena <= '1';
		Cflag <= '1';
--------------- instructions ---------------------	
	add_cmd : process
        begin
		  add <='0', '1' after 100 ns, '0' after 500 ns;
		  wait;
        end process; 
		
	sub_cmd : process
        begin
		  sub <='0','1' after 500 ns, '0' after 900 ns;
		  wait;
        end process;
		
	and_cmd : process
        begin
		  andOp <='0','1' after 900 ns, '0' after 1300 ns;
		  wait;
        end process;
		
		
	or_cmd : process
        begin
		  orOp <='0','1' after 1300 ns, '0' after 1700 ns;
		  wait;
        end process;
		
		
	xor_cmd : process
        begin
		  xorOp <='0','1' after 1700 ns, '0' after 2100 ns;
		  wait;
        end process;
		
	jmp_cmd : process
        begin
		  jmp <='0','1' after 2100 ns, '0' after 2400 ns;
		  wait;
        end process;
	
	jc_cmd : process
	begin
		  jc <= '0', '1' after 2400 ns, '0' after 2700 ns;
		  wait;
	end process;

	jnc_cmd : process
	begin
		  jnc <= '0', '1' after 2700 ns, '0' after 2900 ns;
		  wait;
	end process;
		
	mov_cmd : process
        begin
		  mov <='0','1' after 2900 ns, '0' after 3200 ns;
		  wait;
        end process;
		
	ld_cmd : process
        begin
		  ld <='0','1' after 3200 ns, '0' after 3800 ns;
		  wait;
        end process;
		
	st_cmd : process
        begin
		  st <='0','1' after 3800 ns, '0' after 4300 ns;
		  wait;
        end process;
		
	done_cmd : process
        begin
		  done <='0','1' after 4300 ns, '0' after 4500 ns;
		  wait;
        end process;
		
		
		
end architecture Contb;
