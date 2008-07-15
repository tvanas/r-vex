add $r0.15 = $r0.0, 1
mov $r0.1 = $r0.0
add $r0.10 = $r0.0, 44
add $r0.2 = $r0.0, 1
;;
LABEL_BEGIN:
add $r0.2 = $r0.1, $r0.2
add $r0.3 = $r0.0, $r0.2
cmpeq $b0.0 = $r0.9, $r0.10
br $b0.0, LABEL_END
;;
add $r0.9 = $r0.9, 1
add $r0.1 = $r0.0, $r0.3
goto LABEL_BEGIN
;;
LABEL_END:
stw 0x0[$r0.15] = $r0.1
mov $r0.9 = $r0.0
;;
