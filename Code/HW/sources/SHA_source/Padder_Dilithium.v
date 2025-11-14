/*
 * Copyright 2013, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* "is_last" == 0 means byte number is 4, no matter what value "byte_num" is. */
/* if "in_ready" == 0, then "is_last" should be 0. */
/* the user switches to next "in" only if "ack" == 1. */

/*************************************************
 * Module: Padder_Dilithium
 * 
 * Description: Padding module for SHA-3/SHAKE operations in Dilithium.
 *              Implements domain separation and message padding for
 *              different SHA-3 modes (XOF, KDF, PRF, H, G).
 * 
 * Purpose: Prepares input data for Keccak permutation by adding
 *          appropriate padding bits according to SHA-3 specification.
 * 
 * Operation Modes:
 *   XOF (00): Extendable Output Function - 1344-bit rate
 *   KDF/PRF (01): Key Derivation/Pseudo-Random Function - 1088-bit rate
 *   H (10): Hash function - 1088-bit rate
 *   G (11): General hash - 512-bit rate
 * 
 * Ports:
 *   clk          - System clock
 *   reset        - Synchronous reset
 *   in           - Input data (64-bit)
 *   in_ready     - Input valid signal
 *   is_last      - Last block indicator
 *   mode         - SHA-3 mode selection (2-bit)
 *   byte_num     - Number of valid bytes in last block (3-bit)
 *   buffer_full  - Output buffer full indicator
 *   i_last       - Internal last block flag
 *   out          - Padded output to f_permutation (1344-bit)
 *   out_ready    - Output valid signal
 *   f_ack        - Acknowledge from f_permutation module
 *************************************************/

module Padder_Dilithium(clk, reset, in, in_ready, is_last, mode, byte_num, buffer_full, i_last, out, out_ready, f_ack);
    input              clk, reset;
    input      [63:0]  in;
    input              in_ready, is_last;
    input      [1:0]   mode;
    input      [2:0]   byte_num;
    output             buffer_full; /* to "user" module */
    output i_last;
    output reg [1343:0] out;         /* to "f_permutation" module */ // need update
    output             out_ready;   /* to "f_permutation" module */
    input              f_ack;       /* from "f_permutation" module */
                                    /* if "ack" is 1, then current output has been used by "f_permutation" module */
    
    reg                state;       /* state == 0: user will send more input data
                                     * state == 1: user will not send any data */
    reg                done;        /* == 1: out_ready should be 0 */
    reg        [20:0]  i;           /* length of "out" buffer */ // 576/32 = 18, therefore i[17:0] (one-hot encoding)
    wire       [63:0]  v0;          /* output of module "padder1" */
    reg        [63:0]  v1;          /* to be shifted into register "out" */
    
    wire               accept,      /* accept user input? */
                       update;
                       
    // SHA-3 mode parameters
    parameter   XOF   = 2'b00,   // Extendable output (SHAKE)
                KDF   = 2'b01,   // Key derivation
                PRF   = 2'b01,   // Pseudo-random function
                H     = 2'b10,   // Hash
                G     = 2'b11;   // General hash
    
    // Buffer full detection based on mode (different rate sizes)
    assign buffer_full = (mode == XOF)? i[20]:
                         (mode == KDF)? i[16]:
                         (mode == PRF)? i[16]:
                         (mode == H)  ? i[16]: /*(mode == G)?*/ i[8]; // need update
    
    assign out_ready = buffer_full;
    assign i_last = (mode == XOF)? i[19]:
                    (mode == KDF)? i[15]:
                    (mode == PRF)? i[15]:
                    (mode == H)  ? i[15]: /*(mode == G)?*/ i[7];
    assign accept = (~ state) & in_ready & (~ buffer_full); // if state == 1, do not eat input
    assign update = (accept | (state & (~ buffer_full))) & (~ done); // don't fill buffer if done

    // Shift register for output buffer - accumulates padded message
    always @ (posedge clk)
      if (reset)
        out <= 0;
      else if (update)
        out <= {out[1343-64:0], v1}; // Shift in 64 bits at a time

    // Buffer length counter (one-hot encoding for efficiency)
    always @ (posedge clk)
      if (reset)
        i <= 0;
      else if (f_ack | update)
        i <= {i[19:0], 1'b1} & {21{~ f_ack}}; // Increment on update, reset on ack
/*    if (f_ack)  i <= 0; */
/*    if (update) i <= {i[16:0], 1'b1}; // increase length, when sha3-512: 576/32 = 18 */

    // State machine: track whether more input is expected
    always @ (posedge clk)
      if (reset)
        state <= 0;
      else if (is_last)
        state <= 1;
      else
        state <= state;

    // Done flag: set when final padded block is ready
    always @ (posedge clk)
      if (reset)
        done <= 0;
      else if (state & out_ready)
        done <= 1;
      else
        done <= done;

    // Instantiate padding logic sub-module
    padder1 p0 (in, byte_num, mode, v0);
    
    // Select data to shift into output buffer
    always @ (*)
      begin
        if (state) // Last block already processed
          begin
            v1 = 0;
            v1[7] = v1[7] | i_last; // Set padding bit
            //v1[7] = v1[7] | i[16]; // "v1[7]" is the MSB of the last byte of "v1"
          end
        else if (is_last == 0)
          v1 = in;  // Normal input data
        else // is_last == 1, but not yet synchronized with clock
          begin
            v1 = v0;  // Padded input from padder1
            v1[7] = v1[7] | i_last; // Set padding bit
            //v1[7] = v1[7] | i[16];
          end
      end
endmodule
