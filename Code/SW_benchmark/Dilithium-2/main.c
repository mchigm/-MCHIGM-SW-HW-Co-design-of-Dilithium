/*************************************************
 * File: main.c
 * 
 * Description: Benchmark application for CRYSTALS-Dilithium-2 
 *              post-quantum signature scheme on Xilinx Zynq platform.
 *              Tests key generation, signing, and verification operations.
 * 
 * Purpose: Performance evaluation of Dilithium-2 implementation
 *          using the ARM processor on Zynq-7000 SoC.
 * 
 * Note: Requires Xilinx platform libraries and timer support
 *************************************************/

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

#include<stdio.h>
#include"config.h"
#include"params.h"
#include"api.h"
#include"sign.h"
#include"packing.h"
#include"polyvec.h"
#include"poly.h"
#include"ntt.h"
#include"reduce.h"
#include"rounding.h"
#include"symmetric.h"
#include "random.h"
#include"fips202.h"
#include "scutimer.h"

#if (OS_TARGET == OS_LINUX)
  #include <sys/types.h>
  #include <sys/stat.h>
  #include <fcntl.h>
  #include <unistd.h>
#endif

#define MLEN 256       // Message length for testing
#define NRUNS 1000     // Number of benchmark runs
#define NTESTS 10000   // Number of test iterations (unused)

/*************************************************
 * Name:        cmp_llu
 *
 * Description: Comparison function for sorting unsigned long values
 *              Used by qsort for median calculation
 *
 * Arguments:   - const void *a: pointer to first element
 *              - const void *b: pointer to second element
 *
 * Returns:     -1 if a < b, 1 if a > b, 0 if equal
 *************************************************/
static int cmp_llu(const void *a, const void*b)
{
  if (*(unsigned long *)a < *(unsigned long *)b) return -1;
  if (*(unsigned long *)a > *(unsigned long *)b) return 1;
  return 0;
}


/*************************************************
 * Name:        median
 *
 * Description: Calculate the median value from an array of measurements
 *
 * Arguments:   - unsigned long *l: array of values
 *              - size_t llen: length of array
 *
 * Returns:     median value (middle element for odd length, 
 *              average of two middle elements for even length)
 *************************************************/
static unsigned long median(unsigned long *l, size_t llen)
{
  qsort(l,llen,sizeof(unsigned long),cmp_llu);

  if (llen%2) return l[llen/2];
  else return (l[llen/2-1]+l[llen/2])/2;
}


/*************************************************
 * Name:        average
 *
 * Description: Calculate the average (mean) value from an array of measurements
 *
 * Arguments:   - unsigned long *t: array of timing measurements
 *              - size_t tlen: length of array
 *
 * Returns:     average value in clock cycles
 *************************************************/
static unsigned long average(unsigned long *t, size_t tlen)
{
  unsigned long long acc=0;
  size_t i;
  for (i=0; i<tlen; i++)
    acc += t[i];
  return acc/(tlen);
}


/*************************************************
 * Name:        print_results
 *
 * Description: Print benchmark results showing median and average cycles
 *
 * Arguments:   - const char *s: label for the operation being benchmarked
 *              - unsigned long *t: array of timing measurements
 *              - size_t tlen: length of array
 *************************************************/
static void print_results(const char *s, unsigned long *t, size_t tlen)
{
  printf("%s", s);
  printf("\n");
  printf("median:  %lu ", median(t, tlen));  printf("cycles");  printf("\n");
  printf("average: %lu ", average(t, tlen-1));  printf("cycles"); printf("\n");
  printf("\n");
}


/*************************************************
 * Name:        main
 *
 * Description: Main benchmark program for Dilithium-2.
 *              Performs NRUNS iterations of key generation, signing,
 *              and verification operations, measuring cycle counts.
 *              Validates correctness and prints performance statistics.
 *
 * Returns:     0 on success, 1 on failure
 *************************************************/
int main()
{
    init_platform();
    printf("hello world!\n");
    unsigned char       m[MLEN], sm[200+CRYPTO_BYTES], m1[MLEN];
        unsigned char       pk[CRYPTO_PUBLICKEYBYTES], sk[CRYPTO_SECRETKEYBYTES];
        unsigned long  smlen, mlen1;
        int                 ret_val;

        unsigned int i, j;
        unsigned long cycles0[NRUNS], cycles1[NRUNS], cycles2[NRUNS];

        for (i = 0; i < NRUNS; i++)
        {
            randombytes(m, MLEN);
        	//for(int k = 0; k<MLEN;k++) m[k]=k;
            scutimer_start();
            if ( ret_val = crypto_sign_keypair(pk, sk) != 0) { return 1;}
            cycles0[i] = scutimer_result();

            scutimer_start();
            if ( (ret_val = crypto_sign(sm, &smlen, m, MLEN, sk)) != 0) {printf("crypto_sign returned <%d>\n", ret_val);}
            cycles1[i] = scutimer_result();
            //for(int k = 0; k<200+CRYPTO_BYTES;k++) printf("%d,",sm[k]);

            scutimer_start();
            if ( (ret_val = crypto_sign_open(m1, &mlen1, sm, smlen, pk)) != 0) {printf("crypto_sign_open returned <%d>\n", ret_val);}
            cycles2[i] = scutimer_result();

            if ( MLEN != mlen1 ) { printf("length fail"); return 0;}
            if ( memcmp(m, m1, MLEN)){printf("message fail\n");return 0;}
        }

        printf("Signature tests PASSED... \n\n");
        print_results("dilithium keygen: ", cycles0, NRUNS);
        print_results("dilithium sign: ", cycles1, NRUNS);
        print_results("dilithium verify: ", cycles2, NRUNS);

    cleanup_platform();
    return 0;
}
