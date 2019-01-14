include analysis.mk
M ?= 64
# Frama-C COMMON #########################################################
FRAMAC     ?= frama-c
FCCOMMONFLAGS += -no-frama-c-stdlib -c11 -cpp-frama-c-compliant -variadic-no-translation -machdep gcc_x86_$(M)
# Frama-C PARSE #########################################################
CPPFLAGSTEMPO=
CPPFLAGSTEMPO += ${filter -D% -I%, $(CFLAGS)}
CPPFLAGS=$(filter-out -DCLASSNAME=,$(CPPFLAGSTEMPO))
CPPFLAGS:= ${shell echo ${CPPFLAGS} | sed -r s/\"/'\\\\\\\"'/g}
# Frama-C EACSL #########################################################
include files.mk

##############################################################
MORERTE = -warn-signed-overflow -warn-signed-downcast
#MORERTE=-warn-unsigned-downcast -warn-unsigned-overflow
MORERTE += -rte-div -rte-float-to-int -rte-mem -rte-pointer-call -rte-shift -rte-no-trivial-annotations
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


FULLMMODEL=-e-acsl-full-mmodel
%.eacsl: EACSLCMD = $(FRAMAC) $(FCCOMMONFLAGS) native.rte/framac.c -e-acsl $(FULLMMODEL) -then-last -print -ocode $@/framac.c

eacsl: rte $(TARGET).eacsl

$(TARGET).eacsl:
	@mkdir -p $@
	$(EACSLCMD)
	@touch $@ # Update timestamp and prevents remake if nothing changes
	@echo $(EACSLCMD)

##############################################################
%.total: SOURCES = $(SRCFILES)
%.total: TOTALCMD = $(FRAMAC) -no-warn-invalid-bool $(FCCOMMONFLAGS) -e-acsl-prepare -rte $(MORERTE) -cpp-extra-args="$(CPPFLAGS)" $(SOURCES) -then -e-acsl $(FULLMMODEL) -then-last -print -ocode $@/framac.c

total: $(TARGET).total

$(TARGET).total:
	@mkdir -p $@
	$(TOTALCMD)
	@touch $@ # Update timestamp and prevents remake if nothing changes
	@echo $(TOTALCMD)

##############################################################
parse: $(TARGET).parse

%.parse: SOURCES = $(SRCFILES)
%.parse: PARSE = $(FRAMAC) -no-warn-invalid-bool $(FCCOMMONFLAGS) -cpp-extra-args="-I'/usr/lib/jvm/default-java/include' -I'/usr/lib/jvm/default-java/include/linux' -fno-builtin-printf -fPIC -Wall -g -I/usr/local/include -DCLASSNAME=Lib1 -Werror $(CPPFLAGS)" $(SOURCES) -save $@/framac.save -print -ocode $@/framac.c -then -no-print
%.parse:
	@mkdir -p $@
	$(PARSE)
	@echo $(PARSE)

##############################################################
N ?= 193
LIBNAME ?= mtype$(N)
n: parse
	@echo $(LIBNAME)
	#mv platform.o build/cooja///$(LIBNAME).o
	#objcopy --redefine-sym printf=log_printf test-ringbufindex.o;   objcopy --redefine-sym printf=log_printf build/cooja///$(LIBNAME).o;   objcopy --redefine-sym printf=log_printf build/cooja///$(LIBNAME).a;
	#objcopy --redefine-sym puts=log_puts test-ringbufindex.o;   objcopy --redefine-sym puts=log_puts build/cooja///$(LIBNAME).o;   objcopy --redefine-sym puts=log_puts build/cooja///$(LIBNAME).a;
	#objcopy --redefine-sym putchar=log_putchar test-ringbufindex.o;   objcopy --redefine-sym putchar=log_putchar build/cooja///$(LIBNAME).o;   objcopy --redefine-sym putchar=log_putchar build/cooja///$(LIBNAME).a;
	#gcc -I'/usr/lib/jvm/default-java/include' -I'/usr/lib/jvm/default-java/include/linux' -shared -Wl,-Map=build/cooja/$(LIBNAME).map -o build/cooja/$(LIBNAME).cooja test-ringbufindex.o build/cooja///$(LIBNAME).o build/cooja///$(LIBNAME).a
#	cp build/cooja///$(LIBNAME).cooja test-ringbufindex.cooja
#	rm test-ringbufindex.o
