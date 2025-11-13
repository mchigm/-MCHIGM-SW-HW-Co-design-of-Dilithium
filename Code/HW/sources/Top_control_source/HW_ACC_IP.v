/*************************************************
 * Module: HW_ACC_IP
 * 
 * Description: Top-level hardware accelerator IP for Dilithium operations.
 *              Integrates NTT, point-wise multiplication, addition, and
 *              SHA-3/SHAKE modules into a unified accelerator.
 * 
 * Purpose: Provides AXI4-Lite slave interface for control registers
 *          and AXI4-Stream interfaces for data transfer via DMA.
 * 
 * Interfaces:
 *   - AXI4-Lite Slave (S00_AXI): Control register access
 *   - AXI4-Stream Slave (S_AXIS): Input data from DMA
 *   - AXI4-Stream Master (M_AXIS): Output data to DMA
 * 
 * Sub-modules:
 *   - Top_HW_ACC_Ctrl: Main control and datapath logic
 *   - Control_Reg: AXI4-Lite register interface
 * 
 * Parameters:
 *   C_S00_AXI_DATA_WIDTH - Width of AXI data bus (32 bits)
 *   C_S00_AXI_ADDR_WIDTH - Width of AXI address bus (5 bits)
 *************************************************/

`timescale 1ns / 1ps

module HW_ACC_IP#
(
    localparam C_S00_AXI_DATA_WIDTH	= 32,
    localparam C_S00_AXI_ADDR_WIDTH    = 5
)
(
    // ========== AXI4-Lite Slave Interface (S00_AXI) ==========
    // Control and status register access from ARM processor
    input wire  s00_axi_aclk,
    input wire  s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,  // Write address
    input wire [2 : 0] s00_axi_awprot,                        // Write protection type
    input wire  s00_axi_awvalid,                              // Write address valid
    output wire  s00_axi_awready,                             // Write address ready
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,   // Write data
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb, // Write strobes
    input wire  s00_axi_wvalid,                               // Write valid
    output wire  s00_axi_wready,                              // Write ready
    output wire [1 : 0] s00_axi_bresp,                        // Write response
    output wire  s00_axi_bvalid,                              // Write response valid
    input wire  s00_axi_bready,                               // Write response ready
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,  // Read address
    input wire [2 : 0] s00_axi_arprot,                        // Read protection type
    input wire  s00_axi_arvalid,                              // Read address valid
    output wire  s00_axi_arready,                             // Read address ready
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,  // Read data
    output wire [1 : 0] s00_axi_rresp,                        // Read response
    output wire  s00_axi_rvalid,                              // Read valid
    input wire  s00_axi_rready,                               // Read ready
    
    // ========== Global Control Signals ==========
    input wire aresetn,   // Global reset (active low)
    input wire clk,       // System clock
    
    // ========== AXI4-Stream Slave Interface (DMA Write) ==========
    // Receives data from DMA to hardware accelerator
    input wire s_axis_tvalid,        // Valid signal
    output wire s_axis_tready,       // Ready signal
    input wire[63:0] s_axis_tdata,   // 64-bit data
    input wire[7:0] s_axis_tkeep,    // Byte enable
    input wire s_axis_tlast,         // Last transfer indicator
    
    // ========== AXI4-Stream Master Interface (DMA Read) ==========
    // Sends computed data from accelerator to DMA
    output wire m_axis_tvalid,       // Valid signal
    input wire m_axis_tready,        // Ready signal
    output wire[63:0] m_axis_tdata,  // 64-bit data
    output wire[7:0] m_axis_tkeep,   // Byte enable
    output wire m_axis_tlast         // Last transfer indicator
    );
    
    // ========== Internal Control Signals ==========
    // Signals between Control_Reg and Top_HW_ACC_Ctrl modules
    wire[2:0] start_module;             // Start signal for different modules (NTT/PWM/ADD/SHA)
    wire sel_NTT;                       // NTT/INTT selection (0: NTT, 1: INTT)
    wire[3:0] column_length_PWM;        // Column length for point-wise multiplication
    wire add_sub_sel;                   // Addition/subtraction selection
    wire[3:0] vector_length;            // Vector length parameter
    wire [1:0] mode_SHA;                // SHA-3 mode selection
    wire sample_sel_SHA;                // Sampler selection: 0->Uniform, 1->Rejection
    wire eta_SHA;                       // Eta parameter: 0->2, 1->4
    wire[31:0] byte_read_SHA;           // Bytes to read for SHA operation
    wire[9:0] byte_write_SHA;           // Bytes to write for SHA operation
    wire [31 : 0] read_FIFO_count;      // Read FIFO occupancy count
    wire [31 : 0] write_FIFO_count;     // Write FIFO occupancy count
    
    // ========== Main Hardware Accelerator Control Module ==========
    // Manages NTT, PWM, ADD, and SHA operations with DMA interfaces
    Top_HW_ACC_Ctrl HW_module( aresetn, clk, start_module, sel_NTT, column_length_PWM, add_sub_sel, vector_length, mode_SHA, sample_sel_SHA, eta_SHA, byte_read_SHA, byte_write_SHA,
                           s_axis_tvalid, s_axis_tready, s_axis_tdata, s_axis_tkeep, s_axis_tlast, m_axis_tvalid, m_axis_tready,  m_axis_tdata, m_axis_tkeep, m_axis_tlast,
                           read_FIFO_count, write_FIFO_count
                            );
                            
    // ========== AXI4-Lite Control Register Module ==========
    // Provides memory-mapped register interface for configuration and status
    Control_Reg  Ctrl_module( start_module, sel_NTT, column_length_PWM, add_sub_sel, vector_length, mode_SHA, sample_sel_SHA, eta_SHA, byte_read_SHA, byte_write_SHA, read_FIFO_count, write_FIFO_count,
                              s00_axi_aclk, s00_axi_aresetn, s00_axi_awaddr, s00_axi_awprot, s00_axi_awvalid, s00_axi_awready, s00_axi_wdata, s00_axi_wstrb, s00_axi_wvalid, 
                              s00_axi_wready, s00_axi_bresp, s00_axi_bvalid, s00_axi_bready, s00_axi_araddr, s00_axi_arprot, s00_axi_arvalid, s00_axi_arready, s00_axi_rdata,
                              s00_axi_rresp, s00_axi_rvalid, s00_axi_rready
                             );
    
endmodule
