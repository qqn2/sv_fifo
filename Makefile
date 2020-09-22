.PHONY: compile autocheck debug connect_check clean sim



build_rtl:
	vlog -sv FIFO.sv
	vlog -sv ram.sv
	vlog -sv parity_encoder.sv
	vlog -sv top.sv


build_tb:
	vlog -sv tb.sv
sim:
	vsim -voptargs=+acc -L work tb


