include analysis.mk
# Frama-C COMMON #########################################################
FRAMAC     ?= frama-c
FCCOMMONFLAGS += -no-frama-c-stdlib -c11 -cpp-frama-c-compliant -variadic-no-translation -machdep gcc_x86_64
# Frama-C PARSE #########################################################
CPPFLAGSTEMPO=
CPPFLAGSTEMPO += ${filter -D% -I%, $(CFLAGS)}
CPPFLAGS=$(filter-out -DCLASSNAME=,$(CPPFLAGSTEMPO))
#CPPFLAGS +=-I /usr/lib/gcc/x86_64-linux-gnu/8/include -I /usr/local/include -I /usr/lib/gcc/x86_64-linux-gnu/8/include-fixed -I /usr/include/x86_64-linux-gnu -I /usr/include
#CPPFLAGS += -DAUTOSTART_ENABLE
CPPFLAGS:= ${shell echo ${CPPFLAGS} | sed -r s/\"/'\\\\\\\"'/g}
# Frama-C EACSL #########################################################
include files.mk

##############################################################
MORERTE = -warn-signed-overflow -warn-unsigned-overflow -warn-signed-downcast
#MORERTE=-warn-unsigned-downcast
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
#	ar rcf build/cooja/$(LIBNAME).a build/cooja///obj/simEnvChange.o build/cooja///obj/cooja_mt.o build/cooja///obj/cooja_mtarch.o build/cooja///obj/rtimer-arch.o build/cooja///obj/slip.o build/cooja///obj/watchdog.o build/cooja///obj/beep.o build/cooja///obj/button-sensor.o build/cooja///obj/ip.o build/cooja///obj/leds-arch.o build/cooja///obj/moteid.o build/cooja///obj/pir-sensor.o build/cooja///obj/rs232.o build/cooja///obj/vib-sensor.o build/cooja///obj/clock.o build/cooja///obj/cooja-log.o build/cooja///obj/cfs-cooja.o build/cooja///obj/cooja-radio.o build/cooja///obj/eeprom.o build/cooja///obj/slip-arch.o build/cooja///obj/random.o build/cooja///obj/sensors.o build/cooja///obj/leds.o build/cooja///obj/example-test.o build/cooja///obj/unit-test.o build/cooja///obj/contiki-main.o build/cooja///obj/autostart.o build/cooja///obj/stimer.o build/cooja///obj/log.o build/cooja///obj/energest.o build/cooja///obj/etimer.o build/cooja///obj/node-id.o build/cooja///obj/mutex.o build/cooja///obj/ctimer.o build/cooja///obj/compower.o build/cooja///obj/process.o build/cooja///obj/rtimer.o build/cooja///obj/timer.o build/cooja///obj/stack-check.o build/cooja///obj/button-hal.o build/cooja///obj/serial-line.o build/cooja///obj/spi.o build/cooja///obj/nullradio.o build/cooja///obj/gpio-hal.o build/cooja///obj/dbl-circ-list.o build/cooja///obj/crc16.o build/cooja///obj/ifft.o build/cooja///obj/ccm-star.o build/cooja///obj/dbl-list.o build/cooja///obj/ringbufindex.o build/cooja///obj/list.o build/cooja///obj/circular-list.o build/cooja///obj/aes-128.o build/cooja///obj/trickle-timer.o build/cooja///obj/memb.o build/cooja///obj/heapmem.o build/cooja///obj/assert.o build/cooja///obj/ringbuf.o build/cooja///obj/queuebuf.o build/cooja///obj/nbr-table.o build/cooja///obj/packetbuf.o build/cooja///obj/netstack.o build/cooja///obj/linkaddr.o build/cooja///obj/net-debug.o build/cooja///obj/link-stats.o build/cooja///obj/mac-sequence.o build/cooja///obj/mac.o build/cooja///obj/frame802154e-ie.o build/cooja///obj/framer-802154.o build/cooja///obj/nullframer.o build/cooja///obj/frame802154.o build/cooja///obj/csma-security.o build/cooja///obj/anti-replay.o build/cooja///obj/csma.o build/cooja///obj/csma-output.o build/cooja///obj/ccm-star-packetbuf.o build/cooja///obj/uipbuf.o build/cooja///obj/uip-icmp6.o build/cooja///obj/uip-sr.o build/cooja///obj/uip-ds6.o build/cooja///obj/uip-packetqueue.o build/cooja///obj/tcp-socket.o build/cooja///obj/ip64-addr.o build/cooja///obj/uip-udp-packet.o build/cooja///obj/uip-ds6-route.o build/cooja///obj/psock.o build/cooja///obj/uip-ds6-nbr.o build/cooja///obj/tcpip.o build/cooja///obj/uip6.o build/cooja///obj/resolv.o build/cooja///obj/uip-nameserver.o build/cooja///obj/uip-nd6.o build/cooja///obj/udp-socket.o build/cooja///obj/simple-udp.o build/cooja///obj/sicslowpan.o build/cooja///obj/uiplib.o build/cooja///obj/rpl-nbr-policy.o build/cooja///obj/rpl-of0.o build/cooja///obj/rpl-neighbor.o build/cooja///obj/rpl-dag.o build/cooja///obj/rpl-timers.o build/cooja///obj/rpl-ext-header.o build/cooja///obj/rpl.o build/cooja///obj/rpl-mrhof.o build/cooja///obj/rpl-icmp6.o build/cooja///obj/rpl-dag-root.o
#	objcopy --redefine-sym printf=log_printf test-ringbufindex.o;   objcopy --redefine-sym printf=log_printf build/cooja///$(LIBNAME).o;   objcopy --redefine-sym printf=log_printf build/cooja///$(LIBNAME).a;
#	objcopy --redefine-sym puts=log_puts test-ringbufindex.o;   objcopy --redefine-sym puts=log_puts build/cooja///$(LIBNAME).o;   objcopy --redefine-sym puts=log_puts build/cooja///$(LIBNAME).a;
#	objcopy --redefine-sym putchar=log_putchar test-ringbufindex.o;   objcopy --redefine-sym putchar=log_putchar build/cooja///$(LIBNAME).o;   objcopy --redefine-sym putchar=log_putchar build/cooja///$(LIBNAME).a;
#	gcc -I'/usr/lib/jvm/default-java/include' -I'/usr/lib/jvm/default-java/include/linux' -shared -Wl,-Map=build/cooja/$(LIBNAME).map -o build/cooja/$(LIBNAME).cooja test-ringbufindex.o build/cooja///$(LIBNAME).o build/cooja///$(LIBNAME).a
#	cp build/cooja///$(LIBNAME).cooja test-ringbufindex.cooja
#	rm test-ringbufindex.o
