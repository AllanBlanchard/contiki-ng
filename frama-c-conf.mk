include analysis.mk
FRAMAC     ?= frama-c
FCCOMMONFLAGS += -machdep gcc_x86_64
# Frama-C PARSE #########################################################
CPPFLAGS=
CPPFLAGS += ${filter -D% -I%, $(CFLAGS)}
#CPPFLAGS +=-I /usr/lib/gcc/x86_64-linux-gnu/8/include -I /usr/local/include -I /usr/lib/gcc/x86_64-linux-gnu/8/include-fixed -I /usr/include/x86_64-linux-gnu -I /usr/include
#CPPFLAGS += -DAUTOSTART_ENABLE
CPPFLAGS:= ${shell echo ${CPPFLAGS} | sed -r s/\"/'\\\\\\\"'/g}

FCPARSEFLAGS += -no-frama-c-stdlib -c11 -cpp-frama-c-compliant -variadic-no-translation $(FCCOMMONFLAGS) -e-acsl-prepare -rte # -then -e-acsl
#FCPARSEFLAGS += -kernel-warn-feedback "CERT:MSC:38"

%.parse: SOURCES = $(filter-out %/command,$^)
%.parse: PARSE = $(FRAMAC) $(FCPARSEFLAGS) -cpp-extra-args="$(CPPFLAGS)" $(SOURCES) -save $@/framac.save -print -ocode $@/framac.c -then -no-print
%.parse:
	@mkdir -p $@
	$(PARSE)
	@touch $@ # Update timestamp and prevents remake if nothing changes
	@echo $(PARSE)

parse: $(TARGET).parse

$(TARGET).parse: $(CONTIKI_SOURCEFILES)\
				 $(PROJECT_SOURCEFILES)\
				 $(FC_PROJECT_FILES)

# Frama-C EACSL #########################################################
eacsl: test
	$(FRAMAC) -load native.parse/framac.save -no-frama-c-stdlib -c11 -cpp-frama-c-compliant -variadic-no-translation -e-acsl -print -ocode native.parse/framac2.c
#######################################################################

test:
	@mkdir -p native.parse/
	frama-c -no-frama-c-stdlib -c11 -cpp-frama-c-compliant -variadic-no-translation -machdep gcc_x86_64 -e-acsl-prepare -rte  -cpp-extra-args="-DCONTIKI=1 -DCONTIKI_TARGET_NATIVE=1 -DCONTIKI_TARGET_STRING=\\\"native\\\" -I/usr/local/include -DMAC_CONF_WITH_NULLMAC=1 -DNETSTACK_CONF_WITH_IPV6=1 -DROUTING_CONF_RPL_LITE=1 -I. -I../../arch/platform/native/. -I../../arch/platform/native/dev -I../../arch -I../../arch/cpu/native/. -I../../arch/cpu/native/net -I../../arch/cpu/native/dev -I../../os -I../../os/sys -I../../os/dev -I../../os/lib -I../../os/services -I../../os -I../../os/net -I../../os/net/mac -I../../os/net/mac/framer -I../../os/net/routing -I../../os/storage -I../../os/net/mac/nullmac -I../../os/net/ipv6 -I../../os/net/routing/rpl-lite -I../../arch/platform/native/ -I../.. -DCONTIKI_VERSION_STRING=\\\"Contiki-NG-release/v4.2-135-g676437693-dirty\\\"" ../../arch/platform/native/./platform.c ../../arch/platform/native/./clock.c ../../arch/platform/native/dev/xmem.c ../../arch/platform/native/./cfs-posix.c ../../arch/platform/native/./cfs-posix-dir.c ../../arch/platform/native/dev/buttons.c ../../arch/cpu/native/net/tun6-net.c ../../arch/cpu/native/./rtimer-arch.c ../../arch/cpu/native/./watchdog.c ../../arch/cpu/native/dev/eeprom.c ../../arch/cpu/native/./int-master.c ../../arch/cpu/native/dev/gpio-hal-arch.c ../../os/contiki-main.c ../../os/sys/autostart.c ../../os/sys/stimer.c ../../os/sys/log.c ../../os/sys/energest.c ../../os/sys/etimer.c ../../os/sys/node-id.c ../../os/sys/mutex.c ../../os/sys/ctimer.c ../../os/sys/compower.c ../../os/sys/process.c ../../os/sys/rtimer.c ../../os/sys/timer.c ../../os/sys/stack-check.c ../../os/dev/button-hal.c ../../os/dev/serial-line.c ../../os/dev/spi.c ../../os/dev/leds.c ../../os/dev/slip.c ../../os/dev/nullradio.c ../../os/dev/gpio-hal.c ../../os/lib/dbl-circ-list.c ../../os/lib/crc16.c ../../os/lib/ifft.c ../../os/lib/ccm-star.c ../../os/lib/sensors.c ../../os/lib/dbl-list.c ../../os/lib/ringbufindex.c ../../os/lib/list.c ../../os/lib/circular-list.c ../../os/lib/aes-128.c ../../os/lib/trickle-timer.c ../../os/lib/memb.c ../../os/lib/heapmem.c ../../os/lib/random.c ../../os/lib/assert.c ../../os/lib/ringbuf.c ../../os/net/queuebuf.c ../../os/net/nbr-table.c ../../os/net/packetbuf.c ../../os/net/netstack.c ../../os/net/linkaddr.c ../../os/net/net-debug.c ../../os/net/link-stats.c ../../os/net/mac/mac-sequence.c ../../os/net/mac/mac.c ../../os/net/mac/framer/frame802154e-ie.c ../../os/net/mac/framer/framer-802154.c ../../os/net/mac/framer/nullframer.c ../../os/net/mac/framer/frame802154.c ../../os/net/mac/nullmac/nullmac.c ../../os/net/ipv6/uipbuf.c ../../os/net/ipv6/uip-icmp6.c ../../os/net/ipv6/uip-sr.c ../../os/net/ipv6/uip-ds6.c ../../os/net/ipv6/uip-packetqueue.c ../../os/net/ipv6/tcp-socket.c ../../os/net/ipv6/ip64-addr.c ../../os/net/ipv6/uip-udp-packet.c ../../os/net/ipv6/uip-ds6-route.c ../../os/net/ipv6/psock.c ../../os/net/ipv6/uip-ds6-nbr.c ../../os/net/ipv6/tcpip.c ../../os/net/ipv6/uip6.c ../../os/net/ipv6/resolv.c ../../os/net/ipv6/uip-nameserver.c ../../os/net/ipv6/uip-nd6.c ../../os/net/ipv6/udp-socket.c ../../os/net/ipv6/simple-udp.c ../../os/net/ipv6/sicslowpan.c ../../os/net/ipv6/uiplib.c ../../os/net/routing/rpl-lite/rpl-nbr-policy.c ../../os/net/routing/rpl-lite/rpl-of0.c ../../os/net/routing/rpl-lite/rpl-neighbor.c ../../os/net/routing/rpl-lite/rpl-dag.c ../../os/net/routing/rpl-lite/rpl-timers.c ../../os/net/routing/rpl-lite/rpl-ext-header.c ../../os/net/routing/rpl-lite/rpl.c ../../os/net/routing/rpl-lite/rpl-mrhof.c ../../os/net/routing/rpl-lite/rpl-icmp6.c ../../os/net/routing/rpl-lite/rpl-dag-root.c hello-world.c -save native.parse/framac.save -print -ocode native.parse/framac.c -then -no-print
