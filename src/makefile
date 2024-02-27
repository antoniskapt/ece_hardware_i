# GNU makefile
#
# Kapetanios Antonios [10419]
# kapetaat@ece.auth.gr
#
# (54) Hardware I
# Dep. of ECE, AUTh
#
# January 2024
#
VC=iverilog
EX=vvp
SRC02= alu.v accum.v decoder.v calc.v calc_TB.v
SRC05= alu.v regfile.v datapath.v multicycle.v top_proc_TB.v rom.v ram.v

.PHONY: calc top clean purge

all: calc top

calc: $(SRC02)
	$(VC) -o $@ calc_TB.v
	$(EX) $@

top: $(SRC05)
	$(VC) -o $@ top_proc_TB.v
	$(EX) $@

clean:
	rm -f calc
	rm -f top

purge: clean
	rm -f *.vcd