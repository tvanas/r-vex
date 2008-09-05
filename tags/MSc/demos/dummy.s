# Dummy demo
# -----------------------
#
# Data memory contents after running:
# 0x00: 0xFF
# 0x01: 0x0F
# 0x02: 0xEF1

add $r0.15 = $r0.0, 1
mov $r0.1 = $r0.0
mov $r0.2 = $r0.0
;;
add $r0.1 = $r0.0, 255
;;
add $r0.2 = $r0.0, 15
;;
mpyll $r0.3 = $r0.1, $r0.2 # $r0.3 = $r0.1 * $r0.2
;;
stw 0x0[$r0.15] = $r0.1
;;
stw 0x4[$r0.15] = $r0.2
;;
stw 0x8[$r0.15] = $r0.3
;;
