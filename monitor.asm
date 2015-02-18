;;; A basic monitor program written in MACRO-11
;;; MACRO-11 is the assembly language for PDP-11s
;;;
;;; This monitor program is built using subroutines
;;; each subroutine performs a task, either taking
;;; input producing output, parsing input or
;;; performing a function.
;;;
;;; This has been assemled&tested on real PDP-11 hardware
;;; specifically the PDP-11/23 I have access to.
;;; Input and output to the machie is via a TeleVideo 920C
;;; serial terminal
;;;
;;; Written so far is:
;;; start - main routine of the monitor
;;; srlout - serial output routine
;;; srlinp - serial input routine

.asect
   serial = 177560 ; base addr of DL11 serial card
   monbuf = 2000   ; base addr of monitor buffer
 
.=1000

start:
   mov #monbgn, r1   ; r1 points to first character
   jsr pc, srlout-4-.  ; outputs welcome message
monloo:
   mov #monbuf, r3
   jsr pc, srlinp-4-.  ; gets one line of input
   nop
nop
   nop
   nop
  ; movb #12, scrtch+1   ; put LF char to memory
  ; movb #0, scrtch  ; terminate with 0
   mov #monrst, r1   ; r1 points to current characterfirst char
   jsr pc, srlout-4-.  ; output LF char
   jsr pc, parsrt-4-.  ; parses line of input
   br monloo

; when given an address in r1, outputs char to terminal
; until hits zero termintating byte. then returns
srlout:
   mov #serial+4, r2 ; r2 points to DL11 transmitter section
nxtchr:
   movb (r1)+,r0 ; load next char
   beq done      ; string is terminated with 0                           
   movb r0,2(r2) ; write char to transmit buffer
ouwait:
   tstb (r2)     ; character transmitted?
   bpl ouwait      ; no, loop
   br nxtchr     ; transmit nxt char of string
done:
   rts pc

;fetches input
srlinp:
   mov #serial, r2 ; r2 points to DL11 reciever section
   movb #132, r1    ; octal value for CR(carriage return)
chkchr:
   tstb (r2)     ; character recieved?
   bpl chkchr    ; loop if not
chrrec:
  ; mov 2(r2),6(r2)
  ; br chkchr
   movb 2(r2), r0 ; fetch recieved byte from input buffer
   movb r0, 6(r2) ; echo back recieve char
inwait:
   movb r0, (r3)+
   nop
   nop
  ; tst 4(r2)    ; character transmitted?
  ; bpl inwait    ; no, loop
chkrtn:
   cmpb r1, r0    ; checks if carriage return entered
   beq inppar    ; return to go to then parse
   br srlinp     ; if not loop back
inppar:
   rts pc        ; return


; parse routine
parsrt:
   rts pc ; not implemented yet

monbgn:
   .byte 12,15,40     ; LF char, CR char, space char
   .ascii /WELCOME TO BNLS PDP-11 MONITOR/ ; arbitrary text
monrst:
   .byte 12,15,76,40,0     ; LF char, CR char, end marker

.end
