/*************************************************
 * File: ntt.h
 * 
 * Description: Header file for Number Theoretic Transform operations.
 * 
 * Purpose: Declares NTT and inverse NTT functions for fast polynomial
 *          multiplication in Dilithium signature scheme.
 * 
 * API:
 *   - ntt(): Forward NTT transformation
 *   - invntt_tomont(): Inverse NTT with Montgomery conversion
 *************************************************/

#ifndef NTT_H
#define NTT_H

#include <stdint.h>
#include "params.h"

#define ntt DILITHIUM_NAMESPACE(_ntt)
void ntt(int32_t a[N]);

#define invntt_tomont DILITHIUM_NAMESPACE(_invntt_tomont)
void invntt_tomont(int32_t a[N]);

#endif
