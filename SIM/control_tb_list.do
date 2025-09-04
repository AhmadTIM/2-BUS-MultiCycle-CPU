onerror {resume}
add list -width 17 /control_tb/clk
add list /control_tb/rst
add list /control_tb/ena
add list /control_tb/st
add list /control_tb/ld
add list /control_tb/mov
add list /control_tb/done
add list /control_tb/add
add list /control_tb/sub
add list /control_tb/jmp
add list /control_tb/jc
add list /control_tb/jnc
add list /control_tb/andOp
add list /control_tb/orOp
add list /control_tb/xorOp
add list /control_tb/Cflag
add list /control_tb/IRin
add list /control_tb/Imm1_in
add list /control_tb/Imm2_in
add list /control_tb/PCin
add list /control_tb/RFout
add list /control_tb/RFin
add list /control_tb/DTCM_out
add list /control_tb/DTCM_wr
add list /control_tb/DTCM_addr_out
add list /control_tb/DTCM_addr_in
add list /control_tb/DTCM_addr_sel
add list /control_tb/Ain
add list /control_tb/ALUFN
add list /control_tb/PCsel
add list /control_tb/RFaddr_wr
add list /control_tb/RFaddr_rd
add list /control_tb/done_FSM
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta collapse
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
