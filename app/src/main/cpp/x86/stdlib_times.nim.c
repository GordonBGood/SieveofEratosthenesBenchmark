/* Generated by Nim Compiler v1.2.0 */
/*   (c) 2020 Andreas Rumpf */
/* The generated code is subject to the original license. */
#define NIM_INTBITS 32

#include "nimbase.h"
#include <time.h>
#include <string.h>
#include <sys/types.h>
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
typedef struct tyObject_TimezonecolonObjectType___F8OvqlxXyGXRSiK9c1fCDVw tyObject_TimezonecolonObjectType___F8OvqlxXyGXRSiK9c1fCDVw;
typedef struct tyObject_ZonedTime__WigfH9apQAxJ69bBPh3wB8RQ tyObject_ZonedTime__WigfH9apQAxJ69bBPh3wB8RQ;
typedef struct tyObject_Time__3y2ZpqsTJLqdZvpC9a0rU2Q tyObject_Time__3y2ZpqsTJLqdZvpC9a0rU2Q;
typedef struct NimStringDesc NimStringDesc;
typedef struct TGenericSeq TGenericSeq;
typedef struct TNimType TNimType;
typedef struct TNimNode TNimNode;
typedef struct tyTuple__JfHvHzMrhKkWAUvQKe0i1A tyTuple__JfHvHzMrhKkWAUvQKe0i1A;
typedef struct tyObject_Env_timesdotnim___diB2NTuAIWY0FO9c5IUJRGg tyObject_Env_timesdotnim___diB2NTuAIWY0FO9c5IUJRGg;
struct tyObject_Time__3y2ZpqsTJLqdZvpC9a0rU2Q {
NI64 seconds;
NI nanosecond;
};
struct tyObject_ZonedTime__WigfH9apQAxJ69bBPh3wB8RQ {
tyObject_Time__3y2ZpqsTJLqdZvpC9a0rU2Q time;
NI utcOffset;
NIM_BOOL isDst;
};
typedef struct {
N_NIMCALL_PTR(tyObject_ZonedTime__WigfH9apQAxJ69bBPh3wB8RQ, ClP_0) (tyObject_Time__3y2ZpqsTJLqdZvpC9a0rU2Q x, void* ClE_0);
void* ClE_0;
} tyProc__bs1dgeTxHIjPGTR9axkkHbg;
struct TGenericSeq {
NI len;
NI reserved;
};
struct NimStringDesc {
  TGenericSeq Sup;
NIM_CHAR data[SEQ_DECL_SIZE];
};
struct tyObject_TimezonecolonObjectType___F8OvqlxXyGXRSiK9c1fCDVw {
tyProc__bs1dgeTxHIjPGTR9axkkHbg zonedTimeFromTimeImpl;
tyProc__bs1dgeTxHIjPGTR9axkkHbg zonedTimeFromAdjTimeImpl;
NimStringDesc* name;
};
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
struct tyTuple__JfHvHzMrhKkWAUvQKe0i1A {
void* Field0;
tyObject_Env_timesdotnim___diB2NTuAIWY0FO9c5IUJRGg* Field1;
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
typedef N_NIMCALL_PTR(void, tyProc__T4eqaYlFJYZUv9aG9b1TV0bQ) (void);
N_LIB_PRIVATE N_NIMCALL(void, nimGCvisit)(void* d, NI op);
static N_NIMCALL(void, Marker_tyRef__9a5v4OQPlGqsA25ioN8hFYA)(void* p, NI op);
static N_NIMCALL(void, TM__6NbDwwj5FY059b1gz2AsAZQ_4)(void);
N_LIB_PRIVATE N_NIMCALL(void, nimRegisterThreadLocalMarker)(tyProc__T4eqaYlFJYZUv9aG9b1TV0bQ markerProc);
static N_NIMCALL(void, TM__6NbDwwj5FY059b1gz2AsAZQ_5)(void);
static N_INLINE(void, nimZeroMem)(void* p, NI size);
static N_INLINE(void, nimSetMem__JE6t4x7Z3v2iVz27Nx0MRAmemory)(void* a, int v, NI size);
static N_INLINE(NF, toBiggestFloat__hTpm9cXKgh17pxyZUsNnUyQsystem)(NI64 i);
N_LIB_PRIVATE TNimType NTI__F8OvqlxXyGXRSiK9c1fCDVw_;
N_LIB_PRIVATE TNimType NTI__bs1dgeTxHIjPGTR9axkkHbg_;
extern TNimType NTI__vr5DoT1jILTGdRlYv1OYpw_;
extern TNimType NTI__HsJiUUcO9cHBdUCi0HwkSTA_;
extern TNimType NTI__77mFvmsOLKik79ci2hXkHEg_;
N_LIB_PRIVATE TNimType NTI__9a5v4OQPlGqsA25ioN8hFYA_;
N_LIB_PRIVATE NIM_THREADVAR tyObject_TimezonecolonObjectType___F8OvqlxXyGXRSiK9c1fCDVw* utcInstance__oeKVHn4dFpBJO35HhEkelw;
N_LIB_PRIVATE NIM_THREADVAR tyObject_TimezonecolonObjectType___F8OvqlxXyGXRSiK9c1fCDVw* localInstance__cLtN9cK9bCe6IPhJ3UFNLNKA;
static N_NIMCALL(void, Marker_tyRef__9a5v4OQPlGqsA25ioN8hFYA)(void* p, NI op) {
	tyObject_TimezonecolonObjectType___F8OvqlxXyGXRSiK9c1fCDVw* a;
	a = (tyObject_TimezonecolonObjectType___F8OvqlxXyGXRSiK9c1fCDVw*)p;
	nimGCvisit((void*)(*a).zonedTimeFromTimeImpl.ClE_0, op);
	nimGCvisit((void*)(*a).zonedTimeFromAdjTimeImpl.ClE_0, op);
	nimGCvisit((void*)(*a).name, op);
}
static N_NIMCALL(void, TM__6NbDwwj5FY059b1gz2AsAZQ_4)(void) {
	nimGCvisit((void*)utcInstance__oeKVHn4dFpBJO35HhEkelw, 0);
}
static N_NIMCALL(void, TM__6NbDwwj5FY059b1gz2AsAZQ_5)(void) {
	nimGCvisit((void*)localInstance__cLtN9cK9bCe6IPhJ3UFNLNKA, 0);
}
static N_INLINE(void, nimSetMem__JE6t4x7Z3v2iVz27Nx0MRAmemory)(void* a, int v, NI size) {
	void* T1_;
	T1_ = (void*)0;
	T1_ = memset(a, v, ((size_t) (size)));
}
static N_INLINE(void, nimZeroMem)(void* p, NI size) {
	nimSetMem__JE6t4x7Z3v2iVz27Nx0MRAmemory(p, ((int) 0), size);
}
static N_INLINE(NF, toBiggestFloat__hTpm9cXKgh17pxyZUsNnUyQsystem)(NI64 i) {
	NF result;
	result = (NF)0;
	result = ((NF) (i));
	return result;
}
N_LIB_PRIVATE N_NIMCALL(NF, epochTime__9aodCrWXscOGeNVh2cpuZkw)(void) {
	NF result;
	struct timespec ts;
	int T1_;
	NF T2_;
	NF T3_;
	result = (NF)0;
	nimZeroMem((void*)(&ts), sizeof(struct timespec));
	T1_ = (int)0;
	T1_ = clock_gettime(((clockid_t) (CLOCK_REALTIME)), (&ts));
	(void)(T1_);
	T2_ = (NF)0;
	T2_ = toBiggestFloat__hTpm9cXKgh17pxyZUsNnUyQsystem(((NI64) (ts.tv_sec)));
	T3_ = (NF)0;
	T3_ = toBiggestFloat__hTpm9cXKgh17pxyZUsNnUyQsystem(((NI64) (ts.tv_nsec)));
	result = ((NF)(T2_) + (NF)(((NF)(T3_) / (NF)(1.0000000000000000e+009))));
	return result;
}
N_LIB_PRIVATE N_NIMCALL(void, stdlib_timesInit000)(void) {
{

	nimRegisterThreadLocalMarker(TM__6NbDwwj5FY059b1gz2AsAZQ_4);


	nimRegisterThreadLocalMarker(TM__6NbDwwj5FY059b1gz2AsAZQ_5);

	tzset();
}
}

N_LIB_PRIVATE N_NIMCALL(void, stdlib_timesDatInit000)(void) {
static TNimNode* TM__6NbDwwj5FY059b1gz2AsAZQ_2_3[3];
static TNimNode* TM__6NbDwwj5FY059b1gz2AsAZQ_3_2[2];
static TNimNode TM__6NbDwwj5FY059b1gz2AsAZQ_0[7];
NTI__F8OvqlxXyGXRSiK9c1fCDVw_.size = sizeof(tyObject_TimezonecolonObjectType___F8OvqlxXyGXRSiK9c1fCDVw);
NTI__F8OvqlxXyGXRSiK9c1fCDVw_.kind = 18;
NTI__F8OvqlxXyGXRSiK9c1fCDVw_.base = 0;
TM__6NbDwwj5FY059b1gz2AsAZQ_2_3[0] = &TM__6NbDwwj5FY059b1gz2AsAZQ_0[1];
NTI__bs1dgeTxHIjPGTR9axkkHbg_.size = sizeof(tyTuple__JfHvHzMrhKkWAUvQKe0i1A);
NTI__bs1dgeTxHIjPGTR9axkkHbg_.kind = 18;
NTI__bs1dgeTxHIjPGTR9axkkHbg_.base = 0;
TM__6NbDwwj5FY059b1gz2AsAZQ_3_2[0] = &TM__6NbDwwj5FY059b1gz2AsAZQ_0[3];
TM__6NbDwwj5FY059b1gz2AsAZQ_0[3].kind = 1;
TM__6NbDwwj5FY059b1gz2AsAZQ_0[3].offset = offsetof(tyTuple__JfHvHzMrhKkWAUvQKe0i1A, Field0);
TM__6NbDwwj5FY059b1gz2AsAZQ_0[3].typ = (&NTI__vr5DoT1jILTGdRlYv1OYpw_);
TM__6NbDwwj5FY059b1gz2AsAZQ_0[3].name = "Field0";
TM__6NbDwwj5FY059b1gz2AsAZQ_3_2[1] = &TM__6NbDwwj5FY059b1gz2AsAZQ_0[4];
TM__6NbDwwj5FY059b1gz2AsAZQ_0[4].kind = 1;
TM__6NbDwwj5FY059b1gz2AsAZQ_0[4].offset = offsetof(tyTuple__JfHvHzMrhKkWAUvQKe0i1A, Field1);
TM__6NbDwwj5FY059b1gz2AsAZQ_0[4].typ = (&NTI__HsJiUUcO9cHBdUCi0HwkSTA_);
TM__6NbDwwj5FY059b1gz2AsAZQ_0[4].name = "Field1";
TM__6NbDwwj5FY059b1gz2AsAZQ_0[2].len = 2; TM__6NbDwwj5FY059b1gz2AsAZQ_0[2].kind = 2; TM__6NbDwwj5FY059b1gz2AsAZQ_0[2].sons = &TM__6NbDwwj5FY059b1gz2AsAZQ_3_2[0];
NTI__bs1dgeTxHIjPGTR9axkkHbg_.node = &TM__6NbDwwj5FY059b1gz2AsAZQ_0[2];
TM__6NbDwwj5FY059b1gz2AsAZQ_0[1].kind = 1;
TM__6NbDwwj5FY059b1gz2AsAZQ_0[1].offset = offsetof(tyObject_TimezonecolonObjectType___F8OvqlxXyGXRSiK9c1fCDVw, zonedTimeFromTimeImpl);
TM__6NbDwwj5FY059b1gz2AsAZQ_0[1].typ = (&NTI__bs1dgeTxHIjPGTR9axkkHbg_);
TM__6NbDwwj5FY059b1gz2AsAZQ_0[1].name = "zonedTimeFromTimeImpl";
TM__6NbDwwj5FY059b1gz2AsAZQ_2_3[1] = &TM__6NbDwwj5FY059b1gz2AsAZQ_0[5];
TM__6NbDwwj5FY059b1gz2AsAZQ_0[5].kind = 1;
TM__6NbDwwj5FY059b1gz2AsAZQ_0[5].offset = offsetof(tyObject_TimezonecolonObjectType___F8OvqlxXyGXRSiK9c1fCDVw, zonedTimeFromAdjTimeImpl);
TM__6NbDwwj5FY059b1gz2AsAZQ_0[5].typ = (&NTI__bs1dgeTxHIjPGTR9axkkHbg_);
TM__6NbDwwj5FY059b1gz2AsAZQ_0[5].name = "zonedTimeFromAdjTimeImpl";
TM__6NbDwwj5FY059b1gz2AsAZQ_2_3[2] = &TM__6NbDwwj5FY059b1gz2AsAZQ_0[6];
TM__6NbDwwj5FY059b1gz2AsAZQ_0[6].kind = 1;
TM__6NbDwwj5FY059b1gz2AsAZQ_0[6].offset = offsetof(tyObject_TimezonecolonObjectType___F8OvqlxXyGXRSiK9c1fCDVw, name);
TM__6NbDwwj5FY059b1gz2AsAZQ_0[6].typ = (&NTI__77mFvmsOLKik79ci2hXkHEg_);
TM__6NbDwwj5FY059b1gz2AsAZQ_0[6].name = "name";
TM__6NbDwwj5FY059b1gz2AsAZQ_0[0].len = 3; TM__6NbDwwj5FY059b1gz2AsAZQ_0[0].kind = 2; TM__6NbDwwj5FY059b1gz2AsAZQ_0[0].sons = &TM__6NbDwwj5FY059b1gz2AsAZQ_2_3[0];
NTI__F8OvqlxXyGXRSiK9c1fCDVw_.node = &TM__6NbDwwj5FY059b1gz2AsAZQ_0[0];
NTI__9a5v4OQPlGqsA25ioN8hFYA_.size = sizeof(tyObject_TimezonecolonObjectType___F8OvqlxXyGXRSiK9c1fCDVw*);
NTI__9a5v4OQPlGqsA25ioN8hFYA_.kind = 22;
NTI__9a5v4OQPlGqsA25ioN8hFYA_.base = (&NTI__F8OvqlxXyGXRSiK9c1fCDVw_);
NTI__9a5v4OQPlGqsA25ioN8hFYA_.marker = Marker_tyRef__9a5v4OQPlGqsA25ioN8hFYA;
}

