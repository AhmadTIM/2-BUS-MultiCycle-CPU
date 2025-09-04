LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.aux_package.all;
------------------------------------------------
ENTITY Control IS
	PORT(
		st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge, Cflag, Zflag, Nflag : in std_logic;
		IRin, Imm1_in, Imm2_in, PCin, RFout, RFin, DTCM_out, DTCM_wr, DTCM_addr_out, DTCM_addr_in, DTCM_addr_sel, Ain: out std_logic;
		ALUFN : out std_logic_vector(3 downto 0);
		PCsel, RFaddr_wr, RFaddr_rd : out std_logic_vector(1 downto 0);	
		clk, rst, ena : in STD_LOGIC;
		done_FSM : out std_logic
	);
END Control;
-------------------------------------------------
ARCHITECTURE dfl OF Control IS
	TYPE state IS (state0, state1, state2, state3, state4, state5, state6, state7, state8, state9, state10, s_wait); --states
	SIGNAL pr_state, nx_state: state;
	SIGNAL J : std_logic;  --to help determine if there is a j-type operand before the current operand
BEGIN
---------- Lower section: ------------------------
  PROCESS (rst, clk)
  BEGIN
	IF (rst='1') THEN --reset
		J <= '0';
		pr_state <= state0;
	ELSIF ((clk'EVENT AND clk='1') and (ena = '1')) THEN -- when ena is on and clock on rising edge, take next state
		pr_state <= nx_state;
	END IF;
  END PROCESS;
---------- Upper section: ------------------------
  PROCESS (pr_state, st, ld, mov, done, add, sub, jmp, jc, jnc, andOp, orOp, xorOp, merge, Cflag, Zflag, Nflag)
  BEGIN
	CASE pr_state IS  --each state explained in the FSM file
		WHEN state0 =>   -- start
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
			nx_state <= state1;
		WHEN state1 =>   -- fetch
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
			nx_state <= state2;
		WHEN state2 =>   -- decode
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
			if ((add = '1' or sub = '1' or andOp = '1' or orOp = '1' or xorOp = '1' or merge = '1' or st = '1' or ld = '1') and J = '0') then
				nx_state <= state3;
			elsif (jmp = '1') then
				nx_state <= state5;
			elsif (Cflag = '1' and jc = '1') then
				nx_state <= state5;
			elsif (Cflag = '0' and jnc = '1') then
				nx_state <= state5;
			elsif (done = '1' and J = '0') then
				PCin <= '1';
				done_FSM <= '1';
				nx_state <= state1;
			elsif (mov = '1' and J = '0') then
				nx_state <= state6;
			else
				PCin <= '1';
				nx_state <= state1;
			end if;
		WHEN state3 =>   -- R[rb] -> reg A
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
			if (add = '1' or sub = '1' or andOp = '1' or orOp = '1' or xorOp = '1' or merge = '1') then
				nx_state <= state4;
			elsif (ld = '1') then
				nx_state <= state7;
			elsif (st = '1') then
				nx_state <= state9;
			end if;
		WHEN state4 =>   -- R-type
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
			if (add = '1') then
				ALUFN <= "0000";
			elsif (sub = '1') then
				ALUFN <= "0001";
			elsif (andOp = '1') then
				ALUFN <= "0010";
			elsif (orOp = '1') then
				ALUFN <= "0011";
			elsif (xorOp = '1') then
				ALUFN <= "0100";
			elsif (merge = '1') then
				ALUFN <= "0110";
			end if;
			nx_state <= state1;
		WHEN state5 =>   -- J-type
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
			nx_state <= state1;
		WHEN state6 =>   -- mov
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
			nx_state <= state1;
		WHEN state7 =>   -- ld1
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
			nx_state <= s_wait;
		WHEN state8 =>   -- ld2
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
			nx_state <= state1;
		WHEN state9 =>   -- st1
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
			DTCM_addr_out <= '0';
			DTCM_addr_in <= '1';
			DTCM_addr_sel <= '0';
			Ain <= '0';
			nx_state <= state10;
		WHEN state10 =>   -- st2
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
			nx_state <= state1;
		WHEN s_wait =>   -- wait
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
			nx_state <= state8;
	END CASE;

	if (jmp = '1' or jc = '1' or jnc = '1') then
		J <= '1';
	else
		J <= '0';
	end if;

  END PROCESS;
END dfl;





































