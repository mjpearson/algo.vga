.386
jumps

Code Segment DWord Use16

; Assume CS: Code

Public SetXY

SetXY proc pascal near
arg X:byte,Y:byte
    mov     ah,2
    mov     dl,x
    mov     dh,y
    int     10h
SetXY endp

code ends
end

