1) ALU.vhd - this a file for ALU module that calculates add, sub, and, or, xor, merge and is able to pass the value B to C without A affecting it, we choose the the wanted operation is by using the ALUFN vector. it also caluculates the Cflag, Zflag, and Nflag in the wanted operations.

2) aux_package.vhd - holds components for different modules.

3) BidirPin - a pin that inputs values and outputs values from a module if tri-state buffer is on.

4) BidirPinBasic - a pin that inputs values and outputs values from a module.

5) control.vhd - the control unit, which follows the FSM diagram using process and case.

6) dataMem.vhd - Data Memory of the processor that can be written in it or read from it.

7) datapath.vhd - the datapath Unit, the unit that holds all the processor components together, like the PC, IR, ALU and so on. it also runs the instructions and does calculations according to which control lines the control unit opens.

8) decoder.vhd - tells the control unit which operation the instruction trying to preform using the opcode of the instruction (last 4-bits).

9) FA.vhd- full adder file.

10) IR.vhd - it takes the instruction that wants to be used in the datapath and gives the register values for read, register values for write, immediate value and offset value. 

11) PC.vhd - program counter that holds the next instruction address, and it also adds 1 to the pc (it also adds offset if the current instruct J-type and the condition is true). it could also reset the the PC value (makes PC equal 0).

12) progMem.vhd - Program Memory of the processor that can be written in it or read from it.

13) RF.vhd - register file of the processor that can be written in it or read from it.

14) top.vhd - the overall system that connects the control unit and the datapath together.
