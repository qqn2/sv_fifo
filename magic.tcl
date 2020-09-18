
# TODO : Change tcl to detect windows or linux then choose which path
#variable library  "/home/ss/Desktop/Verilog_projects/FIFO"
variable library "C:/Users/3600X-2700/Desktop/New_folder/sv_fifo"
vlib $library

vmap work $library

vlog -sv FIFO.sv
vlog -sv tb.sv
vlog -sv ram.sv
vlog -sv parity_encoder.sv
vlog -sv top.sv


​vsim tb

add wave -r sim:/tb/*

​run 200ns
