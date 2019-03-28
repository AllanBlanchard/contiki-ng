include analysis.mk
M ?= 64
# Frama-C COMMON #########################################################
FRAMAC     ?= frama-c
FCCOMMONFLAGS += -no-frama-c-stdlib -c11 -cpp-frama-c-compliant -variadic-no-translation -machdep gcc_x86_$(M)
# Frama-C PARSE #########################################################
CPPFLAGSTEMPO=
CPPFLAGSTEMPO += ${filter -D% -I%, $(CFLAGS)}
CPPFLAGS=$(CPPFLAGSTEMPO)
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
FILTEREDSRCFILES=$(filter-out test-ringbufindex.c,$(SRCFILES))

%.total: SOURCES = $(FILTEREDSRCFILES)
%.total: TOTALCMD = $(FRAMAC) -no-warn-invalid-bool $(FCCOMMONFLAGS) -e-acsl-prepare -rte $(MORERTE) -cpp-extra-args="-I'/usr/lib/jvm/default-java/include' -I'/usr/lib/jvm/default-java/include/linux' -fno-builtin-printf -fPIC -Wall -g -I/usr/local/include -DCLASSNAME=Lib1 -Werror $(CPPFLAGS)" $(SOURCES) -then -e-acsl $(FULLMMODEL) -then-last -print -ocode $@/framac.c

total: $(TARGET).total

$(TARGET).total:
	@mkdir -p $@
	$(TOTALCMD)
	@touch $@ # Update timestamp and prevents remake if nothing changes
	@echo $(TOTALCMD)

##############################################################
parse: $(TARGET).parse

%.parse: SOURCES = $(FILTEREDSRCFILES)
%.parse: PARSE = $(FRAMAC) -no-warn-invalid-bool $(FCCOMMONFLAGS) -cpp-extra-args="-I'/usr/lib/jvm/default-java/include' -I'/usr/lib/jvm/default-java/include/linux' -fno-builtin-printf -fPIC -Wall -g -I/usr/local/include -DCLASSNAME=Lib1 -Werror $(CPPFLAGS)" $(SOURCES) -save $@/framac.save -print -ocode $@/framac.c -then -no-print
%.parse:
	@mkdir -p $@
	$(PARSE)
	@echo $(PARSE)

##############################################################
N ?= 193
LIBNAME ?= mtype$(N)
n: RESULT=$(TARGET).total/$(LIBNAME)
n: total
	@echo $(LIBNAME)
	cat $(TARGET).total/framac.c $(CONTIKI)/prepare_memory.c $(CONTIKI)/jnimain.c > $(TARGET).total/prepare_framac.c
	#sed -i -e '665,700{s/^/\/\//g}' $(TARGET).total/prepare_framac.c
	sed -i -e '713,743{s/^/\/\//g}' $(TARGET).total/prepare_framac.c
	#sed -i -e 's/typedef char int8_t;/typedef signed char int8_t;/g' $(TARGET).total/prepare_framac.c
	gcc -fPIC -ffunction-sections -fdata-sections -DE_ACSL_SEGMENT_MMODEL -DE_ACSL_STACK_SIZE=32 -DE_ACSL_HEAP_SIZE=128 -std=c99 -m$(M) -g -O0 -fno-builtin -fno-merge-constants -Wno-attributes -DCONTIKI=1 -DCONTIKI_TARGET_COOJA=1 -DCONTIKI_TARGET_STRING=\"cooja\" -Wno-unused-const-variable -DPROJECT_CONF_PATH=\"project-conf.h\" -I'/usr/lib/jvm/default-java/include' -I'/usr/lib/jvm/default-java/include/linux' -fno-builtin-printf -Wall -g -I/usr/local/include -DCLASSNAME=Lib1 -DMAC_CONF_WITH_CSMA=1 -DNETSTACK_CONF_WITH_IPV6=1 -DROUTING_CONF_RPL_LITE=1  -I. -I../../../arch/platform/cooja/. -I../../../arch/platform/cooja/dev -I../../../arch/platform/cooja/lib -I../../../arch/platform/cooja/sys -I../../../arch/platform/cooja/cfs -I../../../arch/platform/cooja/net -I../../../arch -I../../../os/services/unit-test -I../../../os -I../../../os/sys -I../../../os/dev -I../../../os/lib -I../../../os/services -I../../../os -I../../../os/net -I../../../os/net/mac -I../../../os/net/mac/framer -I../../../os/net/routing -I../../../os/storage -I../../../os/net/mac/csma -I../../../os/net/ipv6 -I../../../os/net/routing/rpl-lite -I../../../arch/platform/cooja/ -I../../.. -DCONTIKI_VERSION_STRING=\"Contiki-NG-release/v4.2-173-ge82159a-dirty\" -MMD -o $(RESULT).o -c $(TARGET).total/prepare_framac.c
	gcc -fPIC -ffunction-sections -fdata-sections -DE_ACSL_SEGMENT_MMODEL -DE_ACSL_STACK_SIZE=32 -DE_ACSL_HEAP_SIZE=128 -std=c99 -m$(M) -g -O0 -fno-builtin -fno-merge-constants -Wno-attributes  -DCONTIKI=1 -DCONTIKI_TARGET_COOJA=1 -DCONTIKI_TARGET_STRING=\"cooja\" -Wno-unused-const-variable -DPROJECT_CONF_PATH=\"project-conf.h\" -I'/usr/lib/jvm/default-java/include' -I'/usr/lib/jvm/default-java/include/linux' -fno-builtin-printf -Wall -g -I/usr/local/include -DCLASSNAME=Lib1 -DMAC_CONF_WITH_CSMA=1 -DNETSTACK_CONF_WITH_IPV6=1 -DROUTING_CONF_RPL_LITE=1  -I. -I../../../arch/platform/cooja/. -I../../../arch/platform/cooja/dev -I../../../arch/platform/cooja/lib -I../../../arch/platform/cooja/sys -I../../../arch/platform/cooja/cfs -I../../../arch/platform/cooja/net -I../../../arch -I../../../os/services/unit-test -I../../../os -I../../../os/sys -I../../../os/dev -I../../../os/lib -I../../../os/services -I../../../os -I../../../os/net -I../../../os/net/mac -I../../../os/net/mac/framer -I../../../os/net/routing -I../../../os/storage -I../../../os/net/mac/csma -I../../../os/net/ipv6 -I../../../os/net/routing/rpl-lite -I../../../arch/platform/cooja/ -I../../.. -DCONTIKI_VERSION_STRING=\"Contiki-NG-release/v4.2-173-ge82159a-dirty\" -MMD -o test-ringbufindex.o -c test-ringbufindex.c
	mkdir -p build/cooja/
	ar rcf build/cooja/$(LIBNAME).a $(RESULT).o
	#mv platform.o build/cooja///$(LIBNAME).o
	# LOG_PRINTF
	#objcopy --redefine-sym printf=log_printf build/cooja///$(LIBNAME).o;
	objcopy --redefine-sym printf=log_printf test-ringbufindex.o
	objcopy --redefine-sym printf=log_printf $(RESULT).o
	objcopy --redefine-sym printf=log_printf build/cooja/$(LIBNAME).a
	# LOG_PUTS
	#objcopy --redefine-sym puts=log_puts build/cooja///$(LIBNAME).o;
	objcopy --redefine-sym puts=log_puts test-ringbufindex.o
	objcopy --redefine-sym puts=log_puts $(RESULT).o
	objcopy --redefine-sym puts=log_puts build/cooja/$(LIBNAME).a
	# LOG_PUTCHAR
	#objcopy --redefine-sym putchar=log_putchar build/cooja///$(LIBNAME).o
	objcopy --redefine-sym putchar=log_putchar test-ringbufindex.o
	objcopy --redefine-sym putchar=log_putchar $(RESULT).o
	objcopy --redefine-sym putchar=log_putchar build/cooja/$(LIBNAME).a
	gcc -Wl,--gc-sections -ffunction-sections -fdata-sections -DE_ACSL_SEGMENT_MMODEL -DE_ACSL_STACK_SIZE=32 -DE_ACSL_HEAP_SIZE=128 -std=c99 -m$(M) -g -O0 -fno-builtin -fno-merge-constants -Wall -Wno-long-long -Wno-attributes -Wno-nonnull -Wno-undef -Wno-unused -Wno-unused-function -Wno-unused-result -Wno-unused-value -Wno-unused-function -Wno-unused-variable -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-empty-body -Wl,-Map=$(RESULT).map -I/home/jean/local-frama-c/bin/../share/frama-c/e-acsl/ -shared -o $(RESULT).cooja test-ringbufindex.o build/cooja/$(LIBNAME).a /home/jean/local-frama-c/bin/../share/frama-c/e-acsl//e_acsl_rtl.c /home/jean/local-frama-c/bin/../lib/libeacsl-dlmalloc.a /home/jean/local-frama-c/bin/../lib/libeacsl-gmp.a -lm
	cp $(RESULT).cooja test-ringbufindex.cooja
	cp $(RESULT).map build/cooja/
	cp test-ringbufindex.cooja build/cooja/$(LIBNAME).cooja
	#rm test-ringbufindex.o
##############################################################
o: RESULT=$(TARGET).parse/$(LIBNAME)
o: parse
	@echo $(LIBNAME)
	gcc -fPIC -DCONTIKI=1 -DCONTIKI_TARGET_COOJA=1 -DCONTIKI_TARGET_STRING=\"cooja\" -Wno-unused-const-variable -DPROJECT_CONF_PATH=\"project-conf.h\" -I'/usr/lib/jvm/default-java/include' -I'/usr/lib/jvm/default-java/include/linux' -fno-builtin-printf -Wall -g -I/usr/local/include -DCLASSNAME=Lib1 -DMAC_CONF_WITH_CSMA=1 -DNETSTACK_CONF_WITH_IPV6=1 -DROUTING_CONF_RPL_LITE=1  -I. -I../../../arch/platform/cooja/. -I../../../arch/platform/cooja/dev -I../../../arch/platform/cooja/lib -I../../../arch/platform/cooja/sys -I../../../arch/platform/cooja/cfs -I../../../arch/platform/cooja/net -I../../../arch -I../../../os/services/unit-test -I../../../os -I../../../os/sys -I../../../os/dev -I../../../os/lib -I../../../os/services -I../../../os -I../../../os/net -I../../../os/net/mac -I../../../os/net/mac/framer -I../../../os/net/routing -I../../../os/storage -I../../../os/net/mac/csma -I../../../os/net/ipv6 -I../../../os/net/routing/rpl-lite -I../../../arch/platform/cooja/ -I../../.. -DCONTIKI_VERSION_STRING=\"Contiki-NG-release/v4.2-173-ge82159a-dirty\" -MMD -o $(RESULT).o -c $(TARGET).parse/framac.c
	gcc -fPIC -DCONTIKI=1 -DCONTIKI_TARGET_COOJA=1 -DCONTIKI_TARGET_STRING=\"cooja\" -Wno-unused-const-variable -DPROJECT_CONF_PATH=\"project-conf.h\" -I'/usr/lib/jvm/default-java/include' -I'/usr/lib/jvm/default-java/include/linux' -fno-builtin-printf -Wall -g -I/usr/local/include -DCLASSNAME=Lib1 -DMAC_CONF_WITH_CSMA=1 -DNETSTACK_CONF_WITH_IPV6=1 -DROUTING_CONF_RPL_LITE=1  -I. -I../../../arch/platform/cooja/. -I../../../arch/platform/cooja/dev -I../../../arch/platform/cooja/lib -I../../../arch/platform/cooja/sys -I../../../arch/platform/cooja/cfs -I../../../arch/platform/cooja/net -I../../../arch -I../../../os/services/unit-test -I../../../os -I../../../os/sys -I../../../os/dev -I../../../os/lib -I../../../os/services -I../../../os -I../../../os/net -I../../../os/net/mac -I../../../os/net/mac/framer -I../../../os/net/routing -I../../../os/storage -I../../../os/net/mac/csma -I../../../os/net/ipv6 -I../../../os/net/routing/rpl-lite -I../../../arch/platform/cooja/ -I../../.. -DCONTIKI_VERSION_STRING=\"Contiki-NG-release/v4.2-173-ge82159a-dirty\" -MMD -o test-ringbufindex.o -c test-ringbufindex.c
	mkdir -p build/cooja/
	ar rcf build/cooja/$(LIBNAME).a $(RESULT).o
	#mv platform.o build/cooja///$(LIBNAME).o
	# LOG_PRINTF
	#objcopy --redefine-sym printf=log_printf build/cooja///$(LIBNAME).o;
	objcopy --redefine-sym printf=log_printf test-ringbufindex.o
	objcopy --redefine-sym printf=log_printf $(RESULT).o
	objcopy --redefine-sym printf=log_printf build/cooja/$(LIBNAME).a
	# LOG_PUTS
	#objcopy --redefine-sym puts=log_puts build/cooja///$(LIBNAME).o;
	objcopy --redefine-sym puts=log_puts test-ringbufindex.o
	objcopy --redefine-sym puts=log_puts $(RESULT).o
	objcopy --redefine-sym puts=log_puts build/cooja/$(LIBNAME).a
	# LOG_PUTCHAR
	#objcopy --redefine-sym putchar=log_putchar build/cooja///$(LIBNAME).o
	objcopy --redefine-sym putchar=log_putchar test-ringbufindex.o
	objcopy --redefine-sym putchar=log_putchar $(RESULT).o
	objcopy --redefine-sym putchar=log_putchar build/cooja/$(LIBNAME).a
	gcc -I'/usr/lib/jvm/default-java/include' -I'/usr/lib/jvm/default-java/include/linux' -shared -Wl,-Map=$(RESULT).map -o $(RESULT).cooja test-ringbufindex.o build/cooja/$(LIBNAME).a
	cp $(RESULT).cooja test-ringbufindex.cooja
	cp $(RESULT).map build/cooja/
	cp test-ringbufindex.cooja build/cooja/$(LIBNAME).cooja
	#rm test-ringbufindex.o
