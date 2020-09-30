interface fifo_intf (input logic clk,rst_n);

	clocking driver_cb @(posedge clk);
	  default input #1 output #1;
	  output push_data_i;
	  output push_valid_i;
	  output pop_grant_i;
	  input  push_grant_o;
	  input  pop_data_o; 
	  input  pop_valid_o;
	endclocking

	clocking monitor_cb @(posedge clk);
	  default input #1 output #1;
	  input  push_data_i;
	  input  push_valid_i;
	  input  pop_grant_i;
	  input  push_grant_o;
	  input  pop_data_o; 
	  input  pop_valid_o;
	endclocking


 //driver modport
  modport DRIVER  (clocking driver_cb,input clk,rst_n);
   
  //monitor modport 
  modport MONITOR (clocking monitor_cb,input clk,rst_n);








endinterface