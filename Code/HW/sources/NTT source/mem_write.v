/*************************************************
 * Module: mem_write
 * 
 * Description: Memory write controller for NTT output data.
 *              Reads polynomial coefficients from dual-port RAM
 *              and writes them to AXI Stream interface.
 * 
 * Purpose: Interfaces between local RAM and DMA (via AXI Stream),
 *          outputting 256 coefficients after NTT processing.
 * 
 * Operation: Reads two 23-bit coefficients from RAM ports,
 *            packs them into 64-bit word, and sends via AXI Stream.
 * 
 * Data Format: Two 23-bit coefficients packed in 64-bit word
 *              [63:32] = second coefficient (port B)
 *              [22:0]  = first coefficient (port A)
 * 
 * Ports:
 *   clk          - System clock
 *   module_start - Start writing operation
 *   Ws_tready    - AXI Stream output ready
 *   Ws_tdata     - AXI Stream output data (64-bit, 2 coefficients)
 *   Ws_tvalid    - AXI Stream output valid
 *   coef_*       - Dual-port RAM interface for coefficient reading
 *   module_done  - Operation complete signal
 *************************************************/

`timescale 1ns / 1ps

module mem_write(

    input  wire clk,
    input  wire module_start,
    
    input  wire Ws_tready,
    output wire [63:0] Ws_tdata,
    output wire Ws_tvalid,
    
    output wire coef_ena,
    output wire coef_wea,
    output wire [7:0]coef_addra,
    input  wire [22:0] coef_douta,
    output wire coef_enb,
    output wire coef_web,
    output wire [7:0]coef_addrb,
    input  wire [22:0] coef_doutb,
    
    output wire module_done 

    );
    
    // Counter and control
    reg[7:0] counter;            // Address counter for RAM (counts by 2)
    wire count_done;             // Counter reached 256
    reg counter_working;         // Counter operation active
    
    // Data buffering
    reg[22:0] data1;             // Coefficient from port A
    reg[22:0] data2;             // Coefficient from port B
    reg working_1;
    reg working_2;
    reg done_1;
    reg done_2;
    wire mem_working;
    
    // Main control logic
    always@(posedge clk)
    begin
        counter <= (module_start)? 0 : (Ws_tready & mem_working)? (counter + 2'd2) : counter;
        counter_working <= module_start? 1 : (counter_working & count_done)? 0 : counter_working;
        data1 <= coef_douta;
        data2 <= coef_doutb;
        
        working_1 <= counter_working;
        working_2 <= working_1;
        done_1 <= count_done;
        done_2 <= done_1;
    end
    
    assign count_done = (counter == 8'd254);
    assign coef_addra = counter;
    assign coef_addrb = counter + 1'b1;
    assign Ws_tvalid = working_2 & Ws_tready;
    
    assign coef_ena = counter_working;
    assign coef_wea = 1'b0;
    assign coef_enb = counter_working;
    assign coef_web = 1'b0;
    assign Ws_tdata[22:0]  = data1;
    assign Ws_tdata[31:23] = 9'b0;
    assign Ws_tdata[54:32] = data2;
    assign Ws_tdata[63:55] = 9'b0; 
    
    assign module_done = done_2;
    assign mem_working = counter_working | done_1 | done_2;
    
endmodule
