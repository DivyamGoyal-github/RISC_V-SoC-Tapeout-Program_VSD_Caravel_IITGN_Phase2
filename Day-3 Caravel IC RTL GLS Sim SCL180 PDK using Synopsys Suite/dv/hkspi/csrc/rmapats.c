// file = 0; split type = patterns; threshold = 100000; total count = 0.
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "rmapats.h"

void  schedNewEvent (struct dummyq_struct * I1403, EBLK  * I1398, U  I624);
void  schedNewEvent (struct dummyq_struct * I1403, EBLK  * I1398, U  I624)
{
    U  I1667;
    U  I1668;
    U  I1669;
    struct futq * I1670;
    struct dummyq_struct * pQ = I1403;
    I1667 = ((U )vcs_clocks) + I624;
    I1669 = I1667 & ((1 << fHashTableSize) - 1);
    I1398->I666 = (EBLK  *)(-1);
    I1398->I667 = I1667;
    if (0 && rmaProfEvtProp) {
        vcs_simpSetEBlkEvtID(I1398);
    }
    if (I1667 < (U )vcs_clocks) {
        I1668 = ((U  *)&vcs_clocks)[1];
        sched_millenium(pQ, I1398, I1668 + 1, I1667);
    }
    else if ((peblkFutQ1Head != ((void *)0)) && (I624 == 1)) {
        I1398->I669 = (struct eblk *)peblkFutQ1Tail;
        peblkFutQ1Tail->I666 = I1398;
        peblkFutQ1Tail = I1398;
    }
    else if ((I1670 = pQ->I1306[I1669].I689)) {
        I1398->I669 = (struct eblk *)I1670->I687;
        I1670->I687->I666 = (RP )I1398;
        I1670->I687 = (RmaEblk  *)I1398;
    }
    else {
        sched_hsopt(pQ, I1398, I1667);
    }
}
void  rmaPropagate37_simv_daidir (UB  * pcode, scalar  val)
{
    UB  * I1737;
    *(pcode + 0) = val;
    *(pcode + 1) = X4val[val];
    {
        scalar  I1626;
        scalar  I1141;
        U  I1581;
        US  I235;
        I1141 = X3val[val];
        I1626 = *(pcode + 2);
        I235 = (I1626 << 2) + I1141;
        I1581 = 1 << I235;
        if (I1581 & 18) {
            if (I1581 & 16) {
                (*(FP  *)(pcode + 8))(*(void **)(pcode + 16), I235);
            }
        }
        else {
            U  I1485;
            U  I650;
            U  I1661;
            U  * I1663;
            UB  * pcode1;
            pcode1 = (UB  *)(*(UP  *)(pcode + 16) & ~3);
            I650 = *(U  *)pcode1;
            I1663 = (U  *)(pcode1 + sizeof(U ));
            I1661 = (I650 + 31) >> 5;
            pcode1 += sizeof(U ) * (1 + I1661);
            for (I1485 = 0; I1485 < I1661; I1485++) {
                if (I1485 == I1661 - 1 && (I650 % 32)) {
                    I1663[I1485] = (1 << (I650 % 32)) - 1;
                }
                else {
                    I1663[I1485] = (U )-1;
                }
            }
            pcode1 = (UB  *)((((RP )pcode1) + 7) & (~7));
            for (; I650 > 0; I650--) {
                (*(FP  *)(pcode1))(*(void **)(pcode1 + 8LU), I235);
                pcode1 += 16;
            }
        }
        *(pcode + 2U) = I1141;
    }
    pcode += 24;
    {
        EBLK  * I1398;
        *((*(UB  **)(pcode + 8)) + 1) = X4val[val];
        I1398 = (EBLK  *)(pcode + 0);
        if (I1398->I666 == 0) {
            struct dummyq_struct * pQ;
            U  I1401;
            I1401 = 0;
            pQ = (struct dummyq_struct *)ref_vcs_clocks;
            EBLK  * I1596 = (EBLK  *)pvcsGetLastEventEblk(I1401);
            I1398->I666 = pQ->I1333;
            pQ->I1333 = I1398;
            {
                (pQ->semilerOptQueuesFlag |= (0x1 << 2));
            }
            if (0 && rmaProfEvtProp) {
                vcs_simpSetEBlkEvtID(I1398);
            }
            I1398 = I1596;
            if (!(I1398->I666)) {
                if ((semilerOpt != 0) && (I1596 == I1398)) {
                }
                else {
                    pQ->I1322->I666 = I1398;
                    pQ->I1322 = I1398;
                }
                I1398->I666 = ((EBLK  *)-1);
                if (0 && rmaProfEvtProp) {
                    vcs_simpSetEBlkEvtID(I1398);
                }
            }
        }
    }
    pcode += 40;
    UB  * I742 = *(UB  **)(pcode + 0);
    if (I742 != (UB  *)(pcode + 0)) {
        RmaSwitchGate  * I1764 = (RmaSwitchGate  *)I742;
        RmaSwitchGate  * I956 = 0;
        do {
            RmaIbfPcode  * I1093 = (RmaIbfPcode  *)(((UB  *)I1764) + 24U);
            ((FP )(I1093->I1093))((void *)I1093->pcode, val);
            RmaDoublyLinkedListElem  I1765;
            I1765.I956 = 0;
            RmaSwitchGateInCbkListInfo  I1766;
            I1766.I1250 = 0;
            I956 = (RmaSwitchGate  *)I1764->I639.I1767.I956;
        } while ((UB  *)(I1764 = I956) != (UB  *)I742);
    }
}
void  rmaPropagate37_t0_simv_daidir (UB  * pcode, UB  val)
{
    val = *(pcode + 0);
    *(pcode + 0) = 0xff;
    rmaPropagate37_simv_daidir(pcode, val);
}
void  rmaPropagate40_simv_daidir (UB  * pcode, scalar  val)
{
    UB  * I1737;
    *(pcode + 0) = val;
    pcode += 8;
    UB  * I742 = *(UB  **)(pcode + 0);
    if (I742 != (UB  *)(pcode + 0)) {
        RmaSwitchGate  * I1764 = (RmaSwitchGate  *)I742;
        RmaSwitchGate  * I956 = 0;
        do {
            RmaIbfPcode  * I1093 = (RmaIbfPcode  *)(((UB  *)I1764) + 24U);
            ((FP )(I1093->I1093))((void *)I1093->pcode, val);
            RmaDoublyLinkedListElem  I1765;
            I1765.I956 = 0;
            RmaSwitchGateInCbkListInfo  I1766;
            I1766.I1250 = 0;
            I956 = (RmaSwitchGate  *)I1764->I639.I1767.I956;
        } while ((UB  *)(I1764 = I956) != (UB  *)I742);
    }
}
#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
