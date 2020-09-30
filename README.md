Paremetrable FIFO with parity checker, data control is based on a simple request-grant protocol   

Build with : make build_rtl build_tb   

You can then simulate with : make sim, a tcl file with useful waves to check is included.   
Use : do waves.tcl on Modelsim to quickly see the important internal signals    


To send/push data, You need to rise push_valid_i and put data in the data input bus.   
If the FIFO is ready (that means push_grant_o is high), data will be stored in its RAM at next posedge of clock.   

To pop/send data, You need to rise pop_grant_i, if the FIFO can pop anything (pop_valid_o is high), it will transmit data in the data_o bus.   
Note: If the parity checker finds corrupted data , data will still be transmitted but pop_valid_o will be overwritten to 0 to warn the receiver.   



Currents Issues :   
*** Parallel Push and pop :  
Doesn't work when fifo is full
** Suggestions to be implemented :    
Completely change TB