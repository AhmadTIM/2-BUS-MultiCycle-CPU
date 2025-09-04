onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /datapath_tb/Cflag
add wave -noupdate /datapath_tb/Zflag
add wave -noupdate /datapath_tb/Nflag
add wave -noupdate /datapath_tb/IRin
add wave -noupdate /datapath_tb/Imm1_in
add wave -noupdate /datapath_tb/Imm2_in
add wave -noupdate /datapath_tb/PCin
add wave -noupdate /datapath_tb/RFout
add wave -noupdate /datapath_tb/RFin
add wave -noupdate /datapath_tb/DTCM_out
add wave -noupdate /datapath_tb/DTCM_wr
add wave -noupdate /datapath_tb/DTCM_addr_out
add wave -noupdate /datapath_tb/DTCM_addr_in
add wave -noupdate /datapath_tb/DTCM_addr_sel
add wave -noupdate /datapath_tb/Ain
add wave -noupdate /datapath_tb/ALUFN
add wave -noupdate /datapath_tb/PCsel
add wave -noupdate /datapath_tb/RFaddr_wr
add wave -noupdate /datapath_tb/RFaddr_rd
add wave -noupdate /datapath_tb/ITCM_tb_wr
add wave -noupdate /datapath_tb/clk
add wave -noupdate /datapath_tb/rst
add wave -noupdate /datapath_tb/DTCM_tb_wr
add wave -noupdate /datapath_tb/TBactive
add wave -noupdate /datapath_tb/ITCM_tb_in
add wave -noupdate /datapath_tb/ITCM_tb_addr_in
add wave -noupdate /datapath_tb/DTCM_tb_in
add wave -noupdate /datapath_tb/DTCM_tb_out
add wave -noupdate /datapath_tb/DTCM_tb_addr_in
add wave -noupdate /datapath_tb/DTCM_tb_addr_out
add wave -noupdate /datapath_tb/done_FSM
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5499289 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {3795379 ps} {7891379 ps}
