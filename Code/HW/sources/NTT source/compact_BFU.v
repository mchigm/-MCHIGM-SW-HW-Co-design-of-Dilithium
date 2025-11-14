/*************************************************
 * Module: compact_BFU
 * 
 * Description: Compact Butterfly Unit for NTT/INTT computation.
 *              Implements the core butterfly operation used in both
 *              forward NTT and inverse NTT transformations.
 * 
 * Purpose: Performs modular arithmetic butterfly operations:
 *          - NTT mode (sel=0): Computes (a+b*omega) and (a-b*omega)
 *          - INTT mode (sel=1): Computes inverse butterfly with division by 2
 * 
 * Pipeline: 10-stage pipeline for throughput optimization
 * 
 * Parameters:
 *   PARAM_Q - Prime modulus for Dilithium (23'b11111111110000000000001 = 8380417)
 * 
 * Ports:
 *   clk         - System clock
 *   sel         - Operation select: 0 for NTT, 1 for INTT
 *   a, b        - Input coefficients (23-bit)
 *   omiga       - Twiddle factor (23-bit)
 *   a1, b1      - Output coefficients after butterfly operation
 *   opt1, opt2  - Intermediate outputs for multiplication stage
 *   mul_result  - Result from external multiplier
 *************************************************/
module compact_BFU
#(  parameter PARAM_Q = 23'b11111111110000000000001)
(
    input  wire clk,
    input  wire sel,//0: NTT, 1: INTT
    input  wire[22:0] a,
    input  wire[22:0] b,
    input  wire[22:0] omiga,
    output reg[22:0] a1,
    output reg[22:0] b1,
    output wire[22:0] opt1,
    output wire[22:0] opt2,
    input  wire[22:0] mul_result
    
);
    // Intermediate signals for butterfly computations
    reg[22:0] opt1_1;
    reg[22:0] opt2_1;
    assign opt1 = opt1_1;
    assign opt2 = opt2_1;
    
    // Computation of first butterfly output (a-b) with modular reduction
    wire signed[23:0] opt1_temp0_0;  // Temporary result with sign bit
    wire [22:0] opt1_temp1_0;        // After modular correction
    //wire [22:0] opt1_temp2_0;      // (Unused)
    wire [22:0] opt1_temp3_0;        // Final output selection based on mode
    assign opt1_temp0_0 = a - b;
    assign opt1_temp1_0 = opt1_temp0_0[23]? (opt1_temp0_0+PARAM_Q): opt1_temp0_0;  // Add Q if negative
    //assign opt1_temp2_0 = opt1_temp1_0[0]? ((opt1_temp1_0>>1)+ 22'b1111111111000000000001):(opt1_temp1_0>>1);
    assign opt1_temp3_0 = (sel)? opt1_temp1_0 : b;  // Select based on NTT/INTT mode
    
    // Pipeline registers for input 'a' (9 stages for alignment with multiplication latency)
    reg[22:0] a_1;
    reg[22:0] a_2;
    reg[22:0] a_3;
    reg[22:0] a_4;
    reg[22:0] a_5;
    reg[22:0] a_6;
    reg[22:0] a_7;
    reg[22:0] a_8;
    reg[22:0] a_9;
    
    // Pipeline registers for input 'b' (9 stages for alignment)
    reg[22:0] b_1;
    reg[22:0] b_2;
    reg[22:0] b_3;
    reg[22:0] b_4;
    reg[22:0] b_5;
    reg[22:0] b_6;
    reg[22:0] b_7;
    reg[22:0] b_8;
    reg[22:0] b_9;
    
    reg [22:0] mul_result_buf;  // Buffer for multiplication result
    
    // Computation of output a1 = a + b*omega (NTT) or with division (INTT)
    wire [22:0] temp1_10;
    wire [23:0] t1_temp1_10;
    wire [22:0] t1_temp2_10;
    reg  [22:0] t1_temp2_11;
    wire[22:0]  t1_temp3_11;      // Division by 2 with rounding for INTT
    wire[22:0] a1_temp_11;
    assign temp1_10 =(sel)? b_9:mul_result ;  // Select b or multiplication result
    assign t1_temp1_10 = temp1_10 + a_9;
    assign t1_temp2_10 = (t1_temp1_10>PARAM_Q)? (t1_temp1_10-PARAM_Q):t1_temp1_10;  // Modular reduction
    assign t1_temp3_11 = t1_temp2_11[0]? ((t1_temp2_11>>1)+ 22'b1111111111000000000001):(t1_temp2_11>>1);  // Divide by 2 with rounding
    assign a1_temp_11 = (sel)? t1_temp3_11 : t1_temp2_11;
    
    // Computation of output b1 = a - b*omega (NTT) or with division (INTT)
    wire signed [23:0] t5_temp1_10;
    reg [23:0] t5_temp1_11;
    wire [22:0] t5_temp2_11;
    wire[22:0]  t5_temp3_11;      // Division by 2 with rounding for INTT
    wire [22:0] b1_temp_11;
   
    assign t5_temp1_10 = a_9 - mul_result;
    assign t5_temp2_11 = (t5_temp1_11[23])? (t5_temp1_11 + PARAM_Q):t5_temp1_11;  // Add Q if negative
    assign t5_temp3_11 = mul_result_buf[0]? ((mul_result_buf[22:1])+ 22'b1111111111000000000001):(mul_result_buf[22:1]);  // Divide by 2 with rounding
    assign b1_temp_11 = (sel)? t5_temp3_11 : t5_temp2_11;
    
    // Main pipeline register update on each clock cycle
    always@(posedge clk)
    begin
        // Stage 1: Latch inputs and compute first output
        opt1_1 <= opt1_temp3_0;
        opt2_1 <= omiga;
        a_1    <= a;
        b_1    <= b;
        
        // Stages 2-9: Pipeline delay stages to align with multiplier latency
        a_2    <= a_1;
        b_2    <= b_1;
        
        a_3    <= a_2;
        b_3    <= b_2;
        
        a_4    <= a_3;
        b_4    <= b_3;
        
        a_5    <= a_4;
        b_5    <= b_4;
        
        a_6    <= a_5;
        b_6    <= b_5;
        
        a_7    <= a_6;
        b_7    <= b_6;
        
        a_8    <= a_7;
        b_8    <= b_7;
        
        a_9    <= a_8;
        b_9    <= b_8;
        
        // Stage 10: Buffer multiplication result and intermediate values
        t5_temp1_11 <= t5_temp1_10;
        mul_result_buf <= mul_result;
        
        t1_temp2_11 <= t1_temp2_10;

        // Stage 11: Final outputs
        a1     <= a1_temp_11;
        b1     <= b1_temp_11;
        
        
        
    end
    
    
endmodule
