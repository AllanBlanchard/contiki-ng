include analysis.mk
M ?= 64
# Frama-C COMMON #########################################################
FRAMAC     ?= frama-c
FCCOMMONFLAGS += -no-frama-c-stdlib -c11 -cpp-frama-c-compliant -variadic-no-translation -machdep gcc_x86_$(M)
FRAMACSHARE ?= $(shell $(FRAMAC) -print-share-path)
# Frama-C PARSE #########################################################
CPPFLAGSTEMPO=
CPPFLAGSTEMPO += ${filter -D% -I%, $(CFLAGS)}
CPPFLAGS=$(CPPFLAGSTEMPO)
CPPFLAGS:= ${shell echo ${CPPFLAGS} | sed -r s/\"/'\\\\\\\"'/g} $(SPECIFIC_OPT)
# Frama-C EACSL #########################################################

include files.mk

##############################################################

MORERTE=-warn-signed-overflow -warn-signed-downcast -rte-div -rte-float-to-int -rte-mem -rte-pointer-call -rte-shift -rte-no-trivial-annotations

%.rte: SOURCES = $(SRCFILES)
%.rte: PARSE = $(FRAMAC) -no-warn-invalid-bool $(FCCOMMONFLAGS) -e-acsl-prepare -rte $(MORERTE) -cpp-extra-args="$(CPPFLAGS)" $(SOURCES) -save $@/framac.save -print -ocode $@/framac.c -then -no-print
%.rte:
	@mkdir -p $@
	$(PARSE)
	@touch $@ # Update timestamp and prevents remake if nothing changes
	@echo $(PARSE)

rte: $(TARGET).rte

$(TARGET).rte: $(CONTIKI_SOURCEFILES)\
	$(PROJECT_SOURCEFILES)\
	$(FC_PROJECT_FILES)


##############################################################

eacsl: rte $(TARGET).eacsl

FULLMMODEL=-e-acsl-full-mmodel

%.eacsl: EACSLCMD = $(FRAMAC) $(FCCOMMONFLAGS) native.rte/framac.c -e-acsl $(FULLMMODEL) -then-last -print -ocode $@/framac.c
$(TARGET).eacsl:
	@mkdir -p $@
	$(EACSLCMD)
	@touch $@ # Update timestamp and prevents remake if nothing changes
	@echo $(EACSLCMD)

##############################################################

EACSL_RTL=$(FRAMACSHARE)/e-acsl/e_acsl_rtl.c
EACSL_LD_FLAGS=-L/usr/local/lib
EACSL_LIBS=-leacsl-dlmalloc -leacsl-gmp -lm
EACSL_INCLUDES=-I$(FRAMACSHARE)/e-acsl/
EACSL_CONFIG=-DE_ACSL_SEGMENT_MMODEL -DE_ACSL_STACK_SIZE=32 -DE_ACSL_HEAP_SIZE=128
EACSL_CFLAGS=-std=c99 -m64 -fno-builtin -fno-merge-constants -Wall -Wno-long-long -Wno-attributes -Wno-nonnull -Wno-undef -Wno-unused -Wno-unused-function -Wno-unused-result -Wno-unused-value -Wno-unused-function -Wno-unused-variable -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-empty-body

eacsl_exec: eacsl $(TARGET).eacsl_exec

$(TARGET).eacsl_exec:
	gcc -o $@ $(TARGET).eacsl/framac.c $(EACSL_RTL) $(EACSL_INCLUDES) $(EACSL_LD_FLAGS) $(EACSL_LIBS) $(EACSL_CONFIG) $(CFLAGS) $(EACSL_CFLAGS)

clean::
	rm -rf $(TARGET).eacsl $(TARGET).rte $(TARGET).eacsl_exec