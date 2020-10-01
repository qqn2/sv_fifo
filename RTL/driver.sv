`define DRIV_IF fifo_vif.DRIVER.driver_cb

class driver;

virtual fifo_intf fifo_vif;
mailbox gen2driv;
//used to count the number of transactions
int no_transactions;

function new(virtual fifo_intf fifo_vif,mailbox gen2driv);
  //getting the interface
  this.fifo_vif = fifo_vif;
  //getting the mailbox handle from  environment
  this.gen2driv = gen2driv;
endfunction

task reset;
	wait(fifo_vif.rst_n);
  $display("--------- [DRIVER] Reset Started ---------");
  `DRIV_IF.push_data_i  <= 0;
  `DRIV_IF.push_valid_i <= 0;
  `DRIV_IF.pop_grant_i  <= 0;
   
  wait(!fifo_vif.rst_n);
  $display("--------- [DRIVER] Reset Ended ---------");
endtask

task drive;
	forever begin
	transaction #(8) trans;
	`DRIV_IF.push_valid_i <= 0;
  	`DRIV_IF.pop_grant_i  <= 0;
	gen2driv.get(trans);
	$display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
	@(posedge fifo_vif.DRIVER.clk);
	if(trans.push_valid_i) begin
		`DRIV_IF.push_valid_i <= trans.push_valid_i;
		`DRIV_IF.push_data_i  <= trans.push_data_i;
      $display("\tDATA_VALID_i = %0b \tDATA_IN = %0h",trans.push_valid_i,trans.push_data_i);
      	@(posedge fifo_vif.DRIVER.clk);
      	`DRIV_IF.push_valid_i  <= 0;
	end
		if(trans.pop_grant_i) begin
        `DRIV_IF.pop_grant_i <= trans.pop_grant_i;
        @(posedge fifo_vif.DRIVER.clk);
          trans.pop_data_o <= `DRIV_IF.pop_data_o;
          @(posedge fifo_vif.DRIVER.clk);
        `DRIV_IF.pop_grant_i  <= 0;
          $display("\tGRANT_I = %0b \tDATA_OUT = %0h",trans.pop_grant_i,trans.pop_data_o);
      end
      $display("-----------------------------------------");
      no_transactions++;
  end
endtask	

  task main;
    forever begin
      fork
        //Thread-1: Waiting for reset
        begin
          wait(fifo_vif.rst_n);
        end
        //Thread-2: Calling drive task
        begin
          forever
            drive();
        end
      join_any
      disable fork;
    end
  endtask
        


endclass : driver