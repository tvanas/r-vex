OBJS =	r-vex_pkg.vhd \
	alu_operations.vhd \
	mul_operations.vhd \
	ctrl_operations.vhd \
	mem_operations.vhd \
	alu.vhd \
	mul.vhd \
	ctrl.vhd \
	mem.vhd \
	pc.vhd \
	registers_br.vhd \
	registers_gr.vhd \
	fetch.vhd \
	decode.vhd \
	execute.vhd \
	writeback.vhd \
	r-vex.vhd \
	d_mem.vhd \
	i_mem.vhd \
	clk_div.vhd \
	uart/clk_18432.vhd \
	uart/uart_pkg.vhd \
	uart/uart_tx.vhd \
	uart/uart.vhd \
	system.vhd

XIL_PART_r-vex_v2p = xc2vp30-ff896-7

default:
	@echo -e "\n---------------------------------"
	@echo -e "r-VEX stand-alone system deployer"
	@echo -e "---------------------------------"
	@echo -e "\nUsage: make <target>"
	@echo -e "\nTargets:  v2p      | Xilinx Virtex-II Pro VP30 Development Board"
	@echo -e "\n          modelsim | Run modelsim simulation"
	@echo -e "          vcom     | Compile files for Modelsim"
	@echo -e "\n          fpga     | Download bitstream to FPGA"
	@echo -e "          unlock   | Unlock download cable"
	@echo -e "\n          clean    | Clean generated project files\n"


v2p: r-vex_v2p.deps r-vex_v2p.bit log_v2p.txt

fpga:
	impact -batch r-vex_fpga.cmd

unlock:	unlock_cable.cmd
	impact -batch unlock_cable.cmd

log_%.txt:
	@echo -e "--- Synthesize ---" > $@
	@echo -e "<r-vex_$*.srp>\n" >> $@
	@cat r-vex_$*.srp >> $@
	@echo -e "\n</r-vex_$*.srp>" >> $@

	@echo -e "\n\n--- Translate ---" >> $@
	@echo -e "<r-vex_$*.bld>\n" >> $@
	@cat r-vex_$*.bld >> $@
	@echo -e "\n</r-vex_$*.bld>" >> $@

	@echo -e "\n\n--- Map ---" >> $@
	@echo -e "<r-vex_$*_map.mrp>\n" >> $@
	@cat r-vex_$*_map.mrp >> $@
	@echo -e "\n</r-vex_$*_map.mrp>" >> $@
	
	@echo -e "\n\n--- Place & Route ---" >> $@
	@echo -e "<r-vex_$*.par>\n" >> $@
	@cat r-vex_$*.par >> $@
	@echo -e "\n</r-vex_$*.par>" >> $@
	
	@echo -e "\n\n--- Unrouted Networks ---" >> $@
	@echo -e "<r-vex_$*.unroutes>\n" >> $@
	@cat r-vex_$*.unroutes >> $@
	@echo -e "\n</r-vex_$*.unroutes>" >> $@
	
	@echo -e "\n\n--- Bitgen ---" >> $@
	@echo -e "<r-vex_$*.bgn>\n" >> log_$*.txt
	@cat r-vex_$*.bgn >> $@
	@echo -e "\n</r-vex_$*.bgn>\n\n" >> $@
	@echo -e "\n\nLog file created in $@\n"

clean:
	rm -f r-vex_v2p*
	rm -f r-vex_fpga.cmd
	rm -f unlock_cable.cmd
	rm -rf __cf
	rm -rf __ngo
	rm -rf __xst
	rm -f _impact*
	rm -f *.bgn
	rm -f *.bit
	rm -f *.bld
	rm -f *.drc
	rm -f *_map.mrp
	rm -f *_map.ncd
	rm -f *_map.ngm
	rm -f *.ncd
	rm -f *.ngc
	rm -f *.ngd
	rm -f *.ngr
	rm -f *.pad
	rm -f *_pad.csv
	rm -f *_pad.txt
	rm -f *.par
	rm -f *.pcf
	rm -f *.srp
	rm -f *.unroutes
	rm -f *_usage.xml
	rm -f *.xpi
	rm -f log_*
	rm -f *~         # temporary backup saves
	rm -rf work      # modelsim
	rm -f vsim.wlf   # modelsim
	rm -f r-vex.do   # modelsim
	rm -f transcript # modelsim

%.deps: %.prj %.lso %.ucf %.ut %.xst %.cmd
	@echo -e "--- auxiliary files generated ---"

%.bgn %.bit %.drc: %.ncd %.ut
	bitgen -f $*.ut $<

%.ncd %.pad %_pad.csv %_pad.txt %.par %.xpi: %_map.ncd %.pcf
	par -w -ol std -t 1 $< $@ $*.pcf

%_map.mrp %_map.ncd %_map.ngm %.pcf: %.ngd
	map -p ${XIL_PART_$*} -cm area -pr b -k 4 -c 100 -o $*_map.ncd $< $*.pcf

%.bld %.ngd: %.ngc %.ucf
	ngdbuild -aul -dd __ngo -uc $*.ucf -p ${XIL_PART_$*} $< $@

%.ngc %.ngr: %.xst ${OBJS}
	xst -ifn $<

%.prj:		
	@echo -e "vhdl work \"r-vex_pkg.vhd\" \
	\nvhdl work \"alu_operations.vhd\" \
	\nvhdl work \"mul_operations.vhd\" \
	\nvhdl work \"ctrl_operations.vhd\" \
	\nvhdl work \"mem_operations.vhd\" \
	\nvhdl work \"alu.vhd\" \
	\nvhdl work \"mul.vhd\" \
	\nvhdl work \"ctrl.vhd\" \
	\nvhdl work \"mem.vhd\" \
	\nvhdl work \"pc.vhd\" \
	\nvhdl work \"registers_br.vhd\" \
	\nvhdl work \"registers_gr.vhd\" \
	\nvhdl work \"fetch.vhd\" \
	\nvhdl work \"decode.vhd\" \
	\nvhdl work \"execute.vhd\" \
	\nvhdl work \"writeback.vhd\" \
	\nvhdl work \"r-vex.vhd\" \
	\nvhdl work \"d_mem.vhd\" \
	\nvhdl work \"i_mem.vhd\" \
	\nvhdl work \"clk_div.vhd\" \
	\nvhdl work \"uart/clk_18432.vhd\" \
	\nvhdl work \"uart/uart_pkg.vhd\" \
	\nvhdl work \"uart/uart_tx.vhd\" \
	\nvhdl work \"uart/uart.vhd\" \
	\nvhdl work \"system.vhd\"" > $@

%.lso:
	@echo -e "work" > $@

r-vex_v2p.ut:
	@echo -e "-w \
	\n-g DebugBitstream:No \
	\n-g Binary:no \
	\n-g CRC:Enable \
	\n-g ConfigRate:4 \
	\n-g CclkPin:PullUp \
	\n-g M0Pin:PullUp \
	\n-g M1Pin:PullUp \
	\n-g M2Pin:PullUp \
	\n-g ProgPin:PullUp \
	\n-g DonePin:PullUp \
	\n-g PowerdownPin:PullUp \
	\n-g TckPin:PullUp \
	\n-g TdiPin:PullUp \
	\n-g TdoPin:PullNone \
	\n-g TmsPin:PullUp \
	\n-g UnusedPin:PullDown \
	\n-g UserID:0xFFFFFFFF \
	\n-g DCMShutdown:Disable \
	\n-g DisableBandgap:No \
	\n-g DCIUpdateMode:AsRequired \
	\n-g StartUpClk:CClk \
	\n-g DONE_cycle:4 \
	\n-g GTS_cycle:5 \
	\n-g GWE_cycle:6 \
	\n-g LCK_cycle:NoWait \
	\n-g Match_cycle:Auto \
	\n-g Security:None \
	\n-g DonePipe:No \
	\n-g DriveDone:No \
	\n-g Encrypt:No " > $@

r-vex_v2p.xst:
	@echo -e "set -xsthdpdir __xst \
	\nrun \
	\n-ifn r-vex_v2p.prj \
	\n-ifmt mixed \
	\n-ofn r-vex_v2p \
	\n-ofmt NGC \
	\n-p xc2vp30-7-ff896 \
	\n-top system \
	\n-opt_mode Speed \
	\n-opt_level 1 \
	\n-iuc NO \
	\n-lso r-vex_v2p.lso \
	\n-keep_hierarchy NO \
	\n-rtlview Yes \
	\n-glob_opt AllClockNets \
	\n-read_cores YES \
	\n-write_timing_constraints NO \
	\n-cross_clock_analysis NO \
	\n-hierarchy_separator / \
	\n-bus_delimiter <> \
	\n-case maintain \
	\n-slice_utilization_ratio 100 \
	\n-verilog2001 YES \
	\n-fsm_extract YES -fsm_encoding Auto \
	\n-safe_implementation No \
	\n-fsm_style lut \
	\n-ram_extract Yes \
	\n-ram_style Auto \
	\n-rom_extract Yes \
	\n-mux_style Auto \
	\n-decoder_extract YES \
	\n-priority_extract YES \
	\n-shreg_extract YES \
	\n-shift_extract YES" > r-vex_v2p.xst

r-vex_v2p.ucf:
	@echo -e "net \"clk\" period = 10.0ns high 50%; \
	\nnet \"clk\" loc = \"aj15\" | iostandard = lvcmos25; \
	\nnet \"reset\" loc = \"ag5\" | iostandard = lvttl; \
	\nnet \"tx\" loc = \"ae7\" | iostandard = lvcmos25 | slew = slow | drive = 8;" > r-vex_v2p.ucf

r-vex_v2p.cmd:
	@echo -e "setMode -bs \
	\nsetMode -bs \
	\nsetCable -port auto \
	\nIdentify \
	\nidentifyMPM \
	\nsetMode -bs \
	\naddDevice -p 3 -file r-vex_v2p.bit \
	\ndeleteDevice -position 4 \
	\nProgram -p 3 -defaultVersion 0 \
	\nquit" > r-vex_fpga.cmd

unlock_cable.cmd:
	@echo -e "setMode -bscan \
	\ncleancablelock \
	\nquit" > unlock_cable.cmd

vsimdo:
	@echo -e "quit -sim \
	\nvsim work.tb_system \
	\nadd wave -r /* \
	\nrun 20000ns" > r-vex.do

vcom:
	vlib work
	vcom ${OBJS}
	vcom ../testbenches/tb_system.vhd

modelsim: vcom vsimdo
	vsim -do r-vex.do

