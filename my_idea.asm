.include "C:\VMLAB\include\m8def.inc"
.def  temp  =r16
.equ asize = 10
.DSEG
arr: .BYTE asize
decnum: .BYTE 5
.CSEG
reset:
   rjmp start
   reti      ; Addr $01
   reti      ; Addr $02
   reti      ; Addr $03
   reti      ; Addr $04
   reti      ; Addr $05
   reti      ; Addr $06        Use 'rjmp myVector'
   reti      ; Addr $07        to define a interrupt vector
   reti      ; Addr $08
   reti      ; Addr $09
   reti      ; Addr $0A
   reti      ; Addr $0B        This is just an example
   reti      ; Addr $0C        Not all MCUs have the same
   reti      ; Addr $0D        number of interrupt vectors
   rjmp ACP      ; Addr $0E
   reti      ; Addr $0F
   reti      ; Addr $10

init:
	ldi YL, low(arr)
	ldi YH, high(arr)
	ldi temp, 192   ; 0
	st Y+, temp
	ldi temp, 249   ; 1
	st Y+, temp
	ldi temp, 164   ; 2
	st Y+, temp
	ldi temp, 176   ; 3
	st Y+, temp
	ldi temp, 153   ; 4
	st Y+, temp
	ldi temp, 146   ; 5
	st Y+, temp
	ldi temp, 130   ; 6
	st Y+, temp
	ldi temp, 248   ; 7
	st Y+, temp
	ldi temp, 128   ; 8
	st Y+, temp
	ldi temp, 144   ; 9
	st Y, temp
	ret
	
Delay:
   ldi R31, 0x6B
	delay1:
		ldi r30, 0x6B
	delay2:
		dec r30
   	brne delay2
   	dec R31
   	brne delay1
   ret
bin16_dec5:                 ;XH:XL -> R18:R19:R20
	ldi YL, low(decnum)
	ldi YH, high(decnum)
	ldi R25, 2
	bd1:
		clr R23
		ldi R24, 16
	bd2:
		lsl XL
		rol XH
		rol R23
		andi XL, 0xFE
		cpi R23, 10
		brcs bd3
		subi R23, 10
		ori XL, 0x01
	bd3:
		dec R24
		brne bd2
		st Y+, R23
		dec R25
		brne bd1
		st Y+, XL
	ldi YL, low(decnum)
	ldi YH, high(decnum)
	ld R20, Y+
	ld R19, Y+
	ld R18, Y
	ret
ldx:
	ldi YL, low(arr)
	ldi YH, high(arr)
	add YL, temp
	clr temp
	adc YH, temp
	ld temp, Y
	ret
get_codes:
	mov temp, R18
	rcall ldx
	mov R18, temp

	
	mov temp, R19
	rcall ldx
	mov R19, temp

	
	mov temp, R20
	rcall ldx
	mov R20, temp
	ret

mul16_32:         ; XH:XL * YH:YL = R21:R22:R23:R24
	clr r21
	clr r22
	clr r23
	clr r24
	mul XL, YL
	mov R24, R0
	mov R23, R1
	mul XH, YH
	mov R22, R0
	mov R21, R1
	mul XL, YH
	clr XL
	add R23, R0
	adc R22, R1
	adc R21, XL
	mul XH, YL
	add R23, R0
	adc R22, R1
	adc R21, XL
	ret
div16_8:
   tst   R23
   breq  dv3
   clr   R24
   clr   R25
   clr   R21
   ldi   R22,16
dv1:
	lsl   XL
   rol   XH
   rol   R24
   rol   R25
   sub   R24,R23
   sbc   R25,R21
   ori   XL,0x01
   brcc  dv2
   add   r24,R23
   adc   R25,R21
   andi  XL,0xFE
dv2:
	dec   R22
   brne  dv1
   clc
   ret
dv3:
	sec
   ret

start:
ldi temp, high(ramend)
out sph, temp
ldi temp, low(ramend)
out spl, temp
rcall init

ldi r17, 0  ; ИТЕРАТОР
ldi XL, 0   ; СУММА : МЛАДШИЙ РАЗРЯД
ldi XH, 0   ; СУММА : СТАРШИЙ РАЗРЯД
ldi YL, 255
ldi YH, -1

ldi temp, 0xFF  ; Делаем пины D выходами
out DDRD, temp
out DDRB, temp
out PORTB, temp

ldi R19, 0xFF
ldi R18, 0xFF
ldi R20, 0xFF

ldi temp, 0b01100001      ; Настраиваем режим работы ADC
out ADMUX, temp	
ldi temp, 0b11001111      ; Настраиваем режим работы ADC
out ADCSR, temp
sei

cycle:

	out PORTD, R18	
	ldi temp, 0b11111110
	out PORTB, temp
	rcall delay
	rcall delay	

	out PORTD, R19	
	ldi temp, 0b11111101
	out PORTB, temp
	rcall delay
	rcall delay	

	out PORTD, R20	
	ldi temp, 0b11111011
	out PORTB, temp
	rcall delay
	rcall delay
				
rjmp cycle

ACP:
   cli
   in R21, ADCL
   in R22, ADCH

   cp r22, YL        ; YL - предыдущее значение из АЦП, r22 - текущее.
   brsh metka1    ; r22 >= YL ; ТЕКУЩЕЕ >= ПРЕДЫДУЩЕГО, значит идем к metka1
   cp YL, r22
   brsh metka2    ; YL >= r22 ; ПРЕДЫДУЩЕЕ >= ТЕКУЩЕГО, значит идем к metka2
   	
metka1:             ; ВСЕГДА, КОГДА r22 >= YL , YH делаем равным 1
	ldi YH, 1
	mov YL, r22
	rjmp exit
		
metka2:             ; ВСЕГДА, КОГДА YL >= r22 , YH делаем равным 0
	cpi YH, 1        ; СРАВНИВАЕМ YH с предыдущего прерывания с 1
	breq PC + 2      ; YH = 1 , значит инкрементируем
	rjmp PC + 5
	subi r17, -1	  ; ЕСЛИ YH был равным 1, значит синус прошел максимум, i++
   rcall SavePoint      ; СОХРАНЯЕМ МАКСИМАЛЬНОЕ ЗНАЧЕНИЕ
   cpi r17, 3
   breq update_numbers
	ldi YH, 0
	mov YL, r22
	rjmp exit	
SavePoint:
	cpi XL, 0
	brne PC + 3
	mov XL, YL     ; ПЕРВОЕ СОХРАНИМ В XL
	ret
	cpi XH, 0
	brne PC + 3
	mov XH, YL    ; ВТОРОЕ В XH
	ret
   ret          ; ТРЕТЬЕ САМО ПО СЕБЕ ОСТАНЕТСЯ В YL
		
update_numbers:
	mov r17, YL
	ldi r22, 0
	ldi r23, 0
	add XL, XH
	adc r22, r23
	add XL, YL
	adc r22, r23
	mov XH, r22
	ldi YL, 9
	ldi YH, 0x00
	rcall mul16_32 ; result - R21:R22:R23:R24
	mov XL, R24
	mov XH, R23
   ldi r23, 100
  	rcall div16_8
   rcall bin16_dec5 ; result - R18:R19:R20
   rcall get_codes
	mov YL, r17
	ldi r17, 0
	ldi YH, 0
	ldi XL, 0
	ldi XH, 0
exit:
	ldi r24, 0b11001111
	out ADCSR, r24	
	sei
	reti










