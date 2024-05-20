bits 64

global _start           

%define SYS_WRITE 1
%define STDOUT 1
%define SYS_EXIT 60
%define EXTERNAL_RECTANGLE_SYMBOL 35
 
section .rodata
buffer_width equ 128
buffer_height equ 32

section .bss
buffer resb buffer_height * buffer_width 

section .text           
_start:
    call init_buffer ; set ' ' for all elements and '\n' at the end
    
    ; ======== draw_horizontal_line ========
    xor rdi, rdi ; X = Y = 0

    mov rsi, buffer_width - 1 ; LENGTH symbols count -1 for '\n'
    mov rdx, EXTERNAL_RECTANGLE_SYMBOL ; symbol

    call draw_horizontal_line ; draw high line
    
    mov rdi, buffer_height - 1 ; low line position

    call draw_horizontal_line ; draw low line

    ; ======== draw_vertical_line ========
    
    mov rdi, 1 ; Y = 1
    mov rsi, buffer_height - 2 ; - start & end symbol
    
    call draw_vertical_line ;  draw left line
    
    mov rdi, 7e01h ; X = 30, Y = 1
    mov rsi, buffer_height - 2 ; - start & end symbol

    call draw_vertical_line ; draw right line

    ; ======== write ========
    mov rax, SYS_WRITE    ; number of sys function write
    mov rdi, STDOUT       ; set standard out stream
    
    lea rsi, buffer
    mov rdx, buffer_width * buffer_height

    syscall                 
    
    ; ======== return 0 ========
    mov rax, SYS_EXIT ; number of sys function exit
    xor rdi, rdi ; 0
    
    syscall ; exit

; =============================================================================
init_buffer:
; Params: None
; Return - None
    
    push rax
    push rcx
    push rdi
    
    ; set blank symbols in whole buffer
    lea rdi, buffer ; set buffer
    mov rcx, buffer_width * buffer_height ; set size of buffer
    mov rax, 32 ; set symbol ' '    

    rep stosb

    ; set new line symbol on every end of string
    lea rdi, buffer ; set buffer
    mov rcx, buffer_height ; set buffer height like counter
    
_loop_init_buffer:
    add rdi, buffer_width - 1 ; set ptr 
    mov byte [rdi], 10 ; mov '\n'
    inc rdi ; next symbol after '\n'

    dec rcx

    jnz _loop_init_buffer 
    

    pop rdi
    pop rcx
    pop rax

    ret


; =============================================================================
draw_horizontal_line:
; Params:
; RDI - position [ X; Y ] 
; RSI - length
; RDX - symbol
; Return - None
    
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    push r9

    mov rbx, rdi ; copy pos to rbx
    mov r9, rdi ; copy pos to rdx    

    and rbx, 000000000000ff00h ; get X pos
    shr rbx, 8 ; mov value to the end 00000......ff
    movzx r9, r9b ; get Y pos 
    
    ; calc offset for buffer (TODO: optimize)
    mov r8, buffer_width ; set buffer_width
    imul r8, r9 ; buffer_width * Y(R9)
    add r8, rbx ; buffer_width * Y + X(RBX)
    
    lea rdi, buffer ; set buffer
    add rdi, r8 ; set offset for buffer

    mov rax, rdx ; set symbol
    mov rcx, rsi ; set count of symbols
    
    rep stosb
    
    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret 

; =============================================================================
draw_vertical_line:
; Params:
; RDI - position [ X; Y ]
; RSI - length
; RDX - symbol 
; Return - None

    push rbx
    push r8
    push r9
    
    mov rbx, rdi ; copy pos to rbx
    mov r9, rdi ; copy pos to rdx    

    and rbx, 000000000000ff00h ; get X pos
    shr rbx, 8 ; mov value to the end 00000......ff
    movzx r9, r9b ; get Y pos 
    
    ; calc offset for buffer (TODO: optimize)
    mov r8, buffer_width ; set buffer_width
    imul r8, r9 ; buffer_width * Y(R9)
    add r8, rbx ; buffer_width * Y + X(RBX)

    lea rdi, buffer ; set buffer
    add rdi, r8 ; set offset for buffer
    
_loop_draw_vertical_line:
    mov [rdi], dl ; set symbol
    add rdi, buffer_width

    dec rsi
    jnz _loop_draw_vertical_line

    pop r9
    pop r8
    pop rbx

    ret
