SOURCES=$(wildcard *.v) \
	$(wildcard ../../../cores/crc32/rtl/*.v) \
	$(wildcard ../rtl/measure_core.v) \
	$(wildcard ../rtl/measure.v) \
	$(wildcard ../../../cores/gmii2xgmii/rtl/*.v)

#all: cversim
all: xgmii_data.hex gmii_data.hex isim

gtk: all
	gtkwave test.vcd

isim: tb_system
	./tb_system

cversim: $(SOURCES)
	cver $(SOURCES)

clean:
	rm -f tb_system verilog.log test.vcd

tb_system: $(SOURCES)
	iverilog -o tb_system $(SOURCES)

.PHONY: clean isim cversim gtk
