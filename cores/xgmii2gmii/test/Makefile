SOURCES=$(wildcard *.v) \
	$(wildcard ../../asfifo/rtl/*.v) \
	$(wildcard ../rtl/*.v)

#all: cversim
all: xgmii_data.hex isim

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
