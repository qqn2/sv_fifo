Currents Issues :   No makefile  
Once the parity checker finds an error, it blocks data_o to the corrupted value and does not allow for any more pops  
The issue is the following : Once an error is detected, the receiver is set to not ready so the write pointer is never updated, which means that data_o is stuck to the same corrupted value  
Pop push parralel action does not work if there's not atleast one element in the fifo because I check the current count value in the code to allow for pop  
Change tcl to detect windows or linux then choose which path  
