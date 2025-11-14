# High-Performance and Configurable SW/HW Co-design of Post-Quantum Signature CRYSTALS-Dilithium

[![ACM TRETS](https://img.shields.io/badge/ACM-TRETS-blue)](https://dl.acm.org/doi/10.1145/3569456)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7546038.svg)](https://doi.org/10.5281/zenodo.7546038)

## Table of Contents
- [Overview](#overview)
- [Important Notes](#important-notes)
- [Key Features](#key-features)
- [Architecture Components](#architecture-components)
- [Pre-requisites](#pre-requisites)
- [Code Organization](#code-organization)
- [Getting Started](#getting-started)
- [Implementation Guides](#implementation-guides)
- [Performance](#performance)
- [Citation](#citation)
- [Contact](#contact)

## Overview

This repository provides a complete **software/hardware co-design** implementation and evaluation of [CRYSTALS-Dilithium](https://pq-crystals.org/dilithium/), a post-quantum digital signature scheme selected by NIST for standardization. The implementation targets the **Xilinx Zynq-7000 FPGA platform** (ZedBoard) and demonstrates how hardware acceleration can significantly improve the performance of post-quantum cryptographic operations.

CRYSTALS-Dilithium is a lattice-based digital signature scheme that offers security against attacks from quantum computers, making it essential for future-proof cryptographic systems.

## Important Notes

✅ **Artifact Evaluation**: Our code has successfully passed the Artifact Evaluation (AE) of ACM TRETS.

📦 **Complete Archive**: The full code with fixes and detailed paper results calculations is available on [Zenodo](https://zenodo.org/record/7546038).

📄 **Publication**: This work is published in ACM Transactions on Reconfigurable Technology and Systems (TRETS): "[High-Performance and Configurable SW/HW Co-design of Post-Quantum Signature CRYSTALS-Dilithium](https://dl.acm.org/doi/10.1145/3569456)"

## Key Features

- ✨ **Hybrid NTT/INTT Architecture**: Optimized Number Theoretic Transform for efficient polynomial multiplication
- 🔧 **Configurable Design**: Supports Dilithium-2, Dilithium-3, and Dilithium-5 security levels
- ⚡ **Hardware Acceleration**: Custom accelerator modules for compute-intensive operations
- 🎯 **SW/HW Co-design**: Optimal partitioning between software and hardware for maximum performance
- 📊 **Comprehensive Benchmarks**: Detailed performance comparisons and analysis

## Architecture Components

This repository hosts a complete hardware accelerator for CRYSTALS-Dilithium with the following modules:

### Hardware Modules
- **Hybrid NTT/INTT Module**: Performs forward and inverse Number Theoretic Transform for polynomial multiplication with optimized butterfly operations
- **Point-wise Multiplication Module (PWM)**: Efficiently computes element-wise multiplication of polynomials in NTT domain
- **Point-wise Addition Module**: Handles polynomial coefficient addition operations
- **PRNG Module**: Pseudo-random number generation with integrated SHA-3 core and unified sampler for coefficient sampling

### System Architecture
The design is based on the **Xilinx Zynq-7000 SoC** architecture, which combines:
- **Processing System (PS)**: ARM Cortex-A9 dual-core processor running software components
- **Programmable Logic (PL)**: FPGA fabric hosting hardware accelerator modules
- **AXI Interface**: High-bandwidth communication between PS and PL via AXI-DMA

## Pre-requisites

### Required Tools and Hardware

To replicate our implementation and testing, you will need:

#### Software Tools
- **Xilinx Vivado 2020.2** - For hardware design (Verilog) implementation, synthesis, and bitstream generation
- **Xilinx Vitis 2020.2** - For software implementation (C/C++), SW/HW integration, and system verification
- **PuTTY (0.67)** or any serial terminal - For UART communication and result display

#### Hardware Platform
- **Xilinx ZedBoard (Zynq-7000 XC7Z020 CLG484-1)** - Target FPGA development board for implementation and testing
  - Contains ARM Cortex-A9 dual-core processor
  - Artix-7 FPGA fabric
  - 512 MB DDR3 memory
  - USB-UART and USB-JTAG interfaces

#### Optional
- **Linux/Windows Development Machine** - For running Vivado and Vitis tools
- **USB Cables** - For JTAG programming and UART communication

## Code Organization

This repository is organized into three main sections: Hardware (HW), Software Benchmark (SW), and SW/HW Co-design implementations.

### 1. Hardware Components (`Code/HW/`)

Complete hardware design files targeting the Zynq-7000 XC7Z020 CLG484-1 FPGA:

- **`constrs/`** - Hardware constraint files (.xdc) defining pin assignments and timing constraints
- **`PS_preset.tcl`** - Zynq Processing System (ARM) configuration script with peripheral and clock settings
- **`sources/`** - Verilog source files organized by functional modules:
  - **`ip/`** - Xilinx IP core files (AXI interfaces, memory controllers, etc.)
  - **`NTT source/`** - Number Theoretic Transform hardware module
    - Forward/Inverse NTT computation
    - Butterfly operation units
    - Twiddle factor ROM
  - **`PWM_source/`** - Point-wise Multiplication hardware module
    - Coefficient-wise multiplication in NTT domain
  - **`SHA_source/`** - PRNG (Pseudo-Random Number Generator) module
    - SHA-3/SHAKE implementation
    - Unified coefficient sampler
  - **`Top_control_source/`** - System control and integration
    - Point-wise addition module
    - Top-level control logic
    - AXI interface controller
- **`zetas.COE`** - ROM memory initialization file containing NTT twiddle factors (roots of unity)

### 2. Software Benchmark (`Code/SW_benchmark/`)

Pure software reference implementations for performance comparison:

- **`Dilithium-2/`** - Software implementation of Dilithium security level 2 (NIST Level 2)
- **`Dilithium-3/`** - Software implementation of Dilithium security level 3 (NIST Level 3)  
- **`Dilithium-5/`** - Software implementation of Dilithium security level 5 (NIST Level 5)

Each directory contains:
- Complete C implementation of the Dilithium signature scheme
- Key generation, signing, and verification functions
- Polynomial arithmetic, NTT, sampling, and hashing operations
- Benchmarking code for performance measurement

### 3. SW/HW Co-design (`Code/SW-HW-Co-design/`)

Hybrid implementations combining software and hardware accelerators:

#### Individual Function Tests (`Individual_function_test/`)
Performance comparison of pure software vs. hardware-accelerated individual functions:
- **`Cache_ON/`** - Tests with data cache enabled for realistic performance
- **`Cache_OFF/`** - Tests with data cache disabled for worst-case analysis

Contains test code for evaluating:
- NTT/INTT acceleration
- Point-wise multiplication speedup
- Polynomial sampling performance
- Data transfer overhead analysis

#### Overall System Design (`Overall-design/`)
Complete SW/HW co-design implementations with optimal hardware acceleration:
- **`Cache_ON/`** - Full implementations with cache enabled (organized by security level)
  - `Dililithium-2/` - Level 2 complete implementation
  - `Dililithium-3/` - Level 3 complete implementation
  - `Dililithium-5/` - Level 5 complete implementation
- **`Cache_OFF/`** - Full implementations with cache disabled (same structure)

Each implementation includes:
- Optimized software code calling hardware accelerators via AXI-DMA
- Hardware acceleration for compute-intensive operations (NTT, PWM, sampling)
- Software execution for control logic and remaining operations
- Performance measurement and timing utilities

### Additional Resources

- **`Figs/`** - Documentation figures and diagrams
  - Board connection photos
  - System architecture diagrams
  - Configuration screenshots
- **`Gen_HW_file/`** - Pre-generated hardware files
  - `component.xml` - Hardware accelerator IP description
  - `design_1_wrapper.xsa` - Complete FPGA bitstream export 

## Getting Started

### Quick Start Guide

1. **Review the Documentation**
   - Read this README for an overview
   - Check [Hardware.md](Hardware.md) for detailed hardware implementation steps
   - Check [Co-design.md](Co-design.md) for SW/HW integration and testing procedures
   - Explore [Code/TOC.md](Code/TOC.md) for detailed code organization

2. **Set Up Your Environment**
   - Install Xilinx Vivado 2020.2 and Vitis 2020.2
   - Connect and configure your ZedBoard
   - Install a serial terminal (PuTTY or similar)

3. **Choose Your Implementation Path**
   
   **Option A: Use Pre-generated Hardware** (Fastest)
   - Use the pre-generated bitstream in `Gen_HW_file/design_1_wrapper.xsa`
   - Skip to SW/HW co-design implementation
   - Follow [Co-design.md](Co-design.md) instructions
   
   **Option B: Build Hardware from Source**
   - Follow [Hardware.md](Hardware.md) to generate the hardware accelerator IP
   - Create the FPGA bitstream
   - Proceed to software integration
   
   **Option C: Software-Only Benchmark**
   - Use code from `Code/SW_benchmark/`
   - Compile and run on ZedBoard ARM processor
   - Compare with hardware-accelerated versions

### Workflow Overview

```
┌─────────────────────┐
│  Hardware Design    │
│   (Vivado)          │──> Generate IP ──> Create Bitstream
└─────────────────────┘                          │
                                                 │
                                                 ▼
┌─────────────────────┐                  ┌─────────────┐
│  Software Design    │                  │   Export    │
│   (C/C++ Code)      │──────────────────>│   .xsa      │
└─────────────────────┘                  └─────────────┘
                                                 │
                                                 ▼
                                          ┌─────────────┐
                                          │ Build Vitis │
                                          │  Project    │
                                          └─────────────┘
                                                 │
                                                 ▼
                                          ┌─────────────┐
                                          │   Program   │
                                          │   ZedBoard  │
                                          └─────────────┘
                                                 │
                                                 ▼
                                          ┌─────────────┐
                                          │ Run & Test  │
                                          └─────────────┘
```

## Implementation Guides

### Detailed Implementation Steps

For complete step-by-step instructions, please refer to:

1. **Hardware Implementation and System Generation**
   - See [Hardware.md](Hardware.md) for:
     - Hardware accelerator IP generation from Verilog sources
     - FPGA bitstream creation and configuration
     - Block design and system integration
     - Pre-generated files usage

2. **SW/HW Co-design and On-board Testing**
   - See [Co-design.md](Co-design.md) for:
     - Vitis project creation and configuration
     - Software application development
     - Hardware-software integration
     - Real board testing procedures
     - Serial communication setup
     - Performance measurement

### Testing Different Configurations

The repository includes multiple test configurations:

- **Security Levels**: Test Dilithium-2, Dilithium-3, or Dilithium-5
- **Cache Settings**: Evaluate with cache enabled or disabled
- **Acceleration Modes**: Pure software, individual function acceleration, or full co-design
- **Performance Analysis**: Individual function tests vs. overall system performance

## Performance

Our SW/HW co-design achieves significant performance improvements over pure software implementations:

### Key Results

- **Hardware Acceleration Speedup**: Up to **10-15x** faster for NTT/INTT operations
- **Overall System Speedup**: Significant improvements in key generation, signing, and verification
- **Configurable Design**: Performance scales across Dilithium-2, Dilithium-3, and Dilithium-5

### Performance Metrics

The implementation provides detailed performance measurements for:
- Individual cryptographic operations (NTT, PWM, sampling)
- Complete key generation, signing, and verification
- Comparison between pure software and hardware-accelerated versions
- Cache-enabled vs. cache-disabled configurations

For detailed performance results and analysis, please refer to our [ACM TRETS paper](https://dl.acm.org/doi/10.1145/3569456).

## Citation

If you use this code in your research, please cite our paper:

```bibtex
@article{gao2023high,
  title={High-Performance and Configurable SW/HW Co-design of Post-Quantum Signature CRYSTALS-Dilithium},
  author={Gao, Yumao and Mohamed, Nour Eldin and Karmakar, Angshuman and Verbauwhede, Ingrid},
  journal={ACM Transactions on Reconfigurable Technology and Systems},
  volume={16},
  number={2},
  pages={1--26},
  year={2023},
  publisher={ACM New York, NY, USA},
  doi={10.1145/3569456}
}
```

### Related Resources

- **CRYSTALS-Dilithium Official**: https://pq-crystals.org/dilithium/
- **NIST Post-Quantum Cryptography**: https://csrc.nist.gov/projects/post-quantum-cryptography
- **Complete Implementation Archive**: [Zenodo Repository](https://zenodo.org/record/7546038)

## Contact

For questions, issues, or collaboration opportunities, please contact:

**Primary Contact**: gaoyumao3-c@my.cityu.edu.hk

### Acknowledgments

This work was supported by the research conducted at City University of Hong Kong. We thank the reviewers and the ACM TRETS editorial team for their valuable feedback.

## License

Please refer to the license terms in the individual source files. The Xilinx-related code contains Xilinx copyright notices and permissions.

---

**Repository Maintained by**: MCHIGM  
**Last Updated**: 2024  
**Status**: ✅ Artifact Evaluated and Approved by ACM TRETS

