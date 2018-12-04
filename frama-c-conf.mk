include analysis.mk
FRAMAC     ?= frama-c
FCCOMMONFLAGS += -no-frama-c-stdlib -c11 -cpp-frama-c-compliant -variadic-no-translation -machdep gcc_x86_64
# Frama-C PARSE #########################################################
CPPFLAGS=
CPPFLAGS += ${filter -D% -I%, $(CFLAGS)}
#CPPFLAGS +=-I /usr/lib/gcc/x86_64-linux-gnu/8/include -I /usr/local/include -I /usr/lib/gcc/x86_64-linux-gnu/8/include-fixed -I /usr/include/x86_64-linux-gnu -I /usr/include
#CPPFLAGS += -DAUTOSTART_ENABLE
CPPFLAGS:= ${shell echo ${CPPFLAGS} | sed -r s/\"/'\\\\\\\"'/g}

FCPARSEFLAGS += -no-frama-c-stdlib -c11 -cpp-frama-c-compliant -variadic-no-translation $(FCCOMMONFLAGS) -e-acsl-prepare -rte # -then -e-acsl
#FCPARSEFLAGS += -kernel-warn-feedback "CERT:MSC:38"

%.parse: SOURCES = $(filter-out %/command,$^)
%.parse: PARSE = $(FRAMAC) -no-warn-invalid-bool $(FCCOMMONFLAGS) -e-acsl-prepare -rte -cpp-extra-args="$(CPPFLAGS)" $(SOURCES) -save $@/framac.save -print -ocode $@/framac.c -then -no-print
%.parse:
	@mkdir -p $@
	$(PARSE)
	@touch $@ # Update timestamp and prevents remake if nothing changes
	@echo $(PARSE)

parse: $(TARGET).parse

$(TARGET).parse: $(CONTIKI_SOURCEFILES)\
				 $(PROJECT_SOURCEFILES)\
				 $(FC_PROJECT_FILES)

%.eacsl: EACSLCMD = $(FRAMAC) $(FCCOMMONFLAGS) native.parse/framac.c -e-acsl -then-last -print -ocode $@/framac.c

eacsl: parse $(TARGET).eacsl

$(TARGET).eacsl:
	@mkdir -p $@
	$(EACSLCMD)
	@touch $@ # Update timestamp and prevents remake if nothing changes
	@echo $(EACSLCMD)
