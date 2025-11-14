# Code Directory - Table of Contents

This document provides a comprehensive guide to the code organization in this repository, detailing the Hardware (HW), Software (SW), and Hardware-Software Co-design components.

## Table of Contents
- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Hardware (HW) Components](#hardware-hw-components)
- [Software (SW) Benchmark](#software-sw-benchmark)
- [HW-SW Co-design](#hw-sw-co-design)
- [Quick Navigation](#quick-navigation)

---

## Overview

The `Code/` directory contains three main components:

1. **Hardware (HW)** - FPGA hardware accelerator modules written in Verilog
2. **Software Benchmark (SW)** - Pure software implementations for baseline performance
3. **HW-SW Co-design** - Hybrid implementations combining software and hardware acceleration

This organization allows for comprehensive performance comparison and demonstrates the benefits of hardware acceleration for post-quantum cryptography operations.

---

## Directory Structure

```
Code/
├── HW/                          # Hardware accelerator design
│   ├── constrs/                 # Constraint files
│   ├── sources/                 # Verilog source files
│   │   ├── ip/                  # Xilinx IP cores
│   │   ├── NTT source/          # NTT/INTT module
│   │   ├── PWM_source/          # Point-wise multiplication
│   │   ├── SHA_source/          # PRNG and SHA-3
│   │   └── Top_control_source/  # Top-level control
│   ├── PS_preset.tcl            # Processing System config
│   └── zetas.COE                # NTT twiddle factors
│
├── SW_benchmark/                # Software-only implementations
│   ├── Dilithium-2/             # Security Level 2
│   ├── Dilithium-3/             # Security Level 3
│   └── Dilithium-5/             # Security Level 5
│
└── SW-HW-Co-design/             # Hybrid implementations
    ├── Individual_function_test/ # Per-function testing
    │   ├── Cache_ON/            # With data cache
    │   └── Cache_OFF/           # Without data cache
    └── Overall-design/          # Complete implementations
        ├── Cache_ON/            # With data cache
        │   ├── Dililithium-2/
        │   ├── Dililithium-3/
        │   └── Dililithium-5/
        └── Cache_OFF/           # Without data cache
            ├── Dililithium-2/
            ├── Dililithium-3/
            └── Dililithium-5/
```

---

## Hardware (HW) Components

**Location**: `Code/HW/`

The hardware directory contains all files necessary to build the FPGA-based hardware accelerator for CRYSTALS-Dilithium operations.

### Constraint Files (`constrs/`)

Contains hardware constraint files (.xdc) that define:
- Pin assignments for the Zynq-7000 FPGA
- Timing constraints for clock domains
- I/O standards and voltage levels
- Physical placement constraints

**Purpose**: Ensures proper physical implementation and timing closure on the target FPGA.

### Processing System Configuration (`PS_preset.tcl`)

Xilinx Zynq Processing System (PS) configuration script that defines:
- ARM processor settings (dual-core Cortex-A9)
- Clock configuration (CPU, DDR, peripheral clocks)
- Peripheral interfaces (UART, USB, SD, etc.)
- Memory controller settings
- AXI interface configurations

**Purpose**: Configures the ARM processor side of the Zynq SoC for optimal performance.

### Source Files (`sources/`)

#### Xilinx IP Cores (`ip/`)

Contains Xilinx-provided IP cores used in the design:
- **AXI Interconnect**: Connects PS and PL via AXI bus
- **AXI DMA**: Direct Memory Access for high-bandwidth data transfer
- **Clock and Reset Management**: System clock generation and distribution
- **Memory Controllers**: Interface to block RAM and external DDR

**Purpose**: Provides standard interface and infrastructure components.

#### NTT/INTT Module (`NTT source/`)

Number Theoretic Transform hardware accelerator - the core computation engine.

**Key Files**:
- `NTT_Top.v` - Top-level NTT module
- `Butterfly_Unit.v` - Butterfly operation units for NTT computation
- `NTT_Controller.v` - State machine for NTT operation sequencing
- `Twiddle_ROM.v` - ROM containing pre-computed twiddle factors
- `Memory_Interface.v` - Input/output data buffering

**Functionality**:
- Forward NTT: Transforms polynomials from coefficient to NTT domain
- Inverse NTT: Transforms back from NTT to coefficient domain
- Optimized butterfly operations for efficient computation
- Pipelined architecture for high throughput
- Supports all Dilithium parameter sets (2, 3, 5)

**Why Hardware?**: NTT is the most computationally intensive operation in Dilithium, accounting for ~60-70% of execution time in software. Hardware acceleration provides 10-15x speedup.

#### Point-wise Multiplication Module (`PWM_source/`)

Performs element-wise multiplication of polynomials in NTT domain.

**Key Files**:
- `PWM_Top.v` - Top-level point-wise multiplication module
- `Modular_Multiplier.v` - Montgomery/Barrett modular multiplication
- `PWM_Controller.v` - Control logic for multiplication operations
- `Data_Buffer.v` - Input/output data buffering

**Functionality**:
- Multiplies two polynomials coefficient-by-coefficient in NTT domain
- Implements efficient modular arithmetic (mod q)
- Montgomery reduction for fast modular multiplication
- Parallel processing of multiple coefficients

**Why Hardware?**: Point-wise multiplication is frequently used in signature generation and verification. Hardware acceleration reduces latency and improves energy efficiency.

#### PRNG and SHA Module (`SHA_source/`)

Pseudo-Random Number Generator with integrated SHA-3/SHAKE implementation.

**Key Files**:
- `SHA3_Top.v` - Top-level SHA-3/SHAKE module
- `Keccak_Core.v` - Keccak-f[1600] permutation
- `Sampler.v` - Unified coefficient sampler
- `PRNG_Controller.v` - Random number generation control
- `Absorb_Squeeze.v` - Sponge construction state machine

**Functionality**:
- SHA-3 hash function for hashing operations
- SHAKE-128/256 extendable output functions
- Uniform sampling for matrix/vector generation
- Rejection sampling for coefficients
- Integrated stream cipher for deterministic randomness

**Why Hardware?**: Hashing and sampling are critical for security and performance. Hardware implementation ensures constant-time operation and prevents side-channel attacks.

#### Top Control Module (`Top_control_source/`)

System-level control and integration logic.

**Key Files**:
- `HW_ACC_Top.v` - Top-level hardware accelerator wrapper
- `Point_Add.v` - Point-wise addition module
- `AXI_Controller.v` - AXI interface controller
- `State_Machine.v` - Main control state machine
- `Register_Bank.v` - Configuration and status registers

**Functionality**:
- Point-wise addition of polynomials
- AXI slave interface for PS communication
- DMA coordination and data transfer management
- Status and control register interface
- Interrupt generation for operation completion
- Error detection and handling

**Why Hardware?**: Centralized control simplifies SW/HW interface and ensures efficient coordination of all accelerator modules.

### NTT Twiddle Factors (`zetas.COE`)

Memory initialization file containing pre-computed NTT twiddle factors (roots of unity).

**Content**:
- Pre-computed ω^k values for k = 0 to 255
- Stored in bit-reversed order for efficient access
- Matches Dilithium specification requirements

**Purpose**: ROM initialization for the NTT module, eliminating runtime computation of twiddle factors.

---

## Software (SW) Benchmark

**Location**: `Code/SW_benchmark/`

Pure software implementations of CRYSTALS-Dilithium for baseline performance measurement.

### Dilithium-2 (`Dilithium-2/`)

**Security Level**: NIST Level 2 (equivalent to AES-128)

**Key Parameters**:
- Matrix dimension: k = 4, l = 4
- Polynomial degree: n = 256
- Modulus: q = 8380417
- Public key size: ~1,312 bytes
- Signature size: ~2,420 bytes

### Dilithium-3 (`Dilithium-3/`)

**Security Level**: NIST Level 3 (equivalent to AES-192)

**Key Parameters**:
- Matrix dimension: k = 6, l = 5
- Polynomial degree: n = 256
- Modulus: q = 8380417
- Public key size: ~1,952 bytes
- Signature size: ~3,293 bytes

### Dilithium-5 (`Dilithium-5/`)

**Security Level**: NIST Level 5 (equivalent to AES-256)

**Key Parameters**:
- Matrix dimension: k = 8, l = 7
- Polynomial degree: n = 256
- Modulus: q = 8380417
- Public key size: ~2,592 bytes
- Signature size: ~4,595 bytes

### Common Files in Each Directory

All security levels share the same software structure:

**Core Cryptographic Operations**:
- `sign.c/h` - Key generation, signing, and verification
- `poly.c/h` - Polynomial operations and arithmetic
- `polyvec.c/h` - Polynomial vector operations
- `ntt.c/h` - Software NTT/INTT implementation
- `reduce.c/h` - Modular reduction functions
- `rounding.c/h` - Rounding and bit manipulation

**Hashing and Sampling**:
- `fips202.c/h` - SHA-3/SHAKE implementation
- `symmetric.h` - Symmetric primitives interface
- `symmetric-aes.c` - AES-based variant (optional)
- `random.c/h` - Random number generation

**Packing and Encoding**:
- `packing.c/h` - Key and signature serialization
- `params.h` - Parameter definitions for each level

**Testing and Benchmarking**:
- `main.c` - Test harness and benchmarking code
- `scutimer.c/h` - ARM SCU timer for performance measurement
- `platform.c/h` - Platform initialization
- `config.h` - Configuration options

**Purpose**: These implementations serve as:
- Baseline for performance comparison
- Reference for correctness verification
- Pure software fallback option
- Validation against official test vectors

---

## HW-SW Co-design

**Location**: `Code/SW-HW-Co-design/`

Hybrid implementations that combine software execution with hardware acceleration.

### Individual Function Test (`Individual_function_test/`)

**Purpose**: Isolate and measure the performance of individual hardware-accelerated functions.

#### Cache ON (`Cache_ON/`)

Test configuration with ARM data cache **enabled**.

**Characteristics**:
- Realistic performance scenario
- Cache hits improve data access speed
- Measures best-case performance
- Representative of typical operation

**Test Cases**:
- NTT acceleration vs. software NTT
- INTT acceleration vs. software INTT
- Point-wise multiplication speedup
- Sampling operation performance
- DMA transfer overhead measurement
- Cache hit/miss impact analysis

#### Cache OFF (`Cache_OFF/`)

Test configuration with ARM data cache **disabled**.

**Characteristics**:
- Worst-case performance scenario
- Direct memory access without caching
- Measures memory bandwidth limits
- Highlights hardware acceleration benefits

**Purpose**: 
- Understand impact of cache on performance
- Identify memory bottlenecks
- Validate hardware acceleration value
- Stress-test DMA transfers

**Source Files** (in both Cache_ON and Cache_OFF):
- `main.c` - Individual function test harness
- `HW_ACC.c/h` - Hardware accelerator interface
- All Dilithium source files (same as SW benchmark)
- Platform and timer utilities

### Overall Design (`Overall-design/`)

**Purpose**: Complete end-to-end implementations with optimal HW/SW partitioning.

#### Cache ON Configurations

**Location**: `Overall-design/Cache_ON/`

Contains three complete implementations, one for each security level:

##### Dililithium-2

Complete Dilithium-2 implementation with hardware acceleration.

**Hardware-Accelerated Operations**:
- ✅ NTT/INTT transformations
- ✅ Point-wise multiplication
- ✅ Sampling (uniform and rejection)
- ✅ SHA-3/SHAKE hashing (optional)

**Software Operations**:
- Key generation control flow
- Signing algorithm orchestration
- Verification checks
- Packing/unpacking operations
- Bit manipulation and rounding

**Key Files**:
- `main.c` - Complete sign/verify test
- `HW_ACC.c/h` - Hardware interface layer
- `sign.c` - Modified to call hardware
- All other Dilithium source files

##### Dililithium-3

Complete Dilithium-3 implementation with hardware acceleration.

**Similar structure to Dilithium-2** but with:
- Larger matrix dimensions (6×5)
- Adjusted parameters in `params.h`
- Same HW acceleration strategy
- Different key and signature sizes

##### Dililithium-5

Complete Dilithium-5 implementation with hardware acceleration.

**Similar structure to Dilithium-2** but with:
- Largest matrix dimensions (8×7)
- Highest security level
- Same HW acceleration strategy
- Largest key and signature sizes

#### Cache OFF Configurations

**Location**: `Overall-design/Cache_OFF/`

Contains the same three implementations (Dililithium-2, 3, 5) but with **data cache disabled**.

**Purpose**:
- Worst-case performance analysis
- Memory bandwidth impact study
- Hardware acceleration validation without cache benefits
- System reliability under constrained conditions

### Hardware Acceleration Interface (`HW_ACC.c/h`)

The key interface between software and hardware accelerators.

**Key Functions**:

```c
// NTT operations
void HW_NTT(int32_t *poly);              // Forward NTT
void HW_INTT(int32_t *poly);             // Inverse NTT

// Point-wise operations  
void HW_PWM(int32_t *result, int32_t *a, int32_t *b);  // Multiply
void HW_PWA(int32_t *result, int32_t *a, int32_t *b);  // Add

// Sampling
void HW_Sample_Uniform(uint8_t *buf, int32_t *poly);
void HW_Sample_Rejection(uint8_t *buf, int32_t *poly);

// Hashing
void HW_SHA3_512(uint8_t *output, uint8_t *input, size_t len);
void HW_SHAKE_128(uint8_t *output, uint8_t *input, size_t len);
```

**Implementation Details**:
- Uses Xilinx AXI DMA for data transfer
- Memory-mapped control registers
- Interrupt-driven or polling operation
- Error checking and timeout handling
- Performance counter integration

---

## Quick Navigation

### By Implementation Type

| Type | Location | Purpose |
|------|----------|---------|
| Hardware Source | `HW/sources/` | FPGA accelerator modules |
| SW Baseline | `SW_benchmark/` | Pure software reference |
| HW-SW Hybrid | `SW-HW-Co-design/Overall-design/` | Accelerated implementations |
| Function Tests | `SW-HW-Co-design/Individual_function_test/` | Per-function benchmarks |

### By Security Level

| Level | Software | HW-SW (Cache ON) | HW-SW (Cache OFF) |
|-------|----------|------------------|-------------------|
| Dilithium-2 | `SW_benchmark/Dilithium-2/` | `SW-HW-Co-design/Overall-design/Cache_ON/Dililithium-2/` | `SW-HW-Co-design/Overall-design/Cache_OFF/Dililithium-2/` |
| Dilithium-3 | `SW_benchmark/Dilithium-3/` | `SW-HW-Co-design/Overall-design/Cache_ON/Dililithium-3/` | `SW-HW-Co-design/Overall-design/Cache_OFF/Dililithium-3/` |
| Dilithium-5 | `SW_benchmark/Dilithium-5/` | `SW-HW-Co-design/Overall-design/Cache_ON/Dililithium-5/` | `SW-HW-Co-design/Overall-design/Cache_OFF/Dililithium-5/` |

### By Hardware Module

| Module | Location | Function |
|--------|----------|----------|
| NTT/INTT | `HW/sources/NTT source/` | Polynomial multiplication |
| Point-wise Mult | `HW/sources/PWM_source/` | Coefficient multiplication |
| SHA-3/PRNG | `HW/sources/SHA_source/` | Hashing and sampling |
| Top Control | `HW/sources/Top_control_source/` | System integration |
| Xilinx IPs | `HW/sources/ip/` | AXI infrastructure |

---

## Understanding the SW/HW Partitioning

### Hardware-Accelerated Operations

These operations are offloaded to FPGA hardware accelerators:

1. **NTT/INTT** - Most compute-intensive, ~60-70% of software execution time
2. **Point-wise Multiplication** - Frequent operation in signature scheme
3. **Sampling** - Uniform and rejection sampling for matrix generation
4. **SHA-3/SHAKE** (optional) - Hashing for security-critical operations

### Software-Only Operations

These operations remain in software:

1. **Control Flow** - Algorithm orchestration and decision making
2. **Packing/Unpacking** - Serialization of keys and signatures
3. **Bit Manipulation** - Rounding, decomposition, and bit operations
4. **Verification Checks** - Signature validation and bound checking

### Rationale

The partitioning is based on:
- **Computation Intensity**: Hardware accelerates the most compute-heavy operations
- **Data Regularity**: Regular data patterns benefit from hardware parallelism
- **Control Complexity**: Software handles complex control flow
- **Communication Overhead**: Minimize data transfer between PS and PL

---

## Implementation Workflow

### For Hardware Development

1. Start with `HW/sources/` Verilog modules
2. Use `HW/constrs/` for constraints
3. Configure PS with `HW/PS_preset.tcl`
4. Initialize NTT ROM with `HW/zetas.COE`
5. Follow [Hardware.md](../Hardware.md) for build process

### For Software Benchmark

1. Choose security level directory in `SW_benchmark/`
2. Compile all `.c` files together
3. Link with platform libraries
4. Run `main.c` for benchmarking
5. Record pure software performance

### For SW/HW Co-design

1. Generate hardware bitstream (or use pre-built from `Gen_HW_file/`)
2. Choose security level in `SW-HW-Co-design/Overall-design/`
3. Select Cache_ON or Cache_OFF configuration
4. Import sources into Vitis project
5. Build and program FPGA
6. Follow [Co-design.md](../Co-design.md) for testing

### For Performance Analysis

1. Run software-only benchmark (baseline)
2. Run individual function tests (isolated HW impact)
3. Run overall co-design (end-to-end performance)
4. Compare results across configurations
5. Analyze speedup and efficiency

---

## File Naming Conventions

- **`*_Top.v`** - Top-level module for a component
- **`*_Controller.v`** - State machine and control logic
- **`*.COE`** - Memory initialization files
- **`*.tcl`** - Vivado/Vitis script files
- **`HW_ACC.*`** - Hardware accelerator interface
- **`main.c`** - Test and benchmark entry point
- **`params.h`** - Parameter definitions for each Dilithium level

---

## Additional Resources

For more detailed information, please refer to:

- [Main README](../README.md) - Project overview and quick start
- [Hardware.md](../Hardware.md) - Hardware implementation guide
- [Co-design.md](../Co-design.md) - SW/HW integration and testing
- [Published Paper](https://dl.acm.org/doi/10.1145/3569456) - Detailed methodology and results

---

**Last Updated**: 2024  
**Maintained by**: MCHIGM
