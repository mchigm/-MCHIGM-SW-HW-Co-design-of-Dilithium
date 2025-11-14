/*************************************************
 * Module: mem_read
 * 
 * Description: Memory read controller for NTT input data.
 *              Reads polynomial coefficients from AXI Stream interface
 *              and writes them to dual-port coefficient RAM.
 * 
 * Purpose: Interfaces between DMA (via AXI Stream) and local RAM,
 *          loading 256 coefficients for NTT processing.
 * 
 * Operation: Reads 64-bit data (2 coefficients per transaction),
 *            extracts 23-bit coefficients, and stores in RAM.
 * 
 * Data Format: Two 23-bit coefficients packed in 64-bit word
 *              [63:32] = second coefficient
 *              [22:0]  = first coefficient
 * 
 * Ports:
 *   clk          - System clock
 *   module_start - Start reading operation
 *   read_working - Operation in progress indicator
 *   Rm_tvalid    - AXI Stream input valid
 *   Rm_tdata     - AXI Stream input data (64-bit, 2 coefficients)
 *   rd_en        - Read enable for AXI Stream
 *   coef_*       - Dual-port RAM interface for coefficient storage
 *   module_done  - Operation complete signal
 *************************************************/

`timescale 1ns / 1ps

module mem_read
(
    input  wire clk,
    input  wire module_start,
    input  wire read_working,
    
    input  wire Rm_tvalid,
    input  wire [63:0] Rm_tdata,
    output wire rd_en,
    
    output wire coef_ena,
    output wire coef_wea,
    output wire [7:0]coef_addra,
    output wire [22:0] coef_dina,
    output wire coef_enb,
    output wire coef_web,
    output wire [7:0]coef_addrb,
    output wire [22:0] coef_dinb,
    
    output wire module_done
    
    );
    
    // Data extraction and buffering
    reg[63:0] data_in;           // Input data buffer
    wire[31:0] data_temp_1;      // Temporary for first coefficient
    wire[31:0] data_temp_2;      // Temporary for second coefficient
    reg[22:0] data_1;            // First coefficient (23-bit)
    reg[22:0] data_2;            // Second coefficient (23-bit)
    
    // Counter and control signals
    wire count_done;             // Counter reached 256
    reg[7:0] counter;            // Address counter for RAM
    reg[7:0] counter_1;          // Pipeline stage 1
    reg[7:0] counter_2;          // Pipeline stage 2
    reg rd_en_1;
    reg rd_en_2;
    
    reg done_1;
    reg done_2;
    reg done_3;
    
    always@(posedge clk)
    begin
        counter <= (module_start | count_done)? 0 : (rd_en)?  (counter + 2'd2) : counter;
        
        data_in <= Rm_tdata;
        data_1 <= data_temp_1[22:0];
        data_2 <= data_temp_2[22:0];
        counter_1 <= counter;
        counter_2 <= counter_1;
        rd_en_1 <= rd_en;
        rd_en_2 <= rd_en_1;
        done_1 <= count_done;
        done_2 <= done_1;
        done_3 <= done_2;
    end
    
    assign data_temp_1 = data_in[31]? (data_in[31:0] + 23'd8380417): data_in[31:0];
    assign data_temp_2 = data_in[63]? (data_in[63:32]+ 23'd8380417): data_in[63:32];
    assign count_done = (counter == 8'd254);
    assign coef_addra = counter_2;
    assign coef_addrb = counter_2 + 1'b1;
    assign rd_en = read_working & Rm_tvalid &(~module_start);
    
    assign coef_ena = rd_en_2;
    assign coef_wea = 1'b1;
    
    assign coef_enb = rd_en_2;
    assign coef_web = 1'b1;
    assign coef_dina = data_1;
    assign coef_dinb = data_2;
    
    assign module_done = done_3;
    
   
    
endmodule
