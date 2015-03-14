# ρ-VEX: A Reconfigurable and Extensible VLIW Processor #

ρ-VEX is an open source VLIW processor with an accompanied development framework. The project started as the MSc project of Thijs van As while he was at the [Computer Engineering Laboratory](http://ce.et.tudelft.nl) at Delft University of Technology.

Today, multiple research groups are still [actively working](https://scholar.google.com/scholar?oi=bibs&hl=en&cites=5509474927382744618) on extending and improving the ρ-VEX framework.

This project was originally hosted on Google Code (at r-vex.googlecode.com).

## About ρ-VEX ##
ρ-VEX is an open source reconfigurable and extensible Very-Long Instruction Word (VLIW) processor, accompanied by a development framework consisting of a VEX assembler, ρ-ASM. The processor architecture is based on the VEX ISA, as introduced by [J.A. Fisher et al.](http://www.vliw.org/). The VEX ISA offers a scalable technology platform for embedded VLIW processors, that allows variation in many aspects, including instruction issue-width, organization of functional units, and instruction set. The ρ-VEX source code is described in VHDL. ρ-ASM is written in C.

A software development compiler toolchain for VEX is made publicly available by [Hewlett-Packard](http://www.hpl.hp.com/downloads/vex/). The reasons VEX was chosen as the ISA are merely its extensibility and the quality of the available compiler. The design provides mechanisms that allow parametric extensibility of ρ-VEX. Both reconfigurable operations, as well as the versatility of VEX machine models are supported by ρ-VEX. The processor and framework are targeted at VLIW prototyping research and  embedded processor design.

The name ρ-VEX stands for 'reconfigurable VEX' processor. Because the letter _Rho_ (_P_ or _ρ_) is the Greek analogous for the Roman _R_ or _r_, ρ-VEX is pronounced as _r-VEX_. This is also the correct spelling when no Greek letters can be used.

## Getting Started ##
To start experimenting with ρ-VEX, read the [Quickstart Guide](https://github.com/tvanas/r-vex/blob/master/QuickstartGuide.md) and [download](https://github.com/tvanas/r-vex/archive/MSc.zip) a release snapshot, or clone [master](https://github.com/tvanas/r-vex/tree/master). When you have a [Xilinx University Program Virtex-II Pro Board by Digilent](http://www.digilentinc.com/Products/Detail.cfm?av1=Products&Nav2=Programmable&Prod=XUPV2P), you should have ρ-VEX running within moments.

## Documentation ##
  * [ρ-VEX Quickstart Guide](https://github.com/tvanas/r-vex/blob/master/QuickstartGuide.md)
  * [ρ-VEX Machine Operations and Semantics](https://github.com/tvanas/r-vex/blob/master/OperationsAndSemantics.md)
  * [Thijs' MSc Thesis with extensive documentation about ρ-VEX' design and implementation](https://github.com/tvanas/r-vex/blob/master/downloads/thesis_tvanas.pdf?raw=true)
  * [ρ-VEX: A Reconfigurable and Extensible VLIW Softcore Processor](https://github.com/tvanas/r-vex/blob/master/downloads/r-vex_icfpt08.pdf?raw=true) (published at [ICFPT'08](http://www.icfpt.org/))
  * [instruction\_layout.txt](https://github.com/tvanas/r-vex/blob/master/doc/instruction_layout.txt)
  * [syllable\_layout.txt](https://github.com/tvanas/r-vex/blob/master/doc/syllable_layout.txt)
