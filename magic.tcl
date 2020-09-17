variable library  "/home/ss/Desktop/Verilog_projects/FIFO"

vlib $library

vmap work $library

vlog -sv FIFO.sv
vlog -sv tb.sv
vlog -sv ram.sv
vlog -sv parity_encoder.sv
vlog -sv top.sv


​vsim

add wave -r sim:/tb/*

​run 200ns
