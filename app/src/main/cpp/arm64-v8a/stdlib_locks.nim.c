/* Generated by Nim Compiler v1.2.0 */
/*   (c) 2020 Andreas Rumpf */
/* The generated code is subject to the original license. */
#define NIM_INTBITS 64
#define NIM_EmulateOverflowChecks

#include "nimbase.h"
#include <pthread.h>
#include <sys/types.h>
                          #include <pthread.h>
#undef LANGUAGE_C
#undef MIPSEB
#undef MIPSEL
#undef PPC
#undef R3000
#undef R4000
#undef i386
#undef linux
#undef mips
#undef near
#undef far
#undef powerpc
#undef unix
#define nimfr_(x, y)
#define nimln_(x, y)
typedef struct TNimType TNimType;
typedef struct TNimNode TNimNode;
typedef NU8 tyEnum_TNimKind__jIBKr1ejBgsfM33Kxw4j7A;
typedef NU8 tySet_tyEnum_TNimTypeFlag__v8QUszD1sWlSIWZz7mC4bQ;
typedef N_NIMCALL_PTR(void, tyProc__ojoeKfW4VYIm36I9cpDTQIg) (void* p, NI op);
typedef N_NIMCALL_PTR(void*, tyProc__WSm2xU5ARYv9aAR4l0z9c9auQ) (void* p);
struct TNimType {
NI size;
tyEnum_TNimKind__jIBKr1ejBgsfM33Kxw4j7A kind;
tySet_tyEnum_TNimTypeFlag__v8QUszD1sWlSIWZz7mC4bQ flags;
TNimType* base;
TNimNode* node;
void* finalizer;
tyProc__ojoeKfW4VYIm36I9cpDTQIg marker;
tyProc__WSm2xU5ARYv9aAR4l0z9c9auQ deepcopy;
};
typedef NU8 tyEnum_TNimNodeKind__unfNsxrcATrufDZmpBq4HQ;
struct TNimNode {
tyEnum_TNimNodeKind__unfNsxrcATrufDZmpBq4HQ kind;
NI offset;
TNimType* typ;
NCSTRING name;
NI len;
TNimNode** sons;
};
N_LIB_PRIVATE TNimType NTI__keOjwH3s9bnYBEeyteQLwbw_;
N_LIB_PRIVATE TNimType NTI__9bxnxao7MiiLOwO9aLAh9a3og_;
N_LIB_PRIVATE N_NIMCALL(void, acquire__9bDG9bIkA6DtNcXVdL7bnLvg)(pthread_mutex_t* lock) {
	pthread_mutex_lock(lock);
}
N_LIB_PRIVATE N_NIMCALL(void, release__9bDG9bIkA6DtNcXVdL7bnLvg_2)(pthread_mutex_t* lock) {
	pthread_mutex_unlock(lock);
}
N_LIB_PRIVATE N_NIMCALL(void, stdlib_locksDatInit000)(void) {
static TNimNode TM__05xOtLU9bCAYnon4m09bcBlg_0[2];
NTI__keOjwH3s9bnYBEeyteQLwbw_.size = sizeof(pthread_cond_t);
NTI__keOjwH3s9bnYBEeyteQLwbw_.kind = 18;
NTI__keOjwH3s9bnYBEeyteQLwbw_.base = 0;
NTI__keOjwH3s9bnYBEeyteQLwbw_.flags = 3;
NTI__keOjwH3s9bnYBEeyteQLwbw_.node = &TM__05xOtLU9bCAYnon4m09bcBlg_0[0];
NTI__9bxnxao7MiiLOwO9aLAh9a3og_.size = sizeof(pthread_mutex_t);
NTI__9bxnxao7MiiLOwO9aLAh9a3og_.kind = 18;
NTI__9bxnxao7MiiLOwO9aLAh9a3og_.base = 0;
NTI__9bxnxao7MiiLOwO9aLAh9a3og_.flags = 3;
NTI__9bxnxao7MiiLOwO9aLAh9a3og_.node = &TM__05xOtLU9bCAYnon4m09bcBlg_0[1];
}

