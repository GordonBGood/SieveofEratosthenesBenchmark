#
#
#    A simple "Wheel Factorized Multi-Threaded Page Segmented Sieve of Eratosthenes" in Nim.
#
#    (c) Copyright 2020 W. Gordon Goodsman (GordonBGood)
#
#    See the file "copying.txt", included at the root of
#    this distribution, for details about the copyright.
#

# The following have been copied from jnim via the jni_wrapper import file:
# Specifically, from: https://github.com/yglukhov/jnim/blob/ec889fd4f58a8f587b53ee3b726de8189cc59769/src/private/jni_wrapper.nim
# type
#   jobject_base {.inheritable, pure.} = object
#   jobject* = ptr jobject_base
#   JClass* = ptr object of jobject
#   jstring* = ptr object of jobject
#   JNIEnv* = ptr JNINativeInterface
#   JNIEnvPtr* = ptr JNIEnv
#   JavaVM* = ptr JNIInvokeInterface
#   JavaVMPtr* = ptr JavaVM
import jni_wrapper

import sugar
import macros
from bitops import popcount
from math import sqrt
import locks
from times import epochTime

type
  Prime = uint64
  PrimeNdx = int64
  BasePrimeRep = uint32

const
  WHLPRMS = [ 2.Prime, 3, 5, 7, 11, 13, 17, 19 ]
  FRSTSVPRM = 23.Prime
  PRMNDXCNST =  (FRSTSVPRM * (FRSTSVPRM - 1.Prime)).int shr 1
  WHLODDCRC = 105 # 3 * 5 * 7 - skip 2 because Odds only CiRCumference Wheel
  WHLHITS = 48 # (2 - 1) * (3 - 1) * (5 - 1) * (7 - 1)

type
  WheelStart = uint16
  SieveBuffer = object # NEEDS WORK TO MAKE IT HEAP BASED FOR FINAL SOLUTION!!!!!!!!!!!!!!!!!!!!!
    bitsz: int
    data: array[WHLHITS, ptr UncheckedArray[uint8]] # ALSO SHOULD BE AN ARRAY OF ARRAYS FOR EXPANSION??????????
  # 2 bits of wheel index delta and 6 bits of residue index (0..47)...
  BasePrimeRepArr = object
    len: int
    data: ptr UncheckedArray[BasePrimeRep]
  StartAddr {.packed.} = object
    # contains 20 bits base prime wheel index,
    # 12 bits of (base prime residue index * WHLHITS + first cull residue index),   
    bpdwhlstrtndx: int32
    bp, sd: uint32 # base prime and current cull wheel index for residue bit plane
  StartAddrArr = object
    len: int
    data: ptr UncheckedArray[StartAddr]
  ThrdCntxt = object
    lwi: PrimeNdx # input
    lstndx: int # the last count index in the buffer
    thrd: Thread[ptr ThrdCntxt]
    bpra: ptr BasePrimeRepArr
    strts: StartAddrArr
    cmpsts: SieveBuffer
    strtjob: Cond
    strtlck: Lock
    fnshdjob: Cond
    fnshdlck: Lock
    cnt: int
    stop: int
  ThreadPool = object
    sz: int
    data: ptr UncheckedArray[ThrdCntxt]

const RESIDUES = [
  23.Prime, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71,
  73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 121, 127,
  131, 137, 139, 143, 149, 151, 157, 163, 167, 169, 173, 179,
  181, 187, 191, 193, 197, 199, 209, 211, 221, 223, 227, 229, 233 ]
const WHLNDXS = [
  0, 0, 0, 1, 2, 2, 2, 3, 3, 4, 5, 5, 6, 6, 6,
  7, 7, 7, 8, 9, 9, 9, 10, 10, 11, 12, 12, 12, 13, 13,
  14, 14, 14, 15, 15, 15, 15, 16, 16, 17, 18, 18, 19, 20, 20,
  21, 21, 21, 21, 22, 22, 22, 23, 23, 24, 24, 24, 25, 26, 26,
  27, 27, 27, 28, 29, 29, 29, 30, 30, 30, 31, 31, 32, 33, 33,
  34, 34, 34, 35, 36, 36, 36, 37, 37, 38, 39, 39, 40, 41, 41,
  41, 41, 41, 42, 43, 43, 43, 43, 43, 44, 45, 45, 46, 47, 47, 48 ]
const WHLRNDUPS = [ # two rounds to avoid overflow, used in start address calcs...
  0, 3, 3, 3, 4, 7, 7, 7, 9, 9, 10, 12, 12, 15, 15,
  15, 18, 18, 18, 19, 22, 22, 22, 24, 24, 25, 28, 28, 28, 30,
  30, 33, 33, 33, 37, 37, 37, 37, 39, 39, 40, 42, 42, 43, 45,
  45, 49, 49, 49, 49, 52, 52, 52, 54, 54, 57, 57, 57, 58, 60,
  60, 63, 63, 63, 64, 67, 67, 67, 70, 70, 70, 72, 72, 73, 75,
  75, 78, 78, 78, 79, 82, 82, 82, 84, 84, 85, 87, 87, 88, 93,
  93, 93, 93, 93, 94, 99, 99, 99, 99, 99, 100, 102, 102, 103, 105,
  105, 108, 108, 108, 109, 112, 112, 112, 114, 114, 115, 117, 117, 120, 120,
  120, 123, 123, 123, 124, 127, 127, 127, 129, 129, 130, 133, 133, 133, 135,
  135, 138, 138, 138, 142, 142, 142, 142, 144, 144, 145, 147, 147, 148, 150,
  150, 154, 154, 154, 154, 157, 157, 157, 159, 159, 162, 162, 162, 163, 165,
  165, 168, 168, 168, 169, 172, 172, 172, 175, 175, 175, 177, 177, 178, 180,
  180, 183, 183, 183, 184, 187, 187, 187, 189, 189, 190, 192, 192, 193, 198,
  198, 198, 198, 198, 199, 204, 204, 204, 204, 204, 205, 207, 207, 208, 210, 210 ]
let WHLSTARTS = ( proc (): array[WHLHITS, ptr UncheckedArray[uint16]] =
  for ri in 0 ..< WHLHITS:
    result[ri] = cast[ptr UncheckedArray[WheelStart]](createU(uint16, WHLHITS * WHLHITS))
  for pi in 0 ..< WHLHITS:
    var mltsarr: array[WHLHITS, int]
    let p = RESIDUES[pi]; let i = (p - FRSTSVPRM).int shr 1
    let s = (i shl 1) * (i + FRSTSVPRM.int) +
              (FRSTSVPRM.int * ((FRSTSVPRM.int - 1) shr 1))
    # build array of relative mults and offsets to `s`...
    for ci in 0 ..< WHLHITS:
      var rmlt = (RESIDUES[(pi + ci) mod WHLHITS] - RESIDUES[pi]).int shr 1
      rmlt += (if rmlt < 0: WHLODDCRC else: 0); let sn = s + p.int * rmlt
      let snd = sn div WHLODDCRC; let snn = WHLNDXS[sn - snd * WHLODDCRC]
      mltsarr[snn] = rmlt # new rmlts 0..209!
    let ondx = pi * WHLHITS
    for si in 0 ..< WHLHITS:
      let s0 = (RESIDUES[si] - FRSTSVPRM).int shr 1; let sm0 = mltsarr[si];
      for ci in 0 ..< WHLHITS:
        let smr = mltsarr[ci]
        let rmlt = (if smr < sm0: smr + WHLODDCRC - sm0 else: smr - sm0)
        let sn = s0 + p.int * rmlt; let rofs = sn div WHLODDCRC
        # we take the multiplier times 2 so it multiplies by the odd wheel index...
        result[ci][ondx + si] = (rmlt.WheelStart shl 9) or rofs.WheelStart)()

const BITMASK = [ 1'u8, 2, 4, 8, 16, 32, 64, 128 ] # faster than shifting!

macro unrollLoops(ca, szbts, whlndx, bp: untyped) =
  let endlmtaid = "endlmta".ident; let strt7id = "strt7".ident
  result = quote do:
    `endlmtaid` = `whlndx` shr 3
    `whlndx` += (`bp` shl 3) - `bp` # add 7 times bp!
  for i in countdown(7, 1):
    let strtid = ident("strt" & $i)
    result.add quote do:
      let `strtid` = (`whlndx` shr 3) - `endlmtaid`; `whlndx` -= `bp`
  var csstmnt = quote do:
    case (((`bp` and 6) shl 2) + (`whlndx` and 7)).uint8
    else: discard
  let sav = csstmnt[1] # keep last `else:` statement for later!
  csstmnt.del 1 # delete last statment; added back at end!
  for n in 0'u8 .. 31'u8: # actually used cases...
    let pn = (n shr 2) or 1'u8
    let cn = n and 7'u8
    let mod0id = newLit(cn)
    let loopstmnts = nnkStmtList.newTree()
    for i in 0'u8 .. 7'u8:
      let mskid = newLit(1'u8 shl ((cn + pn * i.uint8) and 7).int)
      let cptrid = ("cptr" & $i).ident
      let strtid = ("strt" & $i).ident
      if i == 0'u8:
        loopstmnts.add quote do:
          let `cptrid` = cast[ptr uint8](`whlndx`)
      else:      
        loopstmnts.add quote do:
          let `cptrid` = cast[ptr uint8](`whlndx` + `strtid`)
      loopstmnts.add quote do:
        `cptrid`[] = `cptrid`[] or `mskid`
    loopstmnts.add quote do:
      `whlndx` += `bp`
    let ofbrstmnts = quote do:
      `whlndx` = `ca` + (`whlndx` shr 3)
      while `whlndx` < `endlmtaid`:
        `loopstmnts`
      `whlndx` = ((`whlndx` - `ca`) shl 3) or `mod0id`.int
    csstmnt.add nnkOfBranch.newTree(
      newLit(n),
      ofbrstmnts
    )
  csstmnt.add sav
  result.add quote do:
    `endlmtaid` = `ca` + (`szbts` shr 3) - `strt7id`
    `csstmnt`
#  echo csstmnt[2].astGenRepr # to see the generated AST or the actual
#  echo result.toStrLit # generated code, respecitively, uncomment these!

proc cullSieveBuffer(lwi: PrimeNdx; bprps: ptr BasePrimeRepArr;
                     prmstrts: var StartAddrArr;
                     sb: var SieveBuffer) =
  let szbits = sb.bitsz; let sz = szbits shr 3; let bplmt = sz shr 2
  let lowndx = lwi * WHLODDCRC; let nxti = (lwi + szbits) * WHLODDCRC
  # set up prmstrts for use by each modulo residue bit plane...
  let bprpslmt = bprps.len; var pilmt = 0
  for pi in 0 ..< bprpslmt:
    let ndxdprm = bprps.data[pi]
    let prmndx = ndxdprm and 0x3F; let bpd = (ndxdprm.int32 shr 6).int
    let rsd = RESIDUES[prmndx]; let bp = bpd.Prime * (WHLODDCRC shl 1) + rsd
    let i = ((bp - FRSTSVPRM) shr 1).PrimeNdx
    var s = (i shl 1) * (i + FRSTSVPRM.PrimeNdx) + PRMNDXCNST
    if s >= nxti: break # enough base primes
    pilmt.inc
    if s >= lowndx: s -= lowndx
    else:
      let wp = (rsd - FRSTSVPRM).int shr 1
      let r = (lowndx - s) mod (WHLODDCRC.Prime * bp).PrimeNdx
      if r == 0: s = 0
      else: s = (bp.PrimeNdx * (WHLRNDUPS[wp + ((r.Prime + bp - 1) div bp).int] - wp) - r)
    let sd = s.int div WHLODDCRC; let sn = WHLNDXS[s - sd * WHLODDCRC].int32
    let adjndx = (prmndx * WHLHITS).int32 + sn
    prmstrts.data[pi] =
      StartAddr(bpdwhlstrtndx: (bpd shl 12).int32 or adjndx,
                bp: bp.uint32, sd: sd.uint32)

  # proceed with the culling according to the setup...
  let prmstrtsa = cast[int](prmstrts.data)
  let prmstrtslmta = prmstrtsa + pilmt * StartAddr.sizeof - 1
  for ri in 0 ..< WHLHITS:
    let plna = cast[int](sb.data[ri])
    let plnstrtsa = cast[int](WHLSTARTS[ri][0].unsafeAddr)
    for prmstrta in countup(prmstrtsa, prmstrtslmta, StartAddr.sizeof):
      var prmstrt = cast[ptr StartAddr](prmstrta)[];
      let bp = prmstrt.bp.int; var sd = prmstrt.sd.int
      let bpdndx = prmstrt.bpdwhlstrtndx.int
      let bpd = bpdndx shr 12; let adji = bpdndx and 0x0FFF
      let adj = cast[ptr uint16](plnstrtsa + adji + adji)[].int
      sd += (adj shr 8) * bpd + (adj and 0xFF)
      
      when not defined(i386): # x86 doesn't have enough registers!
        var endlmta = szbits - (bp shl 3) + bp
        if bp <= bplmt and sd < endlmta:
          unrollLoops(plna, szbits, sd, bp)
        while sd < szbits:
          let cp = cast[ptr uint8](plna + (sd shr 3))
          cp[] = cp[] or BITMASK[sd and 7]; sd += bp
      else: # lack of unrolling options makes non 64-bit code about 25% slower!
        static: echo "not 64-bit optimized code output!"
        if bp < bplmt:
          let sdlmt = min(szbits, sd + (bp shl 3)); let plnlmta = plna + sz
          while sd < sdlmt:
            let msk = BITMASK[sd and 7]; var ca = plna + (sd shr 3)
            while ca < plnlmta:
              let cp = cast[ptr uint8](ca)
              cp[] = cp[] or msk; ca += bp
            sd += bp
        else:
          while sd < szbits:
            let cp = cast[ptr uint8](plna + (sd shr 3))
            cp[] = cp[] or BITMASK[sd and 7]; sd += bp

proc makeStartAddrArr(sz: int): StartAddrArr =
  result.len = sz
  result.data =
    cast[ptr UncheckedArray[StartAddr]](createU(StartAddr, sz))

proc makeBasePrimeRepArr(sz: int): BasePrimeRepArr =
  result.len = sz
  result.data =
    cast[ptr UncheckedArray[BasePrimeRep]](createU(BasePrimeRep, sz))

proc makeSieveBuffer(btsz: int; zeroed: bool = false): SieveBuffer =
  # round up to 64-bit = 8 byte boundary!...
  result.bitsz = (btsz + 63) and -64; let sz = result.bitsz shr 3
  for ri in 0 ..< WHLHITS:
    result.data[ri] = cast[ptr UncheckedArray[uint8]](
      if zeroed: sz.alloc0 else: sz.alloc)

const WHLPTRNLEN = 11 * 13 * 17 * 19 # product of large wheel primes
let WHLPTRN = (proc (): SieveBuffer =
  # increase size by one cull buffer so as to avoid overflow when filling!
  result = makeSieveBuffer((WHLPTRNLEN + 16384) shl 3, true)
  # contains the wheel index plus the modulo index for 11/13/17/19:
  # or [ 44'u8, 45, 46, 47 ] (all with a -1 wheel index)...
  let ptrnndxdprms = ( proc (): BasePrimeRepArr =
    result = makeBasePrimeRepArr(4)
    for i in 0 ..< 4:
      result.data[i] = 0xFFFFFFC0.BasePrimeRep or (i + 44).BasePrimeRep )()
  var startsarr = makeStartAddrArr(ptrnndxdprms.len)
  cullSieveBuffer(0, ptrnndxdprms.unsafeAddr, startsarr, result) )()
  # ptrnndxdprms and startsarr are never deallocated, but small and run once!!!

proc fillSieveBuffer(lwi: PrimeNdx, sb: var SieveBuffer) =
  let sz = sb.bitsz shr 3; let cpysz = min(16384, sz); let mdlo0 = lwi shr 3
  for ri in 0 ..< WHLHITS:
    let dst = sb.data[ri]; let src = WHLPTRN.data[ri]
    for i in countup(0, sz - 1, 16384):
      let mdlo = ((mdlo0 + i) mod WHLPTRNLEN.PrimeNdx).int
      copyMem(dst[i].addr, src[mdlo].unsafeAddr, cpysz)

func countSieveBuffer(bitlmt: int; sb: ptr SieveBuffer): int = # sb in even 64-bits!
  let lstwi = bitlmt div WHLODDCRC; let lstri = WHLNDXS[bitlmt - lstwi * WHLODDCRC]
  when int.sizeof == 8:
    let lst = (lstwi shr 3) and -8
    result = (lst * 8 + 64) * WHLHITS; let lstm = lstwi and 63
    for ri in 0 ..< WHLHITS:
      let plna = cast[int](sb.data[ri]); let plnlmta = plna + lst
      for vp in countup(plna, plnlmta - 8, 8): result -= cast[ptr uint64](vp)[].popcount
      let msk = (if ri <= lstri: 0'u64 - 2'u64 else: 0'u64 - 1'u64) shl lstm
      result -= (cast[ptr uint64](plnlmta)[] or msk).popcount
  else:
    let lst = (lstwi shr 3) and -4
    result = (lst * 8 + 32) * WHLHITS; let lstm = lstwi and 31
    for ri in 0 ..< WHLHITS:
      let plna = cast[int](sb.data[ri]); let plnlmta = plna + lst
      for vp in countup(plna, plnlmta - 4, 4): result -= cast[ptr uint32](vp)[].popcount
      let msk = (if ri <= lstri: 0'u32 - 2'u32 else: 0'u32 - 1'u32) shl lstm
      result -= (cast[ptr uint32](plnlmta)[] or msk).popcount

echo countSieveBuffer(WHLPTRNLEN * WHLODDCRC - 1, WHLPTRN.unsafeAddr) # should be 1658880

proc sieve(lmt: Prime; cache: int; numprcs: int;
           isCancelled: proc(prg: float64): bool {.closure.};
           doneCancelled: proc() {.closure.},
           doneCompleted: proc(cnt: PrimeNdx) {.closure.}) =
  var count = 0.PrimeNdx
  for p in WHLPRMS: (if p > lmt: break else: count += 1)

  if lmt >= FRSTSVPRM:
    let bparr = (proc (): BasePrimeRepArr =
      let sqrtlmt = (lmt.float64.sqrt.Prime - FRSTSVPRM).int shr 1
      let rqrdszbits = (sqrtlmt + WHLODDCRC - 1) div WHLODDCRC + 1
      var cmpsts = makeSieveBuffer(rqrdszbits)
      let szbits = cmpsts.bitsz; fillSieveBuffer(0, cmpsts)
      # after a fill, the first 2 wheels contain only primes to 439 inclusive:
      # sufficient to sieve to base prime of 439^2 + 1 is 192722, which is enough
      # to sieve to a range of this squared is 37141769284 (sufficient for now)!
      var ndxdrsds = makeBasePrimeRepArr(2 * RESIDUES.len)
      for i in 0 ..< ndxdrsds.len:
        let id = i div WHLHITS; let im = i - id * WHLHITS
        ndxdrsds.data[i] = (id shl 6).BasePrimeRep or im.BasePrimeRep
      var ndxdrsdsstrts = makeStartAddrArr(ndxdrsds.len)
      cullSieveBuffer(0, ndxdrsds.addr, ndxdrsdsstrts, cmpsts)
      let len = countSieveBuffer(szbits * WHLODDCRC - 1, cmpsts.addr)
      result = makeBasePrimeRepArr(len); var j = 0
      for i in 0 ..< szbits:
        for ri in 0 ..< WHLHITS:
          if (cmpsts.data[ri][i shr 3] and BITMASK[i and 7]) == 0'u8:
            result.data[j] = (i.BasePrimeRep shl 6) or ri.BasePrimeRep
            j.inc
      ndxdrsdsstrts.data.dealloc; ndxdrsds.data.dealloc
      for ri in 0 ..< WHLHITS: cmpsts.data[ri].dealloc
    )()

    proc jobthrd(tc: ptr ThrdCntxt) {.thread, nimcall.} =
      {.gcsafe.}:
        tc.strtlck.withLock:
          tc.fnshdlck.withLock: tc.fnshdjob.signal
          while true:
            tc.strtjob.wait tc.strtlck
            if tc.stop != 0: break
            fillSieveBuffer(tc.lwi, tc.cmpsts)
            cullSieveBuffer(tc.lwi, tc.bpra, tc.strts, tc.cmpsts)
            tc.cnt = countSieveBuffer(tc.lstndx, tc.cmpsts.addr)
            tc.fnshdlck.withLock: tc.fnshdjob.signal

    # start the threadpool with its thread contexts...
    let thrds = (proc(): ThreadPool =
      result.sz = numprcs
      result.data =
        cast[ptr UncheckedArray[ThrdCntxt]](createU(ThrdCntxt, numprcs))
      for i in 0 ..< numprcs:
        let tc = result.data[i].addr
        tc[] = ThrdCntxt()
        tc.lstndx = cache * WHLODDCRC - 1
        tc.cmpsts = makeSieveBuffer(cache)
        tc.bpra = bparr.unsafeAddr
        tc.strts = makeStartAddrArr(bparr.len)
        tc.strtjob.initCond; tc.strtlck.initLock
        tc.fnshdjob.initCond; tc.fnshdlck.initLock
        tc.strtlck.acquire; tc.fnshdlck.acquire
        createThread(tc.thrd, jobthrd, tc)
        tc.strtlck.release; tc.fnshdjob.wait tc.fnshdlck)()

    let lmtndx = ((lmt - FRSTSVPRM) shr 1).PrimeNdx
    let lwilmt = lmtndx div WHLODDCRC

    var lwiin = 0.PrimeNdx # give thread pool initial work!
    for ti in 0 ..< numprcs:
      if lwiin > lmtndx: break
      let nxti = lwiin + cache
      let tc = thrds.data[ti].addr
      if nxti >= lmtndx:
        tc.lstndx = (lmtndx - lwiin * WHLODDCRC).int - 1
      tc.lwi = lwiin
      tc.strtlck.withLock: tc.strtjob.signal
      lwiin = nxti

    # set next progress time in a tenth of a second...
    var prgtm = epochTime() + 0.1
    var cncld = false

    # retrieve finished work and feed thread pool...
    var thrdi = 0
    for lwi in countup(0.PrimeNdx, lwilmt, cache):
      # every set interval, do progress update and check if cancelled...
      let curtm = epochTime()
      if curtm >= prgtm:
        while prgtm <= curtm: prgtm += 0.1
        if isCancelled(lwi.float64 / lwilmt.float64):
          for tlwi in countup(lwi, lwiin - 1, cache): # wait for working threads to finish!
            let ttc = thrds.data[thrdi].addr; ttc.fnshdjob.wait ttc.fnshdlck # throw away answer
            thrdi = if thrdi >= numprcs - 1: 0 else: thrdi.succ # ready in case there are more
          doneCancelled(); cncld = true; break

      let tc = thrds.data[thrdi].addr
      tc.fnshdjob.wait tc.fnshdlck
      count += tc.cnt

      let nxti = (lwiin + cache) * WHLODDCRC
      if nxti > lmtndx: # check if on last, if so adjust count limit...
        tc.lstndx = (lmtndx - lwiin * WHLODDCRC).int
      if lwiin <= lwilmt: # check if there is more to process; if so, do it...
        tc.lwi = lwiin; lwiin += cache; tc.strtlck.withLock: tc.strtjob.signal        
      thrdi = if thrdi >= numprcs - 1: 0 else: thrdi.succ # advance round robin thread pool index

    # manual memory managment stop threads and dealloc...
    for i in 0 ..< numprcs:
      let tc = thrds.data[i].addr
      tc.stop = 1; tc.strtlck.withLock: tc.strtjob.signal # kill pool threads
      tc.thrd.joinThread
      tc.strtjob.deinitCond; tc.strtlck.deinitLock
      tc.fnshdjob.deinitCond; tc.fnshdlck.deinitLock
      tc.strts.data.dealloc
      for ri in 0 ..< WHLHITS: tc.cmpsts.data[ri].dealloc
    thrds.data.dealloc; bparr.data.dealloc

    if not cncld: doneCompleted(count)

## global vars that store pointers so they don't need to be recomputed
type
  BckgrndThrdCntxt = ptr BckgrndThrdCntxtObject
  BckgrndThrdCntxtObject = object
    thrd: Thread[BckgrndThrdCntxt]
    vmp: JavaVMPtr
    clzref: JClass
    instcref: jobject
    lmt: Prime
    cchsz: int
    nmprcs: int

# destroy a BckgrndThrdContxt properly...
proc destroyBckgrndThrdCntxt(envp: JNIEnvPtr; btc: BckgrndThrdCntxt) =
  if btc.clzref != nil: envp.DeleteGlobalRef(envp, btc.clzref)
  if btc.instcref != nil: envp.DeleteGlobalRef(envp, btc.instcref)
  btc.clzref = nil; btc.instcref = nil # mark deleted ref's as cleared!
  if btc != nil: btc.dealloc

## the actual background thread program...
proc primesBench(btc: BckgrndThrdCntxt) {.thread, nimcall.} =
  {.gcsafe.}:
    var envp: JNIEnvPtr
    var res = btc.vmp.GetEnv(btc.vmp, cast[ptr pointer](envp.addr), JNI_VERSION_1_6)
    if res != JNI_OK:
      res = btc.vmp.AttachCurrentThread(btc.vmp, cast[ptr pointer](envp.addr), nil)
      if res != JNI_OK:
        echo "failed to attach current thread; error code:  ", res
        destroyBckgrndThrdCntxt(envp, btc); return

    # get mainActivity method id's...
    let progressId = envp.GetMethodID(envp, btc.clzref, "progressIsCancelled", "(D)Z")
    if progressId == nil:
      echo "failed to get progress id!"; destroyBckgrndThrdCntxt(envp, btc); return
    let cancelledId = envp.GetMethodID(envp, btc.clzref, "doneCancelled", "()V")
    if cancelledId == nil:
      echo "failed to get cancelled id!"; destroyBckgrndThrdCntxt(envp, btc); return
    let completedId = envp.GetMethodID(envp, btc.clzref, "doneCompleted", "(J)V")
    if completedId == nil:
      echo "failed to get completed id!"; destroyBckgrndThrdCntxt(envp, btc); return

    sieve(btc.lmt, btc.cchsz, btc.nmprcs,
          proc(x: float64): bool =
            let xjv = x.jdouble.toJValue
            envp.CallBooleanMethodA(envp, btc.instcref,
                                    progressId, xjv.unsafeAddr).bool,
          proc() = envp.CallVoidMethod(envp, btc.instcref, cancelledId),
          proc(cnt: PrimeNdx) =
            let answrjv = cnt.jlong.toJValue
            envp.CallVoidMethodA(envp, btc.instcref, completedId, answrjv.unsafeAddr))

    # destroy things in the thread context that would cause a memory leak...
    discard btc.vmp.DetachCurrentThread(btc.vmp); destroyBckgrndThrdCntxt(envp, btc)

    echo "finished benchmark!"

## The JNI code is called through here, where the sieve proc is called from with
## all appropriate arguments...
proc startPrimesBench*(envp: JNIEnvPtr; instance: jobject;
                  lmt: jlong; cachesz, numprcs: jint) {.cdecl,exportc,dynlib.} =
  echo "got to jni with lmt, cachesz, numprcs ", lmt.Prime, " ", cachesz.int, " ", numprcs.int

  # set up thread context to make it work...
  var btc = create(BckgrndThrdCntxtObject, 1)
  let rc = envp.GetJavaVM(envp, btc.vmp.addr)
  if rc != JNI_OK:
    echo "failed to get Java Virtual Machine pointer!"; destroyBckgrndThrdCntxt(envp, btc); return
  let clz = envp.GetObjectClass(envp, instance)
  if clz == nil: echo "failed to get class!"; destroyBckgrndThrdCntxt(envp, btc); return
  btc.clzref = cast[JClass](envp.NewGlobalRef(envp, clz))
  if btc.clzref == nil:
    echo "failed to get global ref of class!"; destroyBckgrndThrdCntxt(envp, btc); return
  btc.instcref = envp.NewGlobalRef(envp, instance)
  if btc.instcref == nil:
    echo "failed to get global ref of instance!"; destroyBckgrndThrdCntxt(envp, btc); return

  # set up call parameters...
  btc.lmt = lmt.Prime
  btc.cchsz = cachesz.int
  btc.nmprcs = numprcs.int

  # start background thread here...
  createThread(btc.thrd, primesBench, btc)

  if btc.thrd.running: echo "started background primesBench thread - finished setup"
  else: echo "failed to start background primesBench thread!"; destroyBckgrndThrdCntxt(envp, btc)

proc NimMain() {.importc.} # needed to initialize the GC, memory, and stack, etc.

## Automaticalled called just after the library is loaded...
##
## processing one time initialization:
##     Cache the javaVM into our context
##     Find class ID for JniHelper
##     Create an instance of JniHelper
##     Make global reference since we are using them from a native thread
## Note:
##     All resources allocated here are never released by application
##     we rely on system to free all global refs when it goes away;
##     the pairing function JNI_OnUnload() never gets called at all.
proc JNI_OnLoad*(vmp: JavaVMPtr; reserved: pointer): jint {.cdecl,exportc,dynlib.} =
  NimMain() # won't hurt even when not needed for non-GC memory management!
  echo "got to OnLoad"
  # show ABI
  when defined(i386):
    echo "ABI = x86"
  elif defined(amd64):
    echo "ABI = x86_64"
  elif defined(arm):
    echo "ABI = armeabi-v7a"
  elif defined(arm64):
    echo "ABI = arm64-v8a"
  else:
    echo "ABI = unknown"

  # we may as well save a global reference to the class if required?
  # we could also stash method id's for the class methods we will be using!
  var envp: JNIEnvPtr
  if vmp.GetEnv(vmp, cast[ptr pointer](envp.addr), JNI_VERSION_1_6) != JNI_OK:
    echo "failed to get vm pointer!"; return JNI_ERR # JNI version not supported.
  let clz = envp.FindClass(envp, "com/gordonbgood/sieveoferatosthenesbenchmark/MainActivity")
  if clz == nil: echo "failed to get class!"; return JNI_ERR

  # register JNI called primeBench method proc's here: saves runtime looking them up when needed...
  let jnintvmthd = JNINativeMethod(name: "startPrimesBench", signature: "(JII)V",
                                   fnPtr: cast[pointer](startPrimesBench))
  let rc = envp.RegisterNatives(envp, clz, jnintvmthd.unsafeAddr, 1.jint)
  if rc != JNI_OK: echo "failed to register the primesBench method!"; return rc

  echo "completed OnLoad tasks successfully"
  return JNI_VERSION_1_6
