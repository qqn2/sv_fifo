class driver

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
	wait(fifo_vif.reset);
  $display("--------- [DRIVER] Reset Started ---------");
  `DRIV_IF.push_data_i  <= 0;
  `DRIV_IF.push_valid_i <= 0;
  `DRIV_IF.pop_grant_i  <= 0;
   
  wait(!fifo_vif.reset);
  $display("--------- [DRIVER] Reset Ended ---------");
endtask

task drive;
	forever begin
	transaction trans;
	`DRIV_IF.push_valid_i <= 0;
  	`DRIV_IF.pop_grant_i  <= 0;
	gen2driv.get(trans);
	$display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
	@(posedge fifo_vif.DRIVER.clk);
	if(trans.push_valid_i) begin
		`DRIV_IF.push_valid_i = trans.push_valid_i;
		`DRIV_IF.push_data_i  <= trans.push_data_i;
		$display("\tADDR = %0h \tWDATA = %0h",trans.push_data_i,trans.push_data_i);
      	@(posedge fifo_vif.DRIVER.clk);
      	`DRIV_IF.push_data_i  <= 0;
	end
		if(trans.pop_grant_i) begin
        `DRIV_IF.pop_grant_i <= trans.pop_grant_i;
        @(posedge fifo_vif.DRIVER.clk);
        `DRIV_IF.pop_grant_i  <= 0;
        @(posedge mem_vif.DRIVER.clk);
        trans.pop_data_o = `DRIV_IF.pop_data_o;
        $display("\tADDR = %0h \tRDATA = %0h",trans.addr,`DRIV_IF.rdata);
      end
      $display("-----------------------------------------");
      no_transactions++;
	end
endtask	

endclass : driver