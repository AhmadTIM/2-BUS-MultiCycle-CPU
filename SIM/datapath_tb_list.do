onerror {resume}
add list -width 20 /datapath_tb/Cflag
add list /datapath_tb/Zflag
add list /datapath_tb/Nflag
add list /datapath_tb/IRin
add list /datapath_tb/Imm1_in
add list /datapath_tb/Imm2_in
add list /datapath_tb/PCin
add list /datapath_tb/RFout
add list /datapath_tb/RFin
add list /datapath_tb/DTCM_out
add list /datapath_tb/DTCM_wr
add list /datapath_tb/DTCM_addr_out
add list /datapath_tb/DTCM_addr_in
add list /datapath_tb/DTCM_addr_sel
add list /datapath_tb/Ain
add list /datapath_tb/ALUFN
add list /datapath_tb/PCsel
add list /datapath_tb/RFaddr_wr
add list /datapath_tb/RFaddr_rd
add list /datapath_tb/ITCM_tb_wr
add list /datapath_tb/clk
add list /datapath_tb/rst
add list /datapath_tb/DTCM_tb_wr
add list /datapath_tb/TBactive
add list /datapath_tb/ITCM_tb_in
add list /datapath_tb/ITCM_tb_addr_in
add list /datapath_tb/DTCM_tb_in
add list /datapath_tb/DTCM_tb_out
add list /datapath_tb/DTCM_tb_addr_in
add list /datapath_tb/DTCM_tb_addr_out
add list /datapath_tb/done_FSM
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta collapse
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
