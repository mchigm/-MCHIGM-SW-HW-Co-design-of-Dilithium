/*************************************************
 * File: params.h
 * 
 * Description: Parameter definitions for CRYSTALS-Dilithium
 *              post-quantum signature scheme.
 * 
 * Purpose: Defines security parameters, dimensions, and constants
 *          for different Dilithium modes (2, 3, or 5).
 * 
 * Note: Security level is selected via DILITHIUM_MODE in config.h
 *       Mode 2: NIST Level 2 security
 *       Mode 3: NIST Level 3 security  
 *       Mode 5: NIST Level 5 security
 *************************************************/

#ifndef PARAMS_H
#define PARAMS_H

#include "config.h"

/* Common parameters for all Dilithium modes */
#define SEEDBYTES 32            // Size of random seed in bytes
#define CRHBYTES 48             // Size of collision-resistant hash output
#define N 256                   // Polynomial degree
#define Q 8380417               // Prime modulus
#define D 13                    // Dropped bits from t
#define ROOT_OF_UNITY 1753      // N-th root of unity modulo Q

/* Mode-specific parameters
 * K: rows in matrix A (public key dimension)
 * L: columns in matrix A (secret key dimension)  
 * ETA: range of secret key coefficients [-ETA, ETA]
 * TAU: number of non-zero coefficients in challenge polynomial
 * BETA: rejection bound for signature verification
 * GAMMA1: y coefficient range parameter
 * GAMMA2: low-order rounding range
 * OMEGA: maximum number of hints */
#if DILITHIUM_MODE == 2
#define K 4
#define L 4
#define ETA 2
#define TAU 39
#define BETA 78
#define GAMMA1 (1 << 17)
#define GAMMA2 ((Q-1)/88)
#define OMEGA 80

#elif DILITHIUM_MODE == 3
#define K 6
#define L 5
#define ETA 4
#define TAU 49
#define BETA 196
#define GAMMA1 (1 << 19)
#define GAMMA2 ((Q-1)/32)
#define OMEGA 55

#elif DILITHIUM_MODE == 5
#define K 8
#define L 7
#define ETA 2
#define TAU 60
#define BETA 120
#define GAMMA1 (1 << 19)
#define GAMMA2 ((Q-1)/32)
#define OMEGA 75

#endif

#define POLYT1_PACKEDBYTES  320
#define POLYT0_PACKEDBYTES  416
#define POLYVECH_PACKEDBYTES (OMEGA + K)

#if GAMMA1 == (1 << 17)
#define POLYZ_PACKEDBYTES   576
#elif GAMMA1 == (1 << 19)
#define POLYZ_PACKEDBYTES   640
#endif

#if GAMMA2 == (Q-1)/88
#define POLYW1_PACKEDBYTES  192
#elif GAMMA2 == (Q-1)/32
#define POLYW1_PACKEDBYTES  128
#endif

#if ETA == 2
#define POLYETA_PACKEDBYTES  96
#elif ETA == 4
#define POLYETA_PACKEDBYTES 128
#endif

#define CRYPTO_PUBLICKEYBYTES (SEEDBYTES + K*POLYT1_PACKEDBYTES)
#define CRYPTO_SECRETKEYBYTES (2*SEEDBYTES + CRHBYTES \
                               + L*POLYETA_PACKEDBYTES \
                               + K*POLYETA_PACKEDBYTES \
                               + K*POLYT0_PACKEDBYTES)
#define CRYPTO_BYTES (SEEDBYTES + L*POLYZ_PACKEDBYTES + POLYVECH_PACKEDBYTES)

#endif
