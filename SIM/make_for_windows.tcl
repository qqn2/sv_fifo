	vlog -sv ../RTL/FIFO.sv
	vlog -sv ../RTL/ram.sv
	vlog -sv ../RTL/parity_encoder.sv
	vlog -sv ../RTL/top.sv
	vlog -sv ../RTL/tb.sv
	vsim -voptargs=+acc -L work tb
	do waves.tcl