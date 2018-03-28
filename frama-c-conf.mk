# For Frama-C #########################################################
include analysis.mk

FRAMA_C_PATH=$(shell frama-c -print-share-path)
FRAMA_C_SCRIPTS_PATH=$(FRAMA_C_PATH)/analysis-scripts

CPPFLAGS=-I/usr/lib/arm-none-eabi/include
CPPFLAGS += ${filter -D% -I%, $(CFLAGS)}
CPPFLAGS += -DAUTOSTART_ENABLE
CPPFLAGS += -D__ARM_ARCH=7

CPPFLAGS:= ${shell echo ${CPPFLAGS} | sed -r s/\"/'\\\\\\\"'/g}

# FCFLAGS += -no-frama-c-stdlib
FCFLAGS += -kernel-warn-feedback "CERT:MSC:38"

# Does not work :/ 
# SLEVEL	  = 	-slevel=500

EVAFLAGS +=	-slevel=500
EVAFLAGS += 	-eva-equality-domain
EVAFLAGS +=	-eva-gauges-domain
EVAFLAGS += 	-val-warn-on-alarms
EVAFLAGS += 	-no-val-print-callstacks
EVAFLAGS += 	-plevel=1000
EVAFLAGS +=	-context-width=1500 # Max size allocated in memb for rpl-udp
EVAFLAGS +=	-context-depth=100  # The execution time is not really impacted
# EVAFLAGS +=	-context-valid-pointers


# A lot of pointer comparison warnings are (a priori) false alarms due
# to an imprecision with memb/list
EVAGLAGS += 	-undefined-pointer-comparison-propagate-all
# EVAFLAGS += 	-val-warn-undefined-pointer-comparison=pointer

# EVAFLAGS +=	-val-use-spec=memb_init,memb_alloc,memb_free
EVAFLAGS +=	-val-malloc-functions=memb_alloc

# To ignore recursivity of the scheduling process (unsound)
# EVAFLAGS += 	-val-ignore-recursive-calls

EVABUILTINS= 	memset:Frama_C_memset\
		memcpy:Frama_C_memcpy\
		memb_alloc:Frama_C_malloc_by_stack

include $(FRAMA_C_SCRIPTS_PATH)/frama-c.mk

frama-c.parse: ${SUB}_${TARGET}.parse
	@
frama-c.eva: ${SUB}_${TARGET}.eva
	@
frama-c.slevel.eva: ${SUB}_${TARGET}.slevel.eva
	@
frama-c.eva.gui: ${SUB}_${TARGET}.eva.gui
	@

${SUB}_${TARGET}.parse:		$(CONTIKI_SOURCEFILES)\
				$(PROJECT_SOURCEFILES)\
				$(FC_PROJECT_FILES)\
				$(CONTIKI)/arch/cpu/cc2538/startup-gcc.c
#######################################################################
