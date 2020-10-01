.PHONY: compile autocheck debug connect_check clean sim



build_rtl:
	vlog -sv ../RTL/FIFO.sv
	vlog -sv ../RTL/ram.sv
	vlog -sv ../RTL/parity_encoder.sv
	vlog -sv ../RTL/top.sv


build_full_tb:
	vlog -sv ../RTL/tb_top.sv
	vlog -sv ../RTL/test.sv
	vlog -sv ../RTL/environment.sv
sim:
	vsim -voptargs=+acc -L work tb
sim_with_coverage:
	vsim -coverage -voptargs=+acc -L work tb

	


