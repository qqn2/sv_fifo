module top #(
    parameter DATA_WIDTH = 32,
    parameter FIFO_DEPTH = 4,
    parameter EVEN_ODD   = 0,
    parameter PARITY_BIT = 0
) (
    input                               clk,
    input                               rst_n,
    input        [DATA_WIDTH:0]         data_i,     // Data input
    input                               valid_i,    // High if stimuli has data to send
    output                              grant_o,    // Indicates that fifo can accept data
    input                               grant_i,    // Indicats that fifo can send data
    output logic [DATA_WIDTH:0]         data_o,     // Data output
    output                              valid_o     // High if fifo has data to send
);

    logic pop_valid_parity_check;
    logic pop_grant_parity_check;


    parity_encoder#(

        .EVEN_ODD(EVEN_ODD), // EVEN(0) or ODD(1)
        .SELECT_PARITY_BIT(PARITY_BIT), // MSB(0) or LSB(1)
        .DATA_WIDTH(DATA_WIDTH)
    ) parity_encoder_i (
        .data_in(data_o),
        .pop_valid_fifo(pop_valid_parity_check),
        .pop_grant_receiver(grant_i),
        .pop_valid_receiver(valid_o),
        .pop_grant_fifo(pop_grant_parity_check)
    );


    FIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) fifo_i (
        .clk(clk),
        .rst_n(rst_n),
        .push_data_i(data_i),
        .push_valid_i(valid_i),
        .push_grant_o(grant_o),
        .pop_grant_i(pop_grant_parity_check),
        .pop_data_o(data_o),
        .pop_valid_o(pop_valid_parity_check)

    );



endmodule : top