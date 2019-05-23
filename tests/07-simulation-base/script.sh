export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))

CONTIKI_ABSOLUTE=$HOME/Documents/contiki-ng
COOJA_ABSOLUTE=$CONTIKI_ABSOLUTE/tools/cooja

ant -Dbasedir=$COOJA_ABSOLUTE -f $COOJA_ABSOLUTE/build.xml jar_cooja
for i in avrora  mrm  mspsim  powertracker  serial_socket ; do
  ant -Dbasedir=$COOJA_ABSOLUTE/apps/$i -f $COOJA_ABSOLUTE/apps/$i/build.xml jar
done ;
java -Xshare:on -jar ../../tools/cooja/dist/cooja.jar -nogui=02-ringbufindex.csc -contiki=../.. -random-seed=1