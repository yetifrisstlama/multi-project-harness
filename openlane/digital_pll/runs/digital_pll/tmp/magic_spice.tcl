
lef read /home/ag/pdks/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd.tlef
if {  [info exist ::env(EXTRA_LEFS)] } {
	set lefs_in $::env(EXTRA_LEFS)
	foreach lef_file $lefs_in {
		lef read $lef_file
	}
}
def read /openLANE_flow/designs/caravel/openlane/digital_pll/runs/digital_pll/results/routing/digital_pll.def
load digital_pll -dereference
cd /openLANE_flow/designs/caravel/openlane/digital_pll/runs/digital_pll/results/magic/
extract do local
extract no capacitance
extract no coupling
extract no resistance
extract no adjust
# extract warn all
extract

ext2spice lvs
ext2spice digital_pll.ext
feedback save /openLANE_flow/designs/caravel/openlane/digital_pll/runs/digital_pll/logs/magic/magic_ext2spice.feedback.txt
# exec cp digital_pll.spice /openLANE_flow/designs/caravel/openlane/digital_pll/runs/digital_pll/results/magic/digital_pll.spice

