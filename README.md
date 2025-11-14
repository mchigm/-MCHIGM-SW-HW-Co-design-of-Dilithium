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
- [How to Learn from This Repository](#how-to-learn-from-this-repository)
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

## How to Learn from This Repository

This section provides structured learning pathways to help you understand and learn from both the research paper and this implementation. Choose the path that best matches your background and learning goals.

### 📚 Learning Pathways

#### 🎓 For Students and Beginners in Post-Quantum Cryptography

If you're new to post-quantum cryptography or CRYSTALS-Dilithium:

1. **Start with Background Knowledge**
   - Read about [NIST Post-Quantum Cryptography Standardization](https://csrc.nist.gov/projects/post-quantum-cryptography)
   - Learn the basics of [lattice-based cryptography](https://pq-crystals.org/dilithium/)
   - Understand digital signature schemes (classical vs. post-quantum)

2. **Understand the Dilithium Algorithm**
   - Read the [CRYSTALS-Dilithium specification](https://pq-crystals.org/dilithium/data/dilithium-specification-round3-20210208.pdf)
   - Focus on key concepts:
     - Number Theoretic Transform (NTT)
     - Polynomial arithmetic over rings
     - Rejection sampling
     - Key generation, signing, and verification algorithms

3. **Study the Research Paper**
   - Read our [ACM TRETS paper](https://dl.acm.org/doi/10.1145/3569456)
   - Pay attention to:
     - Motivation for hardware acceleration (Section 1)
     - SW/HW partitioning strategy (Section 3)
     - Architecture design decisions (Section 4)
     - Performance analysis and results (Section 5)

4. **Explore the Code**
   - Start with pure software implementation in `Code/SW_benchmark/Dilithium-2/`
   - Understand the software flow before diving into hardware
   - Read [Code/TOC.md](Code/TOC.md) for detailed code organization

5. **Progress to Hardware**
   - Review basic Verilog/FPGA concepts if needed
   - Study the NTT hardware module in `Code/HW/sources/NTT source/`
   - Understand how NTT acceleration provides speedup
   - Follow [Hardware.md](Hardware.md) for implementation details

#### 🔬 For Researchers in Hardware Security / Post-Quantum Crypto

If you're researching hardware implementations of post-quantum cryptography:

1. **Focus on the Novel Contributions**
   - Study the hybrid NTT/INTT architecture design
   - Analyze the SW/HW partitioning methodology
   - Review the configurable design approach for multiple security levels
   - Examine performance-area trade-offs in Section 5 of the paper

2. **Analyze Design Decisions**
   - Compare our approach with related work (Section 6 of the paper)
   - Study the AXI-DMA interface design for PS-PL communication
   - Understand cache impact analysis (Cache ON vs Cache OFF results)
   - Review resource utilization and timing analysis

3. **Reproduce and Extend Results**
   - Use the artifact available on [Zenodo](https://zenodo.org/record/7546038)
   - Follow the complete implementation workflow
   - Replicate performance measurements
   - Consider extensions: side-channel protection, alternative platforms, etc.

4. **Build Upon This Work**
   - Adapt the design for newer FPGA platforms (Zynq UltraScale+, etc.)
   - Explore different SW/HW partitioning strategies
   - Implement additional optimizations
   - Compare with ASIC implementations

#### 💻 For Hardware/FPGA Engineers

If you want to learn FPGA-based cryptographic accelerator design:

1. **Understand the System Architecture**
   - Study the Zynq-7000 SoC architecture (PS + PL)
   - Learn AXI interconnect and AXI-DMA interfaces
   - Review the system block diagram in [Hardware.md](Hardware.md)

2. **Analyze Hardware Modules**
   - **NTT Module** (`Code/HW/sources/NTT source/`):
     - Butterfly operation implementation
     - Memory access patterns
     - Pipeline design
     - Twiddle factor ROM organization
   - **PWM Module** (`Code/HW/sources/PWM_source/`):
     - Modular multiplication
     - Montgomery/Barrett reduction
   - **SHA-3/PRNG Module** (`Code/HW/sources/SHA_source/`):
     - Keccak permutation
     - Sponge construction
     - Coefficient sampling

3. **Follow the Hardware Design Flow**
   - IP core creation in Vivado (Section 1 of [Hardware.md](Hardware.md))
   - Block design and integration (Section 2 of [Hardware.md](Hardware.md))
   - Synthesis, implementation, and bitstream generation
   - Timing closure and optimization techniques

4. **Explore SW/HW Interface Design**
   - Study `HW_ACC.c/h` in SW/HW Co-design directories
   - Understand DMA transfer mechanisms
   - Learn interrupt-driven vs. polling approaches
   - Analyze data movement optimization

#### 🖥️ For Software Engineers

If you're a software developer interested in using hardware acceleration:

1. **Start with Pure Software**
   - Examine `Code/SW_benchmark/Dilithium-2/`
   - Understand the software structure:
     - `sign.c` - Key generation, signing, verification
     - `poly.c` - Polynomial operations
     - `ntt.c` - Software NTT implementation
     - `fips202.c` - SHA-3/SHAKE hashing

2. **Compare with Hardware-Accelerated Version**
   - Study `Code/SW-HW-Co-design/Overall-design/Cache_ON/Dililithium-2/`
   - Identify which functions call hardware accelerators
   - Understand the hardware interface in `HW_ACC.c/h`
   - Compare performance between SW-only and HW-accelerated

3. **Learn the Integration Process**
   - Follow [Co-design.md](Co-design.md) for Vitis project setup
   - Understand how to call hardware functions via AXI interface
   - Learn memory management for DMA transfers
   - Study timing and profiling using ARM SCU timer

4. **Experiment with Optimizations**
   - Test different cache configurations
   - Analyze DMA transfer overhead
   - Experiment with batch processing
   - Measure individual function speedups

#### 🎯 Hands-On Learning Path (Recommended for All)

Follow this practical, step-by-step approach:

**Week 1: Understanding**
- [ ] Read the CRYSTALS-Dilithium specification (key sections)
- [ ] Read the research paper, focusing on Sections 1, 3, and 4
- [ ] Review [Code/TOC.md](Code/TOC.md) to understand code organization

**Week 2: Software Exploration**
- [ ] Set up development environment (Vitis 2020.2)
- [ ] Compile and run pure software implementation (`SW_benchmark/Dilithium-2/`)
- [ ] Understand the software execution flow
- [ ] Measure baseline performance

**Week 3: Hardware Understanding**
- [ ] Study the NTT hardware module design
- [ ] Review Verilog source files in `Code/HW/sources/`
- [ ] Understand the system architecture and PS-PL interface
- [ ] Use pre-generated hardware from `Gen_HW_file/` for quick testing

**Week 4: Integration and Testing**
- [ ] Follow [Co-design.md](Co-design.md) to set up SW/HW co-design
- [ ] Program ZedBoard with the bitstream
- [ ] Run hardware-accelerated implementation
- [ ] Compare performance: SW-only vs HW-accelerated
- [ ] Analyze speedup for individual operations

**Week 5: Deep Dive and Experimentation**
- [ ] Test different security levels (Dilithium-2, 3, 5)
- [ ] Compare Cache ON vs Cache OFF performance
- [ ] Run individual function tests to isolate acceleration benefits
- [ ] Document your findings and learning

### 🛠️ Practical Tips for Learning

1. **Use the Provided Resources Effectively**
   - The [Zenodo archive](https://zenodo.org/record/7546038) contains the complete validated artifact
   - Figures in `Figs/` provide visual guidance for hardware setup
   - Pre-generated files in `Gen_HW_file/` allow quick testing without full hardware build

2. **Start Simple, Then Scale**
   - Begin with Dilithium-2 (smallest parameter set)
   - Use Cache ON configuration first (better performance)
   - Start with pre-generated hardware before building from source
   - Run individual function tests before full system

3. **Leverage the Documentation**
   - **This README**: Overview and quick reference
   - **[Hardware.md](Hardware.md)**: Step-by-step hardware implementation
   - **[Co-design.md](Co-design.md)**: Software integration and testing
   - **[Code/TOC.md](Code/TOC.md)**: Detailed code walkthrough
   - **Research Paper**: Methodology and detailed analysis

4. **Measure and Compare**
   - Always benchmark pure software first (baseline)
   - Use the provided timer utilities (`scutimer.c/h`)
   - Record results for different configurations
   - Calculate speedup factors for each operation

5. **Debug Systematically**
   - Use PuTTY serial terminal to view output
   - Check UART settings (115200 baud)
   - Verify board connections (see `Figs/Board.jpg`)
   - Test individual functions before full system

6. **Join the Community**
   - Cite the paper if you use this work: [Citation](#citation)
   - Contact the authors for questions: gaoyumao3-c@my.cityu.edu.hk
   - Share your findings and improvements

### 📖 Key Concepts to Master

As you work through this repository, focus on understanding these core concepts:

1. **Number Theoretic Transform (NTT)**
   - Why NTT is critical for lattice-based crypto
   - How NTT enables efficient polynomial multiplication
   - The difference between forward NTT and inverse NTT
   - Why hardware acceleration provides significant speedup

2. **SW/HW Co-design Methodology**
   - How to partition algorithms between software and hardware
   - When hardware acceleration is beneficial (compute-intensive, regular operations)
   - When software is better (control flow, irregular operations)
   - Communication overhead and when to use DMA

3. **FPGA System-on-Chip (SoC) Design**
   - Processing System (PS) vs Programmable Logic (PL)
   - AXI interface protocol and DMA transfers
   - Memory hierarchy and cache effects
   - Timing, resource utilization, and optimization

4. **Post-Quantum Cryptography Implementation**
   - Security considerations in implementation
   - Constant-time operations to prevent side-channels
   - Parameter sets and security levels
   - Practical deployment considerations

### 🎓 Suggested External Resources

To supplement your learning:

- **Post-Quantum Cryptography**: [NIST PQC Project](https://csrc.nist.gov/projects/post-quantum-cryptography)
- **CRYSTALS-Dilithium**: [Official Website](https://pq-crystals.org/dilithium/)
- **Xilinx Zynq**: [Zynq-7000 Technical Reference](https://www.xilinx.com/support/documentation/user_guides/ug585-Zynq-7000-TRM.pdf)
- **AXI Protocol**: [AXI Reference Guide](https://www.xilinx.com/support/documentation/ip_documentation/axi_ref_guide/latest/ug1037-vivado-axi-reference-guide.pdf)
- **Number Theoretic Transform**: Academic papers on NTT for lattice crypto

### ✅ Learning Verification Checklist

Use this checklist to verify your understanding:

- [ ] Can explain what CRYSTALS-Dilithium is and why it's important
- [ ] Understand the key generation, signing, and verification algorithms
- [ ] Know what NTT is and why it's computationally expensive
- [ ] Can describe the SW/HW partitioning strategy used in this work
- [ ] Understand how the Zynq PS and PL communicate via AXI
- [ ] Can build and run both software-only and hardware-accelerated versions
- [ ] Able to measure and compare performance between implementations
- [ ] Understand the trade-offs in different design decisions
- [ ] Can modify the code to test different configurations
- [ ] Ready to extend or adapt this work for your own research/projects

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

