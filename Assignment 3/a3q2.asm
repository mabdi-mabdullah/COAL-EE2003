[org 0x0100]

                jmp     Start

winTop:         dw      3
winLeft:        dw      8
winBottom:      dw      21
winRight:       dw      72
scrollLines:    dw      1
topLineIndex:   dw      0
totalDocLines:  dw      24

titleText:      db      ' TEXT VIEWPORT MANAGER '
titleLen:       dw      23
titleAttr:      dw      0x1E

textAttr:       dw      0x07
highlightAttr:  dw      0xCE
statusAttr:     dw      0x0F

documentBuffer: db      'Line 01: Welcome to the 8088 assembly viewport manager.', 0x0A
                db      'Line 02: Press UP/DOWN or W/S keys to scroll the window.', 0x0A
                db      'Line 03: In assembly language, video memory starts at B800.', 0x0A
                db      'Line 04: Each screen cell uses one word in video memory.', 0x0A
                db      'Line 05: The low byte holds the ASCII character code.', 0x0A
                db      'Line 06: The high byte holds the color attribute value.', 0x0A
                db      'Line 07: String primitives make block operations fast.', 0x0A
                db      'Line 08: LODSB loads a byte from DS:SI into register AL.', 0x0A
                db      'Line 09: STOSW stores AX directly into ES:DI video memory.', 0x0A
                db      'Line 10: MOVSW moves words from DS:SI to ES:DI cleanly.', 0x0A
                db      'Line 11: Bounded scrolling keeps outer borders intact.', 0x0A
                db      'Line 12: REPE CMPSB compares assembly strings in memory.', 0x0A
                db      'Line 13: Every assembly match is highlighted in place.', 0x0A
                db      'Line 14: Stack frames use BP to access all parameters.', 0x0A
                db      'Line 15: Local variables are allocated via SUB SP, N.', 0x0A
                db      'Line 16: Callee stack cleanup is enforced via RET N.', 0x0A
                db      'Line 17: Modular assembly code is clean and maintainable.', 0x0A
                db      'Line 18: Extra lines below let you test scrolling down.', 0x0A
                db      'Line 19: And scrolling back up restores the top lines.', 0x0A
                db      'Line 20: Highlighting updates dynamically on every key.', 0x0A
                db      'Line 21: Assembly string instructions keep it fast.', 0x0A
                db      'Line 22: All stack frames strictly use BP addressing.', 0x0A
                db      'Line 23: Press ESC or Q at any time to exit to DOS.', 0x0A
                db      'Line 24: End of the assembly viewport document buffer.', 0x00

searchKeyword:  db      'assembly'
keywordLen:     dw      8

statusPrefix:   db      'Total Matches Found: '
statusPrefLen:  dw      21

statusSuffix:   db      ' | Viewport Status: ACTIVE'
statusSuffLen:  dw      26

matchCount:     dw      0


ClearScreen:
                push    bp
                mov     bp, sp
                sub     sp, 2

                push    es
                push    ax
                push    cx
                push    di

                mov     word [bp - 2], 2000

                mov     ax, 0xB800
                mov     es, ax
                xor     di, di

                mov     ax, [bp + 4]
                mov     ah, al
                mov     al, 0x20

                mov     cx, [bp - 2]
                cld
                rep     stosw

                pop     di
                pop     cx
                pop     ax
                pop     es

                mov     sp, bp
                pop     bp
                ret     2


DrawWindow:
                push    bp
                mov     bp, sp
                sub     sp, 6

                push    es
                push    ds
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di

                mov     ax, 0xB800
                mov     es, ax

                mov     ax, [bp + 10]
                sub     ax, [bp + 14]
                dec     ax
                mov     [bp - 2], ax

                mov     ax, [bp + 12]
                sub     ax, [bp + 16]
                dec     ax
                mov     [bp - 4], ax

                mov     ax, [bp + 16]
                mov     bx, 80
                mul     bx
                add     ax, [bp + 14]
                shl     ax, 1
                mov     di, ax
                mov     [bp - 6], ax

                cld
                mov     ah, 0x0F
                mov     al, 0xC9
                stosw

                mov     cx, [bp - 2]
                mov     al, 0xCD
                rep     stosw

                mov     al, 0xBB
                stosw

                mov     cx, [bp - 4]
DrawSidesLoop:
                add     word [bp - 6], 160
                mov     di, [bp - 6]

                mov     ah, 0x0F
                mov     al, 0xBA
                stosw

                push    cx
                mov     cx, [bp - 2]
                mov     ax, 0x0720
                rep     stosw
                pop     cx

                mov     ah, 0x0F
                mov     al, 0xBA
                stosw

                loop    DrawSidesLoop

                add     word [bp - 6], 160
                mov     di, [bp - 6]

                mov     ah, 0x0F
                mov     al, 0xC8
                stosw

                mov     cx, [bp - 2]
                mov     al, 0xCD
                rep     stosw

                mov     al, 0xBC
                stosw

                mov     ax, [bp + 10]
                sub     ax, [bp + 14]
                inc     ax
                sub     ax, [bp + 6]
                shr     ax, 1
                add     ax, [bp + 14]
                mov     bx, ax

                mov     ax, [bp + 16]
                mov     dx, 80
                mul     dx
                add     ax, bx
                shl     ax, 1
                mov     di, ax

                mov     si, [bp + 8]
                mov     cx, [bp + 6]
                mov     bx, [bp + 4]
                mov     ah, bl

DrawTitleLoop:
                lodsb
                stosw
                loop    DrawTitleLoop

                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     ds
                pop     es

                mov     sp, bp
                pop     bp
                ret     14


StreamTextBuffer:
                push    bp
                mov     bp, sp
                sub     sp, 10

                push    es
                push    ds
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di

                mov     ax, 0xB800
                mov     es, ax

                mov     ax, [bp + 14]
                inc     ax
                mov     [bp - 2], ax

                mov     ax, [bp + 12]
                add     ax, 2
                mov     [bp - 4], ax
                mov     [bp - 6], ax

                mov     ax, [bp + 8]
                sub     ax, 2
                mov     [bp - 8], ax

                mov     ax, [bp + 10]
                dec     ax
                mov     [bp - 10], ax

                mov     si, [bp + 6]
                cld

StreamRowUpdate:
                mov     ax, [bp - 2]
                cmp     ax, [bp - 10]
                jg      StreamDone

                mov     bx, 80
                mul     bx
                add     ax, [bp - 4]
                shl     ax, 1
                mov     di, ax

StreamCharLoop:
                lodsb
                cmp     al, 0x00
                je      StreamDone

                cmp     al, 0x0A
                je      StreamNextLine

                mov     bx, [bp + 4]
                mov     ah, bl
                stosw

                inc     word [bp - 4]
                mov     ax, [bp - 4]
                cmp     ax, [bp - 8]
                jle     StreamCharLoop

StreamNextLine:
                inc     word [bp - 2]
                mov     ax, [bp - 6]
                mov     [bp - 4], ax
                jmp     StreamRowUpdate

StreamDone:
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     ds
                pop     es

                mov     sp, bp
                pop     bp
                ret     12


StreamSingleLine:
                push    bp
                mov     bp, sp
                sub     sp, 6

                push    es
                push    ds
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di

                mov     ax, [bp + 4]
                cmp     ax, 0
                jl      SingleLineDone
                cmp     ax, [totalDocLines]
                jge     SingleLineDone

                mov     ax, 0xB800
                mov     es, ax

                mov     ax, [bp + 12]
                add     ax, 2
                mov     [bp - 2], ax

                mov     ax, [bp + 10]
                sub     ax, 2
                mov     [bp - 4], ax

                mov     si, [bp + 8]
                cld

                mov     cx, [bp + 4]
                cmp     cx, 0
                je      LineLocated

FindTargetLineLoop:
                lodsb
                cmp     al, 0x00
                je      SingleLineDone
                cmp     al, 0x0A
                jne     FindTargetLineLoop
                loop    FindTargetLineLoop

LineLocated:
                mov     ax, [bp + 14]
                mov     bx, 80
                mul     bx
                add     ax, [bp - 2]
                shl     ax, 1
                mov     di, ax

                mov     cx, [bp - 2]

SingleLineCharLoop:
                lodsb
                cmp     al, 0x00
                je      SingleLineDone
                cmp     al, 0x0A
                je      SingleLineDone

                mov     bx, [bp + 6]
                mov     ah, bl
                stosw

                inc     cx
                cmp     cx, [bp - 4]
                jle     SingleLineCharLoop

SingleLineDone:
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     ds
                pop     es

                mov     sp, bp
                pop     bp
                ret     12


ScrollWindowUp:
                push    bp
                mov     bp, sp
                sub     sp, 6

                push    es
                push    ds
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di

                mov     ax, [bp + 4]
                cmp     ax, 0
                jle     ScrollUpExit

                mov     ax, [bp + 6]
                sub     ax, [bp + 10]
                dec     ax
                mov     [bp - 2], ax

                shl     ax, 1
                mov     bx, 160
                sub     bx, ax
                mov     [bp - 6], bx

                mov     ax, [bp + 8]
                sub     ax, [bp + 12]
                dec     ax
                sub     ax, [bp + 4]
                mov     [bp - 4], ax

                mov     ax, [bp + 12]
                inc     ax
                mov     bx, 80
                mul     bx
                add     ax, [bp + 10]
                inc     ax
                shl     ax, 1
                mov     di, ax

                mov     ax, [bp + 4]
                mov     bx, 160
                mul     bx
                mov     si, di
                add     si, ax

                mov     ax, 0xB800
                mov     es, ax
                mov     ds, ax

                cld
                mov     dx, [bp - 4]
                cmp     dx, 0
                jle     ClearVacatedBottom

ScrollUpCopyLoop:
                mov     cx, [bp - 2]
                rep     movsw

                add     si, [bp - 6]
                add     di, [bp - 6]

                dec     dx
                jnz     ScrollUpCopyLoop

ClearVacatedBottom:
                mov     dx, [bp + 4]
                mov     ax, 0x0720

ScrollUpClearLoop:
                mov     cx, [bp - 2]
                rep     stosw

                add     di, [bp - 6]
                dec     dx
                jnz     ScrollUpClearLoop

ScrollUpExit:
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     ds
                pop     es

                mov     sp, bp
                pop     bp
                ret     10


ScrollWindowDown:
                push    bp
                mov     bp, sp
                sub     sp, 6

                push    es
                push    ds
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di

                mov     ax, [bp + 4]
                cmp     ax, 0
                jle     ScrollDownExit

                mov     ax, [bp + 6]
                sub     ax, [bp + 10]
                dec     ax
                mov     [bp - 2], ax

                shl     ax, 1
                mov     bx, 160
                add     bx, ax
                mov     [bp - 6], bx

                mov     ax, [bp + 8]
                sub     ax, [bp + 12]
                dec     ax
                sub     ax, [bp + 4]
                mov     [bp - 4], ax

                mov     ax, [bp + 8]
                dec     ax
                mov     bx, 80
                mul     bx
                add     ax, [bp + 10]
                inc     ax
                shl     ax, 1
                mov     di, ax

                mov     ax, [bp + 4]
                mov     bx, 160
                mul     bx
                mov     si, di
                sub     si, ax

                mov     ax, 0xB800
                mov     es, ax
                mov     ds, ax

                cld
                mov     dx, [bp - 4]
                cmp     dx, 0
                jle     ClearVacatedTop

ScrollDownCopyLoop:
                mov     cx, [bp - 2]
                rep     movsw

                sub     si, [bp - 6]
                sub     di, [bp - 6]

                dec     dx
                jnz     ScrollDownCopyLoop

ClearVacatedTop:
                mov     ax, [bp + 12]
                inc     ax
                mov     bx, 80
                mul     bx
                add     ax, [bp + 10]
                inc     ax
                shl     ax, 1
                mov     di, ax

                mov     ax, [bp - 2]
                shl     ax, 1
                mov     bx, 160
                sub     bx, ax

                mov     dx, [bp + 4]
                mov     ax, 0x0720

ScrollDownClearLoop:
                mov     cx, [bp - 2]
                rep     stosw

                add     di, bx
                dec     dx
                jnz     ScrollDownClearLoop

ScrollDownExit:
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     ds
                pop     es

                mov     sp, bp
                pop     bp
                ret     10


FindAndHighlight:
                push    bp
                mov     bp, sp
                sub     sp, 90

                push    es
                push    ds
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di

                mov     word [bp - 2], 0

                mov     ax, [bp + 16]
                inc     ax
                mov     [bp - 4], ax

                mov     ax, [bp + 10]
                sub     ax, [bp + 6]
                mov     [bp - 6], ax

SearchRowLoop:
                mov     ax, [bp - 4]
                mov     bx, [bp + 12]
                dec     bx
                cmp     ax, bx
                jg      SearchFinished

                mov     ax, [bp - 4]
                mov     bx, 80
                mul     bx
                mov     bx, [bp + 14]
                inc     bx
                add     ax, bx
                shl     ax, 1
                mov     si, ax

                mov     cx, [bp + 10]
                sub     cx, [bp + 14]
                dec     cx

                push    ds
                mov     ax, 0xB800
                mov     ds, ax
                push    ss
                pop     es
                lea     di, [bp - 90]
                cld

ExtractRowChars:
                lodsb
                mov     byte [ds:si], 0x07
                inc     si
                stosb
                loop    ExtractRowChars
                pop     ds

                mov     ax, [bp + 14]
                inc     ax
                mov     [bp - 8], ax

SearchColLoop:
                mov     ax, [bp - 8]
                cmp     ax, [bp - 6]
                jg      NextSearchRow

                mov     ax, [bp - 8]
                sub     ax, [bp + 14]
                dec     ax
                lea     di, [bp - 90]
                add     di, ax

                mov     si, [bp + 8]
                mov     cx, [bp + 6]
                cld
                repe    cmpsb
                jne     NotMatched

                inc     word [bp - 2]

                mov     ax, [bp - 4]
                mov     bx, 80
                mul     bx
                add     ax, [bp - 8]
                shl     ax, 1
                mov     di, ax

                push    es
                mov     ax, 0xB800
                mov     es, ax
                mov     cx, [bp + 6]
                mov     bx, [bp + 4]

HighlightMatchLoop:
                inc     di
                mov     byte [es:di], bl
                inc     di
                loop    HighlightMatchLoop
                pop     es

NotMatched:
                inc     word [bp - 8]
                jmp     SearchColLoop

NextSearchRow:
                inc     word [bp - 4]
                jmp     SearchRowLoop

SearchFinished:
                mov     ax, [bp - 2]
                mov     [matchCount], ax

                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     ds
                pop     es

                mov     sp, bp
                pop     bp
                ret     14


PrintNum:
                push    bp
                mov     bp, sp
                sub     sp, 2

                push    es
                push    ax
                push    bx
                push    cx
                push    dx
                push    di

                mov     word [bp - 2], 0

                mov     ax, 0xB800
                mov     es, ax

                mov     ax, [bp + 10]
                mov     bx, 80
                mul     bx
                add     ax, [bp + 8]
                shl     ax, 1
                mov     di, ax

                mov     ax, [bp + 6]
                mov     bx, 10

DivideLoop:
                xor     dx, dx
                div     bx
                add     dl, 0x30
                push    dx
                inc     word [bp - 2]
                cmp     ax, 0
                jne     DivideLoop

                mov     cx, [bp - 2]
                mov     bx, [bp + 4]
                cld

PopDigitsLoop:
                pop     ax
                mov     ah, bl
                stosw
                loop    PopDigitsLoop

                pop     di
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     es

                mov     sp, bp
                pop     bp
                ret     8


DisplayStatusBar:
                push    bp
                mov     bp, sp
                sub     sp, 4

                push    es
                push    ds
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di

                mov     ax, 0xB800
                mov     es, ax

                mov     ax, [bp + 12]
                mov     bx, 80
                mul     bx
                shl     ax, 1
                mov     di, ax
                mov     cx, 80
                mov     ax, 0x0720
                cld
                rep     stosw

                mov     ax, [bp + 10]
                mov     [bp - 2], ax

                mov     ax, [bp + 12]
                mov     bx, 80
                mul     bx
                add     ax, [bp - 2]
                shl     ax, 1
                mov     di, ax

                mov     si, [bp + 8]
                mov     cx, [bp + 6]
                mov     ah, [statusAttr]
                cld
StatusPrefixLoop:
                lodsb
                stosw
                loop    StatusPrefixLoop

                mov     ax, [bp + 6]
                add     [bp - 2], ax

                push    word [bp + 12]
                push    word [bp - 2]
                push    word [bp + 4]
                push    word [statusAttr]
                call    PrintNum

                mov     word [bp - 4], 0
                mov     ax, [bp + 4]
                mov     bx, 10
CountDigitsLoop:
                inc     word [bp - 4]
                xor     dx, dx
                div     bx
                cmp     ax, 0
                jne     CountDigitsLoop

                mov     ax, [bp - 4]
                add     [bp - 2], ax

                mov     ax, [bp + 12]
                mov     bx, 80
                mul     bx
                add     ax, [bp - 2]
                shl     ax, 1
                mov     di, ax

                mov     si, statusSuffix
                mov     cx, [statusSuffLen]
                mov     ah, [statusAttr]
                cld
StatusSuffixLoop:
                lodsb
                stosw
                loop    StatusSuffixLoop

                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     ds
                pop     es

                mov     sp, bp
                pop     bp
                ret     10


Start:
                push    cs
                pop     ds

                push    word [textAttr]
                call    ClearScreen

                push    word [winTop]
                push    word [winLeft]
                push    word [winBottom]
                push    word [winRight]
                push    word titleText
                push    word [titleLen]
                push    word [titleAttr]
                call    DrawWindow

                push    word [winTop]
                push    word [winLeft]
                push    word [winBottom]
                push    word [winRight]
                push    word documentBuffer
                push    word [textAttr]
                call    StreamTextBuffer

RefreshStatus:
                push    word [winTop]
                push    word [winLeft]
                push    word [winBottom]
                push    word [winRight]
                push    word searchKeyword
                push    word [keywordLen]
                push    word [highlightAttr]
                call    FindAndHighlight

                push    word 23
                push    word 15
                push    word statusPrefix
                push    word [statusPrefLen]
                push    word [matchCount]
                call    DisplayStatusBar

KeyWaitLoop:
                xor     ah, ah
                int     0x16

                cmp     al, 27
                je      ExitProgram
                cmp     al, 'q'
                je      ExitProgram
                cmp     al, 'Q'
                je      ExitProgram

                cmp     ah, 0x50
                je      ScrollDownView
                cmp     al, 's'
                je      ScrollDownView
                cmp     al, 'S'
                je      ScrollDownView

                cmp     ah, 0x48
                je      ScrollUpView
                cmp     al, 'w'
                je      ScrollUpView
                cmp     al, 'W'
                je      ScrollUpView

                jmp     KeyWaitLoop

ScrollDownView:
                mov     ax, [topLineIndex]
                cmp     ax, [totalDocLines]
                jge     KeyWaitLoop

                inc     word [topLineIndex]

                push    word [winTop]
                push    word [winLeft]
                push    word [winBottom]
                push    word [winRight]
                push    word [scrollLines]
                call    ScrollWindowUp

                mov     ax, [winBottom]
                dec     ax
                push    ax
                push    word [winLeft]
                push    word [winRight]
                push    word documentBuffer
                push    word [textAttr]
                mov     ax, [topLineIndex]
                add     ax, 16
                push    ax
                call    StreamSingleLine

                jmp     RefreshStatus

ScrollUpView:
                cmp     word [topLineIndex], 0
                jle     KeyWaitLoop

                dec     word [topLineIndex]

                push    word [winTop]
                push    word [winLeft]
                push    word [winBottom]
                push    word [winRight]
                push    word [scrollLines]
                call    ScrollWindowDown

                mov     ax, [winTop]
                inc     ax
                push    ax
                push    word [winLeft]
                push    word [winRight]
                push    word documentBuffer
                push    word [textAttr]
                push    word [topLineIndex]
                call    StreamSingleLine

                jmp     RefreshStatus

ExitProgram:
                mov     ax, 0x4C00
                int     0x21