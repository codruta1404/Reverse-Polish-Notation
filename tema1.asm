%include "io.inc"

%define MAX_INPUT_SIZE 4096

section .bss
	expr: resb MAX_INPUT_SIZE

section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    push ebp
    mov ebp, esp
    GET_STRING expr, MAX_INPUT_SIZE
    mov ecx, 0

continue_to_read:    
    xor eax, eax    
    mov al, [expr + ecx]
    inc ecx

continue_to_compare:
    cmp al, 0 ; compar cu codul ascii pentru null
    je exit_here
    cmp al, 32 ; compar cu codul ascii pentru spatiu
    je continue_to_read
    cmp eax, 48 ; compar cu codul ascii pentru 0
    jge obtain_your_number
    cmp al, 45 ; compar cu codul ascii pentru -
    je minus_operation
    cmp al, 43 ; compar cu codul ascii pentru +
    je add_operation
    cmp al, 42 ; compar cu codul ascii pentru *
    je multiplication
    cmp al, 47 ; compar cu codul ascii pentru /
    je division
    jmp continue_to_read
    
obtain_your_number:
    sub eax, 48 ; vreau sa obtin numarul efectiv
    
next_elem:
    xor ebx, ebx
    mov bl, [expr + ecx]
    inc ecx 
    cmp bl, 0 
    je exit_here
    cmp bl, 32
    jle push_stack
    mov edx, 10
    mul edx
    sub ebx, 48
    add eax, ebx ; pentru numerele cu mai multe cifre
    jmp next_elem
    
minus_operation:
    xor edx, edx
    mov dl, [expr + ecx] 
    cmp dl, 0 ; daca dupa minus am null => fac operatia  de scadere
    je continue_minus_operation
    cmp dl, 32 ; daca nu am spatiu dupa minus => este un numar negativ
    jne negative_numbers
    
continue_minus_operation: 
    pop ebx
    pop eax
    sub eax, ebx
    push eax
    jmp continue_to_read
    
negative_numbers:  
    xor eax, eax
    mov al, [expr + ecx] ; iau elementul de dupa minus si il neg 
    inc ecx
    sub eax, 48
    neg eax ; aici am numarul negativ 
    xor edx, edx
    mov dl, [expr + ecx] 
    cmp dl, 32 ; compar cu spatiu
    je push_stack ;  daca este doar o cifra => o pun pe stiva
    inc ecx 
   
read_again:  
    sub edx, 48 ; daca numarul negativ este format din mai multe cifre, vreau sa-l obtin
    mov ebx, edx
    mov edx, 10
    mul edx
    sub eax, ebx
    xor edx, edx
    mov dl, [expr + ecx]
    cmp dl, 32 ; compar cu spatiu
    je push_stack
    inc ecx
    jmp read_again ; ma asigur ca am citit intregul numar, indiferent de cate cifre are
    
add_operation:
    pop ebx
    pop eax
    add eax, ebx
    push eax
    jmp continue_to_read
    
multiplication:
    pop ebx
    pop eax
    imul ebx
    push eax
    jmp continue_to_read
    
division:
    mov edx, 0
    pop ebx
    pop eax
    cdq
    idiv ebx 
    push eax
    jmp continue_to_read
    
push_stack:
    push eax
    mov eax, ebx
    jmp continue_to_read

exit_here:
    pop eax
    PRINT_DEC 4, eax
    mov ebp, esp
    xor eax, eax
    pop ebp
    ret