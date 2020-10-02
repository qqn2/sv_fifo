module DUAL_PORT_RAM #(
    parameter DATA_RAM_WIDTH = 8, // DATA WIDTH
    parameter ADDR_WIDTH = 8  // ADRESS WIDTH
) (
    input        [ADDR_WIDTH-1:0]       address_0,      // ADDRESS PORT 0
    input                               chip_enable_0,  // CHIP ENABLE PORT 0
    input                               write_read_0,   // WRITE OR READ PORT 0
    input  logic [DATA_RAM_WIDTH-1:0]   data_0,         // DATA PORT 0
    input        [ADDR_WIDTH-1:0]       address_1,      // ADDRESS PORT 1
    input                               chip_enable_1,  // CHIP ENABLE PORT 1
    input                               write_read_1,   // WRITE OR READ PORT 1
    output logic [DATA_RAM_WIDTH-1:0]   data_1,         // DATA PORT 1
    input                               rst_n,          // RESET
    input                               clk             // CLK
);

    localparam RAM_DEPTH = 1 << ADDR_WIDTH;                  // RAM depth = 2^addr_width
    logic      [DATA_RAM_WIDTH-1:0]     memory[RAM_DEPTH-1:0];

//  ███╗   ███╗███████╗███╗   ███╗ ██████╗ ██████╗ ██╗   ██╗    ██╗    ██╗██████╗ ██╗████████╗███████╗
//  ████╗ ████║██╔════╝████╗ ████║██╔═══██╗██╔══██╗╚██╗ ██╔╝    ██║    ██║██╔══██╗██║╚══██╔══╝██╔════╝
//  ██╔████╔██║█████╗  ██╔████╔██║██║   ██║██████╔╝ ╚████╔╝     ██║ █╗ ██║██████╔╝██║   ██║   █████╗
//  ██║╚██╔╝██║██╔══╝  ██║╚██╔╝██║██║   ██║██╔══██╗  ╚██╔╝      ██║███╗██║██╔══██╗██║   ██║   ██╔══╝
//  ██║ ╚═╝ ██║███████╗██║ ╚═╝ ██║╚██████╔╝██║  ██║   ██║       ╚███╔███╔╝██║  ██║██║   ██║   ███████╗
//  ╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝        ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝   ╚═╝   ╚══════╝
    always_ff @(posedge clk or negedge rst_n) begin : proc_
        if(~rst_n) begin
            for (int i = 0; i < RAM_DEPTH; i++) begin
                memory[i] <=  0;
            end
        end else if (chip_enable_0 && write_read_0) begin
            memory[address_0] <= data_0;
        end
    end



//  ███╗   ███╗███████╗███╗   ███╗ ██████╗ ██████╗ ██╗   ██╗    ██████╗ ███████╗ █████╗ ██████╗
//  ████╗ ████║██╔════╝████╗ ████║██╔═══██╗██╔══██╗╚██╗ ██╔╝    ██╔══██╗██╔════╝██╔══██╗██╔══██╗
//  ██╔████╔██║█████╗  ██╔████╔██║██║   ██║██████╔╝ ╚████╔╝     ██████╔╝█████╗  ███████║██║  ██║
//  ██║╚██╔╝██║██╔══╝  ██║╚██╔╝██║██║   ██║██╔══██╗  ╚██╔╝      ██╔══██╗██╔══╝  ██╔══██║██║  ██║
//  ██║ ╚═╝ ██║███████╗██║ ╚═╝ ██║╚██████╔╝██║  ██║   ██║       ██║  ██║███████╗██║  ██║██████╔╝
//  ╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝       ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝


    always_comb begin
        if(~rst_n) begin
            data_1 = 0;
        end else if (chip_enable_1 && !write_read_1) begin
            data_1 = memory[address_1];
        end
    end



endmodule : DUAL_PORT_RAM
