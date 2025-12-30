LDVERSION= $(shell $(PIC_LD) -v | grep -q 2.30 ;echo $$?)
ifeq ($(LDVERSION), 0)
     LD_NORELAX_FLAG= --no-relax
endif

ARCHIVE_OBJS=
ARCHIVE_OBJS += _22206_archive_1.so
_22206_archive_1.so : archive.3/_22206_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -Bsymbolic $(LD_NORELAX_FLAG)  -o .//../simv.daidir//_22206_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../simv.daidir//_22206_archive_1.so $@




VCS_CU_ARC_OBJS = 


O0_OBJS =

$(O0_OBJS) : %.o: %.c
	$(CC_CG) $(CFLAGS_O0) -c -o $@ $<


%.o: %.c
	$(CC_CG) $(CFLAGS_CG) -c -o $@ $<
CU_UDP_OBJS = \
objs/udps/iJuDZ.o objs/udps/Nginy.o objs/udps/QRIPd.o objs/udps/U9Crq.o objs/udps/eLUxc.o  \
objs/udps/Tcvek.o objs/udps/i0psV.o objs/udps/TB6Ix.o objs/udps/aLBRD.o objs/udps/V7WvH.o  \
objs/udps/FqLFq.o objs/udps/yz1uR.o objs/udps/RUKVA.o objs/udps/afYMY.o objs/udps/fsCp2.o  \
objs/udps/USMy8.o objs/udps/PSwnp.o objs/udps/f0xYg.o objs/udps/tw5vQ.o objs/udps/qwM0m.o  \
objs/udps/KME4Y.o objs/udps/h5bqa.o objs/udps/Gdmn6.o objs/udps/U6qjI.o objs/udps/DtgyT.o  \
objs/udps/K79QG.o objs/udps/dUm5G.o objs/udps/ymc5r.o objs/udps/AENcr.o objs/udps/wIL7Z.o  \
objs/udps/uQKHy.o objs/udps/dxA5k.o objs/udps/iYgyp.o 

CU_LVL_OBJS = \
SIM_l.o 

MAIN_OBJS = \
objs/amcQw_d.o 

CU_OBJS = $(MAIN_OBJS) $(ARCHIVE_OBJS) $(CU_UDP_OBJS) $(CU_LVL_OBJS)

