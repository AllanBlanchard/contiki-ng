include analysis.mk
# Frama-C COMMON #########################################################
FRAMAC     ?= frama-c
FCCOMMONFLAGS += -no-frama-c-stdlib -c11 -cpp-frama-c-compliant -variadic-no-translation -machdep gcc_x86_64
# Frama-C PARSE #########################################################
CPPFLAGS=
CPPFLAGS += ${filter -D% -I%, $(CFLAGS)}
#CPPFLAGS +=-I /usr/lib/gcc/x86_64-linux-gnu/8/include -I /usr/local/include -I /usr/lib/gcc/x86_64-linux-gnu/8/include-fixed -I /usr/include/x86_64-linux-gnu -I /usr/include
#CPPFLAGS += -DAUTOSTART_ENABLE
CPPFLAGS:= ${shell echo ${CPPFLAGS} | sed -r s/\"/'\\\\\\\"'/g}
# Frama-C EACSL #########################################################
include files.mk

%.rte: SOURCES = $(SRCFILES)
%.rte: PARSE = $(FRAMAC) -no-warn-invalid-bool $(FCCOMMONFLAGS) -e-acsl-prepare -rte -cpp-extra-args="$(CPPFLAGS)" $(SOURCES) -save $@/framac.save -print -ocode $@/framac.c -then -no-print
%.rte:
	@mkdir -p $@
	$(PARSE)
	@touch $@ # Update timestamp and prevents remake if nothing changes
	@echo $(PARSE)

rte: $(TARGET).rte

$(TARGET).rte: $(CONTIKI_SOURCEFILES)\
				 $(PROJECT_SOURCEFILES)\
				 $(FC_PROJECT_FILES)

FULLMMODEL=-e-acsl-full-mmodel
%.eacsl: EACSLCMD = $(FRAMAC) $(FCCOMMONFLAGS) native.rte/framac.c -e-acsl $(FULLMMODEL) -then-last -print -ocode $@/framac.c

eacsl: rte $(TARGET).eacsl

$(TARGET).eacsl:
	@mkdir -p $@
	$(EACSLCMD)
	@touch $@ # Update timestamp and prevents remake if nothing changes
	@echo $(EACSLCMD)

parse: $(TARGET).parse

%.parse: SOURCES = $(SRCFILES)
%.parse: PARSE = $(FRAMAC) -no-warn-invalid-bool $(FCCOMMONFLAGS) -cpp-extra-args="$(CPPFLAGS)" $(SOURCES) -save $@/framac.save -print -ocode $@/framac.c -then -no-print
%.parse:
	@mkdir -p $@
	$(PARSE)
	@echo $(PARSE)
