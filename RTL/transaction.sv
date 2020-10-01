

class transaction #(int DATA_WIDTH = 8);

// declaring transaction items
rand bit[DATA_WIDTH:0] push_data_i;
rand bit push_valid_i;
bit push_grant_o;
bit[DATA_WIDTH:0] pop_data_o;
bit pop_valid_o;
rand bit pop_grant_i;

endclass : transaction


