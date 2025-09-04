onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /control_tb/clk
add wave -noupdate /control_tb/rst
add wave -noupdate /control_tb/ena
add wave -noupdate /control_tb/st
add wave -noupdate /control_tb/ld
add wave -noupdate /control_tb/mov
add wave -noupdate /control_tb/done
add wave -noupdate /control_tb/add
add wave -noupdate /control_tb/sub
add wave -noupdate /control_tb/jmp
add wave -noupdate /control_tb/jc
add wave -noupdate /control_tb/jnc
add wave -noupdate /control_tb/andOp
add wave -noupdate /control_tb/orOp
add wave -noupdate /control_tb/xorOp
add wave -noupdate /control_tb/Cflag
add wave -noupdate /control_tb/IRin
add wave -noupdate /control_tb/Imm1_in
add wave -noupdate /control_tb/Imm2_in
add wave -noupdate /control_tb/PCin
add wave -noupdate /control_tb/RFout
add wave -noupdate /control_tb/RFin
add wave -noupdate /control_tb/DTCM_out
add wave -noupdate /control_tb/DTCM_wr
add wave -noupdate /control_tb/DTCM_addr_out
add wave -noupdate /control_tb/DTCM_addr_in
add wave -noupdate /control_tb/DTCM_addr_sel
add wave -noupdate /control_tb/Ain
add wave -noupdate /control_tb/ALUFN
add wave -noupdate /control_tb/PCsel
add wave -noupdate /control_tb/RFaddr_wr
add wave -noupdate /control_tb/RFaddr_rd
add wave -noupdate /control_tb/done_FSM
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3462639 ps} 0}
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
WaveRestoreZoom {1897689 ps} {5993689 ps}
