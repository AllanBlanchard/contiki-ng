# For Frama-C #########################################################
include analysis.mk

CPPFLAGS=
CPPFLAGS += ${filter -D% -I%, $(CFLAGS)}
#CPPFLAGS +=-I /usr/lib/gcc/x86_64-linux-gnu/8/include -I /usr/local/include -I /usr/lib/gcc/x86_64-linux-gnu/8/include-fixed -I /usr/include/x86_64-linux-gnu -I /usr/include
#CPPFLAGS += -DAUTOSTART_ENABLE
CPPFLAGS:= ${shell echo ${CPPFLAGS} | sed -r s/\"/'\\\\\\\"'/g}

FCFLAGS += -no-frama-c-stdlib -c11 -cpp-frama-c-compliant -variadic-no-translation -machdep gcc_x86_64 -e-acsl-prepare -rte # -then -e-acsl
#FCFLAGS += -kernel-warn-feedback "CERT:MSC:38"

FRAMAC     ?= frama-c

%.parse: SOURCES = $(filter-out %/command,$^)
%.parse: PARSE = $(FRAMAC) $(FCFLAGS) -cpp-extra-args="$(CPPFLAGS)" $(SOURCES) -print -ocode $@/framac.c -then -no-print
%.parse:
	@mkdir -p $@
	$(PARSE)
	@touch $@ # Update timestamp and prevents remake if nothing changes
	@echo $(PARSE)

fc: $(TARGET).parse

$(TARGET).parse: $(CONTIKI_SOURCEFILES)\
				 $(PROJECT_SOURCEFILES)\
				 $(FC_PROJECT_FILES)
#######################################################################
