	.zp

_BL = $FA
_BH = $FB
_CL = $FC
_CH = $FD
_CX = $FC
_DL = $FE
_DH = $FF

	.code
	.bank	$0
	.org	$E000

00000: 4C F3 E0      JMP   CD_BOOT		;$E0F3
00003: 4C E3 E8      JMP   CD_RESET		;$E8E3
00006: 4C 8F EB      JMP   CD_BASE		;$EB8F
00009: 4C 05 EC      JMP   CD_READ		;$EC05
0000C: 4C CB ED      JMP   CD_SEEK		;$EDCB
0000F: 4C EC EB      JMP   CD_EXEC		;$EBEC
00012: 4C 10 EE      JMP   CD_PLAY		;$EE10
00015: 4C 34 EF      JMP   CD_SEARCH	;$EF34
00018: 4C 94 EF      JMP   CD_PAUSE		;$EF94
0001B: 4C 47 F3      JMP   CD_STAT		;$F347
0001E: 4C BF EF      JMP   CD_SUBQ		;$EFBF
00021: 4C F1 EF      JMP   CD_DINFO		;$EFF1
00024: 4C A9 F0      JMP   CD_CONTNTS	;$F0A9
00027: 4C 54 F3      JMP   CD_SUBRD		;$F354
0002A: 4C 64 F3      JMP   CD_PCMRD		;$F364
0002D: 4C 79 F3      JMP   CD_FADE		;$F379
00030: 4C 7F F3      JMP   AD_RESET		;$F37F
00033: 4C 93 F3      JMP   AD_TRANS		;$F393
00036: 4C 07 F4      JMP   AD_READ		;$F407
00039: 4C D8 F4      JMP   AD_WRITE		;$F4D8
0003C: 4C C6 F5      JMP   AD_PLAY		;$F5C6
0003F: 4C 1F F6      JMP   AD_CPLAY		;$F61F
00042: 4C C1 F6      JMP   AD_STOP		;$F6C1
00045: 4C DB F6      JMP   AD_STAT		;$F6DB
00048: 4C 58 F8      JMP   BM_FORMAT	;$F858
0004B: 4C B8 F8      JMP   BM_FREE		;$F8B8
0004E: 4C E3 F8      JMP   BM_READ		;$F8E3
00051: 4C 55 F9      JMP   BM_WRITE		;$F955
00054: 4C 1A FA      JMP   BM_DELETE	;$FA1A
00057: 4C 72 FA      JMP   BM_FILES		;$FA72
0005A: 4C 2D F0      JMP   EX_GETVER	;$F02D
0005D: 4C 34 F0      JMP   EX_SETVEC	;$F034
00060: 4C 24 F1      JMP   $F124
00063: 4C 9A E4      JMP   EX_JOYSNS	;$E49A
00066: 4C 75 E1      JMP   $E175
00069: 4C 67 E2      JMP   $E267
0006C: 4C 72 E2      JMP   $E272
0006F: 4C 9D E2      JMP   $E29D
00072: 4C 82 E3      JMP   $E382
00075: 4C 91 E3      JMP   $E391
00078: 4C A4 E3      JMP   $E3A4
0007B: 4C B5 E3      JMP   EX_VSYNC		;$E3B5
0007E: 4C C7 E3      JMP   $E3C7
00081: 4C CB E3      JMP   $E3CB
00084: 4C CF E3      JMP   $E3CF
00087: 4C D3 E3      JMP   $E3D3
0008A: 4C E2 E3      JMP   $E3E2
0008D: 4C E5 E3      JMP   $E3E5
00090: 4C E8 E3      JMP   $E3E8
00093: 4C EB E3      JMP   $E3EB
00096: 4C EE E3      JMP   $E3EE
00099: 4C F3 E3      JMP   $E3F3
0009C: 4C F8 E3      JMP   $E3F8
0009F: 4C 0B E4      JMP   $E40B
000A2: 4C DA E5      JMP   $E5DA
000A5: 4C 3C E6      JMP   $E63C
000A8: 4C 1F E4      JMP   $E41F
000AB: 4C 2F E4      JMP   $E42F
000AE: 4C 46 E4      JMP   $E446
000B1: 4C 5D E4      JMP   $E45D
000B4: 4C 21 E6      JMP   $E621
000B7: 4C 00 E6      JMP   $E600
000BA: 4C 7E E6      JMP   $E67E
000BD: 4C C6 FD      JMP   $FDC6
000C0: 4C BF FD      JMP   $FDBF
000C3: 4C D4 FD      JMP   $FDD4
000C6: 4C E2 FD      JMP   $FDE2
000C9: 4C E9 FD      JMP   $FDE9
000CC: 4C F0 FD      JMP   $FDF0
000CF: 4C FE FD      JMP   $FDFE
000D2: 4C F7 FD      JMP   $FDF7
000D5: 4C 05 FE      JMP   $FE05
000D8: 4C 0C FE      JMP   $FE0C
000DB: 4C 57 FE      JMP   $FE57
000DE: 4C 92 FE      JMP   EX_MEMOPEN	;$FE92
000E1: 4C CF E6      JMP   $E6CF
000E4: 4C 09 E5      JMP   $E509
000E7: 4C 30 F7      JMP   $F730
000EA: 4C 6C F7      JMP   $F76C
000ED: 4C CD FD      JMP   $FDCD
000F0: 4C DB FD      JMP   $FDDB

CD_BOOT:
000F3: 78            SEI 
000F4: D4            CSH 
000F5: D8            CLD 
000F6: A2 FF         LDX   #$FF
000F8: 9A            TXS 
000F9: 8A            TXA 
000FA: 53 01         TAM   #$01
000FC: A9 F8         LDA   #$F8
000FE: 53 02         TAM   #$02
00100: 44 38         BSR   $013A
00102: A9 01         LDA   #$01
00104: 53 40         TAM   #$40
00106: 20 0F CB      JSR   $CB0F
00109: 20 60 C8      JSR   $C860
0010C: AA            TAX 
0010D: F0 09         BEQ   $0118
0010F: 44 29         BSR   $013A
00111: A9 03         LDA   #$03
00113: 53 40         TAM   #$40
00115: 4C 78 CF      JMP   $CF78
00118: 20 A9 F0      JSR   $F0A9
0011B: 44 2F         BSR   $014C
0011D: 90 0D         BCC   $012C
0011F: A9 01         LDA   #$01
00121: 53 40         TAM   #$40
00123: 20 03 CB      JSR   $CB03
00126: 20 54 CB      JSR   $CB54
00129: 4C 09 E1      JMP   $E109
0012C: A9 04         LDA   #$04
0012E: 44 0D         BSR   $013D
00130: 4C 00 40      JMP   $4000
00133: A9 17         LDA   #$17
00135: 44 06         BSR   $013D
00137: 4C 00 40      JMP   $4000


0013A: AD F5 FF      LDA   $FFF5
0013D: 53 04         TAM   #$04
0013F: 1A            INC 
00140: 53 08         TAM   #$08
00142: 1A            INC 
00143: 53 10         TAM   #$10
00145: 1A            INC 
00146: 53 20         TAM   #$20
00148: 1A            INC 
00149: 53 40         TAM   #$40
0014B: 60            RTS 

0014C: AD 6A 22      LDA   $226A
0014F: 48            PHA 
00150: 85 F9         STA   $F9
00152: A9 02         LDA   #$02
00154: 85 F8         STA   $F8
00156: A9 56         LDA   #$56
00158: 85 FA         STA   $FA
0015A: A9 22         LDA   #$22
0015C: 85 FB         STA   $FB
0015E: 20 F1 EF      JSR   $EFF1
00161: 68            PLA 
00162: 93 04 59 22   TST   $04, $2259
00166: D0 0E         BNE   $0176
00168: CD 6B 22      CMP   $226B
0016B: B0 07         BCS   $0174
0016D: F8            SED 
0016E: 18            CLC 
0016F: 69 01         ADC   #$01
00171: D8            CLD 
00172: 80 DB         BRA   $014F
00174: 18            CLC 
00175: 60            RTS 
00176: 8D 69 22      STA   $2269
00179: 20 17 CC      JSR   $CC17
0017C: 73 F8 20 74 22 03 00  TII   $20F8, $2274, $0003
00183: 73 F8 20 77 22 03 00  TII   $20F8, $2277, $0003
0018A: 64 FC         STZ   $FC
0018C: 64 FD         STZ   $FD
0018E: 64 FE         STZ   $FE
00190: A9 00         LDA   #$00
00192: 85 FA         STA   $FA
00194: A9 28         LDA   #$28
00196: 85 FB         STA   $FB
00198: A9 01         LDA   #$01
0019A: 85 FF         STA   $FF
0019C: 1A            INC 
0019D: 85 F8         STA   $F8
0019F: 64 F9         STZ   $F9
001A1: 20 05 EC      JSR   $EC05
001A4: A9 1F         LDA   #$1F
001A6: 53 40         TAM   #$40
001A8: A9 00         LDA   #$00
001AA: 85 EC         STA   $EC
001AC: A9 28         LDA   #$28
001AE: 85 ED         STA   $ED
001B0: A9 E1         LDA   #$E1
001B2: 85 EE         STA   $EE
001B4: A9 DA         LDA   #$DA
001B6: 85 EF         STA   $EF
001B8: A9 D5         LDA   #$D5
001BA: 85 FC         STA   $FC
001BC: A9 04         LDA   #$04
001BE: 85 FD         STA   $FD
001C0: B2 EC         LDA   ($EC)
001C2: D2 EE         CMP   ($EE)
001C4: D0 43         BNE   $0209
001C6: E6 EC         INC   $EC
001C8: D0 02         BNE   $01CC
001CA: E6 ED         INC   $ED
001CC: E6 EE         INC   $EE
001CE: D0 02         BNE   $01D2
001D0: E6 EF         INC   $EF
001D2: A5 FC         LDA   $FC
001D4: D0 02         BNE   $01D8
001D6: C6 FD         DEC   $FD
001D8: C6 FC         DEC   $FC
001DA: A5 FC         LDA   $FC
001DC: 05 FD         ORA   $FD
001DE: D0 E0         BNE   $01C0
001E0: A9 4A         LDA   #$4A
001E2: 85 FC         STA   $FC
001E4: A9 00         LDA   #$00
001E6: 85 FD         STA   $FD
001E8: B2 EC         LDA   ($EC)
001EA: D0 1D         BNE   $0209
001EC: E6 EC         INC   $EC
001EE: D0 02         BNE   $01F2
001F0: E6 ED         INC   $ED
001F2: E6 EE         INC   $EE
001F4: D0 02         BNE   $01F8
001F6: E6 EF         INC   $EF
001F8: A5 FC         LDA   $FC
001FA: D0 02         BNE   $01FE
001FC: C6 FD         DEC   $FD
001FE: C6 FC         DEC   $FC
00200: A5 FC         LDA   $FC
00202: 05 FD         ORA   $FD
00204: D0 E2         BNE   $01E8
00206: 20 26 2B      JSR   $2B26
00209: 38            SEC 
0020A: 60            RTS 

0020B: C9 06         CMP   #$06
0020D: F0 54         BEQ   $0263
0020F: C9 02         CMP   #$02
00211: D0 50         BNE   $0263
00213: A0 09         LDY   #$09
00215: B9 4C 22      LDA   $224C,Y
00218: 99 91 22      STA   $2291,Y
0021B: 88            DEY 
0021C: 10 F7         BPL   $0215
0021E: 20 53 F0      JSR   $F053
00221: AD 7C 22      LDA   $227C
00224: F0 3D         BEQ   $0263
00226: C9 04         CMP   #$04
00228: D0 05         BNE   $022F
0022A: 8D 47 22      STA   $2247
0022D: 80 34         BRA   $0263
0022F: C9 0B         CMP   #$0B
00231: F0 32         BEQ   $0265
00233: C9 0D         CMP   #$0D
00235: F0 2E         BEQ   $0265
00237: C9 11         CMP   #$11
00239: F0 28         BEQ   $0263
0023B: C9 15         CMP   #$15
0023D: F0 24         BEQ   $0263
0023F: C9 16         CMP   #$16
00241: F0 20         BEQ   $0263
00243: C9 1C         CMP   #$1C
00245: F0 1E         BEQ   $0265
00247: C9 1D         CMP   #$1D
00249: F0 1A         BEQ   $0265
0024B: C9 20         CMP   #$20
0024D: F0 16         BEQ   $0265
0024F: C9 21         CMP   #$21
00251: F0 12         BEQ   $0265
00253: C9 22         CMP   #$22
00255: F0 0E         BEQ   $0265
00257: C9 25         CMP   #$25
00259: F0 0A         BEQ   $0265
0025B: C9 2A         CMP   #$2A
0025D: F0 06         BEQ   $0265
0025F: C9 2C         CMP   #$2C
00261: F0 02         BEQ   $0265
00263: 18            CLC 
00264: 60            RTS 
00265: 38            SEC 
00266: 60            RTS 


00267: 29 07         AND   #$07
00269: 0A            ASL 
0026A: 0A            ASL 
0026B: 0A            ASL 
0026C: 0A            ASL 
0026D: A8            TAY 
0026E: A9 8F         LDA   #$8F
00270: 80 05         BRA   $0277


00272: 29 8F         AND   #$8F
00274: A8            TAY 
00275: A9 70         LDA   #$70

00277: 2D 42 22      AND   $2242
0027A: 8D 42 22      STA   $2242
0027D: 98            TYA 
0027E: 0D 42 22      ORA   $2242
00281: 8D 42 22      STA   $2242
00284: A9 09         LDA   #$09
00286: 85 F7         STA   $F7
00288: 8D 00 00      STA   $0000
0028B: AD 42 22      LDA   $2242
0028E: 8D 02 00      STA   $0002
00291: 60            RTS 
00292: 62            CLA 
00293: A2 20         LDX   #$20
00295: A0 1E         LDY   #$1E
00297: 44 04         BSR   $029D
00299: A9 01         LDA   #$01
0029B: 38            SEC 
0029C: 60            RTS 


0029D: 8D 44 22      STA   $2244
002A0: 29 05         AND   #$05
002A2: 8D 44 22      STA   $2244
002A5: 8E 45 22      STX   $2245
002A8: 8C 46 22      STY   $2246
002AB: AD 46 22      LDA   $2246
002AE: C9 0A         CMP   #$0A
002B0: 90 E0         BCC   $0292
002B2: C9 1F         CMP   #$1F
002B4: B0 DC         BCS   $0292
002B6: 93 01 44 22   TST   $01, $2244
002BA: D0 42         BNE   $02FE
002BC: AD 45 22      LDA   $2245
002BF: C9 0A         CMP   #$0A
002C1: 90 CF         BCC   $0292
002C3: C9 23         CMP   #$23
002C5: B0 CB         BCS   $0292
002C7: 44 78         BSR   $0341
002C9: A9 0A         LDA   #$0A
002CB: 85 F7         STA   $F7
002CD: 8D 00 00      STA   $0000
002D0: 13 02         ST1   #$02
002D2: AD 45 22      LDA   $2245
002D5: AA            TAX 
002D6: CA            DEX 
002D7: 4A            LSR 
002D8: 49 FF         EOR   #$FF
002DA: 18            CLC 
002DB: 69 13         ADC   #$13
002DD: 8D 03 00      STA   $0003
002E0: 18            CLC 
002E1: 6D 45 22      ADC   $2245
002E4: 49 FF         EOR   #$FF
002E6: A8            TAY 
002E7: A9 0B         LDA   #$0B
002E9: 85 F7         STA   $F7
002EB: 8D 00 00      STA   $0000
002EE: 8E 02 00      STX   $0002
002F1: 98            TYA 
002F2: 18            CLC 
002F3: 69 27         ADC   #$27
002F5: 8D 03 00      STA   $0003
002F8: 62            CLA 
002F9: 20 72 E2      JSR   $E272
002FC: 18            CLC 
002FD: 60            RTS 
002FE: AD 45 22      LDA   $2245
00301: C9 10         CMP   #$10
00303: 90 8D         BCC   $0292
00305: C9 2D         CMP   #$2D
00307: B0 89         BCS   $0292
00309: 44 36         BSR   $0341
0030B: A9 0A         LDA   #$0A
0030D: 85 F7         STA   $F7
0030F: 8D 00 00      STA   $0000
00312: 13 03         ST1   #$03
00314: AD 45 22      LDA   $2245
00317: AA            TAX 
00318: CA            DEX 
00319: 4A            LSR 
0031A: 49 FF         EOR   #$FF
0031C: 18            CLC 
0031D: 69 19         ADC   #$19
0031F: 8D 03 00      STA   $0003
00322: 18            CLC 
00323: 6D 45 22      ADC   $2245
00326: 49 FF         EOR   #$FF
00328: A8            TAY 
00329: A9 0B         LDA   #$0B
0032B: 85 F7         STA   $F7
0032D: 8D 00 00      STA   $0000
00330: 8E 02 00      STX   $0002
00333: 98            TYA 
00334: 18            CLC 
00335: 69 35         ADC   #$35
00337: 8D 03 00      STA   $0003
0033A: A9 0A         LDA   #$0A
0033C: 20 72 E2      JSR   $E272
0033F: 18            CLC 
00340: 60            RTS 
00341: A9 0C         LDA   #$0C
00343: 85 F7         STA   $F7
00345: 8D 00 00      STA   $0000
00348: 13 02         ST1   #$02
0034A: AD 46 22      LDA   $2246
0034D: 0A            ASL 
0034E: 0A            ASL 
0034F: 0A            ASL 
00350: AA            TAX 
00351: CA            DEX 
00352: 4A            LSR 
00353: 49 FF         EOR   #$FF
00355: 18            CLC 
00356: 69 88         ADC   #$88
00358: 8D 03 00      STA   $0003
0035B: A9 0D         LDA   #$0D
0035D: 85 F7         STA   $F7
0035F: 8D 00 00      STA   $0000
00362: 8E 02 00      STX   $0002
00365: 23 00         ST2   #$00
00367: A9 0E         LDA   #$0E
00369: 85 F7         STA   $F7
0036B: 8D 00 00      STA   $0000
0036E: 8A            TXA 
0036F: 1A            INC 
00370: 1A            INC 
00371: 4A            LSR 
00372: 69 7D         ADC   #$7D
00374: 8D 02 00      STA   $0002
00377: 23 00         ST2   #$00
00379: AD 44 22      LDA   $2244
0037C: 49 04         EOR   #$04
0037E: 8D 00 04      STA   $0400
00381: 60            RTS 


00382: 37 F4         RMB3  $F4
00384: 47 F4         RMB4  $F4
00386: 0A            ASL 
00387: 0A            ASL 
00388: 0A            ASL 
00389: 29 18         AND   #$18
0038B: 05 F4         ORA   $F4
0038D: 85 F4         STA   $F4
0038F: 80 17         BRA   $03A8


00391: B7 F4         SMB3  $F4
00393: AD 42 22      LDA   $2242
00396: 29 30         AND   #$30
00398: F0 0C         BEQ   $03A6
0039A: C7 F4         SMB4  $F4
0039C: 29 01         AND   #$01
0039E: D0 08         BNE   $03A8
003A0: 37 F4         RMB3  $F4
003A2: 80 04         BRA   $03A8
003A4: 37 F4         RMB3  $F4
003A6: 47 F4         RMB4  $F4

003A8: A9 05         LDA   #$05
003AA: 85 F7         STA   $F7
003AC: 8D 00 00      STA   $0000
003AF: A5 F4         LDA   $F4
003B1: 8D 03 00      STA   $0003
003B4: 60            RTS 

EX_VSYNC:
003B5: 9F F5 0E      BBS1  $F5, $03C6
003B8: 58            CLI 
003B9: BF F3 02      BBS3  $F3, $03BE
003BC: 44 11         BSR   $03CF
003BE: AD 41 22      LDA   $2241
003C1: CD 41 22      CMP   $2241
003C4: F0 FB         BEQ   $03C1
003C6: 60            RTS 

003C7: A7 F3         SMB2  $F3
003C9: 80 0A         BRA   $03D5
003CB: 27 F3         RMB2  $F3
003CD: 80 06         BRA   $03D5
003CF: B7 F3         SMB3  $F3
003D1: 80 02         BRA   $03D5
003D3: 37 F3         RMB3  $F3
003D5: A9 05         LDA   #$05
003D7: 85 F7         STA   $F7
003D9: 8D 00 00      STA   $0000
003DC: A5 F3         LDA   $F3
003DE: 8D 02 00      STA   $0002
003E1: 60            RTS 
003E2: F7 F3         SMB7  $F3
003E4: 60            RTS 
003E5: 77 F3         RMB7  $F3
003E7: 60            RTS 
003E8: E7 F3         SMB6  $F3
003EA: 60            RTS 
003EB: 67 F3         RMB6  $F3
003ED: 60            RTS 
003EE: E7 F3         SMB6  $F3
003F0: F7 F3         SMB7  $F3
003F2: 60            RTS 
003F3: 67 F3         RMB6  $F3
003F5: 77 F3         RMB7  $F3
003F7: 60            RTS 
003F8: 29 1F         AND   #$1F
003FA: 8D 43 22      STA   $2243
003FD: A9 0F         LDA   #$0F
003FF: 85 F7         STA   $F7
00401: 8D 00 00      STA   $0000
00404: AD 43 22      LDA   $2243
00407: 8D 02 00      STA   $0002
0040A: 60            RTS 
0040B: A9 13         LDA   #$13
0040D: 85 F7         STA   $F7
0040F: 8D 00 00      STA   $0000
00412: AD 14 22      LDA   $2214
00415: 8D 02 00      STA   $0002
00418: AD 15 22      LDA   $2215
0041B: 8D 03 00      STA   $0003
0041E: 60            RTS 
0041F: 48            PHA 
00420: A9 06         LDA   #$06
00422: 85 F7         STA   $F7
00424: 8D 00 00      STA   $0000
00427: 68            PLA 
00428: 8D 02 00      STA   $0002
0042B: 8E 03 00      STX   $0003
0042E: 60            RTS 
0042F: 48            PHA 
00430: A9 01         LDA   #$01
00432: 85 F7         STA   $F7
00434: 8D 00 00      STA   $0000
00437: 68            PLA 
00438: 8D 02 00      STA   $0002
0043B: 8E 03 00      STX   $0003
0043E: A9 02         LDA   #$02
00440: 85 F7         STA   $F7
00442: 8D 00 00      STA   $0000
00445: 60            RTS 
00446: 48            PHA 
00447: A9 00         LDA   #$00
00449: 85 F7         STA   $F7
0044B: 8D 00 00      STA   $0000
0044E: 68            PLA 
0044F: 8D 02 00      STA   $0002
00452: 8E 03 00      STX   $0003
00455: A9 02         LDA   #$02
00457: 85 F7         STA   $F7
00459: 8D 00 00      STA   $0000
0045C: 60            RTS 
0045D: A5 F7         LDA   $F7
0045F: 48            PHA 
00460: A9 10         LDA   #$10
00462: 85 F7         STA   $F7
00464: 8D 00 00      STA   $0000
00467: A5 FA         LDA   $FA
00469: 8D 02 00      STA   $0002
0046C: A5 FB         LDA   $FB
0046E: 8D 03 00      STA   $0003
00471: A9 11         LDA   #$11
00473: 85 F7         STA   $F7
00475: 8D 00 00      STA   $0000
00478: A5 FE         LDA   $FE
0047A: 8D 02 00      STA   $0002
0047D: A5 FF         LDA   $FF
0047F: 8D 03 00      STA   $0003
00482: A9 12         LDA   #$12
00484: 85 F7         STA   $F7
00486: 8D 00 00      STA   $0000
00489: A5 FC         LDA   $FC
0048B: 8D 02 00      STA   $0002
0048E: A5 FD         LDA   $FD
00490: 8D 03 00      STA   $0003
00493: 68            PLA 
00494: 85 F7         STA   $F7
00496: 8D 00 00      STA   $0000
00499: 60            RTS 

EX_JOYSNS:
0049A: A9 01         LDA   #$01
0049C: 8D 00 10      STA   $1000
0049F: A9 03         LDA   #$03
004A1: 8D 00 10      STA   $1000
004A4: C2            CLY 
004A5: A9 01         LDA   #$01
004A7: 8D 00 10      STA   $1000
004AA: 48            PHA 
004AB: 68            PLA 
004AC: EA            NOP 
004AD: EA            NOP 
004AE: B9 28 22      LDA   $2228,Y
004B1: 99 32 22      STA   $2232,Y
004B4: AD 00 10      LDA   $1000
004B7: 0A            ASL 
004B8: 0A            ASL 
004B9: 0A            ASL 
004BA: 0A            ASL 
004BB: 99 28 22      STA   $2228,Y
004BE: 9C 00 10      STZ   $1000
004C1: 48            PHA 
004C2: 68            PLA 
004C3: EA            NOP 
004C4: EA            NOP 
004C5: AD 00 10      LDA   $1000
004C8: 29 0F         AND   #$0F
004CA: 19 28 22      ORA   $2228,Y
004CD: 49 FF         EOR   #$FF
004CF: 99 28 22      STA   $2228,Y
004D2: 59 32 22      EOR   $2232,Y
004D5: 39 28 22      AND   $2228,Y
004D8: 99 2D 22      STA   $222D,Y
004DB: C8            INY 
004DC: C0 05         CPY   #$05
004DE: 90 C5         BCC   $04A5
004E0: C2            CLY 
004E1: AD 27 22      LDA   $2227
004E4: 39 04 E5      AND   $E504,Y
004E7: F0 15         BEQ   $04FE
004E9: B9 2D 22      LDA   $222D,Y
004EC: C9 04         CMP   #$04
004EE: D0 0E         BNE   $04FE
004F0: B9 28 22      LDA   $2228,Y
004F3: C9 0C         CMP   #$0C
004F5: D0 07         BNE   $04FE
004F7: A9 80         LDA   #$80
004F9: 85 E7         STA   $E7
004FB: 6C 84 22      JMP   ($2284)
004FE: C8            INY 
004FF: C0 05         CPY   #$05
00501: 90 DE         BCC   $04E1
00503: 60            RTS 

00504: 01 02         ORA   ($02,X)
00506: 04 08         TSB   $08
00508: 10 AD         BPL   $04B7
0050A: 1F 22 D0      BBR1  $22, $04DD
0050D: 01 60         ORA   ($60,X)
0050F: 29 01         AND   #$01
00511: F0 02         BEQ   $0515
00513: D0 64         BNE   $0579
00515: A9 E3         LDA   #$E3
00517: 8D 86 22      STA   $2286
0051A: A9 04         LDA   #$04
0051C: 8D 89 22      STA   $2289
0051F: 8D 8A 22      STA   $228A
00522: A9 60         LDA   #$60
00524: 8D 8D 22      STA   $228D
00527: AD 22 22      LDA   $2222
0052A: F0 21         BEQ   $054D
0052C: 9C 8C 22      STZ   $228C
0052F: 0A            ASL 
00530: 0A            ASL 
00531: 0A            ASL 
00532: 0A            ASL 
00533: 2E 8C 22      ROL   $228C
00536: 0A            ASL 
00537: 2E 8C 22      ROL   $228C
0053A: 8D 8B 22      STA   $228B
0053D: 73 20 22 87 22 02 00  TII   $2220, $2287, $0002
00544: 9C 02 04      STZ   $0402
00547: 9C 03 04      STZ   $0403
0054A: 20 86 22      JSR   $2286
0054D: AD 25 22      LDA   $2225
00550: F0 23         BEQ   $0575
00552: 9C 8C 22      STZ   $228C
00555: 0A            ASL 
00556: 0A            ASL 
00557: 0A            ASL 
00558: 0A            ASL 
00559: 2E 8C 22      ROL   $228C
0055C: 0A            ASL 
0055D: 2E 8C 22      ROL   $228C
00560: 8D 8B 22      STA   $228B
00563: 73 23 22 87 22 02 00  TII   $2223, $2287, $0002
0056A: 9C 02 04      STZ   $0402
0056D: A9 01         LDA   #$01
0056F: 8D 03 04      STA   $0403
00572: 20 86 22      JSR   $2286
00575: 9C 1F 22      STZ   $221F
00578: 60            RTS 
00579: 73 D7 E5 86 22 03 00  TII   $E5D7, $2286, $0003
00580: A9 60         LDA   #$60
00582: 8D 8D 22      STA   $228D
00585: AD 22 22      LDA   $2222
00588: F0 21         BEQ   $05AB
0058A: 9C 8C 22      STZ   $228C
0058D: 0A            ASL 
0058E: 0A            ASL 
0058F: 0A            ASL 
00590: 0A            ASL 
00591: 2E 8C 22      ROL   $228C
00594: 0A            ASL 
00595: 2E 8C 22      ROL   $228C
00598: 8D 8B 22      STA   $228B
0059B: 73 20 22 89 22 02 00  TII   $2220, $2289, $0002
005A2: 9C 02 04      STZ   $0402
005A5: 9C 03 04      STZ   $0403
005A8: 20 86 22      JSR   $2286
005AB: AD 25 22      LDA   $2225
005AE: F0 23         BEQ   $05D3
005B0: 9C 8C 22      STZ   $228C
005B3: 0A            ASL 
005B4: 0A            ASL 
005B5: 0A            ASL 
005B6: 0A            ASL 
005B7: 2E 8C 22      ROL   $228C
005BA: 0A            ASL 
005BB: 2E 8C 22      ROL   $228C
005BE: 8D 8B 22      STA   $228B
005C1: 73 23 22 89 22 02 00  TII   $2223, $2289, $0002
005C8: 9C 02 04      STZ   $0402
005CB: A9 01         LDA   #$01
005CD: 8D 03 04      STA   $0403
005D0: 20 86 22      JSR   $2286
005D3: 9C 1F 22      STZ   $221F
005D6: 60            RTS 
005D7: F3 04 04 A9 00 85 F7  TAI   $0404, $00A9, $F785
005DE: 8D 00 00      STA   $0000
005E1: AD 14 22      LDA   $2214
005E4: 8D 02 00      STA   $0002
005E7: AD 15 22      LDA   $2215
005EA: 8D 03 00      STA   $0003
005ED: A9 02         LDA   #$02
005EF: 85 F7         STA   $F7
005F1: 8D 00 00      STA   $0000
005F4: 82            CLX 
005F5: 13 00         ST1   #$00
005F7: 23 00         ST2   #$00
005F9: CA            DEX 
005FA: D0 F9         BNE   $05F5
005FC: 9C 16 22      STZ   $2216
005FF: 60            RTS 
00600: DA            PHX 
00601: AA            TAX 
00602: 29 F0         AND   #$F0
00604: C9 A0         CMP   #$A0
00606: B0 16         BCS   $061E
00608: 4A            LSR 
00609: 85 EC         STA   $EC
0060B: 4A            LSR 
0060C: 4A            LSR 
0060D: 18            CLC 
0060E: 65 EC         ADC   $EC
00610: 85 EC         STA   $EC
00612: 8A            TXA 
00613: 29 0F         AND   #$0F
00615: C9 0A         CMP   #$0A
00617: B0 05         BCS   $061E
00619: 18            CLC 
0061A: 65 EC         ADC   $EC
0061C: AA            TAX 
0061D: 18            CLC 
0061E: 8A            TXA 
0061F: FA            PLX 
00620: 60            RTS 
00621: C9 64         CMP   #$64
00623: B0 16         BCS   $063B
00625: DA            PHX 
00626: A2 FF         LDX   #$FF
00628: 38            SEC 
00629: E8            INX 
0062A: E9 0A         SBC   #$0A
0062C: B0 FB         BCS   $0629
0062E: 69 0A         ADC   #$0A
00630: 22            SAX 
00631: 0A            ASL 
00632: 0A            ASL 
00633: 0A            ASL 
00634: 0A            ASL 
00635: 86 EC         STX   $EC
00637: 65 EC         ADC   $EC
00639: FA            PLX 
0063A: 18            CLC 
0063B: 60            RTS 
0063C: AD 16 22      LDA   $2216
0063F: C9 40         CMP   #$40
00641: B0 3A         BCS   $067D
00643: 5A            PHY 
00644: A9 00         LDA   #$00
00646: 85 F7         STA   $F7
00648: 8D 00 00      STA   $0000
0064B: AD 16 22      LDA   $2216
0064E: 0A            ASL 
0064F: 0A            ASL 
00650: 18            CLC 
00651: 6D 14 22      ADC   $2214
00654: 8D 02 00      STA   $0002
00657: AD 15 22      LDA   $2215
0065A: 69 00         ADC   #$00
0065C: 8D 03 00      STA   $0003
0065F: A9 02         LDA   #$02
00661: 85 F7         STA   $F7
00663: 8D 00 00      STA   $0000
00666: C2            CLY 
00667: B9 17 22      LDA   $2217,Y
0066A: 8D 02 00      STA   $0002
0066D: C8            INY 
0066E: B9 17 22      LDA   $2217,Y
00671: 8D 03 00      STA   $0003
00674: C8            INY 
00675: C0 08         CPY   #$08
00677: D0 EE         BNE   $0667
00679: EE 16 22      INC   $2216
0067C: 7A            PLY 
0067D: 60            RTS 
0067E: AD 4A 22      LDA   $224A
00681: 2A            ROL 
00682: 2A            ROL 
00683: 2A            ROL 
00684: 4D 49 22      EOR   $2249
00687: 6A            ROR 
00688: 08            PHP 
00689: AD 4A 22      LDA   $224A
0068C: 4D 49 22      EOR   $2249
0068F: 8D 4A 22      STA   $224A
00692: AD 4B 22      LDA   $224B
00695: 4D 49 22      EOR   $2249
00698: 8D 49 22      STA   $2249
0069B: 28            PLP 
0069C: 2E 49 22      ROL   $2249
0069F: 2E 4A 22      ROL   $224A
006A2: AD 4A 22      LDA   $224A
006A5: 4D 49 22      EOR   $2249
006A8: 60            RTS 
006A9: BF F5 01      BBS3  $F5, $06AD
006AC: 40            RTI 
006AD: 6C 06 22      JMP   ($2206)
006B0: 6C 04 22      JMP   ($2204)
006B3: AF F5 FA      BBS2  $F5, $06B0
006B6: 48            PHA 
006B7: DA            PHX 
006B8: 5A            PHY 
006B9: 8D 03 14      STA   $1403
006BC: A5 E6         LDA   $E6
006BE: D0 0B         BNE   $06CB
006C0: E6 E6         INC   $E6
006C2: 58            CLI 
006C3: A5 E7         LDA   $E7
006C5: D0 02         BNE   $06C9
006C7: 44 06         BSR   $06CF
006C9: 64 E6         STZ   $E6
006CB: 7A            PLY 
006CC: FA            PLX 
006CD: 68            PLA 
006CE: 40            RTI 
006CF: 43 10         TMA   #$10
006D1: 48            PHA 
006D2: 43 20         TMA   #$20
006D4: 48            PHA 
006D5: 43 40         TMA   #$40
006D7: 48            PHA 
006D8: AD EB 22      LDA   $22EB
006DB: 53 10         TAM   #$10
006DD: AD EC 22      LDA   $22EC
006E0: 53 20         TAM   #$20
006E2: A9 02         LDA   #$02
006E4: 53 40         TAM   #$40
006E6: AD DF 22      LDA   $22DF
006E9: F0 0F         BEQ   $06FA
006EB: 20 12 CD      JSR   $CD12
006EE: C9 00         CMP   #$00
006F0: D0 08         BNE   $06FA
006F2: AD DE 22      LDA   $22DE
006F5: 09 40         ORA   #$40
006F7: 8D DE 22      STA   $22DE
006FA: AD DF 22      LDA   $22DF
006FD: C9 01         CMP   #$01
006FF: F0 0F         BEQ   $0710
00701: 20 EF C2      JSR   $C2EF
00704: C9 00         CMP   #$00
00706: D0 08         BNE   $0710
00708: AD DE 22      LDA   $22DE
0070B: 09 80         ORA   #$80
0070D: 8D DE 22      STA   $22DE
00710: A5 E7         LDA   $E7
00712: 29 01         AND   #$01
00714: D0 0D         BNE   $0723
00716: AD D4 22      LDA   $22D4
00719: 30 08         BMI   $0723
0071B: 8D 00 0C      STA   $0C00
0071E: 09 80         ORA   #$80
00720: 8D D4 22      STA   $22D4
00723: 68            PLA 
00724: 53 40         TAM   #$40
00726: 68            PLA 
00727: 53 20         TAM   #$20
00729: 68            PLA 
0072A: 53 10         TAM   #$10
0072C: AD ED 22      LDA   $22ED
0072F: 8D 00 08      STA   $0800
00732: 60            RTS 

00733: 6C 00 22      JMP   ($2200)
IRQ2_INT:
00736: 8F F5 FA      BBS0  $F5, $0733
00739: 48            PHA 
0073A: DA            PHX 
0073B: 5A            PHY 
0073C: 44 04         BSR   IRQ2_INT2		;$0742
0073E: 7A            PLY 
0073F: FA            PLX 
00740: 68            PLA 
00741: 40            RTI 
IRQ2_INT2:
00742: AD 02 18      LDA   $1802
00745: 2D 03 18      AND   $1803
00748: 05 F2         ORA   $F2
0074A: 85 F2         STA   $F2
0074C: 2F F2 64      BBR2  $F2, $07B3
0074F: A9 04         LDA   #$04
00751: 1C 02 18      TRB   $1802
00754: A9 04         LDA   #$04
00756: 14 F2         TRB   $F2
00758: 58            CLI 
00759: AD 9E 22      LDA   $229E
0075C: 0D 9F 22      ORA   $229F
0075F: 0D A0 22      ORA   $22A0
00762: F0 4F         BEQ   $07B3
00764: AD 00 18      LDA   $1800
00767: 29 80         AND   #$80
00769: F0 08         BEQ   $0773
0076B: 9C A4 22      STZ   $22A4
0076E: 20 CE F6      JSR   $F6CE
00771: 80 40         BRA   $07B3

00773: 20 EE F0      JSR   $F0EE
00776: A9 08         LDA   #$08
00778: 8D 4C 22      STA   $224C
0077B: AD A1 22      LDA   $22A1
0077E: 8D 4D 22      STA   $224D
00781: AD A2 22      LDA   $22A2
00784: 8D 4E 22      STA   $224E
00787: AD A3 22      LDA   $22A3
0078A: 8D 4F 22      STA   $224F
0078D: A2 10         LDX   #$10
0078F: AD 9F 22      LDA   $229F
00792: 0D A0 22      ORA   $22A0
00795: D0 08         BNE   $079F
00797: AD 9E 22      LDA   $229E
0079A: C9 10         CMP   #$10
0079C: B0 01         BCS   $079F
0079E: AA            TAX 
0079F: 8A            TXA 
007A0: 8D 9D 22      STA   $229D
007A3: 8D 50 22      STA   $2250
007A6: A9 01         LDA   #$01
007A8: 8D A4 22      STA   $22A4
007AB: 20 05 E9      JSR   $E905
007AE: A9 60         LDA   #$60
007B0: 0C 02 18      TSB   $1802
007B3: 6F F2 0F      BBR6  $F2, $07C5
007B6: A9 40         LDA   #$40
007B8: 1C 02 18      TRB   $1802
007BB: A9 40         LDA   #$40
007BD: 14 F2         TRB   $F2
007BF: 58            CLI 
007C0: A9 02         LDA   #$02
007C2: 8D 0B 18      STA   $180B
007C5: 5F F2 65      BBR5  $F2, $082D
007C8: A9 20         LDA   #$20
007CA: 1C 02 18      TRB   $1802
007CD: A9 20         LDA   #$20
007CF: 14 F2         TRB   $F2
007D1: 58            CLI 
007D2: AD A4 22      LDA   $22A4
007D5: F0 03         BEQ   $07DA
007D7: 9C 0B 18      STZ   $180B
007DA: AD 01 18      LDA   $1801
007DD: 8D 7B 22      STA   $227B
007E0: F0 06         BEQ   $07E8
007E2: 9C A4 22      STZ   $22A4
007E5: 20 CE F6      JSR   $F6CE
007E8: A9 80         LDA   #$80
007EA: 0C 02 18      TSB   $1802
007ED: 93 40 00 18   TST   $40, $1800
007F1: D0 FA         BNE   $07ED
007F3: A9 80         LDA   #$80
007F5: 1C 02 18      TRB   $1802
007F8: AD 00 18      LDA   $1800
007FB: 29 F8         AND   #$F8
007FD: C9 F8         CMP   #$F8
007FF: D0 F7         BNE   $07F8
00801: AD 01 18      LDA   $1801
00804: A9 80         LDA   #$80
00806: 0C 02 18      TSB   $1802
00809: 93 40 00 18   TST   $40, $1800
0080D: D0 FA         BNE   $0809
0080F: A9 80         LDA   #$80
00811: 1C 02 18      TRB   $1802
00814: 93 80 00 18   TST   $80, $1800
00818: D0 FA         BNE   $0814
0081A: AD A4 22      LDA   $22A4
0081D: F0 0E         BEQ   $082D
0081F: 9C A4 22      STZ   $22A4
00822: 20 8C F6      JSR   $F68C
00825: 9C 9D 22      STZ   $229D
00828: A9 04         LDA   #$04
0082A: 0C 02 18      TSB   $1802
0082D: 4F F2 12      BBR4  $F2, $0842
00830: A9 10         LDA   #$10
00832: 1C 02 18      TRB   $1802
00835: A9 10         LDA   #$10
00837: 14 F2         TRB   $F2
00839: 58            CLI 
0083A: 20 5A F3      JSR   $F35A
0083D: A9 10         LDA   #$10
0083F: 0C 02 18      TSB   $1802
00842: 3F F2 21      BBR3  $F2, $0866
00845: A9 0C         LDA   #$0C
00847: 1C 02 18      TRB   $1802
0084A: A9 08         LDA   #$08
0084C: 14 F2         TRB   $F2
0084E: A9 60         LDA   #$60
00850: 1C 0D 18      TRB   $180D
00853: 20 CE F6      JSR   $F6CE
00856: 58            CLI 
00857: AD A5 22      LDA   $22A5
0085A: F0 0A         BEQ   $0866
0085C: AD 0C 18      LDA   $180C
0085F: 29 08         AND   #$08
00861: D0 F9         BNE   $085C
00863: 20 F5 F5      JSR   $F5F5
00866: 60            RTS 

00867: 6C 0A 22      JMP   ($220A)
0086A: 6C 08 22      JMP   ($2208)
0086D: 6C 02 22      JMP   ($2202)
IRQ1_INT:
00870: 9F F5 FA      BBS1  $F5, $086D
00873: 48            PHA 
00874: DA            PHX 
00875: 5A            PHY 
00876: AD 00 00      LDA   $0000
00879: 85 F6         STA   $F6
0087B: 5F F6 3B      BBR5  $F6, $08B9
0087E: 03 05         ST0   #$05
00880: A5 F3         LDA   $F3
00882: 8D 02 00      STA   $0002
00885: A5 F4         LDA   $F4
00887: 8D 03 00      STA   $0003
0088A: EE 41 22      INC   $2241
0088D: DF F5 24      BBS5  $F5, $08B4
00890: 03 07         ST0   #$07
00892: 73 0C 22 02 00 02 00  TII   $220C, $0002, $0002
00899: 03 08         ST0   #$08
0089B: 73 10 22 02 00 02 00  TII   $2210, $0002, $0002
008A2: 20 09 E5      JSR   $E509
008A5: EE 49 22      INC   $2249
008A8: A5 E7         LDA   $E7
008AA: C9 01         CMP   #$01
008AC: D0 03         BNE   $08B1
008AE: 20 CF E6      JSR   $E6CF
008B1: 20 9A E4      JSR   $E49A
008B4: 4F F5 02      BBR4  $F5, $08B9
008B7: 44 B1         BSR   $086A
008B9: 2F F6 1E      BBR2  $F6, $08DA
008BC: FF F5 16      BBS7  $F5, $08D5
008BF: 44 A5         BSR   $0866
008C1: 44 A3         BSR   $0866
008C3: 03 07         ST0   #$07
008C5: 73 0E 22 02 00 02 00  TII   $220E, $0002, $0002
008CC: 03 08         ST0   #$08
008CE: 73 12 22 02 00 02 00  TII   $2212, $0002, $0002
008D5: 6F F5 02      BBR6  $F5, $08DA
008D8: 44 8D         BSR   $0867
008DA: A5 F7         LDA   $F7
008DC: 8D 00 00      STA   $0000
008DF: 7A            PLY 
008E0: FA            PLX 
008E1: 68            PLA 
008E2: 40            RTI 

CD_RESET:
008E3: A9 02         LDA   #$02
008E5: 0C 04 18      TSB   $1804
008E8: A0 0A         LDY   #$0A
008EA: A2 3B         LDX   #$3B
008EC: CA            DEX 
008ED: D0 FD         BNE   $08EC
008EF: 88            DEY 
008F0: D0 F8         BNE   $08EA
008F2: AD 04 18      LDA   $1804
008F5: 29 FD         AND   #$FD
008F7: 8D 04 18      STA   $1804
008FA: A2 77         LDX   #$77
008FC: CA            DEX 
008FD: D0 FD         BNE   $08FC
008FF: 60            RTS 

00900: AD A4 22      LDA   $22A4
00903: D0 FB         BNE   $0900

00905: 9C 9B 22      STZ   $229B
00908: A9 81         LDA   #$81
0090A: 8D 01 18      STA   $1801
0090D: 93 80 00 18   TST   $80, $1800
00911: F0 31         BEQ   $0944
00913: A9 60         LDA   #$60
00915: 1C 02 18      TRB   $1802
00918: 8D 00 18      STA   $1800
0091B: A2 95         LDX   #$95
0091D: A9 ED         LDA   #$ED
0091F: 3A            DEC 
00920: D0 FD         BNE   $091F
00922: EA            NOP 
00923: EA            NOP 
00924: EA            NOP 
00925: CA            DEX 
00926: D0 F5         BNE   $091D
00928: A9 FF         LDA   #$FF
0092A: 8D 01 18      STA   $1801
0092D: 93 40 00 18   TST   $40, $1800
00931: F0 D5         BEQ   $0908
00933: 20 27 EA      JSR   $EA27
00936: 93 40 00 18   TST   $40, $1800
0093A: D0 F7         BNE   $0933
0093C: 93 80 00 18   TST   $80, $1800
00940: D0 F4         BNE   $0936
00942: 80 C4         BRA   $0908

00944: 8D 00 18      STA   $1800
00947: 82            CLX 
00948: AD 00 18      LDA   $1800
0094B: 29 40         AND   #$40
0094D: D0 0B         BNE   $095A
0094F: A9 5A         LDA   #$5A
00951: 3A            DEC 
00952: D0 FD         BNE   $0951
00954: EA            NOP 
00955: CA            DEX 
00956: D0 F0         BNE   $0948
00958: 80 AE         BRA   $0908
0095A: 9C 7A 22      STZ   $227A
0095D: 82            CLX 
0095E: AD 00 18      LDA   $1800
00961: 29 F8         AND   #$F8
00963: 8D 7A 22      STA   $227A
00966: C9 D0         CMP   #$D0
00968: F0 10         BEQ   $097A
0096A: 29 B8         AND   #$B8
0096C: C9 98         CMP   #$98
0096E: F0 1A         BEQ   $098A
00970: C9 88         CMP   #$88
00972: F0 16         BEQ   $098A
00974: C9 80         CMP   #$80
00976: F0 12         BEQ   $098A
00978: 80 E4         BRA   $095E
0097A: BD 4C 22      LDA   $224C,X
0097D: E8            INX 
0097E: 8D 01 18      STA   $1801
00981: EA            NOP 
00982: EA            NOP 
00983: EA            NOP 
00984: EA            NOP 
00985: 20 27 EA      JSR   $EA27
00988: 80 D4         BRA   $095E
0098A: AD A4 22      LDA   $22A4
0098D: 0D 48 22      ORA   $2248
00990: D0 32         BNE   $09C4
00992: AD 4C 22      LDA   $224C
00995: C9 D9         CMP   #$D9
00997: D0 0B         BNE   $09A4
00999: AD 4D 22      LDA   $224D
0099C: C9 01         CMP   #$01
0099E: F0 24         BEQ   $09C4
009A0: C9 02         CMP   #$02
009A2: F0 20         BEQ   $09C4
009A4: AE 41 22      LDX   $2241
009A7: AD 00 18      LDA   $1800
009AA: 29 F8         AND   #$F8
009AC: 8D 7A 22      STA   $227A
009AF: 89 40         BIT   #$40
009B1: D0 11         BNE   $09C4
009B3: 8A            TXA 
009B4: 38            SEC 
009B5: ED 41 22      SBC   $2241
009B8: 49 FF         EOR   #$FF
009BA: 1A            INC 
009BB: C9 FE         CMP   #$FE
009BD: 90 E8         BCC   $09A7
009BF: A9 01         LDA   #$01
009C1: 8D 9B 22      STA   $229B
009C4: 60            RTS 

cd_read_status:
009C5: AD 9B 22      LDA   $229B
009C8: F0 09         BEQ   $09D3
009CA: 9C 9B 22      STZ   $229B
009CD: 20 E3 E8      JSR   CD_RESET		;$E8E3
009D0: A9 06         LDA   #$06
009D2: 60            RTS 
009D3: 20 DC E9      JSR   cd_read_status2;$E9DC
009D6: D0 03         BNE   $09DB
009D8: 9C 7C 22      STZ   $227C
009DB: 60            RTS 

cd_read_status2:
009DC: 9C 7B 22      STZ   $227B
009DF: AD 00 18      LDA   $1800
009E2: 29 F8         AND   #$F8
009E4: 8D 7A 22      STA   $227A
009E7: C9 D8         CMP   #$D8
009E9: D0 F4         BNE   $09DF
009EB: AD 01 18      LDA   $1801
009EE: 8D 7B 22      STA   $227B
009F1: 44 42         BSR   $0A35
009F3: 93 40 00 18   TST   $40, $1800
009F7: D0 FA         BNE   $09F3
009F9: 44 34         BSR   $0A2F
009FB: AD 00 18      LDA   $1800
009FE: 29 F8         AND   #$F8
00A00: 8D 7A 22      STA   $227A
00A03: C9 F8         CMP   #$F8
00A05: F0 06         BEQ   $0A0D
00A07: C9 D8         CMP   #$D8
00A09: D0 F0         BNE   $09FB
00A0B: 80 D2         BRA   $09DF
00A0D: AD 01 18      LDA   $1801
00A10: 8D 7A 22      STA   $227A
00A13: 44 20         BSR   $0A35
00A15: 93 40 00 18   TST   $40, $1800
00A19: D0 FA         BNE   $0A15
00A1B: 44 12         BSR   $0A2F
00A1D: 93 80 00 18   TST   $80, $1800
00A21: D0 FA         BNE   $0A1D
00A23: AD 7B 22      LDA   $227B
00A26: 60            RTS 

00A27: 44 0C         BSR   $0A35
00A29: 93 40 00 18   TST   $40, $1800
00A2D: D0 FA         BNE   $0A29
00A2F: A9 80         LDA   #$80
00A31: 1C 02 18      TRB   $1802
00A34: 60            RTS 
00A35: A9 80         LDA   #$80
00A37: 0C 02 18      TSB   $1802
00A3A: 60            RTS 
00A3B: AD 00 18      LDA   $1800
00A3E: 29 F8         AND   #$F8
00A40: 8D 7A 22      STA   $227A
00A43: C9 C8         CMP   #$C8
00A45: F0 06         BEQ   $0A4D
00A47: C9 D8         CMP   #$D8
00A49: F0 1C         BEQ   $0A67
00A4B: 80 EE         BRA   $0A3B
00A4D: AD 01 18      LDA   $1801
00A50: 92 FA         STA   ($FA)
00A52: 44 D3         BSR   $0A27
00A54: E6 FA         INC   $FA
00A56: D0 02         BNE   $0A5A
00A58: E6 FB         INC   $FB
00A5A: A5 F8         LDA   $F8
00A5C: D0 02         BNE   $0A60
00A5E: C6 F9         DEC   $F9
00A60: 3A            DEC 
00A61: 85 F8         STA   $F8
00A63: 05 F9         ORA   $F9
00A65: D0 D4         BNE   $0A3B
00A67: AD 00 18      LDA   $1800
00A6A: 29 F8         AND   #$F8
00A6C: 8D 7A 22      STA   $227A
00A6F: 29 B8         AND   #$B8
00A71: C9 88         CMP   #$88
00A73: D0 03         BNE   $0A78
00A75: 4C 5E EB      JMP   $EB5E
00A78: 60            RTS 

00A79: AD 00 18      LDA   $1800
00A7C: 29 F8         AND   #$F8
00A7E: 8D 7A 22      STA   $227A
00A81: C9 C8         CMP   #$C8
00A83: F0 06         BEQ   $0A8B
00A85: C9 D8         CMP   #$D8
00A87: F0 34         BEQ   $0ABD
00A89: 80 EE         BRA   $0A79
00A8B: A5 F8         LDA   $F8
00A8D: 05 F9         ORA   $F9
00A8F: F0 24         BEQ   $0AB5
00A91: A2 03         LDX   #$03
00A93: CA            DEX 
00A94: D0 FD         BNE   $0A93
00A96: C2            CLY 
00A97: A2 08         LDX   #$08
00A99: AD 08 18      LDA   $1808
00A9C: 91 FA         STA   ($FA),Y
00A9E: A5 F8         LDA   $F8
00AA0: D0 02         BNE   $0AA4
00AA2: C6 F9         DEC   $F9
00AA4: 3A            DEC 
00AA5: 85 F8         STA   $F8
00AA7: 05 F9         ORA   $F9
00AA9: F0 0A         BEQ   $0AB5
00AAB: C8            INY 
00AAC: D0 EB         BNE   $0A99
00AAE: E6 FB         INC   $FB
00AB0: CA            DEX 
00AB1: D0 E6         BNE   $0A99
00AB3: 80 C4         BRA   $0A79
00AB5: AD 00 18      LDA   $1800
00AB8: 29 F8         AND   #$F8
00ABA: 8D 7A 22      STA   $227A
00ABD: 60            RTS 

00ABE: AD 00 18      LDA   $1800
00AC1: 29 F8         AND   #$F8
00AC3: 8D 7A 22      STA   $227A
00AC6: C9 C8         CMP   #$C8
00AC8: F0 06         BEQ   $0AD0
00ACA: C9 D8         CMP   #$D8
00ACC: F0 37         BEQ   $0B05
00ACE: 80 EE         BRA   $0ABE
00AD0: A2 03         LDX   #$03
00AD2: CA            DEX 
00AD3: D0 FD         BNE   $0AD2
00AD5: C2            CLY 
00AD6: A2 04         LDX   #$04
00AD8: AD 08 18      LDA   $1808
00ADB: 8D 02 00      STA   $0002
00ADE: EA            NOP 
00ADF: EA            NOP 
00AE0: EA            NOP 
00AE1: EA            NOP 
00AE2: EA            NOP 
00AE3: EA            NOP 
00AE4: EA            NOP 
00AE5: EA            NOP 
00AE6: AD 08 18      LDA   $1808
00AE9: 8D 03 00      STA   $0003
00AEC: A5 F8         LDA   $F8
00AEE: 38            SEC 
00AEF: E9 02         SBC   #$02
00AF1: 85 F8         STA   $F8
00AF3: A5 F9         LDA   $F9
00AF5: E9 00         SBC   #$00
00AF7: 85 F9         STA   $F9
00AF9: 05 F8         ORA   $F8
00AFB: F0 08         BEQ   $0B05
00AFD: 88            DEY 
00AFE: D0 D8         BNE   $0AD8
00B00: CA            DEX 
00B01: D0 D5         BNE   $0AD8
00B03: 80 B9         BRA   $0ABE
00B05: AD 00 18      LDA   $1800
00B08: 29 F8         AND   #$F8
00B0A: 8D 7A 22      STA   $227A
00B0D: 29 B8         AND   #$B8
00B0F: C9 88         CMP   #$88
00B11: D0 02         BNE   $0B15
00B13: 80 49         BRA   $0B5E
00B15: 60            RTS 
00B16: A9 02         LDA   #$02
00B18: 85 FA         STA   $FA
00B1A: A9 00         LDA   #$00
00B1C: 85 FB         STA   $FB
00B1E: AD 00 18      LDA   $1800
00B21: 29 F8         AND   #$F8
00B23: 8D 7A 22      STA   $227A
00B26: C9 C8         CMP   #$C8
00B28: F0 06         BEQ   $0B30
00B2A: C9 D8         CMP   #$D8
00B2C: F0 2F         BEQ   $0B5D
00B2E: 80 EE         BRA   $0B1E
00B30: AD 01 18      LDA   $1801
00B33: 92 FA         STA   ($FA)
00B35: 20 27 EA      JSR   $EA27
00B38: A5 FA         LDA   $FA
00B3A: 49 01         EOR   #$01
00B3C: 85 FA         STA   $FA
00B3E: A5 F8         LDA   $F8
00B40: 38            SEC 
00B41: E9 01         SBC   #$01
00B43: 85 F8         STA   $F8
00B45: A5 F9         LDA   $F9
00B47: E9 00         SBC   #$00
00B49: 85 F9         STA   $F9
00B4B: 05 F8         ORA   $F8
00B4D: D0 CF         BNE   $0B1E
00B4F: AD 00 18      LDA   $1800
00B52: 29 F8         AND   #$F8
00B54: 8D 7A 22      STA   $227A
00B57: 29 B8         AND   #$B8
00B59: C9 88         CMP   #$88
00B5B: F0 01         BEQ   $0B5E
00B5D: 60            RTS 
00B5E: AD 00 18      LDA   $1800
00B61: 29 F8         AND   #$F8
00B63: 8D 7A 22      STA   $227A
00B66: C9 C8         CMP   #$C8
00B68: F0 06         BEQ   $0B70
00B6A: C9 D8         CMP   #$D8
00B6C: F0 1D         BEQ   $0B8B
00B6E: 80 EE         BRA   $0B5E
00B70: A2 05         LDX   #$05
00B72: CA            DEX 
00B73: D0 FD         BNE   $0B72
00B75: C2            CLY 
00B76: A2 08         LDX   #$08
00B78: AD 08 18      LDA   $1808
00B7B: EA            NOP 
00B7C: EA            NOP 
00B7D: EA            NOP 
00B7E: EA            NOP 
00B7F: EA            NOP 
00B80: EA            NOP 
00B81: EA            NOP 
00B82: EA            NOP 
00B83: C8            INY 
00B84: D0 F2         BNE   $0B78
00B86: CA            DEX 
00B87: D0 EF         BNE   $0B78
00B89: 80 D3         BRA   $0B5E
00B8B: AD 7A 22      LDA   $227A
00B8E: 60            RTS 

CD_BASE:
00B8F: A5 FB         LDA   $FB
00B91: F0 34         BEQ   $0BC7
00B93: EF FB 15      BBS6  $FB, $0BAB
00B96: A5 F8         LDA   $F8
00B98: 85 F9         STA   $F9
00B9A: A9 02         LDA   #$02
00B9C: 85 F8         STA   $F8
00B9E: A9 56         LDA   #$56
00BA0: 85 FA         STA   $FA
00BA2: A9 22         LDA   #$22
00BA4: 85 FB         STA   $FB
00BA6: 20 F1 EF      JSR   $EFF1
00BA9: 80 0F         BRA   $0BBA

00BAB: A5 F8         LDA   $F8
00BAD: 8D 56 22      STA   $2256
00BB0: A5 F9         LDA   $F9
00BB2: 8D 57 22      STA   $2257
00BB5: A5 FA         LDA   $FA
00BB7: 8D 58 22      STA   $2258

00BBA: 43 40         TMA   #$40
00BBC: 48            PHA 
00BBD: A9 01         LDA   #$01
00BBF: 53 40         TAM   #$40
00BC1: 20 17 CC      JSR   $CC17
00BC4: 68            PLA 
00BC5: 53 40         TAM   #$40
00BC7: 9F FC 0F      BBS1  $FC, $0BD9
00BCA: A5 F8         LDA   $F8
00BCC: 8D 74 22      STA   $2274
00BCF: A5 F9         LDA   $F9
00BD1: 8D 75 22      STA   $2275
00BD4: A5 FA         LDA   $FA
00BD6: 8D 76 22      STA   $2276
00BD9: 8F FC 0F      BBS0  $FC, $0BEB
00BDC: A5 F8         LDA   $F8
00BDE: 8D 77 22      STA   $2277
00BE1: A5 F9         LDA   $F9
00BE3: 8D 78 22      STA   $2278
00BE6: A5 FA         LDA   $FA
00BE8: 8D 79 22      STA   $2279
00BEB: 60            RTS 

CD_EXEC:
00BEC: A5 FA         LDA   $FA
00BEE: 8D 82 22      STA   $2282
00BF1: A5 FB         LDA   $FB
00BF3: 8D 83 22      STA   $2283
00BF6: 44 0D         BSR   $0C05
00BF8: C9 00         CMP   #$00
00BFA: F0 03         BEQ   $0BFF
00BFC: 4C F3 E0      JMP   $E0F3
00BFF: A2 FF         LDX   #$FF
00C01: 9A            TXS 
00C02: 6C 82 22      JMP   ($2282)

CD_READ:
00C05: 9C 73 22      STZ   $2273
00C08: 20 09 F3      JSR   cd_save_param		;$F309
00C0B: 20 EE F0      JSR   cd_clear_ram_024C	;$F0EE
00C0E: A9 08         LDA   #$08
00C10: 8D 4C 22      STA   $224C
00C13: 20 04 F1      JSR   cd_calc_lba		;$F104
00C16: A2 04         LDX   #$04
00C18: A0 01         LDY   #$01
00C1A: 20 27 F3      JSR   cd_copy_lba		;$F327
00C1D: A5 FF         LDA   _DH			;data read address type
00C1F: C9 02         CMP   #$02
00C21: 90 0E         BCC   CD_READ_LOCAL		;$0C31
00C23: C9 FF         CMP   #$FF
00C25: F0 52         BEQ   CD_READ_VRAM		;$0C79
00C27: C9 FE         CMP   #$FE
00C29: D0 03         BNE   $0C2E
00C2B: 4C BB EC      JMP   $ECBB
00C2E: 4C 03 ED      JMP   CD_READ_MPR		;$ED03
CD_READ_LOCAL:
00C31: A5 FF         LDA   $FF
00C33: F0 0E         BEQ   $0C43
00C35: A5 F8         LDA   $F8
00C37: 8D 80 22      STA   $2280
00C3A: 0A            ASL 
00C3B: 0A            ASL 
00C3C: 0A            ASL 
00C3D: 85 F9         STA   $F9
00C3F: 64 F8         STZ   $F8
00C41: 80 03         BRA   $0C46
00C43: 20 9F ED      JSR   $ED9F
00C46: AD 80 22      LDA   $2280
00C49: F0 2B         BEQ   $0C76
00C4B: 8D 50 22      STA   $2250
00C4E: 20 00 E9      JSR   $E900
00C51: C9 C8         CMP   #$C8
00C53: D0 0A         BNE   $0C5F
00C55: 20 79 EA      JSR   $EA79
00C58: C9 C8         CMP   #$C8
00C5A: D0 03         BNE   $0C5F
00C5C: 20 5E EB      JSR   $EB5E
00C5F: 20 C5 E9      JSR   $E9C5
00C62: C9 00         CMP   #$00
00C64: F0 06         BEQ   $0C6C
00C66: 20 0B E2      JSR   $E20B
00C69: 90 08         BCC   $0C73
00C6B: 60            RTS 
00C6C: A5 F8         LDA   $F8
00C6E: 05 F9         ORA   $F9
00C70: D0 01         BNE   $0C73
00C72: 60            RTS 
00C73: 4C F1 EC      JMP   $ECF1
00C76: A9 22         LDA   #$22
00C78: 60            RTS 
CD_READ_VRAM:
00C79: A5 F8         LDA   $F8
00C7B: F0 F9         BEQ   $0C76
00C7D: 8D 50 22      STA   $2250
00C80: 20 00 E9      JSR   $E900
00C83: C9 C8         CMP   #$C8
00C85: D0 20         BNE   $0CA7
00C87: A5 F8         LDA   $F8
00C89: 0A            ASL 
00C8A: 0A            ASL 
00C8B: 0A            ASL 
00C8C: 85 F9         STA   $F9
00C8E: 64 F8         STZ   $F8
00C90: A9 00         LDA   #$00
00C92: 85 F7         STA   $F7
00C94: 8D 00 00      STA   $0000
00C97: 20 37 F3      JSR   $F337
00C9A: A9 02         LDA   #$02
00C9C: 85 F7         STA   $F7
00C9E: 8D 00 00      STA   $0000
00CA1: 20 BE EA      JSR   $EABE
00CA4: 9C 72 22      STZ   $2272
00CA7: 20 C5 E9      JSR   $E9C5
00CAA: C9 00         CMP   #$00
00CAC: F0 06         BEQ   $0CB4
00CAE: 20 0B E2      JSR   $E20B
00CB1: 90 3E         BCC   $0CF1
00CB3: 60            RTS 
00CB4: A5 F8         LDA   $F8
00CB6: 05 F9         ORA   $F9
00CB8: D0 37         BNE   $0CF1
00CBA: 60            RTS 

00CBB: 20 9F ED      JSR   $ED9F
00CBE: AD 80 22      LDA   $2280
00CC1: F0 B3         BEQ   $0C76
00CC3: 8D 50 22      STA   $2250
00CC6: 20 00 E9      JSR   $E900
00CC9: C9 C8         CMP   #$C8
00CCB: D0 17         BNE   $0CE4
00CCD: A9 00         LDA   #$00
00CCF: 85 F7         STA   $F7
00CD1: 8D 00 00      STA   $0000
00CD4: 20 37 F3      JSR   $F337
00CD7: A9 02         LDA   #$02
00CD9: 85 F7         STA   $F7
00CDB: 8D 00 00      STA   $0000
00CDE: 20 16 EB      JSR   $EB16
00CE1: 9C 72 22      STZ   $2272
00CE4: 20 C5 E9      JSR   $E9C5
00CE7: C9 00         CMP   #$00
00CE9: F0 C9         BEQ   $0CB4
00CEB: 20 0B E2      JSR   $E20B
00CEE: 90 01         BCC   $0CF1
00CF0: 60            RTS 
00CF1: 20 18 F3      JSR   $F318
00CF4: AD 7C 22      LDA   $227C
00CF7: C9 10         CMP   #$10
00CF9: 90 05         BCC   $0D00
00CFB: A9 01         LDA   #$01
00CFD: 8D 73 22      STA   $2273
00D00: 4C 0B EC      JMP   $EC0B
CD_READ_MPR:
00D03: A6 F8         LDX   _AL			;rec length
00D05: F0 04         BEQ   $0D0B
00D07: C9 07         CMP   #$07
00D09: 30 03         BMI   CD_READ_MPR2		;$0D0E
00D0B: A9 22         LDA   #$22
00D0D: 60            RTS 
CD_READ_MPR2:
00D0E: AA            TAX 
00D0F: A9 01         LDA   #$01
00D11: 0A            ASL 
00D12: CA            DEX 
00D13: D0 FC         BNE   $0D11
00D15: 8D 8F 22      STA   $228F
00D18: A9 43         LDA   #$43
00D1A: 8D 8E 22      STA   $228E
00D1D: A9 60         LDA   #$60
00D1F: 8D 90 22      STA   $2290
00D22: 20 8E 22      JSR   $228E
00D25: 8D 68 22      STA   $2268
00D28: A5 FA         LDA   _BL
00D2A: 85 FE         STA   _DL
00D2C: A5 F8         LDA   _AL
00D2E: 8D 50 22      STA   $2250
00D31: 4A            LSR 
00D32: 4A            LSR 
00D33: 8D 80 22      STA   $2280
00D36: A5 F8         LDA   _AL
00D38: 29 03         AND   #$03
00D3A: 8D 81 22      STA   $2281
00D3D: 20 00 E9      JSR   $E900
00D40: 09 40         ORA   #$40
00D42: C9 C8         CMP   #$C8
00D44: D0 3C         BNE   $0D82
00D46: AD 80 22      LDA   $2280
00D49: F0 06         BEQ   $0D51
00D4B: A9 20         LDA   #$20
00D4D: 85 F9         STA   _AH
00D4F: 80 0A         BRA   $0D5B
00D51: AD 81 22      LDA   $2281
00D54: F0 2C         BEQ   $0D82
00D56: 0A            ASL 
00D57: 0A            ASL 
00D58: 0A            ASL 
00D59: 85 F9         STA   _AH
00D5B: 64 F8         STZ   _AL
00D5D: A5 FF         LDA   _DH
00D5F: 0A            ASL 
00D60: 0A            ASL 
00D61: 0A            ASL 
00D62: 0A            ASL 
00D63: 0A            ASL 
00D64: 85 FB         STA   $FB
00D66: 64 FA         STZ   $FA
00D68: A9 53         LDA   #$53
00D6A: 8D 8E 22      STA   $228E
00D6D: A5 FE         LDA   $FE
00D6F: 20 8E 22      JSR   $228E
00D72: 20 79 EA      JSR   $EA79
00D75: 09 40         ORA   #$40
00D77: C9 C8         CMP   #$C8
00D79: D0 07         BNE   $0D82
00D7B: E6 FE         INC   $FE
00D7D: CE 80 22      DEC   $2280
00D80: 10 C4         BPL   $0D46
00D82: 20 C5 E9      JSR   $E9C5
00D85: C9 00         CMP   #$00
00D87: F0 08         BEQ   $0D91
00D89: 20 0B E2      JSR   $E20B
00D8C: B0 03         BCS   $0D91
00D8E: 4C F1 EC      JMP   $ECF1
00D91: 48            PHA 
00D92: A9 53         LDA   #$53
00D94: 8D 8E 22      STA   $228E
00D97: AD 68 22      LDA   $2268
00D9A: 20 8E 22      JSR   $228E
00D9D: 68            PLA 
00D9E: 60            RTS 

00D9F: A9 01         LDA   #$01
00DA1: 8D 81 22      STA   $2281
00DA4: A5 F9         LDA   $F9
00DA6: 4A            LSR 
00DA7: 90 03         BCC   $0DAC
00DA9: 9C 81 22      STZ   $2281
00DAC: 4A            LSR 
00DAD: 90 03         BCC   $0DB2
00DAF: 9C 81 22      STZ   $2281
00DB2: 4A            LSR 
00DB3: 90 03         BCC   $0DB8
00DB5: 9C 81 22      STZ   $2281
00DB8: 8D 80 22      STA   $2280
00DBB: A5 F8         LDA   $F8
00DBD: F0 03         BEQ   $0DC2
00DBF: 9C 81 22      STZ   $2281
00DC2: AD 81 22      LDA   $2281
00DC5: D0 03         BNE   $0DCA
00DC7: EE 80 22      INC   $2280
00DCA: 60            RTS 

CD_SEEK:
00DCB: 9C 73 22      STZ   $2273
00DCE: 20 09 F3      JSR   $F309
00DD1: 20 EE F0      JSR   $F0EE
00DD4: A9 08         LDA   #$08
00DD6: 8D 4C 22      STA   $224C
00DD9: 20 04 F1      JSR   $F104
00DDC: A2 04         LDX   #$04
00DDE: A0 01         LDY   #$01
00DE0: 20 27 F3      JSR   $F327
00DE3: A9 01         LDA   #$01
00DE5: 8D 50 22      STA   $2250
00DE8: 20 00 E9      JSR   $E900
00DEB: C9 C8         CMP   #$C8
00DED: D0 03         BNE   $0DF2
00DEF: 20 5E EB      JSR   $EB5E
00DF2: 20 C5 E9      JSR   $E9C5
00DF5: C9 00         CMP   #$00
00DF7: F0 05         BEQ   $0DFE
00DF9: 20 0B E2      JSR   $E20B
00DFC: 90 01         BCC   $0DFF
00DFE: 60            RTS 
00DFF: 20 18 F3      JSR   $F318
00E02: AD 7C 22      LDA   $227C
00E05: C9 10         CMP   #$10
00E07: 90 C8         BCC   $0DD1
00E09: A9 01         LDA   #$01
00E0B: 8D 73 22      STA   $2273
00E0E: 80 C1         BRA   $0DD1

CD_PLAY:
00E10: 20 09 F3      JSR   $F309
00E13: 20 EE F0      JSR   $F0EE
00E16: A5 FB         LDA   $FB
00E18: 29 C0         AND   #$C0
00E1A: C9 C0         CMP   #$C0
00E1C: F0 37         BEQ   $0E55
00E1E: C9 80         CMP   #$80
00E20: D0 04         BNE   $0E26
00E22: 64 F9         STZ   $F9
00E24: 64 FA         STZ   $FA
00E26: 8D 55 22      STA   $2255
00E29: A9 D8         LDA   #$D8
00E2B: 8D 4C 22      STA   $224C
00E2E: A5 FB         LDA   $FB
00E30: D0 08         BNE   $0E3A
00E32: 82            CLX 
00E33: A0 03         LDY   #$03
00E35: 20 27 F3      JSR   $F327
00E38: 80 06         BRA   $0E40
00E3A: 82            CLX 
00E3B: A0 02         LDY   #$02
00E3D: 20 27 F3      JSR   $F327
00E40: 20 00 E9      JSR   $E900
00E43: 20 C5 E9      JSR   $E9C5
00E46: C9 00         CMP   #$00
00E48: F0 0B         BEQ   $0E55
00E4A: 20 0B E2      JSR   $E20B
00E4D: 90 01         BCC   $0E50
00E4F: 60            RTS 
00E50: 20 18 F3      JSR   $F318
00E53: 80 BE         BRA   $0E13
00E55: A5 FB         LDA   $FB
00E57: 29 01         AND   #$01
00E59: F0 02         BEQ   $0E5D
00E5B: 62            CLA 
00E5C: 60            RTS 

00E5D: 20 EE F0      JSR   $F0EE
00E60: A9 D9         LDA   #$D9
00E62: 8D 4C 22      STA   $224C
00E65: A5 FF         LDA   $FF
00E67: 29 07         AND   #$07
00E69: 8D 4D 22      STA   $224D
00E6C: A5 FF         LDA   $FF
00E6E: 29 C0         AND   #$C0
00E70: 8D 55 22      STA   $2255
00E73: D0 09         BNE   $0E7E
00E75: A2 04         LDX   #$04
00E77: A0 03         LDY   #$03
00E79: 20 27 F3      JSR   $F327
00E7C: 80 40         BRA   $0EBE
00E7E: C9 C0         CMP   #$C0
00E80: F0 11         BEQ   $0E93
00E82: C9 80         CMP   #$80
00E84: D0 04         BNE   $0E8A
00E86: 64 FD         STZ   $FD
00E88: 64 FE         STZ   $FE
00E8A: A2 04         LDX   #$04
00E8C: A0 02         LDY   #$02
00E8E: 20 27 F3      JSR   $F327
00E91: 80 2B         BRA   $0EBE
00E93: AD 6C 22      LDA   $226C
00E96: 8D 6F 22      STA   $226F
00E99: AD 6D 22      LDA   $226D
00E9C: 8D 70 22      STA   $2270
00E9F: AD 6E 22      LDA   $226E
00EA2: 8D 71 22      STA   $2271
00EA5: 44 5B         BSR   $0F02
00EA7: AD 6F 22      LDA   $226F
00EAA: 8D 4E 22      STA   $224E
00EAD: AD 70 22      LDA   $2270
00EB0: 8D 4F 22      STA   $224F
00EB3: AD 71 22      LDA   $2271
00EB6: 8D 50 22      STA   $2250
00EB9: A9 40         LDA   #$40
00EBB: 8D 55 22      STA   $2255
00EBE: 20 00 E9      JSR   $E900
00EC1: C9 D8         CMP   #$D8
00EC3: F0 20         BEQ   $0EE5
00EC5: AD 4D 22      LDA   $224D
00EC8: C9 04         CMP   #$04
00ECA: D0 03         BNE   $0ECF
00ECC: AD 9C 22      LDA   $229C
00ECF: 8D 9C 22      STA   $229C
00ED2: C9 01         CMP   #$01
00ED4: F0 85         BEQ   $0E5B
00ED6: C9 02         CMP   #$02
00ED8: D0 0B         BNE   $0EE5
00EDA: 9C A4 22      STZ   $22A4
00EDD: A9 20         LDA   #$20
00EDF: 0C 02 18      TSB   $1802
00EE2: 4C 5B EE      JMP   $EE5B
00EE5: AD 4D 22      LDA   $224D
00EE8: C9 04         CMP   #$04
00EEA: D0 03         BNE   $0EEF
00EEC: 8D 9C 22      STA   $229C
00EEF: 20 C5 E9      JSR   $E9C5
00EF2: C9 00         CMP   #$00
00EF4: F0 0B         BEQ   $0F01
00EF6: 20 0B E2      JSR   $E20B
00EF9: B0 06         BCS   $0F01
00EFB: 20 18 F3      JSR   $F318
00EFE: 4C 55 EE      JMP   $EE55
00F01: 60            RTS 
00F02: 48            PHA 
00F03: F8            SED 
00F04: AD 71 22      LDA   $2271
00F07: 38            SEC 
00F08: E9 01         SBC   #$01
00F0A: 8D 71 22      STA   $2271
00F0D: C9 75         CMP   #$75
00F0F: 90 20         BCC   $0F31
00F11: A9 74         LDA   #$74
00F13: 8D 71 22      STA   $2271
00F16: AD 70 22      LDA   $2270
00F19: 38            SEC 
00F1A: E9 01         SBC   #$01
00F1C: 8D 70 22      STA   $2270
00F1F: C9 60         CMP   #$60
00F21: 90 0E         BCC   $0F31
00F23: A9 59         LDA   #$59
00F25: 8D 70 22      STA   $2270
00F28: AD 6F 22      LDA   $226F
00F2B: 38            SEC 
00F2C: E9 01         SBC   #$01
00F2E: 8D 6F 22      STA   $226F
00F31: D8            CLD 
00F32: 68            PLA 
00F33: 60            RTS 

CD_SEARCH:
00F34: 20 09 F3      JSR   $F309
00F37: 20 EE F0      JSR   $F0EE
00F3A: A9 D8         LDA   #$D8
00F3C: 8D 4C 22      STA   $224C
00F3F: A5 FB         LDA   $FB
00F41: 29 C0         AND   #$C0
00F43: 8D 55 22      STA   $2255
00F46: D0 08         BNE   $0F50
00F48: 82            CLX 
00F49: A0 03         LDY   #$03
00F4B: 20 27 F3      JSR   $F327
00F4E: 80 0E         BRA   $0F5E
00F50: C9 80         CMP   #$80
00F52: D0 04         BNE   $0F58
00F54: 64 F9         STZ   $F9
00F56: 64 FA         STZ   $FA
00F58: 82            CLX 
00F59: A0 02         LDY   #$02
00F5B: 20 27 F3      JSR   $F327
00F5E: A5 FB         LDA   $FB
00F60: AA            TAX 
00F61: 29 01         AND   #$01
00F63: 8D 48 22      STA   $2248
00F66: 8A            TXA 
00F67: 29 02         AND   #$02
00F69: 4A            LSR 
00F6A: 8D 4D 22      STA   $224D
00F6D: 20 00 E9      JSR   $E900
00F70: AD 48 22      LDA   $2248
00F73: F0 0D         BEQ   $0F82
00F75: 9C A4 22      STZ   $22A4
00F78: A9 20         LDA   #$20
00F7A: 0C 02 18      TSB   $1802
00F7D: 9C 48 22      STZ   $2248
00F80: 62            CLA 
00F81: 60            RTS 
00F82: 20 C5 E9      JSR   $E9C5
00F85: C9 00         CMP   #$00
00F87: F0 0A         BEQ   $0F93
00F89: 20 0B E2      JSR   $E20B
00F8C: B0 05         BCS   $0F93
00F8E: 20 18 F3      JSR   $F318
00F91: 80 A4         BRA   $0F37
00F93: 60            RTS 

CD_PAUSE:
00F94: A9 56         LDA   #$56
00F96: 85 FA         STA   $FA
00F98: A9 22         LDA   #$22
00F9A: 85 FB         STA   $FB
00F9C: 44 21         BSR   $0FBF
00F9E: AD 56 22      LDA   $2256
00FA1: C9 00         CMP   #$00
00FA3: F0 02         BEQ   $0FA7
00FA5: 62            CLA 
00FA6: 60            RTS 
00FA7: 20 EE F0      JSR   $F0EE
00FAA: A9 DA         LDA   #$DA
00FAC: 8D 4C 22      STA   $224C
00FAF: 20 00 E9      JSR   $E900
00FB2: 20 C5 E9      JSR   $E9C5
00FB5: C9 00         CMP   #$00
00FB7: F0 05         BEQ   $0FBE
00FB9: 20 0B E2      JSR   $E20B
00FBC: 90 D6         BCC   $0F94
00FBE: 60            RTS 

CD_SUBQ:
00FBF: 20 09 F3      JSR   $F309
00FC2: 20 EE F0      JSR   $F0EE
00FC5: A9 DD         LDA   #$DD
00FC7: 8D 4C 22      STA   $224C
00FCA: A9 0A         LDA   #$0A
00FCC: 8D 4D 22      STA   $224D
00FCF: 20 00 E9      JSR   $E900
00FD2: C9 C8         CMP   #$C8
00FD4: D0 09         BNE   $0FDF
00FD6: A9 0A         LDA   #$0A
00FD8: 85 F8         STA   $F8
00FDA: 64 F9         STZ   $F9
00FDC: 20 3B EA      JSR   $EA3B
00FDF: 20 C5 E9      JSR   $E9C5
00FE2: C9 00         CMP   #$00
00FE4: F0 0A         BEQ   $0FF0
00FE6: 20 0B E2      JSR   $E20B
00FE9: B0 05         BCS   $0FF0
00FEB: 20 18 F3      JSR   $F318
00FEE: 80 D2         BRA   $0FC2
00FF0: 60            RTS 

CD_DINFO:
00FF1: 20 09 F3      JSR   $F309
00FF4: 20 EE F0      JSR   $F0EE
00FF7: A9 DE         LDA   #$DE
00FF9: 8D 4C 22      STA   $224C
00FFC: A5 F8         LDA   $F8
00FFE: 8D 4D 22      STA   $224D
01001: A5 F9         LDA   $F9
01003: 8D 4E 22      STA   $224E
01006: 20 00 E9      JSR   $E900
01009: C9 C8         CMP   #$C8
0100B: D0 09         BNE   $1016
0100D: A9 04         LDA   #$04
0100F: 85 F8         STA   $F8
01011: 64 F9         STZ   $F9
01013: 20 3B EA      JSR   $EA3B
01016: 20 C5 E9      JSR   $E9C5
01019: 48            PHA 
0101A: 20 18 F3      JSR   $F318
0101D: 68            PLA 
0101E: C9 00         CMP   #$00
01020: F0 0A         BEQ   $102C
01022: 20 0B E2      JSR   $E20B
01025: B0 05         BCS   $102C
01027: 20 18 F3      JSR   $F318
0102A: 80 C8         BRA   $0FF4
0102C: 60            RTS 

EX_GETVER:
0102D: AE C2 FE      LDX   version		;$FEC2
01030: AC C3 FE      LDY   version+1	;$FEC3
01033: 60            RTS 

EX_SETVEC:
01034: 08            PHP 
01035: 78            SEI 
01036: C9 06         CMP   #$06
01038: D0 08         BNE   $1042
0103A: 8E 84 22      STX   $2284
0103D: 8C 85 22      STY   $2285
01040: 80 0F         BRA   $1051
01042: 48            PHA 
01043: 5A            PHY 
01044: DA            PHX 
01045: 0A            ASL 
01046: AA            TAX 
01047: 68            PLA 
01048: 9D 00 22      STA   $2200,X
0104B: E8            INX 
0104C: 68            PLA 
0104D: 9D 00 22      STA   $2200,X
01050: 68            PLA 
01051: 28            PLP 
01052: 60            RTS 

01053: 20 F9 F0      JSR   $F0F9
01056: 20 EE F0      JSR   $F0EE
01059: A9 03         LDA   #$03
0105B: 8D 4C 22      STA   $224C
0105E: A9 0A         LDA   #$0A
01060: 8D 50 22      STA   $2250
01063: 20 00 E9      JSR   $E900
01066: C9 C8         CMP   #$C8
01068: D0 11         BNE   $107B
0106A: A9 56         LDA   #$56
0106C: 85 FA         STA   $FA
0106E: A9 22         LDA   #$22
01070: 85 FB         STA   $FB
01072: A9 0A         LDA   #$0A
01074: 85 F8         STA   $F8
01076: 64 F9         STZ   $F9
01078: 20 3B EA      JSR   $EA3B
0107B: 20 C5 E9      JSR   $E9C5
0107E: 48            PHA 
0107F: C9 00         CMP   #$00
01081: D0 0C         BNE   $108F
01083: AD 58 22      LDA   $2258
01086: 8D 7D 22      STA   $227D
01089: AD 5F 22      LDA   $225F
0108C: 8D 7C 22      STA   $227C
0108F: 68            PLA 
01090: 60            RTS 
01091: 44 5B         BSR   $10EE
01093: A9 00         LDA   #$00
01095: 8D 4C 22      STA   $224C
01098: 20 00 E9      JSR   $E900
0109B: 20 C5 E9      JSR   $E9C5
0109E: C9 00         CMP   #$00
010A0: F0 05         BEQ   $10A7
010A2: 20 0B E2      JSR   $E20B
010A5: 38            SEC 
010A6: 60            RTS 
010A7: 18            CLC 
010A8: 60            RTS 

CD_CONTNTS:
010A9: 64 F8         STZ   $F8
010AB: A9 56         LDA   #$56
010AD: 85 FA         STA   $FA
010AF: A9 22         LDA   #$22
010B1: 85 FB         STA   $FB
010B3: 20 F1 EF      JSR   $EFF1
010B6: C9 00         CMP   #$00
010B8: D0 33         BNE   $10ED
010BA: AD 56 22      LDA   $2256
010BD: 8D 6A 22      STA   $226A
010C0: AD 57 22      LDA   $2257
010C3: 8D 6B 22      STA   $226B
010C6: A9 01         LDA   #$01
010C8: 85 F8         STA   $F8
010CA: A9 56         LDA   #$56
010CC: 85 FA         STA   $FA
010CE: A9 22         LDA   #$22
010D0: 85 FB         STA   $FB
010D2: 20 F1 EF      JSR   $EFF1
010D5: C9 00         CMP   #$00
010D7: D0 14         BNE   $10ED
010D9: 48            PHA 
010DA: AD 56 22      LDA   $2256
010DD: 8D 6C 22      STA   $226C
010E0: AD 57 22      LDA   $2257
010E3: 8D 6D 22      STA   $226D
010E6: AD 58 22      LDA   $2258
010E9: 8D 6E 22      STA   $226E
010EC: 68            PLA 
010ED: 60            RTS 

cd_clear_ram_024C:
010EE: DA            PHX 
010EF: A2 09         LDX   #$09
010F1: 9E 4C 22      STZ   $224C,X
010F4: CA            DEX 
010F5: D0 FA         BNE   $10F1
010F7: FA            PLX 
010F8: 60            RTS 

010F9: DA            PHX 
010FA: A2 09         LDX   #$09
010FC: 9E 56 22      STZ   $2256,X
010FF: CA            DEX 
01100: 10 FA         BPL   $10FC
01102: FA            PLX 
01103: 60            RTS 

cd_calc_lba:
01104: AD 73 22      LDA   $2273
01107: 0A            ASL 
01108: 18            CLC 
01109: 6D 73 22      ADC   $2273
0110C: A8            TAY 
0110D: A5 FE         LDA   _DL		;REC_L
0110F: 18            CLC 
01110: 79 76 22      ADC   $2276,Y
01113: 85 FE         STA   _DL
01115: A5 FD         LDA   _CH		;REC_M
01117: 79 75 22      ADC   $2275,Y
0111A: 85 FD         STA   _CH
0111C: A5 FC         LDA   _CL		;REC_H
0111E: 79 74 22      ADC   $2274,Y
01121: 85 FC         STA   _CL
01123: 60            RTS 

01124: 20 E3 F1      JSR   $F1E3
01127: 90 03         BCC   $112C
01129: A9 01         LDA   #$01
0112B: 60            RTS 
0112C: A9 A0         LDA   #$A0
0112E: 85 FC         STA   $FC
01130: A5 FB         LDA   $FB
01132: 38            SEC 
01133: E9 A0         SBC   #$A0
01135: 10 0C         BPL   $1143
01137: 43 20         TMA   #$20
01139: 8D BA 22      STA   $22BA
0113C: 43 40         TMA   #$40
0113E: 8D BB 22      STA   $22BB
01141: 80 0E         BRA   $1151
01143: A9 60         LDA   #$60
01145: 85 FC         STA   $FC
01147: 43 08         TMA   #$08
01149: 8D B8 22      STA   $22B8
0114C: 43 10         TMA   #$10
0114E: 8D B9 22      STA   $22B9
01151: A5 F8         LDA   $F8
01153: 85 EC         STA   $EC
01155: A5 F9         LDA   $F9
01157: 85 ED         STA   $ED
01159: 64 EE         STZ   $EE
0115B: 0F FF 1F      BBR0  $FF, $117D
0115E: A2 08         LDX   #$08
01160: 18            CLC 
01161: A5 EC         LDA   $EC
01163: 65 F8         ADC   $F8
01165: 85 EC         STA   $EC
01167: A5 ED         LDA   $ED
01169: 65 F9         ADC   $F9
0116B: 85 ED         STA   $ED
0116D: 62            CLA 
0116E: 65 EE         ADC   $EE
01170: 85 EE         STA   $EE
01172: CA            DEX 
01173: D0 EB         BNE   $1160
01175: 06 EC         ASL   $EC
01177: 26 ED         ROL   $ED
01179: 26 EE         ROL   $EE
0117B: 80 0B         BRA   $1188
0117D: A2 05         LDX   #$05
0117F: 06 EC         ASL   $EC
01181: 26 ED         ROL   $ED
01183: 26 EE         ROL   $EE
01185: CA            DEX 
01186: D0 F7         BNE   $117F
01188: A5 FF         LDA   $FF
0118A: 0A            ASL 
0118B: 1A            INC 
0118C: 65 EE         ADC   $EE
0118E: 85 EE         STA   $EE
01190: A5 ED         LDA   $ED
01192: A2 05         LDX   #$05
01194: 46 EE         LSR   $EE
01196: 6A            ROR 
01197: CA            DEX 
01198: D0 FA         BNE   $1194
0119A: 85 EE         STA   $EE
0119C: A5 ED         LDA   $ED
0119E: 29 1F         AND   #$1F
011A0: 18            CLC 
011A1: 65 FC         ADC   $FC
011A3: 85 ED         STA   $ED
011A5: A5 EE         LDA   $EE
011A7: FF FC 07      BBS7  $FC, $11B1
011AA: 53 08         TAM   #$08
011AC: 1A            INC 
011AD: 53 10         TAM   #$10
011AF: 80 05         BRA   $11B6
011B1: 53 20         TAM   #$20
011B3: 1A            INC 
011B4: 53 40         TAM   #$40
011B6: 8F FF 0C      BBS0  $FF, $11C5
011B9: C2            CLY 
011BA: B1 EC         LDA   ($EC),Y
011BC: 91 FA         STA   ($FA),Y
011BE: C8            INY 
011BF: C0 20         CPY   #$20
011C1: D0 F7         BNE   $11BA
011C3: 80 03         BRA   $11C8
011C5: 20 CC F2      JSR   $F2CC
011C8: FF FC 0C      BBS7  $FC, $11D7
011CB: AD B8 22      LDA   $22B8
011CE: 53 08         TAM   #$08
011D0: AD B9 22      LDA   $22B9
011D3: 53 10         TAM   #$10
011D5: 80 0A         BRA   $11E1
011D7: AD BA 22      LDA   $22BA
011DA: 53 20         TAM   #$20
011DC: AD BB 22      LDA   $22BB
011DF: 53 40         TAM   #$40
011E1: 62            CLA 
011E2: 60            RTS 

011E3: A5 F9         LDA   $F9
011E5: 38            SEC 
011E6: E9 81         SBC   #$81
011E8: C9 6F         CMP   #$6F
011EA: B0 28         BCS   $1214
011EC: C9 1F         CMP   #$1F
011EE: 90 06         BCC   $11F6
011F0: C9 3F         CMP   #$3F
011F2: 90 20         BCC   $1214
011F4: E9 40         SBC   #$40
011F6: 0A            ASL 
011F7: 69 21         ADC   #$21
011F9: 85 F9         STA   $F9
011FB: A5 F8         LDA   $F8
011FD: 38            SEC 
011FE: E9 40         SBC   #$40
01200: C9 BD         CMP   #$BD
01202: B0 10         BCS   $1214
01204: C9 3F         CMP   #$3F
01206: F0 0C         BEQ   $1214
01208: B0 01         BCS   $120B
0120A: 1A            INC 
0120B: C9 5F         CMP   #$5F
0120D: B0 07         BCS   $1216
0120F: 18            CLC 
01210: 69 20         ADC   #$20
01212: 80 07         BRA   $121B
01214: 38            SEC 
01215: 60            RTS 
01216: E6 F9         INC   $F9
01218: 38            SEC 
01219: E9 3E         SBC   #$3E
0121B: 85 F8         STA   $F8
0121D: A5 F9         LDA   $F9
0121F: C9 23         CMP   #$23
01221: F0 19         BEQ   $123C
01223: C9 26         CMP   #$26
01225: F0 28         BEQ   $124F
01227: C9 27         CMP   #$27
01229: F0 2E         BEQ   $1259
0122B: C9 28         CMP   #$28
0122D: 90 36         BCC   $1265
0122F: C9 30         CMP   #$30
01231: 90 E1         BCC   $1214
01233: C9 50         CMP   #$50
01235: B0 DD         BCS   $1214
01237: 38            SEC 
01238: E9 08         SBC   #$08
0123A: 80 29         BRA   $1265
0123C: A5 F8         LDA   $F8
0123E: C9 61         CMP   #$61
01240: 90 02         BCC   $1244
01242: E9 06         SBC   #$06
01244: C9 41         CMP   #$41
01246: 90 02         BCC   $124A
01248: E9 07         SBC   #$07
0124A: 38            SEC 
0124B: E9 0F         SBC   #$0F
0124D: 80 12         BRA   $1261
0124F: A5 F8         LDA   $F8
01251: C9 41         CMP   #$41
01253: 90 0C         BCC   $1261
01255: E9 08         SBC   #$08
01257: 80 08         BRA   $1261
01259: A5 F8         LDA   $F8
0125B: C9 51         CMP   #$51
0125D: 90 02         BCC   $1261
0125F: E9 0F         SBC   #$0F
01261: 85 F8         STA   $F8
01263: A5 F9         LDA   $F9
01265: 38            SEC 
01266: E9 21         SBC   #$21
01268: 0A            ASL 
01269: A8            TAY 
0126A: A5 F8         LDA   $F8
0126C: 38            SEC 
0126D: E9 21         SBC   #$21
0126F: 18            CLC 
01270: 79 7E F2      ADC   $F27E,Y
01273: 85 F8         STA   $F8
01275: B9 7F F2      LDA   $F27F,Y
01278: 69 00         ADC   #$00
0127A: 85 F9         STA   $F9
0127C: 18            CLC 
0127D: 60            RTS 
0127E: 00            BRK 
0127F: 00            BRK 
01280: 5E 00 6C      LSR   $6C00,X
01283: 00            BRK 
01284: AA            TAX 
01285: 00            BRK 
01286: FD 00 53      SBC   $5300,X
01289: 01 83         ORA   ($83,X)
0128B: 01 C5         ORA   ($C5,X)
0128D: 01 23         ORA   ($23,X)
0128F: 02            SXY 
01290: 81 02         STA   ($02,X)
01292: DF 02 3D      BBS5  $02, $12D2
01295: 03 9B         ST0   #$9B
01297: 03 F9         ST0   #$F9
01299: 03 57         ST0   #$57
0129B: 04 B5         TSB   $B5
0129D: 04 13         TSB   $13
0129F: 05 71         ORA   $71
012A1: 05 CF         ORA   $CF
012A3: 05 2D         ORA   $2D
012A5: 06 8B         ASL   $8B
012A7: 06 E9         ASL   $E9
012A9: 06 47         ASL   $47
012AB: 07 A5         RMB0  $A5
012AD: 07 03         RMB0  $03
012AF: 08            PHP 
012B0: 61 08         ADC   ($08,X)
012B2: BF 08 1D      BBS3  $08, $12D2
012B5: 09 7B         ORA   #$7B
012B7: 09 D9         ORA   #$D9
012B9: 09 37         ORA   #$37
012BB: 0A            ASL 
012BC: 95 0A         STA   $0A,X
012BE: F3 0A 51 0B AF 0B 0D  TAI   $510A, $AF0B, $0D0B
012C5: 0C 6B 0C      TSB   $0C6B
012C8: C9 0C         CMP   #$0C
012CA: 27 0D         RMB2  $0D
012CC: C2            CLY 
012CD: B1 EC         LDA   ($EC),Y
012CF: C8            INY 
012D0: 44 2E         BSR   $1300
012D2: B1 EC         LDA   ($EC),Y
012D4: C8            INY 
012D5: 48            PHA 
012D6: 29 F0         AND   #$F0
012D8: 44 26         BSR   $1300
012DA: B1 EC         LDA   ($EC),Y
012DC: C8            INY 
012DD: 8D BD 22      STA   $22BD
012E0: 68            PLA 
012E1: A2 04         LDX   #$04
012E3: 0E BD 22      ASL   $22BD
012E6: 2A            ROL 
012E7: CA            DEX 
012E8: D0 F9         BNE   $12E3
012EA: 44 14         BSR   $1300
012EC: AD BD 22      LDA   $22BD
012EF: 29 F0         AND   #$F0
012F1: 44 0D         BSR   $1300
012F3: C0 12         CPY   #$12
012F5: 90 D6         BCC   $12CD
012F7: 62            CLA 
012F8: A0 07         LDY   #$07
012FA: 91 FA         STA   ($FA),Y
012FC: 88            DEY 
012FD: 10 FB         BPL   $12FA
012FF: 60            RTS 
01300: 92 FA         STA   ($FA)
01302: E6 FA         INC   $FA
01304: D0 02         BNE   $1308
01306: E6 FB         INC   $FB
01308: 60            RTS 

cd_save_param:
01309: DA            PHX 
0130A: 48            PHA 
0130B: A2 07         LDX   #$07
0130D: B5 F8         LDA   $F8,X
0130F: 9D 60 22      STA   $2260,X
01312: CA            DEX 
01313: 10 F8         BPL   $130D
01315: 68            PLA 
01316: FA            PLX 
01317: 60            RTS 

01318: DA            PHX 
01319: 48            PHA 
0131A: A2 07         LDX   #$07
0131C: BD 60 22      LDA   $2260,X
0131F: 95 F8         STA   $F8,X
01321: CA            DEX 
01322: 10 F8         BPL   $131C
01324: 68            PLA 
01325: FA            PLX 
01326: 60            RTS 

cd_copy_lba:
01327: B5 F8         LDA   $F8,X
01329: 99 4C 22      STA   $224C,Y
0132C: B5 F9         LDA   $F9,X
0132E: 99 4D 22      STA   $224D,Y
01331: B5 FA         LDA   $FA,X
01333: 99 4E 22      STA   $224E,Y
01336: 60            RTS 


01337: A9 01         LDA   #$01
01339: 8D 72 22      STA   $2272
0133C: A5 FA         LDA   $FA
0133E: 8D 02 00      STA   $0002
01341: A5 FB         LDA   $FB
01343: 8D 03 00      STA   $0003
01346: 60            RTS 

CD_STAT:
01347: C9 00         CMP   #$00
01349: D0 06         BNE   $1351
0134B: AD 00 18      LDA   $1800
0134E: 29 80         AND   #$80
01350: 60            RTS 
01351: 4C 91 F0      JMP   $F091

CD_SUBRD:
01354: 93 10 03 18   TST   $10, $1803
01358: F0 08         BEQ   $1362
0135A: AD 07 18      LDA   $1807
0135D: 8D 7E 22      STA   $227E
01360: 18            CLC 
01361: 60            RTS 
01362: 38            SEC 
01363: 60            RTS

CD_PCMRD: 
01364: 8D 05 18      STA   $1805
01367: A2 1B         LDX   #$1B
01369: CA            DEX 
0136A: D0 FD         BNE   $1369
0136C: AE 05 18      LDX   $1805
0136F: AC 06 18      LDY   $1806
01372: AD 03 18      LDA   $1803
01375: 29 02         AND   #$02
01377: 4A            LSR 
01378: 60            RTS 

CD_FADE:
01379: 29 0F         AND   #$0F
0137B: 8D 0F 18      STA   $180F
0137E: 60            RTS 

AD_RESET:
0137F: A9 80         LDA   #$80
01381: 8D 0D 18      STA   $180D
01384: 9C 0D 18      STZ   $180D
01387: 9C 0B 18      STZ   $180B
0138A: A9 6F         LDA   #$6F
0138C: 1C 02 18      TRB   $1802
0138F: 9C 0E 18      STZ   $180E
01392: 60            RTS 

AD_TRANS:
01393: 93 03 0B 18   TST   $03, $180B
01397: F0 04         BEQ   $139D
01399: A9 04         LDA   #$04
0139B: 80 60         BRA   $13FD
0139D: 9C 73 22      STZ   $2273
013A0: 20 09 F3      JSR   $F309
013A3: A5 FF         LDA   $FF
013A5: D0 0A         BNE   $13B1
013A7: A6 FA         LDX   $FA
013A9: A4 FB         LDY   $FB
013AB: 20 29 F7      JSR   $F729
013AE: 20 10 F7      JSR   $F710
013B1: 20 EE F0      JSR   $F0EE
013B4: A9 08         LDA   #$08
013B6: 8D 4C 22      STA   $224C
013B9: 20 04 F1      JSR   $F104
013BC: A2 04         LDX   #$04
013BE: A0 01         LDY   #$01
013C0: 20 27 F3      JSR   $F327
013C3: A5 F8         LDA   $F8
013C5: 8D 50 22      STA   $2250
013C8: 20 00 E9      JSR   $E900
013CB: A9 02         LDA   #$02
013CD: 8D 0B 18      STA   $180B
013D0: 93 04 0C 18   TST   $04, $180C
013D4: D0 FA         BNE   $13D0
013D6: AD 03 18      LDA   $1803
013D9: 29 20         AND   #$20
013DB: F0 F3         BEQ   $13D0
013DD: 9C 0B 18      STZ   $180B
013E0: 20 C5 E9      JSR   cd_read_status	;$E9C5
013E3: C9 00         CMP   #$00
013E5: F0 16         BEQ   $13FD
013E7: 20 0B E2      JSR   $E20B
013EA: B0 11         BCS   $13FD
013EC: 20 18 F3      JSR   $F318
013EF: AD 7C 22      LDA   $227C
013F2: C9 10         CMP   #$10
013F4: 90 AD         BCC   $13A3
013F6: A9 01         LDA   #$01
013F8: 8D 73 22      STA   $2273
013FB: 80 A6         BRA   $13A3
013FD: 60            RTS 

ad_dram_read:
013FE: AD 0C 18      LDA   $180C
01401: 30 FB         BMI   $13FE
01403: AD 0A 18      LDA   $180A
01406: 60            RTS 

AD_READ:		;_BX: dest address,_CX: ADPCM buffer address, _DH: read address type
01407: 20 DB F6      JSR   AD_STAT			;$F6DB
0140A: D0 FB         BNE   $1407
0140C: A6 FC         LDX   _CX
0140E: A4 FD         LDY   _CX+1
01410: 20 29 F7      JSR   ad_pointer_set		;$F729
01413: 20 FF F6      JSR   ad_read_addr_set	;$F6FF
01416: 44 E6         BSR   ad_dram_read		;$13FE
01418: A5 FF         LDA   _DH
0141A: F0 07         BEQ   $1423
0141C: C9 FF         CMP   #$FF
0141E: F0 1D         BEQ   ad_read_to_vram	;$143D
01420: 4C 6B F4      JMP   $F46B

01423: 44 D9         BSR   $13FE
01425: 92 FA         STA   (_BL)
01427: E6 FA         INC   _BL
01429: D0 02         BNE   $142D
0142B: E6 FB         INC   _BH
0142D: A5 F8         LDA   $F8
0142F: D0 02         BNE   $1433
01431: C6 F9         DEC   $F9
01433: C6 F8         DEC   $F8
01435: A5 F8         LDA   $F8
01437: 05 F9         ORA   $F9
01439: D0 E8         BNE   $1423
0143B: 62            CLA 
0143C: 60            RTS 
ad_read_to_vram:
0143D: A9 00         LDA   #$00
0143F: 85 F7         STA   $F7
01441: 8D 00 00      STA   $0000
01444: 20 F5 F6      JSR   set_vram_addr		;$F6F5
01447: A9 02         LDA   #$02
01449: 85 F7         STA   $F7
0144B: 8D 00 00      STA   $0000

0144E: 44 AE         BSR   ad_dram_read		;$13FE
01450: 92 FA         STA   ($FA)
01452: A5 FA         LDA   $FA
01454: 49 01         EOR   #$01
01456: 85 FA         STA   $FA
01458: A5 F8         LDA   $F8
0145A: D0 02         BNE   $145E
0145C: C6 F9         DEC   $F9
0145E: C6 F8         DEC   $F8
01460: A5 F8         LDA   $F8
01462: 05 F9         ORA   $F9
01464: D0 E8         BNE   $144E
01466: 9C 72 22      STZ   $2272
01469: 62            CLA 
0146A: 60            RTS 

0146B: C9 07         CMP   #$07
0146D: 30 03         BMI   $1472
0146F: A9 22         LDA   #$22
01471: 60            RTS 
01472: AA            TAX 
01473: A9 01         LDA   #$01
01475: 0A            ASL 
01476: CA            DEX 
01477: D0 FC         BNE   $1475
01479: 8D 8F 22      STA   $228F
0147C: A9 43         LDA   #$43
0147E: 8D 8E 22      STA   $228E
01481: A9 60         LDA   #$60
01483: 8D 90 22      STA   $2290
01486: 20 8E 22      JSR   $228E
01489: 8D 68 22      STA   $2268
0148C: A5 FA         LDA   $FA
0148E: 85 FE         STA   $FE
01490: A5 FF         LDA   $FF
01492: 0A            ASL 
01493: 0A            ASL 
01494: 0A            ASL 
01495: 0A            ASL 
01496: 0A            ASL 
01497: 85 FB         STA   $FB
01499: 64 FA         STZ   $FA
0149B: A9 53         LDA   #$53
0149D: 8D 8E 22      STA   $228E
014A0: A5 FE         LDA   $FE
014A2: 20 8E 22      JSR   $228E
014A5: A2 20         LDX   #$20
014A7: C2            CLY 
014A8: 20 FE F3      JSR   $F3FE
014AB: 92 FA         STA   ($FA)
014AD: E6 FA         INC   $FA
014AF: D0 02         BNE   $14B3
014B1: E6 FB         INC   $FB
014B3: A5 F8         LDA   $F8
014B5: D0 02         BNE   $14B9
014B7: C6 F9         DEC   $F9
014B9: C6 F8         DEC   $F8
014BB: A5 F8         LDA   $F8
014BD: 05 F9         ORA   $F9
014BF: F0 0A         BEQ   $14CB
014C1: 88            DEY 
014C2: D0 E4         BNE   $14A8
014C4: CA            DEX 
014C5: D0 E1         BNE   $14A8
014C7: E6 FE         INC   $FE
014C9: 80 C5         BRA   $1490
014CB: A9 53         LDA   #$53
014CD: 8D 8E 22      STA   $228E
014D0: AD 68 22      LDA   $2268
014D3: 20 8E 22      JSR   $228E
014D6: 62            CLA 
014D7: 60            RTS 

AD_WRITE:
014D8: AD 0B 18      LDA   $180B
014DB: 29 03         AND   #$03
014DD: D0 3D         BNE   $151C
014DF: A5 FC         LDA   $FC
014E1: 25 FD         AND   $FD
014E3: C9 FF         CMP   #$FF
014E5: F0 0A         BEQ   $14F1
014E7: A6 FC         LDX   $FC
014E9: A4 FD         LDY   $FD
014EB: 20 29 F7      JSR   $F729
014EE: 20 10 F7      JSR   $F710
014F1: A5 FF         LDA   $FF
014F3: F0 07         BEQ   $14FC
014F5: C9 FF         CMP   #$FF
014F7: F0 24         BEQ   $151D
014F9: 4C 52 F5      JMP   $F552
014FC: B2 FA         LDA   ($FA)
014FE: 8D 0A 18      STA   $180A
01501: 93 04 0C 18   TST   $04, $180C
01505: D0 FA         BNE   $1501
01507: E6 FA         INC   $FA
01509: D0 02         BNE   $150D
0150B: E6 FB         INC   $FB
0150D: A5 F8         LDA   $F8
0150F: D0 02         BNE   $1513
01511: C6 F9         DEC   $F9
01513: C6 F8         DEC   $F8
01515: A5 F8         LDA   $F8
01517: 05 F9         ORA   $F9
01519: D0 E1         BNE   $14FC
0151B: 62            CLA 
0151C: 60            RTS 
0151D: A9 01         LDA   #$01
0151F: 85 F7         STA   $F7
01521: 8D 00 00      STA   $0000
01524: 20 F5 F6      JSR   $F6F5
01527: A9 02         LDA   #$02
01529: 85 F7         STA   $F7
0152B: 8D 00 00      STA   $0000
0152E: 93 04 0C 18   TST   $04, $180C
01532: D0 FA         BNE   $152E
01534: B2 FA         LDA   ($FA)
01536: 8D 0A 18      STA   $180A
01539: A5 FA         LDA   $FA
0153B: 49 01         EOR   #$01
0153D: 85 FA         STA   $FA
0153F: A5 F8         LDA   $F8
01541: D0 02         BNE   $1545
01543: C6 F9         DEC   $F9
01545: C6 F8         DEC   $F8
01547: A5 F8         LDA   $F8
01549: 05 F9         ORA   $F9
0154B: D0 E1         BNE   $152E
0154D: 9C 72 22      STZ   $2272
01550: 62            CLA 
01551: 60            RTS 
01552: C9 07         CMP   #$07
01554: 30 04         BMI   $155A
01556: A9 22         LDA   #$22
01558: 80 F7         BRA   $1551
0155A: AA            TAX 
0155B: A9 01         LDA   #$01
0155D: 0A            ASL 
0155E: CA            DEX 
0155F: D0 FC         BNE   $155D
01561: 8D 8F 22      STA   $228F
01564: A9 43         LDA   #$43
01566: 8D 8E 22      STA   $228E
01569: A9 60         LDA   #$60
0156B: 8D 90 22      STA   $2290
0156E: 20 8E 22      JSR   $228E
01571: 8D 68 22      STA   $2268
01574: A5 FA         LDA   $FA
01576: 85 FE         STA   $FE
01578: A5 FF         LDA   $FF
0157A: 0A            ASL 
0157B: 0A            ASL 
0157C: 0A            ASL 
0157D: 0A            ASL 
0157E: 0A            ASL 
0157F: 85 FB         STA   $FB
01581: 64 FA         STZ   $FA
01583: A9 53         LDA   #$53
01585: 8D 8E 22      STA   $228E
01588: A5 FE         LDA   $FE
0158A: 20 8E 22      JSR   $228E
0158D: A2 20         LDX   #$20
0158F: C2            CLY 
01590: 93 04 0C 18   TST   $04, $180C
01594: D0 FA         BNE   $1590
01596: B2 FA         LDA   ($FA)
01598: 8D 0A 18      STA   $180A
0159B: E6 FA         INC   $FA
0159D: D0 02         BNE   $15A1
0159F: E6 FB         INC   $FB
015A1: A5 F8         LDA   $F8
015A3: D0 02         BNE   $15A7
015A5: C6 F9         DEC   $F9
015A7: C6 F8         DEC   $F8
015A9: A5 F8         LDA   $F8
015AB: 05 F9         ORA   $F9
015AD: F0 0A         BEQ   $15B9
015AF: 88            DEY 
015B0: D0 DE         BNE   $1590
015B2: CA            DEX 
015B3: D0 DB         BNE   $1590
015B5: E6 FE         INC   $FE
015B7: 80 BF         BRA   $1578
015B9: A9 53         LDA   #$53
015BB: 8D 8E 22      STA   $228E
015BE: AD 68 22      LDA   $2268
015C1: 20 8E 22      JSR   $228E
015C4: 62            CLA 
015C5: 60            RTS 

AD_PLAY:
015C6: 20 DB F6      JSR   $F6DB
015C9: D0 53         BNE   $161E
015CB: A5 FE         LDA   $FE
015CD: 29 80         AND   #$80
015CF: 8D A5 22      STA   $22A5
015D2: A5 FE         LDA   $FE
015D4: 29 7F         AND   #$7F
015D6: D0 3B         BNE   $1613
015D8: A5 FA         LDA   $FA
015DA: 8D A8 22      STA   $22A8
015DD: A5 FB         LDA   $FB
015DF: 8D A9 22      STA   $22A9
015E2: A5 F8         LDA   $F8
015E4: 8D A6 22      STA   $22A6
015E7: A5 F9         LDA   $F9
015E9: 8D A7 22      STA   $22A7
015EC: A5 FF         LDA   $FF
015EE: C9 10         CMP   #$10
015F0: B0 2C         BCS   $161E
015F2: 8D AA 22      STA   $22AA
015F5: AE A8 22      LDX   $22A8
015F8: AC A9 22      LDY   $22A9
015FB: 20 29 F7      JSR   $F729
015FE: 20 FF F6      JSR   $F6FF
01601: AE A6 22      LDX   $22A6
01604: AC A7 22      LDY   $22A7
01607: 20 29 F7      JSR   $F729
0160A: 20 1E F7      JSR   $F71E
0160D: AD AA 22      LDA   $22AA
01610: 8D 0E 18      STA   $180E
01613: A9 08         LDA   #$08
01615: 0C 02 18      TSB   $1802
01618: A9 60         LDA   #$60
0161A: 8D 0D 18      STA   $180D
0161D: 62            CLA 
0161E: 60            RTS 

AD_CPLAY:
0161F: 20 DB F6      JSR   $F6DB
01622: D0 67         BNE   $168B
01624: A5 F8         LDA   $F8
01626: 8D 9E 22      STA   $229E
01629: A5 F9         LDA   $F9
0162B: 8D 9F 22      STA   $229F
0162E: A5 FA         LDA   $FA
01630: 8D A0 22      STA   $22A0
01633: A5 FE         LDA   $FE
01635: 18            CLC 
01636: 6D 76 22      ADC   $2276
01639: 8D A3 22      STA   $22A3
0163C: A5 FD         LDA   $FD
0163E: 6D 75 22      ADC   $2275
01641: 8D A2 22      STA   $22A2
01644: A5 FC         LDA   $FC
01646: 6D 74 22      ADC   $2274
01649: 8D A1 22      STA   $22A1
0164C: 20 7F F3      JSR   $F37F
0164F: A5 FF         LDA   $FF
01651: C9 10         CMP   #$10
01653: B0 36         BCS   $168B
01655: 8D 0E 18      STA   $180E
01658: A9 20         LDA   #$20
0165A: 85 F8         STA   $F8
0165C: A9 00         LDA   #$00
0165E: 85 FF         STA   $FF
01660: 64 FA         STZ   $FA
01662: 64 FB         STZ   $FB
01664: 20 93 F3      JSR   AD_TRANS		;$F393
01667: C9 00         CMP   #$00
01669: D0 20         BNE   $168B
0166B: A9 20         LDA   #$20
0166D: 8D 9D 22      STA   $229D
01670: 44 1A         BSR   $168C
01672: A9 FF         LDA   #$FF
01674: 8D 08 18      STA   $1808
01677: 8D 09 18      STA   $1809
0167A: 20 1E F7      JSR   ad_length_set	;$F71E
0167D: 9C A5 22      STZ   $22A5
01680: A9 0C         LDA   #$0C
01682: 0C 02 18      TSB   $1802
01685: A9 60         LDA   #$60
01687: 8D 0D 18      STA   $180D
0168A: 62            CLA 
0168B: 60            RTS 

0168C: 18            CLC 
0168D: AD A3 22      LDA   $22A3
01690: 6D 9D 22      ADC   $229D
01693: 8D A3 22      STA   $22A3
01696: AD A2 22      LDA   $22A2
01699: 69 00         ADC   #$00
0169B: 8D A2 22      STA   $22A2
0169E: AD A1 22      LDA   $22A1
016A1: 69 00         ADC   #$00
016A3: 8D A1 22      STA   $22A1
016A6: 38            SEC 
016A7: AD 9E 22      LDA   $229E
016AA: ED 9D 22      SBC   $229D
016AD: 8D 9E 22      STA   $229E
016B0: AD 9F 22      LDA   $229F
016B3: E9 00         SBC   #$00
016B5: 8D 9F 22      STA   $229F
016B8: AD A0 22      LDA   $22A0
016BB: E9 00         SBC   #$00
016BD: 8D A0 22      STA   $22A0
016C0: 60            RTS 

AD_STOP:
016C1: A9 0C         LDA   #$0C
016C3: 1C 02 18      TRB   $1802
016C6: A9 60         LDA   #$60
016C8: 1C 0D 18      TRB   $180D
016CB: 9C A5 22      STZ   $22A5
016CE: 9C 9D 22      STZ   $229D
016D1: 9C 9E 22      STZ   $229E
016D4: 9C 9F 22      STZ   $229F
016D7: 9C A0 22      STZ   $22A0
016DA: 60            RTS 

AD_STAT:
016DB: AD 0C 18      LDA   $180C
016DE: 29 01         AND   #$01
016E0: D0 05         BNE   $16E7
016E2: AD 03 18      LDA   $1803
016E5: 29 04         AND   #$04
016E7: AA            TAX 
016E8: AD 0D 18      LDA   $180D
016EB: 29 20         AND   #$20
016ED: D0 05         BNE   $16F4
016EF: AD 0C 18      LDA   $180C
016F2: 29 08         AND   #$08
016F4: 60            RTS 

set_vram_addr:
016F5: 20 37 F3      JSR   $F337
016F8: A9 02         LDA   #$02
016FA: 85 FA         STA   $FA
016FC: 64 FB         STZ   $FB
016FE: 60            RTS 

ad_read_addr_set:
016FF: A9 08         LDA   #$08
01701: 0C 0D 18      TSB   $180D
01704: AD 0A 18      LDA   $180A
01707: A9 05         LDA   #$05
01709: 3A            DEC 
0170A: D0 FD         BNE   $1709
0170C: A9 08         LDA   #$08
0170E: 80 15         BRA   $1725
ad_write_addr_set:
01710: A9 03         LDA   #$03
01712: 0C 0D 18      TSB   $180D
01715: A9 01         LDA   #$01
01717: 1C 0D 18      TRB   $180D
0171A: A9 02         LDA   #$02
0171C: 80 07         BRA   $1725
ad_length_set:
0171E: A9 10         LDA   #$10
01720: 0C 0D 18      TSB   $180D
01723: A9 10         LDA   #$10
01725: 1C 0D 18      TRB   $180D
01728: 60            RTS 

ad_pointer_set:
01729: 8E 08 18      STX   $1808
0172C: 8C 09 18      STY   $1809
0172F: 60            RTS 

01730: 93 03 0B 18   TST   $03, $180B
01734: F0 03         BEQ   $1739
01736: 38            SEC 
01737: 80 32         BRA   $176B
01739: A9 08         LDA   #$08
0173B: 8D 4C 22      STA   $224C
0173E: 20 04 F1      JSR   $F104
01741: A5 FC         LDA   $FC
01743: 8D 4D 22      STA   $224D
01746: A5 FD         LDA   $FD
01748: 8D 4E 22      STA   $224E
0174B: A5 FE         LDA   $FE
0174D: 8D 4F 22      STA   $224F
01750: A5 F8         LDA   $F8
01752: 8D 50 22      STA   $2250
01755: 9C 51 22      STZ   $2251
01758: A5 FA         LDA   $FA
0175A: 8D C3 22      STA   $22C3
0175D: A5 FB         LDA   $FB
0175F: 8D C4 22      STA   $22C4
01762: 9C C1 22      STZ   $22C1
01765: A9 01         LDA   #$01
01767: 8D C2 22      STA   $22C2
0176A: 18            CLC 
0176B: 60            RTS 
0176C: AD C2 22      LDA   $22C2
0176F: F0 20         BEQ   $1791
01771: C9 01         CMP   #$01
01773: D0 04         BNE   $1779
01775: 44 1C         BSR   $1793
01777: 80 18         BRA   $1791
01779: C9 02         CMP   #$02
0177B: D0 04         BNE   $1781
0177D: 44 3C         BSR   $17BB
0177F: 80 10         BRA   $1791
01781: C9 03         CMP   #$03
01783: D0 04         BNE   $1789
01785: 44 68         BSR   $17EF
01787: 80 08         BRA   $1791
01789: C9 04         CMP   #$04
0178B: D0 04         BNE   $1791
0178D: 20 09 F8      JSR   $F809
01790: 60            RTS 
01791: 18            CLC 
01792: 60            RTS 
01793: A9 81         LDA   #$81
01795: 8D 01 18      STA   $1801
01798: 93 80 00 18   TST   $80, $1800
0179C: D0 14         BNE   $17B2
0179E: 8D 00 18      STA   $1800
017A1: 82            CLX 
017A2: AD 00 18      LDA   $1800
017A5: 29 40         AND   #$40
017A7: D0 0C         BNE   $17B5
017A9: A9 5A         LDA   #$5A
017AB: 3A            DEC 
017AC: D0 FD         BNE   $17AB
017AE: EA            NOP 
017AF: CA            DEX 
017B0: D0 F0         BNE   $17A2
017B2: A9 01         LDA   #$01
017B4: 60            RTS 
017B5: A9 02         LDA   #$02
017B7: 8D C2 22      STA   $22C2
017BA: 60            RTS 
017BB: AD 00 18      LDA   $1800
017BE: 29 F8         AND   #$F8
017C0: 8D 7A 22      STA   $227A
017C3: C9 D0         CMP   #$D0
017C5: F0 0B         BEQ   $17D2
017C7: 29 B8         AND   #$B8
017C9: C9 98         CMP   #$98
017CB: F0 1C         BEQ   $17E9
017CD: C9 88         CMP   #$88
017CF: F0 14         BEQ   $17E5
017D1: 60            RTS 
017D2: AE C1 22      LDX   $22C1
017D5: EE C1 22      INC   $22C1
017D8: BD 4C 22      LDA   $224C,X
017DB: 8D 01 18      STA   $1801
017DE: EA            NOP 
017DF: EA            NOP 
017E0: EA            NOP 
017E1: EA            NOP 
017E2: 4C 27 EA      JMP   $EA27
017E5: A9 03         LDA   #$03
017E7: 80 02         BRA   $17EB
017E9: A9 04         LDA   #$04
017EB: 8D C2 22      STA   $22C2
017EE: 60            RTS 
017EF: AD C3 22      LDA   $22C3
017F2: 8D 08 18      STA   $1808
017F5: AD C4 22      LDA   $22C4
017F8: 8D 09 18      STA   $1809
017FB: 20 10 F7      JSR   $F710
017FE: A9 02         LDA   #$02
01800: 8D 0B 18      STA   $180B
01803: A9 04         LDA   #$04
01805: 8D C2 22      STA   $22C2
01808: 60            RTS 
01809: AD 00 18      LDA   $1800
0180C: 29 F8         AND   #$F8
0180E: 8D 7A 22      STA   $227A
01811: C9 D8         CMP   #$D8
01813: D0 41         BNE   $1856
01815: 9C 0B 18      STZ   $180B
01818: AD 01 18      LDA   $1801
0181B: 8D 7B 22      STA   $227B
0181E: 20 35 EA      JSR   $EA35
01821: 93 40 00 18   TST   $40, $1800
01825: D0 FA         BNE   $1821
01827: 20 2F EA      JSR   $EA2F
0182A: AD 00 18      LDA   $1800
0182D: 29 F8         AND   #$F8
0182F: 8D 7A 22      STA   $227A
01832: C9 F8         CMP   #$F8
01834: D0 F4         BNE   $182A
01836: AD 01 18      LDA   $1801
01839: 8D 7A 22      STA   $227A
0183C: 20 35 EA      JSR   $EA35
0183F: 93 40 00 18   TST   $40, $1800
01843: D0 FA         BNE   $183F
01845: 20 2F EA      JSR   $EA2F
01848: 93 80 00 18   TST   $80, $1800
0184C: D0 FA         BNE   $1848
0184E: 9C C2 22      STZ   $22C2
01851: 38            SEC 
01852: AD 7B 22      LDA   $227B
01855: 60            RTS 
01856: 18            CLC 
01857: 60            RTS 

BM_FORMAT
01858: A0 0A         LDY   #$0A
0185A: B9 AD F8      LDA   $F8AD,Y
0185D: D1 F8         CMP   ($F8),Y
0185F: D0 45         BNE   $18A6
01861: 88            DEY 
01862: 10 F6         BPL   $185A
01864: 20 49 FC      JSR   $FC49
01867: A9 80         LDA   #$80
01869: 85 ED         STA   $ED
0186B: 64 EC         STZ   $EC
0186D: A2 20         LDX   #$20
0186F: C2            CLY 
01870: 62            CLA 
01871: 91 EC         STA   ($EC),Y
01873: D1 EC         CMP   ($EC),Y
01875: D0 08         BNE   $187F
01877: C8            INY 
01878: D0 F7         BNE   $1871
0187A: E6 ED         INC   $ED
0187C: CA            DEX 
0187D: D0 F0         BNE   $186F
0187F: 8C 04 80      STY   $8004
01882: A5 ED         LDA   $ED
01884: 8D 05 80      STA   $8005
01887: A2 03         LDX   #$03
01889: BD A9 F8      LDA   $F8A9,X
0188C: 9D 00 80      STA   $8000,X
0188F: CA            DEX 
01890: 10 F7         BPL   $1889
01892: A9 10         LDA   #$10
01894: 8D 06 80      STA   $8006
01897: A9 80         LDA   #$80
01899: 8D 07 80      STA   $8007
0189C: 9C 10 80      STZ   $8010
0189F: 9C 11 80      STZ   $8011
018A2: 62            CLA 
018A3: 4C 7F FC      JMP   $FC7F
018A6: A9 01         LDA   #$01
018A8: 60            RTS 
018A9: 48            PHA 
018AA: 55 42         EOR   $42,X
018AC: 4D 21 42      EOR   $4221
018AF: 4D 20 46      EOR   $4620
018B2: 4F 52 4D      BBR4  $52, $1902
018B5: 41 54         EOR   ($54,X)
018B7: 21 

BM_FREE:
018B8: 20
018B9: 32 FC         AND   ($FC)
018BB: AD 04 80      LDA   $8004
018BE: 38            SEC 
018BF: ED 06 80      SBC   $8006
018C2: 85 FC         STA   $FC
018C4: AD 05 80      LDA   $8005
018C7: ED 07 80      SBC   $8007
018CA: 85 FD         STA   $FD
018CC: A5 FC         LDA   $FC
018CE: 38            SEC 
018CF: E9 12         SBC   #$12
018D1: 85 FC         STA   $FC
018D3: A5 FD         LDA   $FD
018D5: E9 00         SBC   #$00
018D7: 85 FD         STA   $FD
018D9: 10 04         BPL   $18DF
018DB: 64 FC         STZ   $FC
018DD: 64 FD         STZ   $FD
018DF: 62            CLA 
018E0: 4C 7F FC      JMP   $FC7F

BM_READ:
018E3: 20 32 FC      JSR   $FC32
018E6: 20 96 FB      JSR   $FB96
018E9: B0 60         BCS   $194B
018EB: A0 01         LDY   #$01
018ED: A5 FF         LDA   $FF
018EF: D1 F0         CMP   ($F0),Y
018F1: D0 04         BNE   $18F7
018F3: A5 FE         LDA   $FE
018F5: D2 F0         CMP   ($F0)
018F7: B0 4A         BCS   $1943
018F9: 20 FC FB      JSR   $FBFC
018FC: A0 02         LDY   #$02
018FE: B1 F0         LDA   ($F0),Y
01900: C8            INY 
01901: 18            CLC 
01902: 65 EE         ADC   $EE
01904: 85 EE         STA   $EE
01906: B1 F0         LDA   ($F0),Y
01908: 65 EF         ADC   $EF
0190A: 05 EE         ORA   $EE
0190C: 48            PHA 
0190D: 20 46 FB      JSR   $FB46
01910: 30 11         BMI   $1923
01912: AD B3 22      LDA   $22B3
01915: 38            SEC 
01916: E5 EE         SBC   $EE
01918: 8D B3 22      STA   $22B3
0191B: AD B4 22      LDA   $22B4
0191E: E5 EF         SBC   $EF
01920: 8D B4 22      STA   $22B4
01923: AD B3 22      LDA   $22B3
01926: 85 FC         STA   $FC
01928: AD B4 22      LDA   $22B4
0192B: 85 FD         STA   $FD
0192D: 0D B3 22      ORA   $22B3
01930: F0 0B         BEQ   $193D
01932: A5 FA         LDA   $FA
01934: 85 EE         STA   $EE
01936: A5 FB         LDA   $FB
01938: 85 EF         STA   $EF
0193A: 20 17 FD      JSR   $FD17
0193D: 68            PLA 
0193E: D0 10         BNE   $1950
01940: 4C 7F FC      JMP   $FC7F
01943: 64 FD         STZ   $FD
01945: 64 FC         STZ   $FC
01947: 62            CLA 
01948: 4C 7F FC      JMP   $FC7F
0194B: A9 01         LDA   #$01
0194D: 4C 7F FC      JMP   $FC7F
01950: A9 02         LDA   #$02
01952: 4C 7F FC      JMP   $FC7F

BM_WRITE:
01955: 20 32 FC      JSR   $FC32
01958: 20 96 FB      JSR   $FB96
0195B: 90 08         BCC   $1965
0195D: 20 E2 FA      JSR   $FAE2
01960: 90 03         BCC   $1965
01962: 4C 15 FA      JMP   $FA15
01965: 20 46 FB      JSR   $FB46
01968: 10 03         BPL   $196D
0196A: 4C F5 F9      JMP   $F9F5
0196D: A5 EE         LDA   $EE
0196F: 8D B3 22      STA   $22B3
01972: A5 EF         LDA   $EF
01974: 8D B4 22      STA   $22B4
01977: AD 06 80      LDA   $8006
0197A: 18            CLC 
0197B: 6D B3 22      ADC   $22B3
0197E: 85 EE         STA   $EE
01980: AD 07 80      LDA   $8007
01983: 6D B4 22      ADC   $22B4
01986: 85 EF         STA   $EF
01988: A5 EE         LDA   $EE
0198A: 18            CLC 
0198B: 69 02         ADC   #$02
0198D: 85 EC         STA   $EC
0198F: A5 EF         LDA   $EF
01991: 69 00         ADC   #$00
01993: 85 ED         STA   $ED
01995: AD 04 80      LDA   $8004
01998: C5 EC         CMP   $EC
0199A: AD 05 80      LDA   $8005
0199D: E5 ED         SBC   $ED
0199F: 90 74         BCC   $1A15
019A1: A5 EE         LDA   $EE
019A3: 8D 06 80      STA   $8006
019A6: A5 EF         LDA   $EF
019A8: 8D 07 80      STA   $8007
019AB: A0 01         LDY   #$01
019AD: B2 F0         LDA   ($F0)
019AF: 18            CLC 
019B0: 65 F0         ADC   $F0
019B2: 85 EE         STA   $EE
019B4: 85 EC         STA   $EC
019B6: B1 F0         LDA   ($F0),Y
019B8: 65 F1         ADC   $F1
019BA: 85 EF         STA   $EF
019BC: 85 ED         STA   $ED
019BE: A0 01         LDY   #$01
019C0: AD B3 22      LDA   $22B3
019C3: 18            CLC 
019C4: 72 F0         ADC   ($F0)
019C6: 92 F0         STA   ($F0)
019C8: AD B4 22      LDA   $22B4
019CB: 71 F0         ADC   ($F0),Y
019CD: 91 F0         STA   ($F0),Y
019CF: AD B3 22      LDA   $22B3
019D2: 18            CLC 
019D3: 65 EE         ADC   $EE
019D5: 85 EE         STA   $EE
019D7: AD B4 22      LDA   $22B4
019DA: 65 EF         ADC   $EF
019DC: 85 EF         STA   $EF
019DE: AD 06 80      LDA   $8006
019E1: 38            SEC 
019E2: E5 EC         SBC   $EC
019E4: 8D B3 22      STA   $22B3
019E7: AD 07 80      LDA   $8007
019EA: E5 ED         SBC   $ED
019EC: 8D B4 22      STA   $22B4
019EF: 20 D3 FC      JSR   $FCD3
019F2: 20 46 FB      JSR   $FB46
019F5: A5 FA         LDA   $FA
019F7: 85 EE         STA   $EE
019F9: A5 FB         LDA   $FB
019FB: 85 EF         STA   $EF
019FD: 20 2C FD      JSR   $FD2C
01A00: 20 FC FB      JSR   $FBFC
01A03: A0 02         LDY   #$02
01A05: 62            CLA 
01A06: 38            SEC 
01A07: E5 EE         SBC   $EE
01A09: 91 F0         STA   ($F0),Y
01A0B: C8            INY 
01A0C: 62            CLA 
01A0D: E5 EF         SBC   $EF
01A0F: 91 F0         STA   ($F0),Y
01A11: 62            CLA 
01A12: 4C 7F FC      JMP   $FC7F
01A15: A9 01         LDA   #$01
01A17: 4C 7F FC      JMP   $FC7F

BM_DELETE:
01A1A: 20 32 FC      JSR   $FC32
01A1D: 20 96 FB      JSR   $FB96
01A20: B0 4B         BCS   $1A6D
01A22: A5 F0         LDA   $F0
01A24: 85 EE         STA   $EE
01A26: A5 F1         LDA   $F1
01A28: 85 EF         STA   $EF
01A2A: B2 F0         LDA   ($F0)
01A2C: 8D B3 22      STA   $22B3
01A2F: A0 01         LDY   #$01
01A31: B1 F0         LDA   ($F0),Y
01A33: 8D B4 22      STA   $22B4
01A36: A5 F0         LDA   $F0
01A38: 18            CLC 
01A39: 6D B3 22      ADC   $22B3
01A3C: 85 EC         STA   $EC
01A3E: A5 F1         LDA   $F1
01A40: 6D B4 22      ADC   $22B4
01A43: 85 ED         STA   $ED
01A45: AD 06 80      LDA   $8006
01A48: 38            SEC 
01A49: E5 EC         SBC   $EC
01A4B: 8D B3 22      STA   $22B3
01A4E: AD 07 80      LDA   $8007
01A51: E5 ED         SBC   $ED
01A53: 8D B4 22      STA   $22B4
01A56: AD 06 80      LDA   $8006
01A59: 38            SEC 
01A5A: F2 F0         SBC   ($F0)
01A5C: 8D 06 80      STA   $8006
01A5F: AD 07 80      LDA   $8007
01A62: F1 F0         SBC   ($F0),Y
01A64: 8D 07 80      STA   $8007
01A67: 20 D3 FC      JSR   $FCD3
01A6A: 4C 7F FC      JMP   $FC7F
01A6D: A9 01         LDA   #$01
01A6F: 4C 7F FC      JMP   $FC7F

BM_FILES:
01A72: 20 32 FC      JSR   $FC32
01A75: A9 10         LDA   #$10
01A77: 85 F0         STA   $F0
01A79: A9 80         LDA   #$80
01A7B: 85 F1         STA   $F1
01A7D: A5 F8         LDA   $F8
01A7F: 8D B3 22      STA   $22B3
01A82: 64 F8         STZ   $F8
01A84: A0 01         LDY   #$01
01A86: B2 F0         LDA   ($F0)
01A88: 11 F0         ORA   ($F0),Y
01A8A: F0 51         BEQ   $1ADD
01A8C: E6 F8         INC   $F8
01A8E: CE B3 22      DEC   $22B3
01A91: F0 11         BEQ   $1AA4
01A93: B1 F0         LDA   ($F0),Y
01A95: 48            PHA 
01A96: B2 F0         LDA   ($F0)
01A98: 18            CLC 
01A99: 65 F0         ADC   $F0
01A9B: 85 F0         STA   $F0
01A9D: 68            PLA 
01A9E: 65 F1         ADC   $F1
01AA0: 85 F1         STA   $F1
01AA2: 80 E2         BRA   $1A86
01AA4: B2 F0         LDA   ($F0)
01AA6: 38            SEC 
01AA7: E9 10         SBC   #$10
01AA9: AA            TAX 
01AAA: B1 F0         LDA   ($F0),Y
01AAC: E9 00         SBC   #$00
01AAE: 48            PHA 
01AAF: DA            PHX 
01AB0: A5 F0         LDA   $F0
01AB2: 18            CLC 
01AB3: 69 04         ADC   #$04
01AB5: 85 F0         STA   $F0
01AB7: A5 F1         LDA   $F1
01AB9: 69 00         ADC   #$00
01ABB: 85 F1         STA   $F1
01ABD: A5 FA         LDA   $FA
01ABF: 85 EE         STA   $EE
01AC1: A5 FB         LDA   $FB
01AC3: 85 EF         STA   $EF
01AC5: 20 7B FD      JSR   $FD7B
01AC8: C2            CLY 
01AC9: B1 F0         LDA   ($F0),Y
01ACB: 91 EE         STA   ($EE),Y
01ACD: C8            INY 
01ACE: C0 0C         CPY   #$0C
01AD0: 90 F7         BCC   $1AC9
01AD2: 68            PLA 
01AD3: 91 EE         STA   ($EE),Y
01AD5: C8            INY 
01AD6: 68            PLA 
01AD7: 91 EE         STA   ($EE),Y
01AD9: 62            CLA 
01ADA: 4C 7F FC      JMP   $FC7F
01ADD: A9 01         LDA   #$01
01ADF: 4C 7F FC      JMP   $FC7F
01AE2: AD 06 80      LDA   $8006
01AE5: 85 F0         STA   $F0
01AE7: AD 07 80      LDA   $8007
01AEA: 85 F1         STA   $F1
01AEC: AD 04 80      LDA   $8004
01AEF: 38            SEC 
01AF0: E5 F0         SBC   $F0
01AF2: 85 EC         STA   $EC
01AF4: AD 05 80      LDA   $8005
01AF7: E5 F1         SBC   $F1
01AF9: 85 ED         STA   $ED
01AFB: A5 EE         LDA   $EE
01AFD: C9 10         CMP   #$10
01AFF: A5 EF         LDA   $EF
01B01: E9 00         SBC   #$00
01B03: 90 3F         BCC   $1B44
01B05: A5 F0         LDA   $F0
01B07: 18            CLC 
01B08: 69 04         ADC   #$04
01B0A: 85 EC         STA   $EC
01B0C: A5 F1         LDA   $F1
01B0E: 69 00         ADC   #$00
01B10: 85 ED         STA   $ED
01B12: A5 F8         LDA   $F8
01B14: 85 EE         STA   $EE
01B16: A5 F9         LDA   $F9
01B18: 85 EF         STA   $EF
01B1A: 20 7B FD      JSR   $FD7B
01B1D: C2            CLY 
01B1E: B1 EE         LDA   ($EE),Y
01B20: 91 EC         STA   ($EC),Y
01B22: C8            INY 
01B23: C0 0C         CPY   #$0C
01B25: D0 F7         BNE   $1B1E
01B27: AD 06 80      LDA   $8006
01B2A: 18            CLC 
01B2B: 69 10         ADC   #$10
01B2D: 8D 06 80      STA   $8006
01B30: AD 07 80      LDA   $8007
01B33: 69 00         ADC   #$00
01B35: 8D 07 80      STA   $8007
01B38: A0 01         LDY   #$01
01B3A: A9 10         LDA   #$10
01B3C: 92 F0         STA   ($F0)
01B3E: A9 00         LDA   #$00
01B40: 91 F0         STA   ($F0),Y
01B42: 18            CLC 
01B43: 60            RTS 
01B44: 38            SEC 
01B45: 60            RTS 
01B46: A5 FE         LDA   $FE
01B48: 18            CLC 
01B49: 65 FC         ADC   $FC
01B4B: 85 EE         STA   $EE
01B4D: A5 FF         LDA   $FF
01B4F: 65 FD         ADC   $FD
01B51: 85 EF         STA   $EF
01B53: A5 EE         LDA   $EE
01B55: 18            CLC 
01B56: 69 10         ADC   #$10
01B58: 85 EE         STA   $EE
01B5A: A5 EF         LDA   $EF
01B5C: 69 00         ADC   #$00
01B5E: 85 EF         STA   $EF
01B60: A0 01         LDY   #$01
01B62: A5 EE         LDA   $EE
01B64: 38            SEC 
01B65: F2 F0         SBC   ($F0)
01B67: 85 EE         STA   $EE
01B69: A5 EF         LDA   $EF
01B6B: F1 F0         SBC   ($F0),Y
01B6D: 85 EF         STA   $EF
01B6F: A5 F0         LDA   $F0
01B71: 18            CLC 
01B72: 69 10         ADC   #$10
01B74: 85 EC         STA   $EC
01B76: A5 F1         LDA   $F1
01B78: 69 00         ADC   #$00
01B7A: 85 ED         STA   $ED
01B7C: A5 FE         LDA   $FE
01B7E: 18            CLC 
01B7F: 65 EC         ADC   $EC
01B81: 85 EC         STA   $EC
01B83: A5 FF         LDA   $FF
01B85: 65 ED         ADC   $ED
01B87: 85 ED         STA   $ED
01B89: A5 FC         LDA   $FC
01B8B: 8D B3 22      STA   $22B3
01B8E: A5 FD         LDA   $FD
01B90: 8D B4 22      STA   $22B4
01B93: A5 EF         LDA   $EF
01B95: 60            RTS 
01B96: A5 F8         LDA   $F8
01B98: 85 EE         STA   $EE
01B9A: A5 F9         LDA   $F9
01B9C: 85 EF         STA   $EF
01B9E: 20 7B FD      JSR   $FD7B
01BA1: A9 10         LDA   #$10
01BA3: 85 F0         STA   $F0
01BA5: A9 80         LDA   #$80
01BA7: 85 F1         STA   $F1
01BA9: A0 01         LDY   #$01
01BAB: B2 F0         LDA   ($F0)
01BAD: 11 F0         ORA   ($F0),Y
01BAF: F0 49         BEQ   $1BFA
01BB1: A5 F0         LDA   $F0
01BB3: 18            CLC 
01BB4: 69 04         ADC   #$04
01BB6: 85 F0         STA   $F0
01BB8: A5 F1         LDA   $F1
01BBA: 69 00         ADC   #$00
01BBC: 85 F1         STA   $F1
01BBE: C2            CLY 
01BBF: B1 EE         LDA   ($EE),Y
01BC1: D1 F0         CMP   ($F0),Y
01BC3: D0 14         BNE   $1BD9
01BC5: C8            INY 
01BC6: C0 0C         CPY   #$0C
01BC8: 90 F5         BCC   $1BBF
01BCA: A5 F0         LDA   $F0
01BCC: 38            SEC 
01BCD: E9 04         SBC   #$04
01BCF: 85 F0         STA   $F0
01BD1: A5 F1         LDA   $F1
01BD3: E9 00         SBC   #$00
01BD5: 85 F1         STA   $F1
01BD7: 18            CLC 
01BD8: 60            RTS 
01BD9: A5 F0         LDA   $F0
01BDB: 38            SEC 
01BDC: E9 04         SBC   #$04
01BDE: 85 F0         STA   $F0
01BE0: A5 F1         LDA   $F1
01BE2: E9 00         SBC   #$00
01BE4: 85 F1         STA   $F1
01BE6: A0 01         LDY   #$01
01BE8: B1 F0         LDA   ($F0),Y
01BEA: 48            PHA 
01BEB: B2 F0         LDA   ($F0)
01BED: 18            CLC 
01BEE: 65 F0         ADC   $F0
01BF0: 85 F0         STA   $F0
01BF2: 68            PLA 
01BF3: 65 F1         ADC   $F1
01BF5: 85 F1         STA   $F1
01BF7: 4C A9 FB      JMP   $FBA9
01BFA: 38            SEC 
01BFB: 60            RTS 

01BFC: A5 F0         LDA   $F0
01BFE: 85 EC         STA   $EC
01C00: A5 F1         LDA   $F1
01C02: 85 ED         STA   $ED
01C04: A0 01         LDY   #$01
01C06: B2 EC         LDA   ($EC)
01C08: 38            SEC 
01C09: E9 04         SBC   #$04
01C0B: 8D B3 22      STA   $22B3
01C0E: B1 EC         LDA   ($EC),Y
01C10: E9 00         SBC   #$00
01C12: 8D B4 22      STA   $22B4
01C15: 64 EE         STZ   $EE
01C17: 64 EF         STZ   $EF
01C19: A0 04         LDY   #$04
01C1B: B1 EC         LDA   ($EC),Y
01C1D: 18            CLC 
01C1E: 65 EE         ADC   $EE
01C20: 85 EE         STA   $EE
01C22: 62            CLA 
01C23: 65 EF         ADC   $EF
01C25: 85 EF         STA   $EF
01C27: C8            INY 
01C28: D0 02         BNE   $1C2C
01C2A: E6 ED         INC   $ED
01C2C: 20 97 FD      JSR   $FD97
01C2F: D0 EA         BNE   $1C1B
01C31: 60            RTS 

01C32: 44 15         BSR   $1C49
01C34: A2 03         LDX   #$03
01C36: BD 00 80      LDA   $8000,X
01C39: DD A9 F8      CMP   $F8A9,X
01C3C: D0 04         BNE   $1C42
01C3E: CA            DEX 
01C3F: 10 F5         BPL   $1C36
01C41: 60            RTS 

01C42: 44 3B         BSR   $1C7F
01C44: 68            PLA 
01C45: 68            PLA 
01C46: A9 FF         LDA   #$FF
01C48: 60            RTS 

01C49: 48            PHA 
01C4A: 43 01         TMA   #$01
01C4C: 8D B5 22      STA   $22B5
01C4F: 43 02         TMA   #$02
01C51: 8D B6 22      STA   $22B6
01C54: 43 04         TMA   #$04
01C56: 8D B7 22      STA   $22B7
01C59: 43 08         TMA   #$08
01C5B: 8D B8 22      STA   $22B8
01C5E: 43 10         TMA   #$10
01C60: 8D B9 22      STA   $22B9
01C63: 43 20         TMA   #$20
01C65: 8D BA 22      STA   $22BA
01C68: 43 40         TMA   #$40
01C6A: 8D BB 22      STA   $22BB
01C6D: 43 80         TMA   #$80
01C6F: 8D BC 22      STA   $22BC
01C72: A9 F7         LDA   #$F7
01C74: 53 10         TAM   #$10
01C76: 54            CSL
01C77: 78            SEI 
01C78: A9 80         LDA   #$80
01C7A: 8D 07 18      STA   $1807
01C7D: 68            PLA 
01C7E: 60            RTS 

01C7F: 48            PHA 
01C80: AD B5 22      LDA   $22B5
01C83: 53 01         TAM   #$01
01C85: AD B6 22      LDA   $22B6
01C88: 53 02         TAM   #$02
01C8A: AD B7 22      LDA   $22B7
01C8D: 53 04         TAM   #$04
01C8F: AD B8 22      LDA   $22B8
01C92: 53 08         TAM   #$08
01C94: AD B9 22      LDA   $22B9
01C97: 53 10         TAM   #$10
01C99: AD BA 22      LDA   $22BA
01C9C: 53 20         TAM   #$20
01C9E: AD BB 22      LDA   $22BB
01CA1: 53 40         TAM   #$40
01CA3: AD BC 22      LDA   $22BC
01CA6: 53 80         TAM   #$80
01CA8: AD 03 18      LDA   $1803
01CAB: D4            CSH 
01CAC: A9 05         LDA   #$05
01CAE: 8D 00 00      STA   $0000
01CB1: A5 F3         LDA   $F3
01CB3: 09 08         ORA   #$08
01CB5: 8D 02 00      STA   $0002
01CB8: AD 00 00      LDA   $0000
01CBB: 29 20         AND   #$20
01CBD: D0 F9         BNE   $1CB8
01CBF: AD 00 00      LDA   $0000
01CC2: 29 20         AND   #$20
01CC4: F0 F9         BEQ   $1CBF
01CC6: A5 F3         LDA   $F3
01CC8: 8D 02 00      STA   $0002
01CCB: A5 F7         LDA   $F7
01CCD: 8D 00 00      STA   $0000
01CD0: 68            PLA 
01CD1: 58            CLI 
01CD2: 60            RTS 

01CD3: AD B3 22      LDA   $22B3
01CD6: 0D B4 22      ORA   $22B4
01CD9: F0 2A         BEQ   $1D05
01CDB: 20 41 FD      JSR   $FD41
01CDE: C2            CLY 
01CDF: 8A            TXA 
01CE0: D0 13         BNE   $1CF5
01CE2: B1 EC         LDA   ($EC),Y
01CE4: 91 EE         STA   ($EE),Y
01CE6: 98            TYA 
01CE7: D0 04         BNE   $1CED
01CE9: C6 ED         DEC   $ED
01CEB: C6 EF         DEC   $EF
01CED: 88            DEY 
01CEE: 20 97 FD      JSR   $FD97
01CF1: D0 EF         BNE   $1CE2
01CF3: F0 10         BEQ   $1D05
01CF5: B1 EC         LDA   ($EC),Y
01CF7: 91 EE         STA   ($EE),Y
01CF9: C8            INY 
01CFA: D0 04         BNE   $1D00
01CFC: E6 ED         INC   $ED
01CFE: E6 EF         INC   $EF
01D00: 20 97 FD      JSR   $FD97
01D03: D0 F0         BNE   $1CF5
01D05: AD 06 80      LDA   $8006
01D08: 85 EC         STA   $EC
01D0A: AD 07 80      LDA   $8007
01D0D: 85 ED         STA   $ED
01D0F: A0 01         LDY   #$01
01D11: 62            CLA 
01D12: 92 EC         STA   ($EC)
01D14: 91 EC         STA   ($EC),Y
01D16: 60            RTS 

01D17: 20 7B FD      JSR   $FD7B
01D1A: C2            CLY 
01D1B: B1 EC         LDA   ($EC),Y
01D1D: 91 EE         STA   ($EE),Y
01D1F: C8            INY 
01D20: D0 04         BNE   $1D26
01D22: E6 ED         INC   $ED
01D24: E6 EF         INC   $EF
01D26: 20 97 FD      JSR   $FD97
01D29: D0 F0         BNE   $1D1B
01D2B: 60            RTS 

01D2C: 20 7B FD      JSR   $FD7B
01D2F: C2            CLY 
01D30: B1 EE         LDA   ($EE),Y
01D32: 91 EC         STA   ($EC),Y
01D34: C8            INY 
01D35: D0 04         BNE   $1D3B
01D37: E6 ED         INC   $ED
01D39: E6 EF         INC   $EF
01D3B: 20 97 FD      JSR   $FD97
01D3E: D0 F0         BNE   $1D30
01D40: 60            RTS 

01D41: A5 EC         LDA   $EC
01D43: 38            SEC 
01D44: E5 EE         SBC   $EE
01D46: A5 ED         LDA   $ED
01D48: E5 EF         SBC   $EF
01D4A: B0 2C         BCS   $1D78
01D4C: 20 97 FD      JSR   $FD97
01D4F: A5 EC         LDA   $EC
01D51: 18            CLC 
01D52: 6D B3 22      ADC   $22B3
01D55: 85 EC         STA   $EC
01D57: A5 ED         LDA   $ED
01D59: 6D B4 22      ADC   $22B4
01D5C: 85 ED         STA   $ED
01D5E: A5 EE         LDA   $EE
01D60: 18            CLC 
01D61: 6D B3 22      ADC   $22B3
01D64: 85 EE         STA   $EE
01D66: A5 EF         LDA   $EF
01D68: 6D B4 22      ADC   $22B4
01D6B: 85 EF         STA   $EF
01D6D: EE B3 22      INC   $22B3
01D70: D0 03         BNE   $1D75
01D72: EE B4 22      INC   $22B4
01D75: A2 00         LDX   #$00
01D77: 60            RTS 
01D78: A2 02         LDX   #$02
01D7A: 60            RTS 

01D7B: A5 EF         LDA   $EF
01D7D: 2A            ROL 
01D7E: 2A            ROL 
01D7F: 2A            ROL 
01D80: 2A            ROL 
01D81: 29 07         AND   #$07
01D83: AA            TAX 
01D84: BD B5 22      LDA   $22B5,X
01D87: 53 20         TAM   #$20
01D89: BD B6 22      LDA   $22B6,X
01D8C: 53 40         TAM   #$40
01D8E: A5 EF         LDA   $EF
01D90: 29 1F         AND   #$1F
01D92: 09 A0         ORA   #$A0
01D94: 85 EF         STA   $EF
01D96: 60            RTS 

01D97: AD B3 22      LDA   $22B3
01D9A: D0 03         BNE   $1D9F
01D9C: CE B4 22      DEC   $22B4
01D9F: CE B3 22      DEC   $22B3
01DA2: AD B3 22      LDA   $22B3
01DA5: 0D B4 22      ORA   $22B4
01DA8: 60            RTS 

01DA9: 48            PHA 
01DAA: 43 40         TMA   #$40
01DAC: 8D BB 22      STA   $22BB
01DAF: A9 03         LDA   #$03
01DB1: 53 40         TAM   #$40
01DB3: 68            PLA 
01DB4: 60            RTS 

01DB5: 08            PHP 
01DB6: 48            PHA 
01DB7: AD BB 22      LDA   $22BB
01DBA: 53 40         TAM   #$40
01DBC: 68            PLA 
01DBD: 28            PLP 
01DBE: 60            RTS 
01DBF: 44 E8         BSR   $1DA9
01DC1: 20 10 CD      JSR   $CD10
01DC4: 80 EF         BRA   $1DB5
01DC6: 44 E1         BSR   $1DA9
01DC8: 20 3A CD      JSR   $CD3A
01DCB: 80 E8         BRA   $1DB5
01DCD: 44 DA         BSR   $1DA9
01DCF: 20 57 CD      JSR   $CD57
01DD2: 80 E1         BRA   $1DB5
01DD4: 44 D3         BSR   $1DA9
01DD6: 20 92 CD      JSR   $CD92
01DD9: 80 DA         BRA   $1DB5
01DDB: 44 CC         BSR   $1DA9
01DDD: 20 C3 CD      JSR   $CDC3
01DE0: 80 D3         BRA   $1DB5
01DE2: 44 C5         BSR   $1DA9
01DE4: 20 DB CD      JSR   $CDDB
01DE7: 80 CC         BRA   $1DB5
01DE9: 44 BE         BSR   $1DA9
01DEB: 20 2E CE      JSR   $CE2E
01DEE: 80 C5         BRA   $1DB5
01DF0: 44 B7         BSR   $1DA9
01DF2: 20 75 CE      JSR   $CE75
01DF5: 80 BE         BRA   $1DB5
01DF7: 44 B0         BSR   $1DA9
01DF9: 20 C3 CE      JSR   $CEC3
01DFC: 80 B7         BRA   $1DB5
01DFE: 44 A9         BSR   $1DA9
01E00: 20 C8 CE      JSR   $CEC8
01E03: 80 B0         BRA   $1DB5


01E05: 44 A2         BSR   $1DA9
01E07: 20 D2 CE      JSR   $CED2
01E0A: 80 A9         BRA   $1DB5


01E0C: DA            PHX 
01E0D: 5A            PHY 
01E0E: 43 40         TMA   #$40
01E10: 48            PHA 
01E11: A9 02         LDA   #$02
01E13: 53 40         TAM   #$40
01E15: A5 FF         LDA   $FF
01E17: C9 15         CMP   #$15
01E19: B0 07         BCS   $1E22
01E1B: 0A            ASL 
01E1C: AA            TAX 
01E1D: A5 F8         LDA   $F8
01E1F: 20 2A FE      JSR   $FE2A
01E22: A8            TAY 
01E23: 68            PLA 
01E24: 53 40         TAM   #$40
01E26: 98            TYA 
01E27: 7A            PLY 
01E28: FA            PLX 
01E29: 60            RTS 

01E2A: 7C 2D FE      JMP   ($FE2D,X)

01E2D: 00            BRK 
01E2E: C0 19         CPY   #$19
01E30: C0 43         CPY   #$43
01E32: C0 DB         CPY   #$DB
01E34: C0 E6         CPY   #$E6
01E36: C0 F1         CPY   #$F1
01E38: C0 FC         CPY   #$FC
01E3A: C0 07         CPY   #$07
01E3C: C1 12         CMP   ($12,X)
01E3E: C1 1D         CMP   ($1D,X)
01E40: C1 28         CMP   ($28,X)
01E42: C1 42         CMP   ($42,X)
01E44: C1 51         CMP   ($51,X)
01E46: C1 6C         CMP   ($6C,X)
01E48: C1 85         CMP   ($85,X)
01E4A: C1 CA         CMP   ($CA,X)
01E4C: C1 21         CMP   ($21,X)
01E4E: C2            CLY 
01E4F: 4A            LSR 
01E50: C2            CLY 
01E51: 7C C2 CD      JMP   ($CDC2,X)
01E54: C2            CLY 
01E55: E9 C2         SBC   #$C2


01E57: 43 40         TMA   #$40
01E59: 48            PHA 
01E5A: A9 03         LDA   #$03
01E5C: 53 40         TAM   #$40
01E5E: A5 FF         LDA   $FF
01E60: C9 11         CMP   #$11
01E62: B0 05         BCS   $1E69
01E64: 0A            ASL 
01E65: AA            TAX 
01E66: 20 6D FE      JSR   $FE6D
01E69: 68            PLA 
01E6A: 53 40         TAM   #$40
01E6C: 60            RTS 


01E6D: 7C 70 FE      JMP   ($FE70,X)


01E70: F3 CA 07 CB ED CB B2  TAI   $07CA, $EDCB, $B2CB
01E77: CA            DEX 
01E78: 29 C5         AND   #$C5
01E7A: A8            TAY 
01E7B: C1 A2         CMP   ($A2,X)
01E7D: C2            CLY 
01E7E: 85 C0         STA   $C0
01E80: 3C C0 67      BIT   $67C0,X
01E83: C0 90         CPY   #$90
01E85: C3 48 C4 14 CB 0E CB  TDD   $C448, $CB14, $CB0E
01E8C: F4            SET 
01E8D: C7 F0         SMB4  $F0
01E8F: C6 71         DEC   $71
01E91: CC 

EX_MEMOPEN:
01E92: AD C5 18      LDA   $18C5
01E95: C9 AA         CMP   #$AA
01E97: D0 0C         BNE   $1EA5
01E99: AD C6 18      LDA   $18C6
01E9C: C9 55         CMP   #$55
01E9E: D0 05         BNE   $1EA5
01EA0: AE C7 18      LDX   $18C7
01EA3: 80 15         BRA   $1EBA
01EA5: AD C1 18      LDA   $18C1
01EA8: C9 AA         CMP   #$AA
01EAA: D0 13         BNE   $1EBF
01EAC: AD C2 18      LDA   $18C2
01EAF: C9 55         CMP   #$55
01EB1: D0 0C         BNE   $1EBF
01EB3: AE C3 18      LDX   $18C3
01EB6: 22            SAX 
01EB7: 09 80         ORA   #$80
01EB9: 22            SAX 
01EBA: AD F4 FF      LDA   $FFF4
01EBD: 18            CLC 
01EBE: 60            RTS 
01EBF: 82            CLX 
01EC0: 38            SEC 
01EC1: 60            RTS 

version:
01EC2: 03 00

01EC4: FF FF FF      BBS7  $FF, $1EC6
01EC7: FF FF FF      BBS7  $FF, $1EC9
01ECA: FF FF FF      BBS7  $FF, $1ECC
01ECD: FF FF FF      BBS7  $FF, $1ECF
01ED0: FF FF FF      BBS7  $FF, $1ED2
01ED3: FF FF FF      BBS7  $FF, $1ED5
01ED6: FF FF FF      BBS7  $FF, $1ED8
01ED9: FF FF FF      BBS7  $FF, $1EDB
01EDC: FF FF FF      BBS7  $FF, $1EDE
01EDF: FF FF FF      BBS7  $FF, $1EE1
01EE2: FF FF FF      BBS7  $FF, $1EE4
01EE5: FF FF FF      BBS7  $FF, $1EE7
01EE8: FF FF FF      BBS7  $FF, $1EEA
01EEB: FF FF FF      BBS7  $FF, $1EED
01EEE: FF FF FF      BBS7  $FF, $1EF0
01EF1: FF FF FF      BBS7  $FF, $1EF3
01EF4: FF FF FF      BBS7  $FF, $1EF6
01EF7: FF FF FF      BBS7  $FF, $1EF9
01EFA: FF FF FF      BBS7  $FF, $1EFC
01EFD: FF FF FF      BBS7  $FF, $1EFF
01F00: FF FF FF      BBS7  $FF, $1F02
01F03: FF FF FF      BBS7  $FF, $1F05
01F06: FF FF FF      BBS7  $FF, $1F08
01F09: FF FF FF      BBS7  $FF, $1F0B
01F0C: FF FF FF      BBS7  $FF, $1F0E
01F0F: FF FF FF      BBS7  $FF, $1F11
01F12: FF FF FF      BBS7  $FF, $1F14
01F15: FF FF FF      BBS7  $FF, $1F17
01F18: FF FF FF      BBS7  $FF, $1F1A
01F1B: FF FF FF      BBS7  $FF, $1F1D
01F1E: FF FF FF      BBS7  $FF, $1F20
01F21: FF FF FF      BBS7  $FF, $1F23
01F24: FF FF FF      BBS7  $FF, $1F26
01F27: FF FF FF      BBS7  $FF, $1F29
01F2A: FF FF FF      BBS7  $FF, $1F2C
01F2D: FF FF FF      BBS7  $FF, $1F2F
01F30: FF FF FF      BBS7  $FF, $1F32
01F33: FF FF FF      BBS7  $FF, $1F35
01F36: FF FF FF      BBS7  $FF, $1F38
01F39: FF FF FF      BBS7  $FF, $1F3B
01F3C: FF FF FF      BBS7  $FF, $1F3E
01F3F: FF FF FF      BBS7  $FF, $1F41
01F42: FF FF FF      BBS7  $FF, $1F44
01F45: FF FF FF      BBS7  $FF, $1F47
01F48: FF FF FF      BBS7  $FF, $1F4A
01F4B: FF FF FF      BBS7  $FF, $1F4D
01F4E: FF FF FF      BBS7  $FF, $1F50
01F51: FF FF FF      BBS7  $FF, $1F53
01F54: FF FF FF      BBS7  $FF, $1F56
01F57: FF FF FF      BBS7  $FF, $1F59
01F5A: FF FF FF      BBS7  $FF, $1F5C
01F5D: FF FF FF      BBS7  $FF, $1F5F
01F60: FF FF FF      BBS7  $FF, $1F62
01F63: FF FF FF      BBS7  $FF, $1F65
01F66: FF FF FF      BBS7  $FF, $1F68
01F69: FF FF FF      BBS7  $FF, $1F6B
01F6C: FF FF FF      BBS7  $FF, $1F6E
01F6F: FF FF FF      BBS7  $FF, $1F71
01F72: FF FF FF      BBS7  $FF, $1F74
01F75: FF FF FF      BBS7  $FF, $1F77
01F78: FF FF FF      BBS7  $FF, $1F7A
01F7B: FF FF FF      BBS7  $FF, $1F7D
01F7E: FF FF FF      BBS7  $FF, $1F80
01F81: FF FF FF      BBS7  $FF, $1F83
01F84: FF FF FF      BBS7  $FF, $1F86
01F87: FF FF FF      BBS7  $FF, $1F89
01F8A: FF FF FF      BBS7  $FF, $1F8C
01F8D: FF FF FF      BBS7  $FF, $1F8F
01F90: FF FF FF      BBS7  $FF, $1F92
01F93: FF FF FF      BBS7  $FF, $1F95
01F96: FF FF FF      BBS7  $FF, $1F98
01F99: FF FF FF      BBS7  $FF, $1F9B
01F9C: FF FF FF      BBS7  $FF, $1F9E
01F9F: FF FF FF      BBS7  $FF, $1FA1
01FA2: FF FF FF      BBS7  $FF, $1FA4
01FA5: FF FF FF      BBS7  $FF, $1FA7
01FA8: FF FF FF      BBS7  $FF, $1FAA
01FAB: FF FF FF      BBS7  $FF, $1FAD
01FAE: FF FF FF      BBS7  $FF, $1FB0
01FB1: FF FF FF      BBS7  $FF, $1FB3
01FB4: FF FF FF      BBS7  $FF, $1FB6
01FB7: FF FF FF      BBS7  $FF, $1FB9
01FBA: FF FF FF      BBS7  $FF, $1FBC
01FBD: FF FF FF      BBS7  $FF, $1FBF
01FC0: FF FF FF      BBS7  $FF, $1FC2
01FC3: FF FF FF      BBS7  $FF, $1FC5
01FC6: FF FF FF      BBS7  $FF, $1FC8
01FC9: FF FF FF      BBS7  $FF, $1FCB
01FCC: FF FF FF      BBS7  $FF, $1FCE
01FCF: FF FF FF      BBS7  $FF, $1FD1
01FD2: FF FF FF      BBS7  $FF, $1FD4
01FD5: FF FF FF      BBS7  $FF, $1FD7
01FD8: FF FF FF      BBS7  $FF, $1FDA
01FDB: FF 4C 00      BBS7  $4C, $1FDE
01FDE: E9 4C         SBC   #$4C
01FE0: 3B            ??? 
01FE1: EA            NOP 
01FE2: 4C 79 EA      JMP   $EA79
01FE5: 4C BE EA      JMP   $EABE
01FE8: 4C 16 EB      JMP   $EB16
01FEB: 4C 5E EB      JMP   $EB5E
01FEE: 4C C5 E9      JMP   $E9C5
01FF1: 4C DC E9      JMP   $E9DC
01FF4: 68
01FF5: 80 

01FF6: IRQ2_INT				;$E736 
01FF8: IRQ1_INT				;$E870
01FFA: TIMER_INT				;$E6B3  
01FFC: NMI_INT				;$E6A9 
01FFE: CD_BOOT				;$E0F3 

02000: 00 00 00 00 00
02005: 00            BRK 
02006: 00            BRK 
02007: 00            BRK 
02008: 00            BRK 
02009: 00            BRK 
0200A: 00            BRK 
0200B: 00            BRK 
0200C: 00            BRK 
0200D: 00            BRK 
0200E: 00            BRK 
0200F: FF 00 00      BBS7  $00, $2012
02012: 00            BRK 
02013: 00            BRK 
02014: 00            BRK 
02015: 00            BRK 
02016: FF FF 00      BBS7  $FF, $2019
02019: 00            BRK 
0201A: 00            BRK 
0201B: 00            BRK 
0201C: 00            BRK 
0201D: FF FF FF      BBS7  $FF, $201F
02020: 00            BRK 
02021: 00            BRK 
02022: 00            BRK 
02023: 00            BRK 
02024: FF FF FF      BBS7  $FF, $2026
02027: FF 00 00      BBS7  $00, $202A
0202A: 00            BRK 
0202B: FF FF FF      BBS7  $FF, $202D
0202E: FF FF 00      BBS7  $FF, $2031
02031: 00            BRK 
02032: FF FF FF      BBS7  $FF, $2034
02035: FF FF FF      BBS7  $FF, $2037
02038: 00            BRK 
02039: FF FF FF      BBS7  $FF, $203B
0203C: FF FF FF      BBS7  $FF, $203E
0203F: FF FF FF      BBS7  $FF, $2041
02042: FF FF FF      BBS7  $FF, $2044
02045: FF FF FF      BBS7  $FF, $2047
02048: 10 38         BPL   $2082
0204A: 7C FE FE      JMP   ($FEFE,X)
0204D: 7C 10 38      JMP   ($3810,X)
02050: 00            BRK 
02051: 6C FE FE      JMP   ($FEFE)
02054: FE 7C 38      INC   $387C,X
02057: 10 00         BPL   $2059
02059: 10 38         BPL   $2093
0205B: 7C FE 7C      JMP   ($7CFE,X)
0205E: 38            SEC 
0205F: 10 10         BPL   $2071
02061: 38            SEC 
02062: 38            SEC 
02063: 7C FE 7C      JMP   ($7CFE,X)
02066: 10 38         BPL   $20A0
02068: 38            SEC 
02069: 7C FE FE      JMP   ($FEFE,X)
0206C: FE 7C 38      INC   $387C,X
0206F: 00            BRK 
02070: 38            SEC 
02071: 44 82         BSR   $1FF5
02073: 82            CLX 
02074: 82            CLX 
02075: 44 38         BSR   $20AF
02077: 00            BRK 
02078: 01 02         ORA   ($02,X)
0207A: 04 08         TSB   $08
0207C: 10 20         BPL   $209E
0207E: 40            RTI 
0207F: 80 80         BRA   $2001
02081: 40            RTI 
02082: 20 10 08      JSR   $0810
02085: 04 02         TSB   $02
02087: 01 FE         ORA   ($FE,X)
02089: 92 92         STA   ($92)
0208B: FE 82 82      INC   $8282,X
0208E: 86 82         STX   $82
02090: 40            RTI 
02091: 7C 90 7C      JMP   ($7C90,X)
02094: 50 FE         BVC   $2094
02096: 10 10         BPL   $20A8
02098: 7E 42 7E      ROR   $7E42,X
0209B: 42            SAY 
0209C: 7E 42 46      ROR   $4642,X
0209F: 82            CLX 
020A0: FE 82 82      INC   $8282,X
020A3: FE 82 82      INC   $8282,X
020A6: FE 82 08      INC   $0882,X
020A9: FC            ??? 
020AA: A8            TAY 
020AB: FE A4 FE      INC   $FEA4,X
020AE: 14 0C         TRB   $0C
020B0: 10 38         BPL   $20EA
020B2: 6C C6 7C      JMP   ($7CC6)
020B5: 24 4C         BIT   $4C
020B7: 00            BRK 
020B8: 00            BRK 
020B9: E8            INX 
020BA: 5A            PHY 
020BB: E8            INX 
020BC: 48            PHA 
020BD: CA            DEX 
020BE: 64 58         STZ   $58
020C0: 01 03         ORA   ($03,X)
020C2: 07 0F         RMB0  $0F
020C4: 1F 3F 7F      BBR1  $3F, $2146
020C7: FF 80 C0      BBS7  $80, $208A
020CA: E0 F0         CPX   #$F0
020CC: F8            SED 
020CD: FC            ??? 
020CE: FE FF FF      INC   $FFFF,X
020D1: 7F 3F 1F      BBR7  $3F, $20F3
020D4: 0F 07 03      BBR0  $07, $20DA
020D7: 01 FF         ORA   ($FF,X)
020D9: FE FC F8      INC   $F8FC,X
020DC: F0 E0         BEQ   $20BE
020DE: C0 80         CPY   #$80
020E0: 00            BRK 
020E1: 04 06         TSB   $06
020E3: FF 06 04      BBS7  $06, $20EA
020E6: 00            BRK 
020E7: 00            BRK 
020E8: 00            BRK 
020E9: 20 60 FF      JSR   $FF60
020EC: 60            RTS 
020ED: 20 00 00      JSR   $0000
020F0: 10 38         BPL   $212A
020F2: 7C 10 10      JMP   ($1010,X)
020F5: 10 10         BPL   $2107
020F7: 10 10         BPL   $2109
020F9: 10 10         BPL   $210B
020FB: 10 10         BPL   $210D
020FD: 7C 38 10      JMP   ($1038,X)
02100: 00            BRK 
02101: 00            BRK 
02102: 00            BRK 
02103: 00            BRK 
02104: 00            BRK 
02105: 00            BRK 
02106: 00            BRK 
02107: 00            BRK 
02108: 10 38         BPL   $2142
0210A: 38            SEC 
0210B: 38            SEC 
0210C: 10 10         BPL   $211E
0210E: 00            BRK 
0210F: 10 00         BPL   $2111
02111: 14 14         TRB   $14
02113: 00            BRK 
02114: 00            BRK 
02115: 00            BRK 
02116: 00            BRK 
02117: 00            BRK 
02118: 24 26         BIT   $26
0211A: 3C 66 3C      BIT   $3C66,X
0211D: 64 24         STZ   $24
0211F: 00            BRK 
02120: 10 7C         BPL   $219E
02122: D0 7C         BNE   $21A0
02124: 16 96         ASL   $96,X
02126: 7C 10 00      JMP   ($0010,X)
02129: 42            SAY 
0212A: A4 48         LDY   $48
0212C: 12 25         ORA   ($25)
0212E: 42            SAY 
0212F: 00            BRK 
02130: 30 48         BMI   $217A
02132: 48            PHA 
02133: 39 46 44      AND   $4446,Y
02136: 3B            ??? 
02137: 00            BRK 
02138: 00            BRK 
02139: 02            SXY 
0213A: 06 04         ASL   $04
0213C: 00            BRK 
0213D: 00            BRK 
0213E: 00            BRK 
0213F: 00            BRK 
02140: 04 08         TSB   $08
02142: 10 10         BPL   $2154
02144: 10 08         BPL   $214E
02146: 04 00         TSB   $00
02148: 20 10 08      JSR   $0810
0214B: 08            PHP 
0214C: 08            PHP 
0214D: 10 20         BPL   $216F
0214F: 00            BRK 
02150: 00            BRK 
02151: 00            BRK 
02152: 10 54         BPL   $21A8
02154: 38            SEC 
02155: 54            ??? 
02156: 10 00         BPL   $2158
02158: 00            BRK 
02159: 00            BRK 
0215A: 10 10         BPL   $216C
0215C: 7C 10 10      JMP   ($1010,X)
0215F: 00            BRK 
02160: 00            BRK 
02161: 00            BRK 
02162: 00            BRK 
02163: 00            BRK 
02164: 06 06         ASL   $06
02166: 02            SXY 
02167: 04 00         TSB   $00
02169: 00            BRK 
0216A: 00            BRK 
0216B: 00            BRK 
0216C: 7C 00 00      JMP   ($0000,X)
0216F: 00            BRK 
02170: 00            BRK 
02171: 00            BRK 
02172: 00            BRK 
02173: 00            BRK 
02174: 00            BRK 
02175: 18            CLC 
02176: 18            CLC 
02177: 00            BRK 
02178: 00            BRK 
02179: 02            SXY 
0217A: 04 08         TSB   $08
0217C: 10 20         BPL   $219E
0217E: 40            RTI 
0217F: 00            BRK 
02180: 38            SEC 
02181: 4C C6 C6      JMP   $C6C6
02184: C6 64         DEC   $64
02186: 38            SEC 
02187: 00            BRK 
02188: 18            CLC 
02189: 38            SEC 
0218A: 18            CLC 
0218B: 18            CLC 
0218C: 18            CLC 
0218D: 18            CLC 
0218E: 7E 00 7C      ROR   $7C00,X
02191: C6 0E         DEC   $0E
02193: 3C 78 E0      BIT   $E078,X
02196: FE 00 7E      INC   $7E00,X
02199: 0C 18 3C      TSB   $3C18
0219C: 06 C6         ASL   $C6
0219E: 7C 00 1C      JMP   ($1C00,X)
021A1: 3C 6C CC      BIT   $CC6C,X
021A4: FE 0C 0C      INC   $0C0C,X
021A7: 00            BRK 
021A8: FC            ??? 
021A9: C0 FC         CPY   #$FC
021AB: 06 06         ASL   $06
021AD: C6 7C         DEC   $7C
021AF: 00            BRK 
021B0: 3C 60 C0      BIT   $C060,X
021B3: FC            ??? 
021B4: C6 C6         DEC   $C6
021B6: 7C 00 FE      JMP   ($FE00,X)
021B9: C6 0C         DEC   $0C
021BB: 18            CLC 
021BC: 30 30         BMI   $21EE
021BE: 30 00         BMI   $21C0
021C0: 78            SEI 
021C1: C4 E4         CPY   $E4
021C3: 78            SEI 
021C4: 86 86         STX   $86
021C6: 7C 00 7C      JMP   ($7C00,X)
021C9: C6 C6         DEC   $C6
021CB: 7E 06 0C      ROR   $0C06,X
021CE: 78            SEI 
021CF: 00            BRK 
021D0: 00            BRK 
021D1: 30 30         BMI   $2203
021D3: 00            BRK 
021D4: 30 30         BMI   $2206
021D6: 00            BRK 
021D7: 00            BRK 
021D8: 00            BRK 
021D9: 30 30         BMI   $220B
021DB: 00            BRK 
021DC: 30 30         BMI   $220E
021DE: 10 20         BPL   $2200
021E0: 00            BRK 
021E1: 00            BRK 
021E2: 0C 30 40      TSB   $4030
021E5: 30 0C         BMI   $21F3
021E7: 00            BRK 
021E8: 00            BRK 
021E9: 00            BRK 
021EA: 00            BRK 
021EB: 7C 00 7C      JMP   ($7C00,X)
021EE: 00            BRK 
021EF: 00            BRK 
021F0: 00            BRK 
021F1: 00            BRK 
021F2: 60            RTS 
021F3: 18            CLC 
021F4: 04 18         TSB   $18
021F6: 60            RTS 
021F7: 00            BRK 
021F8: 7C C6 C6      JMP   ($C6C6,X)
021FB: 1C 10 10      TRB   $1010
021FE: 00            BRK 
021FF: 10 7C         BPL   $227D
02201: C6 9A         DEC   $9A
02203: AA            TAX 
02204: B4 C0         LDY   $C0,X
02206: 7C 00 38      JMP   ($3800,X)
02209: 64 C2         STZ   $C2
0220B: C2            CLY 
0220C: FE C2 C2      INC   $C2C2,X
0220F: 00            BRK 
02210: FC            ??? 
02211: C2            CLY 
02212: C2            CLY 
02213: FC            ??? 
02214: C2            CLY 
02215: C2            CLY 
02216: FC            ??? 
02217: 00            BRK 
02218: 3C 62 C0      BIT   $C062,X
0221B: C0 C0         CPY   #$C0
0221D: 62            CLA 
0221E: 3C 00 F8      BIT   $F800,X
02221: C4 C2         CPY   $C2
02223: C2            CLY 
02224: C2            CLY 
02225: C4 F8         CPY   $F8
02227: 00            BRK 
02228: FE C0 C0      INC   $C0C0,X
0222B: FC            ??? 
0222C: C0 C0         CPY   #$C0
0222E: FE 00 FE      INC   $FE00,X
02231: C0 C0         CPY   #$C0
02233: FC            ??? 
02234: C0 C0         CPY   #$C0
02236: C0 00         CPY   #$00
02238: 3E 60 C0      ROL   $C060,X
0223B: CE C2 62      DEC   $62C2
0223E: 3E 00 C2      ROL   $C200,X
02241: C2            CLY 
02242: C2            CLY 
02243: FE C2 C2      INC   $C2C2,X
02246: C2            CLY 
02247: 00            BRK 
02248: 7E 18 18      ROR   $1818,X
0224B: 18            CLC 
0224C: 18            CLC 
0224D: 18            CLC 
0224E: 7E 00 1E      ROR   $1E00,X
02251: 06 06         ASL   $06
02253: 06 86         ASL   $86
02255: 86 7C         STX   $7C
02257: 00            BRK 
02258: C6 C4         DEC   $C4
0225A: C8            INY 
0225B: D0 E8         BNE   $2245
0225D: C4 C2         CPY   $C2
0225F: 00            BRK 
02260: 60            RTS 
02261: 60            RTS 
02262: 60            RTS 
02263: 60            RTS 
02264: 60            RTS 
02265: 60            RTS 
02266: 7E 00 C2      ROR   $C200,X
02269: C6 EA         DEC   $EA
0226B: D2 C2         CMP   ($C2)
0226D: C2            CLY 
0226E: C2            CLY 
0226F: 00            BRK 
02270: C2            CLY 
02271: C2            CLY 
02272: E2            ??? 
02273: D2 CA         CMP   ($CA)
02275: C6 C2         DEC   $C2
02277: 00            BRK 
02278: 7C C2 C2      JMP   ($C2C2,X)
0227B: C2            CLY 
0227C: C2            CLY 
0227D: C2            CLY 
0227E: 7C 00 FC      JMP   ($FC00,X)
02281: C2            CLY 
02282: C2            CLY 
02283: C2            CLY 
02284: FC            ??? 
02285: C0 C0         CPY   #$C0
02287: 00            BRK 
02288: 7C C2 C2      JMP   ($C2C2,X)
0228B: C2            CLY 
0228C: DA            PHX 
0228D: C4 7A         CPY   $7A
0228F: 00            BRK 
02290: FC            ??? 
02291: C2            CLY 
02292: C2            CLY 
02293: C2            CLY 
02294: FC            ??? 
02295: C4 C2         CPY   $C2
02297: 00            BRK 
02298: 7C C2 C0      JMP   ($C0C2,X)
0229B: 7C 02 C2      JMP   ($C202,X)
0229E: 7C 00 7E      JMP   ($7E00,X)
022A1: 18            CLC 
022A2: 18            CLC 
022A3: 18            CLC 
022A4: 18            CLC 
022A5: 18            CLC 
022A6: 18            CLC 
022A7: 00            BRK 
022A8: C2            CLY 
022A9: C2            CLY 
022AA: C2            CLY 
022AB: C2            CLY 
022AC: C2            CLY 
022AD: C2            CLY 
022AE: 7C 00 C2      JMP   ($C200,X)
022B1: C2            CLY 
022B2: C2            CLY 
022B3: E2            ??? 
022B4: 74 38         STZ   $38,X
022B6: 10 00         BPL   $22B8
022B8: C2            CLY 
022B9: C2            CLY 
022BA: C2            CLY 
022BB: D2 EA         CMP   ($EA)
022BD: C6 C2         DEC   $C2
022BF: 00            BRK 
022C0: C2            CLY 
022C1: E6 7C         INC   $7C
022C3: 38            SEC 
022C4: 7C E6 C2      JMP   ($C2E6,X)
022C7: 00            BRK 
022C8: 62            CLA 
022C9: 62            CLA 
022CA: 62            CLA 
022CB: 34 18         BIT   $18,X
022CD: 18            CLC 
022CE: 18            CLC 
022CF: 00            BRK 
022D0: FE 0E 1C      INC   $1C0E,X
022D3: 38            SEC 
022D4: 70 E0         BVS   $22B6
022D6: FE 00 18      INC   $1800,X
022D9: 10 10         BPL   $22EB
022DB: 10 10         BPL   $22ED
022DD: 10 18         BPL   $22F7
022DF: 00            BRK 
022E0: 66 66         ROR   $66
022E2: 24 7E         BIT   $7E
022E4: 18            CLC 
022E5: 7E 18 00      ROR   $0018,X
022E8: 18            CLC 
022E9: 08            PHP 
022EA: 08            PHP 
022EB: 08            PHP 
022EC: 08            PHP 
022ED: 08            PHP 
022EE: 18            CLC 
022EF: 00            BRK 
022F0: 00            BRK 
022F1: 00            BRK 
022F2: 10 28         BPL   $231C
022F4: 28            PLP 
022F5: 44 44         BSR   $233B
022F7: 00            BRK 
022F8: 00            BRK 
022F9: 00            BRK 
022FA: 00            BRK 
022FB: 00            BRK 
022FC: 00            BRK 
022FD: 00            BRK 
022FE: 7E 00 00      ROR   $0000,X
02301: 00            BRK 
02302: 00            BRK 
02303: 00            BRK 
02304: 00            BRK 
02305: 00            BRK 
02306: 00            BRK 
02307: 00            BRK 
02308: 00            BRK 
02309: 00            BRK 
0230A: 38            SEC 
0230B: 04 3C         TSB   $3C
0230D: 64 3A         STZ   $3A
0230F: 00            BRK 
02310: 20 20 20      JSR   $2020
02313: 38            SEC 
02314: 24 24         BIT   $24
02316: 38            SEC 
02317: 00            BRK 
02318: 00            BRK 
02319: 00            BRK 
0231A: 18            CLC 
0231B: 24 20         BIT   $20
0231D: 24 18         BIT   $18
0231F: 00            BRK 
02320: 04 04         TSB   $04
02322: 04 1C         TSB   $1C
02324: 24 24         BIT   $24
02326: 1C 00 00      TRB   $0000
02329: 00            BRK 
0232A: 18            CLC 
0232B: 24 3C         BIT   $3C
0232D: 20 1C 00      JSR   $001C
02330: 18            CLC 
02331: 26 20         ROL   $20
02333: 78            SEI 
02334: 20 20 20      JSR   $2020
02337: 00            BRK 
02338: 00            BRK 
02339: 00            BRK 
0233A: 1A            INC 
0233B: 24 24         BIT   $24
0233D: 1C 04 38      TRB   $3804
02340: 20 20 20      JSR   $2020
02343: 38            SEC 
02344: 24 24         BIT   $24
02346: 24 00         BIT   $00
02348: 00            BRK 
02349: 00            BRK 
0234A: 10 00         BPL   $234C
0234C: 10 10         BPL   $235E
0234E: 10 00         BPL   $2350
02350: 00            BRK 
02351: 00            BRK 
02352: 04 00         TSB   $00
02354: 04 04         TSB   $04
02356: 24 18         BIT   $18
02358: 20 20 20      JSR   $2020
0235B: 24 28         BIT   $28
0235D: 38            SEC 
0235E: 24 00         BIT   $00
02360: 30 10         BMI   $2372
02362: 10 10         BPL   $2374
02364: 10 10         BPL   $2376
02366: 10 00         BPL   $2368
02368: 00            BRK 
02369: 00            BRK 
0236A: 54            ??? 
0236B: 2A            ROL 
0236C: 2A            ROL 
0236D: 2A            ROL 
0236E: 2A            ROL 
0236F: 00            BRK 
02370: 00            BRK 
02371: 00            BRK 
02372: 58            CLI 
02373: 24 24         BIT   $24
02375: 24 24         BIT   $24
02377: 00            BRK 
02378: 00            BRK 
02379: 00            BRK 
0237A: 18            CLC 
0237B: 24 24         BIT   $24
0237D: 24 18         BIT   $18
0237F: 00            BRK 
02380: 00            BRK 
02381: 00            BRK 
02382: 38            SEC 
02383: 24 24         BIT   $24
02385: 38            SEC 
02386: 20 20 00      JSR   $0020
02389: 00            BRK 
0238A: 1C 24 24      TRB   $2424
0238D: 1C 04 04      TRB   $0404
02390: 00            BRK 
02391: 00            BRK 
02392: 20 2C 30      JSR   $302C
02395: 20 20 00      JSR   $0020
02398: 00            BRK 
02399: 00            BRK 
0239A: 1C 20 3C      TRB   $3C20
0239D: 04 38         TSB   $38
0239F: 00            BRK 
023A0: 00            BRK 
023A1: 20 20 78      JSR   $7820
023A4: 20 24 18      JSR   $1824
023A7: 00            BRK 
023A8: 00            BRK 
023A9: 00            BRK 
023AA: 24 24         BIT   $24
023AC: 24 24         BIT   $24
023AE: 18            CLC 
023AF: 00            BRK 
023B0: 00            BRK 
023B1: 00            BRK 
023B2: 24 24         BIT   $24
023B4: 28            PLP 
023B5: 30 20         BMI   $23D7
023B7: 00            BRK 
023B8: 00            BRK 
023B9: 00            BRK 
023BA: 44 54         BSR   $2410
023BC: 54            ??? 
023BD: 54            ??? 
023BE: 28            PLP 
023BF: 00            BRK 
023C0: 00            BRK 
023C1: 00            BRK 
023C2: 24 18         BIT   $18
023C4: 18            CLC 
023C5: 18            CLC 
023C6: 24 00         BIT   $00
023C8: 00            BRK 
023C9: 00            BRK 
023CA: 24 24         BIT   $24
023CC: 24 1C         BIT   $1C
023CE: 04 18         TSB   $18
023D0: 00            BRK 
023D1: 00            BRK 
023D2: 7C 0C 18      JMP   ($180C,X)
023D5: 30 7C         BMI   $2453
023D7: 00            BRK 
023D8: 08            PHP 
023D9: 10 10         BPL   $23EB
023DB: 20 10 10      JSR   $1010
023DE: 08            PHP 
023DF: 00            BRK 
023E0: 08            PHP 
023E1: 08            PHP 
023E2: 00            BRK 
023E3: 00            BRK 
023E4: 00            BRK 
023E5: 08            PHP 
023E6: 08            PHP 
023E7: 00            BRK 
023E8: 10 08         BPL   $23F2
023EA: 08            PHP 
023EB: 04 08         TSB   $08
023ED: 08            PHP 
023EE: 10 00         BPL   $23F0
023F0: 00            BRK 
023F1: 00            BRK 
023F2: 00            BRK 
023F3: 32 4C         AND   ($4C)
023F5: 00            BRK 
023F6: 00            BRK 
023F7: 00            BRK 
023F8: 81 42         STA   ($42,X)
023FA: 24 18         BIT   $18
023FC: 18            CLC 
023FD: 24 42         BIT   $42
023FF: 81 00         STA   ($00,X)
02401: 00            BRK 
02402: 00            BRK 
02403: 00            BRK 
02404: 00            BRK 
02405: 00            BRK 
02406: 00            BRK 
02407: 00            BRK 
02408: 00            BRK 
02409: 00            BRK 
0240A: 00            BRK 
0240B: 00            BRK 
0240C: 00            BRK 
0240D: 20 50 20      JSR   $2050
02410: 3E 20 20      ROL   $2020,X
02413: 20 20 00      JSR   $0020
02416: 00            BRK 
02417: 00            BRK 
02418: 00            BRK 
02419: 00            BRK 
0241A: 00            BRK 
0241B: 08            PHP 
0241C: 08            PHP 
0241D: 08            PHP 
0241E: 08            PHP 
0241F: F8            SED 
02420: 00            BRK 
02421: 00            BRK 
02422: 00            BRK 
02423: 00            BRK 
02424: 0C 06 06      TSB   $0606
02427: 00            BRK 
02428: 00            BRK 
02429: 00            BRK 
0242A: 00            BRK 
0242B: 18            CLC 
0242C: 18            CLC 
0242D: 00            BRK 
0242E: 00            BRK 
0242F: 00            BRK 
02430: 08            PHP 
02431: 7C 10 32      JMP   ($3210,X)
02434: 4C 14 20      JMP   $2014
02437: 3C 00 00      BIT   $0000,X
0243A: 20 F8 20      JSR   $20F8
0243D: 78            SEI 
0243E: AC 54 00      LDY   $0054
02441: 00            BRK 
02442: 00            BRK 
02443: 00            BRK 
02444: 44 42         BSR   $2488
02446: 22            SAX 
02447: 00            BRK 
02448: 00            BRK 
02449: 00            BRK 
0244A: 18            CLC 
0244B: 00            BRK 
0244C: 3C 04 04      BIT   $0404,X
0244F: 18            CLC 
02450: 00            BRK 
02451: 00            BRK 
02452: 18            CLC 
02453: 00            BRK 
02454: 3C 08 18      BIT   $1808,X
02457: 26 00         ROL   $00
02459: 00            BRK 
0245A: 20 F8 22      JSR   $22F8
0245D: 78            SEI 
0245E: A4 68         LDY   $68
02460: 00            BRK 
02461: 00            BRK 
02462: 08            PHP 
02463: 2C 12 32      BIT   $3212
02466: 48            PHA 
02467: 04 00         TSB   $00
02469: 00            BRK 
0246A: 10 58         BPL   $24C4
0246C: 74 54         STZ   $54,X
0246E: 18            CLC 
0246F: 20 00 00      JSR   $0000
02472: 10 10         BPL   $2484
02474: 1C 30 58      TRB   $5830
02477: 34 00         BIT   $00,X
02479: 00            BRK 
0247A: 00            BRK 
0247B: 00            BRK 
0247C: 18            CLC 
0247D: 64 04         STZ   $04
0247F: 08            PHP 
02480: 00            BRK 
02481: 00            BRK 
02482: 00            BRK 
02483: 00            BRK 
02484: 7E 00 00      ROR   $0000,X
02487: 00            BRK 
02488: 20 F8 20      JSR   $20F8
0248B: 3C 66 AA      BIT   $AA66,X
0248E: B2 54         LDA   ($54)
02490: 80 84         BRA   $2416
02492: 82            CLX 
02493: 82            CLX 
02494: 82            CLX 
02495: 82            CLX 
02496: D0 60         BNE   $24F8
02498: 38            SEC 
02499: 00            BRK 
0249A: 3C 42 02      BIT   $0242,X
0249D: 02            SXY 
0249E: 04 18         TSB   $18
024A0: 38            SEC 
024A1: 00            BRK 
024A2: 7C 08 10      JMP   ($1008,X)
024A5: 30 48         BMI   $24EF
024A7: 8E 22 F2      STX   $F222
024AA: 20 3C 62      JSR   $623C
024AD: A2 A2         LDX   #$A2
024AF: 64 20         STZ   $20
024B1: 24 F2         BIT   $F2
024B3: 2A            ROL 
024B4: 2A            ROL 
024B5: 48            PHA 
024B6: 68            PLA 
024B7: 90 20         BCC   $24D9
024B9: FC            ??? 
024BA: 10 FE         BPL   $24BA
024BC: 08            PHP 
024BD: 04 40         TSB   $40
024BF: 38            SEC 
024C0: 08            PHP 
024C1: 08            PHP 
024C2: 10 60         BPL   $2524
024C4: 20 10 08      JSR   $0810
024C7: 0C 04 84      TSB   $8404
024CA: 9E 84 84      STZ   $8484,X
024CD: 84 84         STY   $84
024CF: 08            PHP 
024D0: 78            SEI 
024D1: 04 00         TSB   $00
024D3: 00            BRK 
024D4: 00            BRK 
024D5: 40            RTI 
024D6: C0 7C         CPY   #$7C
024D8: 20 10 FE      JSR   $FE10
024DB: 08            PHP 
024DC: 04 40         TSB   $40
024DE: 40            RTI 
024DF: 3C 40 40      BIT   $4040,X
024E2: 40            RTI 
024E3: 40            RTI 
024E4: 40            RTI 
024E5: 44 44         BSR   $252B
024E7: 38            SEC 
024E8: 18            CLC 
024E9: FE 08 38      INC   $3808,X
024EC: 28            PLP 
024ED: 38            SEC 
024EE: 08            PHP 
024EF: 10 44         BPL   $2535
024F1: 44 FE         BSR   $24F1
024F3: 44 48         BSR   $253D
024F5: 40            RTI 
024F6: 40            RTI 
024F7: 3C 5C 10      BIT   $105C,X
024FA: 20 FE 10      JSR   $10FE
024FD: 20 20 1C      JSR   $1C20
02500: 00            BRK 
02501: 00            BRK 
02502: 00            BRK 
02503: 00            BRK 
02504: 00            BRK 
02505: 00            BRK 
02506: 00            BRK 
02507: 00            BRK 
02508: 00            BRK 
02509: 00            BRK 
0250A: 00            BRK 
0250B: 00            BRK 
0250C: 00            BRK 
0250D: 20 50 20      JSR   $2050
02510: 3E 20 20      ROL   $2020,X
02513: 20 20 00      JSR   $0020
02516: 00            BRK 
02517: 00            BRK 
02518: 00            BRK 
02519: 00            BRK 
0251A: 00            BRK 
0251B: 08            PHP 
0251C: 08            PHP 
0251D: 08            PHP 
0251E: 08            PHP 
0251F: F8            SED 
02520: 00            BRK 
02521: 00            BRK 
02522: 00            BRK 
02523: 00            BRK 
02524: 0C 06 06      TSB   $0606
02527: 00            BRK 
02528: 00            BRK 
02529: 00            BRK 
0252A: 00            BRK 
0252B: 18            CLC 
0252C: 18            CLC 
0252D: 00            BRK 
0252E: 00            BRK 
0252F: 00            BRK 
02530: FE 02 02      INC   $0202,X
02533: FE 02 06      INC   $0602,X
02536: 0C F8 00      TSB   $00F8
02539: 00            BRK 
0253A: 00            BRK 
0253B: 00            BRK 
0253C: F0 10         BEQ   $254E
0253E: 60            RTS 
0253F: 40            RTI 
02540: 00            BRK 
02541: 00            BRK 
02542: 00            BRK 
02543: 00            BRK 
02544: 30 60         BMI   $25A6
02546: A0 20         LDY   #$20
02548: 00            BRK 
02549: 00            BRK 
0254A: 00            BRK 
0254B: 00            BRK 
0254C: 20 F8 88      JSR   $88F8
0254F: 30 00         BMI   $2551
02551: 00            BRK 
02552: 00            BRK 
02553: 00            BRK 
02554: 70 20         BVS   $2576
02556: 20 F8 00      JSR   $00F8
02559: 00            BRK 
0255A: 00            BRK 
0255B: 08            PHP 
0255C: 7C 18 28      JMP   ($2818,X)
0255F: 48            PHA 
02560: 00            BRK 
02561: 00            BRK 
02562: 00            BRK 
02563: 20 7C 24      JSR   $247C
02566: 28            PLP 
02567: 20 00 00      JSR   $0000
0256A: 00            BRK 
0256B: 00            BRK 
0256C: 70 10         BVS   $257E
0256E: 10 FC         BPL   $256C
02570: 00            BRK 
02571: 00            BRK 
02572: 00            BRK 
02573: 78            SEI 
02574: 08            PHP 
02575: 78            SEI 
02576: 08            PHP 
02577: 78            SEI 
02578: 00            BRK 
02579: 00            BRK 
0257A: 00            BRK 
0257B: 54            ??? 
0257C: 54            ??? 
0257D: 04 08         TSB   $08
0257F: 30 00         BMI   $2581
02581: 00            BRK 
02582: 00            BRK 
02583: 00            BRK 
02584: 7E 00 00      ROR   $0000,X
02587: 00            BRK 
02588: FE 02 12      INC   $1202,X
0258B: 14 10         TRB   $10
0258D: 10 20         BPL   $25AF
0258F: 40            RTI 
02590: 02            SXY 
02591: 04 08         TSB   $08
02593: 38            SEC 
02594: C8            INY 
02595: 08            PHP 
02596: 08            PHP 
02597: 08            PHP 
02598: 10 10         BPL   $25AA
0259A: FE 82 82      INC   $8282,X
0259D: 02            SXY 
0259E: 04 38         TSB   $38
025A0: 7C 10 10      JMP   ($1010,X)
025A3: 10 10         BPL   $25B5
025A5: 10 10         BPL   $25B7
025A7: FE 08 FE      INC   $FE08,X
025AA: 08            PHP 
025AB: 18            CLC 
025AC: 28            PLP 
025AD: 48            PHA 
025AE: 88            DEY 
025AF: 18            CLC 
025B0: 10 FE         BPL   $25B0
025B2: 12 12         ORA   ($12)
025B4: 22            SAX 
025B5: 22            SAX 
025B6: 42            SAY 
025B7: 0C 08 FE      TSB   $FE08
025BA: 18            CLC 
025BB: FE 08 08      INC   $0808,X
025BE: 08            PHP 
025BF: 08            PHP 
025C0: 3E 22 42      ROL   $4222,X
025C3: 82            CLX 
025C4: 04 04         TSB   $04
025C6: 08            PHP 
025C7: F0 40         BEQ   $2609
025C9: 7E 48 48      ROR   $4848,X
025CC: 88            DEY 
025CD: 08            PHP 
025CE: 10 60         BPL   $2630
025D0: 00            BRK 
025D1: FE 02 02      INC   $0202,X
025D4: 02            SXY 
025D5: 02            SXY 
025D6: 02            SXY 
025D7: FE 44 44      INC   $4444,X
025DA: FE 44 44      INC   $4444,X
025DD: 04 04         TSB   $04
025DF: 78            SEI 
025E0: 40            RTI 
025E1: 22            SAX 
025E2: 82            CLX 
025E3: 42            SAY 
025E4: 04 04         TSB   $04
025E6: 88            DEY 
025E7: 70 FE         BVS   $25E7
025E9: 02            SXY 
025EA: 04 08         TSB   $08
025EC: 10 28         BPL   $2616
025EE: 44 82         BSR   $2572
025F0: 40            RTI 
025F1: FE 46 48      INC   $4846,X
025F4: 40            RTI 
025F5: 40            RTI 
025F6: 40            RTI 
025F7: 3E 02 C2      ROL   $C202,X
025FA: 42            SAY 
025FB: 04 04         TSB   $04
025FD: 08            PHP 
025FE: 10 20         BPL   $2620
02600: 3E 22 62      ROL   $6222,X
02603: 92 0C         STA   ($0C)
02605: 04 08         TSB   $08
02607: F0 1C         BEQ   $2625
02609: 70 10         BVS   $261B
0260B: FE 08 08      INC   $0808,X
0260E: 10 60         BPL   $2670
02610: 02            SXY 
02611: 92 92         STA   ($92)
02613: 02            SXY 
02614: 04 04         TSB   $04
02616: 08            PHP 
02617: 70 7C         BVS   $2695
02619: 00            BRK 
0261A: FE 10 10      INC   $1010,X
0261D: 10 30         BPL   $264F
0261F: E0 40         CPX   #$40
02621: 40            RTI 
02622: 40            RTI 
02623: 70 48         BVS   $266D
02625: 44 40         BSR   $2667
02627: 40            RTI 
02628: 08            PHP 
02629: 08            PHP 
0262A: FE 08 08      INC   $0808,X
0262D: 08            PHP 
0262E: 10 E0         BPL   $2610
02630: 00            BRK 
02631: 7C 00 00      JMP   ($0000,X)
02634: 00            BRK 
02635: 00            BRK 
02636: 00            BRK 
02637: FE 7E 02      INC   $027E,X
0263A: 04 04         TSB   $04
0263C: 28            PLP 
0263D: 10 28         BPL   $2667
0263F: C4 10         CPY   $10
02641: 7E 04 18      ROR   $1804,X
02644: 74 92         STZ   $92,X
02646: 10 10         BPL   $2658
02648: 04 04         TSB   $04
0264A: 04 04         TSB   $04
0264C: 08            PHP 
0264D: 08            PHP 
0264E: 10 E0         BPL   $2630
02650: 20 28 44      JSR   $4428
02653: 44 82         BSR   $25D7
02655: 82            CLX 
02656: 82            CLX 
02657: 82            CLX 
02658: 40            RTI 
02659: 40            RTI 
0265A: 4E 78 40      LSR   $4078
0265D: 40            RTI 
0265E: 40            RTI 
0265F: 3E FE 02      ROL   $02FE,X
02662: 02            SXY 
02663: 02            SXY 
02664: 04 04         TSB   $04
02666: 08            PHP 
02667: 70 00         BVS   $2669
02669: 00            BRK 
0266A: 20 50 88      JSR   $8850
0266D: 04 02         TSB   $02
0266F: 00            BRK 
02670: 10 10         BPL   $2682
02672: FE 10 54      INC   $5410,X
02675: 92 92         STA   ($92)
02677: 10 FE         BPL   $2677
02679: 02            SXY 
0267A: 04 08         TSB   $08
0267C: 50 20         BVC   $269E
0267E: 10 08         BPL   $2688
02680: 70 1C         BVS   $269E
02682: 00            BRK 
02683: 70 1C         BVS   $26A1
02685: 00            BRK 
02686: 70 1C         BVS   $26A4
02688: 08            PHP 
02689: 10 10         BPL   $269B
0268B: 20 44 C4      JSR   $C444
0268E: FE 02 02      INC   $0202,X
02691: 22            SAX 
02692: 14 08         TRB   $08
02694: 0C 12 20      TSB   $2012
02697: C0 7C         CPY   #$7C
02699: 20 20 FE      JSR   $FE20
0269C: 20 20 20      JSR   $2020
0269F: 1E C0 5E      ASL   $5EC0,X
026A2: E2            ??? 
026A3: 24 10         BIT   $10
026A5: 10 08         BPL   $26AF
026A7: 08            PHP 
026A8: 00            BRK 
026A9: 78            SEI 
026AA: 08            PHP 
026AB: 08            PHP 
026AC: 08            PHP 
026AD: 08            PHP 
026AE: 08            PHP 
026AF: FE 00 FC      INC   $FC00,X
026B2: 04 04         TSB   $04
026B4: FC            ??? 
026B5: 04 04         TSB   $04
026B7: FC            ??? 
026B8: 7C 00 FE      JMP   ($FE00,X)
026BB: 02            SXY 
026BC: 02            SXY 
026BD: 04 04         TSB   $04
026BF: 78            SEI 
026C0: 44 44         BSR   $2706
026C2: 44 44         BSR   $2708
026C4: 04 04         TSB   $04
026C6: 08            PHP 
026C7: 10 48         BPL   $2711
026C9: 28            PLP 
026CA: 28            PLP 
026CB: 28            PLP 
026CC: 28            PLP 
026CD: 4A            LSR 
026CE: 4A            LSR 
026CF: 8C 40 40      STY   $4040
026D2: 40            RTI 
026D3: 40            RTI 
026D4: 42            SAY 
026D5: 44 48         BSR   $271F
026D7: 70 00         BVS   $26D9
026D9: FC            ??? 
026DA: 82            CLX 
026DB: 82            CLX 
026DC: 82            CLX 
026DD: 82            CLX 
026DE: 82            CLX 
026DF: FE FE 82      INC   $82FE,X
026E2: 82            CLX 
026E3: 02            SXY 
026E4: 02            SXY 
026E5: 04 04         TSB   $04
026E7: 78            SEI 
026E8: 00            BRK 
026E9: 40            RTI 
026EA: 22            SAX 
026EB: 02            SXY 
026EC: 02            SXY 
026ED: 02            SXY 
026EE: C4 78         CPY   $78
026F0: 02            SXY 
026F1: 09 04         ORA   #$04
026F3: 00            BRK 
026F4: 00            BRK 
026F5: 00            BRK 
026F6: 00            BRK 
026F7: 00            BRK 
026F8: 04 0A         TSB   $0A
026FA: 04 00         TSB   $00
026FC: 00            BRK 
026FD: 00            BRK 
026FE: 00            BRK 
026FF: 00            BRK 
02700: 20 FC 20      JSR   $20FC
02703: 26 40         ROL   $40
02705: 40            RTI 
02706: 88            DEY 
02707: 86 20         STX   $20
02709: FE 20 7C      INC   $7C20,X
0270C: 42            SAY 
0270D: 02            SXY 
0270E: 42            SAY 
0270F: 3C 00 3C      BIT   $3C00,X
02712: C2            CLY 
02713: 02            SXY 
02714: 02            SXY 
02715: 04 18         TSB   $18
02717: 00            BRK 
02718: FE 18 20      INC   $2018,X
0271B: 40            RTI 
0271C: 40            RTI 
0271D: 40            RTI 
0271E: 20 1C 20      JSR   $201C
02721: 20 2C 30      JSR   $302C
02724: 40            RTI 
02725: 80 80         BRA   $26A7
02727: 7E 20 F4      ROR   $F420,X
0272A: 46 88         LSR   $88
0272C: 08            PHP 
0272D: 38            SEC 
0272E: 4C 30 00      JMP   $0030
02731: 9C 82 80      STZ   $8082
02734: 80 80         BRA   $26B6
02736: 90 8E         BCC   $26C6
02738: 00            BRK 
02739: 48            PHA 
0273A: 5C            ??? 
0273B: 7A            PLY 
0273C: 52 AE         EOR   ($AE)
0273E: AA            TAX 
0273F: 4C 20 20      JMP   $2020
02742: EC 32 22      CPX   $2232
02745: 66 AA         ROR   $AA
02747: 2E 00 38      ROL   $3800
0274A: 54            ??? 
0274B: 92 92         STA   ($92)
0274D: A2 A4         LDX   #$A4
0274F: 48            PHA 
02750: 04 9E         TSB   $9E
02752: 84 84         STY   $84
02754: 84 9C         STY   $9C
02756: 96 8C         STX   $8C,Y
02758: 64 A4         STZ   $A4
0275A: 44 86         BSR   $26E2
0275C: 8A            TXA 
0275D: 88            DEY 
0275E: 90 60         BCC   $27C0
02760: 10 08         BPL   $276A
02762: 00            BRK 
02763: 10 48         BPL   $27AD
02765: 8A            TXA 
02766: AA            TAX 
02767: 10 00         BPL   $2769
02769: 00            BRK 
0276A: 20 50 88      JSR   $8850
0276D: 06 00         ASL   $00
0276F: 00            BRK 
02770: 1E 84 9E      ASL   $9E84,X
02773: 84 84         STY   $84
02775: 9C A6 98      STZ   $98A6
02778: 10 FC         BPL   $2776
0277A: 10 FC         BPL   $2778
0277C: 10 F0         BPL   $276E
0277E: 98            TYA 
0277F: 74 78         STZ   $78,X
02781: 08            PHP 
02782: 0A            ASL 
02783: 12 7E         ORA   ($7E)
02785: 92 A4         STA   ($A4)
02787: 48            PHA 
02788: 20 F4 22      JSR   $22F4
0278B: 62            CLA 
0278C: A0 A0         LDY   #$A0
0278E: 64 3C         STZ   $3C
02790: 08            PHP 
02791: 48            PHA 
02792: 5C            ??? 
02793: 6A            ROR 
02794: 52 A2         EOR   ($A2)
02796: A4 48         LDY   $48
02798: 10 78         BPL   $2812
0279A: 20 F8 40      JSR   $40F8
0279D: 42            SAY 
0279E: 42            SAY 
0279F: 3C 90 4C      BIT   $4C90,X
027A2: 52 62         EOR   ($62)
027A4: A4 10         LDY   $10
027A6: 10 08         BPL   $27B0
027A8: 08            PHP 
027A9: BC CA 8A      LDY   $8ACA,X
027AC: AA            TAX 
027AD: 9C 08 10      STZ   $1008
027B0: 10 10         BPL   $27C2
027B2: 1C 10 10      TRB   $1010
027B5: 70 D8         BVS   $278F
027B7: 74 10         STZ   $10,X
027B9: 48            PHA 
027BA: 40            RTI 
027BB: 5C            ??? 
027BC: 62            CLA 
027BD: 02            SXY 
027BE: 04 38         TSB   $38
027C0: 4C 44 44      JMP   $4444
027C3: 44 24         BSR   $27E9
027C5: 04 08         TSB   $08
027C7: 10 3C         BPL   $2805
027C9: 08            PHP 
027CA: 10 3C         BPL   $2808
027CC: 42            SAY 
027CD: 12 2A         ORA   ($2A)
027CF: 3C 20 2C      BIT   $2C20,X
027D2: F2 22         SBC   ($22)
027D4: 24 64         BIT   $64
027D6: A4 22         LDY   $22
027D8: 3C 08 10      BIT   $1008,X
027DB: 3C 42 02      BIT   $0242,X
027DE: 06 1C         ASL   $1C
027E0: 20 20 EC      JSR   $EC20
027E3: 32 22         AND   ($22)
027E5: 62            CLA 
027E6: A2 24         LDX   #$24
027E8: 10 10         BPL   $27FA
027EA: 20 20 70      JSR   $7020
027ED: 50 92         BVC   $2781
027EF: 8C 02 09      STY   $0902
027F2: 04 00         TSB   $00
027F4: 00            BRK 
027F5: 00            BRK 
027F6: 00            BRK 
027F7: 00            BRK 
027F8: 7C C6 92      JMP   ($92C6,X)
027FB: BE 92 C6      LDX   $C692,Y
027FE: 7C 00 00      JMP   ($0000,X)
02801: 00            BRK 
02802: D8            CLD 
02803: 00            BRK 
02804: 20 01 68      JSR   $6801
02807: 01 B0         ORA   ($B0,X)
02809: 01 F8         ORA   ($F8,X)
0280B: 01 90         ORA   ($90,X)
0280D: 00            BRK 
0280E: 48            PHA 
0280F: 00            BRK 
02810: 6D 01 92      ADC   $9201
02813: 00            BRK 
02814: 83 00 C4      TST   $00, $C4
02817: 00            BRK 
02818: C5 00         CMP   $00
0281A: 06 01         ASL   $01
0281C: 07 01         RMB0  $01
0281E: FF 01 00      BBS7  $01, $2821
02821: 00            BRK 
02822: 38            SEC 
02823: 00            BRK 
02824: 48            PHA 
02825: 00            BRK 
02826: F8            SED 
02827: 01 90         ORA   ($90,X)
02829: 00            BRK 
0282A: D8            CLD 
0282B: 00            BRK 
0282C: C3 01 C7 01 07 01 48  TDD   $C701, $0701, $4801
02833: 00            BRK 
02834: 1F 00 A9      BBR1  $00, $27E0
02837: 00            BRK 
02838: F9 00 92      SBC   $9200,Y
0283B: 00            BRK 
0283C: 24 01         BIT   $01
0283E: FF 01 00      BBS7  $01, $2841
02841: 00            BRK 
02842: 38            SEC 
02843: 00            BRK 
02844: F8            SED 
02845: 00            BRK 
02846: F8            SED 
02847: 01 D8         ORA   ($D8,X)
02849: 01 C0         ORA   ($C0,X)
0284B: 01 C3         ORA   ($C3,X)
0284D: 01 C7         ORA   ($C7,X)
0284F: 01 F0         ORA   ($F0,X)
02851: 00            BRK 
02852: 48            PHA 
02853: 00            BRK 
02854: 1F 00 3F      BBR1  $00, $2896
02857: 00            BRK 
02858: 3B            ??? 
02859: 00            BRK 
0285A: 92 00         STA   ($00)
0285C: 24 01         BIT   $01
0285E: FF 01 A9      BBS7  $01, $280A
02861: 7B            ??? 
02862: 85 F8         STA   $F8
02864: A9 C9         LDA   #$C9
02866: 85 F9         STA   $F9
02868: 20 50 C9      JSR   $C950
0286B: 20 92 FE      JSR   $FE92
0286E: B0 1C         BCS   $288C
02870: 8A            TXA 
02871: 89 80         BIT   #$80
02873: F0 0A         BEQ   $287F
02875: A9 AA         LDA   #$AA
02877: 8D C0 18      STA   $18C0
0287A: A9 55         LDA   #$55
0287C: 8D C0 18      STA   $18C0
0287F: A9 0C         LDA   #$0C
02881: 85 F8         STA   $F8
02883: A9 CA         LDA   #$CA
02885: 85 F9         STA   $F9
02887: 20 50 C9      JSR   $C950
0288A: 80 0B         BRA   $2897
0288C: A9 56         LDA   #$56
0288E: 85 F8         STA   $F8
02890: A9 CA         LDA   #$CA
02892: 85 F9         STA   $F9
02894: 20 50 C9      JSR   $C950
02897: AD 41 22      LDA   $2241
0289A: 29 3F         AND   #$3F
0289C: C9 20         CMP   #$20
0289E: B0 0D         BCS   $28AD
028A0: A9 84         LDA   #$84
028A2: 85 F8         STA   $F8
028A4: A9 CA         LDA   #$CA
028A6: 85 F9         STA   $F9
028A8: 20 50 C9      JSR   $C950
028AB: 80 17         BRA   $28C4
028AD: A2 08         LDX   #$08
028AF: A0 12         LDY   #$12
028B1: 20 22 C9      JSR   $C922
028B4: A9 03         LDA   #$03
028B6: 85 FF         STA   $FF
028B8: C2            CLY 
028B9: A9 9C         LDA   #$9C
028BB: 85 F8         STA   $F8
028BD: A9 CA         LDA   #$CA
028BF: 85 F9         STA   $F9
028C1: 20 6A C9      JSR   $C96A
028C4: AD 2D 22      LDA   $222D
028C7: C9 08         CMP   #$08
028C9: F0 07         BEQ   $28D2
028CB: C9 04         CMP   #$04
028CD: D0 C8         BNE   $2897
028CF: A9 01         LDA   #$01
028D1: 60            RTS 
028D2: A9 99         LDA   #$99
028D4: 85 F8         STA   $F8
028D6: A9 CA         LDA   #$CA
028D8: 85 F9         STA   $F9
028DA: 44 74         BSR   $2950
028DC: A9 B1         LDA   #$B1
028DE: 85 F8         STA   $F8
028E0: A9 CA         LDA   #$CA
028E2: 85 F9         STA   $F9
028E4: 44 6A         BSR   $2950
028E6: 20 91 F0      JSR   $F091
028E9: B0 02         BCS   $28ED
028EB: 62            CLA 
028EC: 60            RTS 
028ED: C9 04         CMP   #$04
028EF: F0 25         BEQ   $2916
028F1: C9 0B         CMP   #$0B
028F3: D0 10         BNE   $2905
028F5: A9 C6         LDA   #$C6
028F7: 85 F8         STA   $F8
028F9: A9 CA         LDA   #$CA
028FB: 85 F9         STA   $F9
028FD: 44 51         BSR   $2950
028FF: 20 54 CB      JSR   $CB54
02902: 4C 60 C8      JMP   $C860
02905: C9 0D         CMP   #$0D
02907: D0 0D         BNE   $2916
02909: A9 DB         LDA   #$DB
0290B: 85 F8         STA   $F8
0290D: A9 CA         LDA   #$CA
0290F: 85 F9         STA   $F9
02911: 44 3D         BSR   $2950
02913: 4C 60 C8      JMP   $C860
02916: A2 46         LDX   #$46
02918: DA            PHX 
02919: 20 B5 E3      JSR   $E3B5
0291C: FA            PLX 
0291D: CA            DEX 
0291E: D0 F8         BNE   $2918
02920: 80 C4         BRA   $28E6
02922: 64 EC         STZ   $EC
02924: 84 ED         STY   $ED
02926: 46 ED         LSR   $ED
02928: 66 EC         ROR   $EC
0292A: 46 ED         LSR   $ED
0292C: 66 EC         ROR   $EC
0292E: 46 ED         LSR   $ED
02930: 66 EC         ROR   $EC
02932: 8A            TXA 
02933: 29 3F         AND   #$3F
02935: 04 EC         TSB   $EC
02937: A9 00         LDA   #$00
02939: 85 F7         STA   $F7
0293B: 8D 00 00      STA   $0000
0293E: A5 EC         LDA   $EC
02940: 8D 02 00      STA   $0002
02943: A5 ED         LDA   $ED
02945: 8D 03 00      STA   $0003
02948: A9 02         LDA   #$02
0294A: 85 F7         STA   $F7
0294C: 8D 00 00      STA   $0000
0294F: 60            RTS 
02950: C2            CLY 
02951: B1 F8         LDA   ($F8),Y
02953: C9 FF         CMP   #$FF
02955: D0 01         BNE   $2958
02957: 60            RTS 
02958: 18            CLC 
02959: 69 03         ADC   #$03
0295B: 85 FF         STA   $FF
0295D: C8            INY 
0295E: B1 F8         LDA   ($F8),Y
02960: AA            TAX 
02961: C8            INY 
02962: B1 F8         LDA   ($F8),Y
02964: 5A            PHY 
02965: A8            TAY 
02966: 44 BA         BSR   $2922
02968: 7A            PLY 
02969: C8            INY 
0296A: B1 F8         LDA   ($F8),Y
0296C: C8            INY 
0296D: C9 FF         CMP   #$FF
0296F: F0 E0         BEQ   $2951
02971: 8D 02 00      STA   $0002
02974: A5 FF         LDA   $FF
02976: 8D 03 00      STA   $0003
02979: 80 EF         BRA   $296A
0297B: 00            BRK 
0297C: 01 0B         ORA   ($0B,X)
0297E: 01 02         ORA   ($02,X)
02980: 03 04         ST0   #$04
02982: 05 06         ORA   $06
02984: 07 08         RMB0  $08
02986: 09 0A         ORA   #$0A
02988: 0B            ??? 
02989: 0C 0D 0E      TSB   $0E0D
0298C: 0F 60 61      BBR0  $60, $29F0
0298F: 62            CLA 
02990: 63            ??? 
02991: 64 65         STZ   $65
02993: 66 67         ROR   $67
02995: 68            PLA 
02996: 69 6A         ADC   #$6A
02998: 6B            ??? 
02999: 6C 6D FF      JMP   ($FF6D)
0299C: 00            BRK 
0299D: 0F 0A 9A      BBR0  $0A, $293A
029A0: FF 00 01      BBS7  $00, $29A4
029A3: 0C 11 12      TSB   $1211
029A6: 13 14         ST1   #$14
029A8: 15 16         ORA   $16,X
029AA: 17 18         RMB1  $18
029AC: 19 1A 1B      ORA   $1B1A,Y
029AF: 1C 1D 1E      TRB   $1E1D
029B2: 1F 70 71      BBR1  $70, $2A26
029B5: 72 73         ADC   ($73)
029B7: 74 75         STZ   $75,X
029B9: 76 77         ROR   $77,X
029BB: 78            SEI 
029BC: 79 7A 7B      ADC   $7B7A,Y
029BF: 7C 7D FF      JMP   ($FF7D,X)
029C2: 10 1E         BPL   $29E2
029C4: 0B            ??? 
029C5: 0E 0F FF      ASL   $FF0F
029C8: 10 1E         BPL   $29E8
029CA: 0C 1E 1F      TSB   $1F1E
029CD: FF 00 15      BBS7  $00, $29E5
029D0: 0E 56 45      ASL   $4556
029D3: 52 2E         EOR   ($2E)
029D5: 20 33 2E      JSR   $2E33
029D8: 30 30         BMI   $2A0A
029DA: FF 00 06      BBS7  $00, $29E3
029DD: 17 40         RMB1  $40
029DF: 20 22 23      JSR   $2322
029E2: 24 25         BIT   $25
029E4: 26 27         ROL   $27
029E6: 28            PLP 
029E7: 29 2A         AND   #$2A
029E9: 2B            ??? 
029EA: 2C 2D 3D      BIT   $3D2D
029ED: 2F 00 20      BBR2  $00, $2A10
029F0: 3A            DEC 
029F1: 3B            ??? 
029F2: FF 00 06      BBS7  $00, $29FB
029F5: 19 40 20      ORA   $2040,Y
029F8: 5B            ??? 
029F9: 5C            ??? 
029FA: 5D 5E 5F      EOR   $5F5E,X
029FD: 3C 3E 3F      BIT   $3F3E,X
02A00: 20 20 20      JSR   $2020
02A03: 20 20 20      JSR   $2020
02A06: 20 20 3A      JSR   $3A20
02A09: 3B            ??? 
02A0A: FF FF 00      BBS7  $FF, $2A0D
02A0D: 08            PHP 
02A0E: 03 80         ST0   #$80
02A10: 81 82         STA   ($82,X)
02A12: 83 84 85      TST   $84, $85
02A15: 86 87         STX   $87
02A17: 88            DEY 
02A18: 89 88         BIT   #$88
02A1A: 8A            TXA 
02A1B: 8C 8B 8C      STY   $8C8B
02A1E: FF 00 08      BBS7  $00, $2A29
02A21: 04 8E         TSB   $8E
02A23: 8F 90 91      BBS0  $90, $29B7
02A26: 92 93         STA   ($93)
02A28: 94 95         STY   $95,X
02A2A: 96 97         STX   $97,Y
02A2C: 98            TYA 
02A2D: 99 6E 6F      STA   $6F6E,Y
02A30: 7E 7F FF      ROR   $FF7F,X
02A33: 00            BRK 
02A34: 11 05         ORA   ($05),Y
02A36: 8D 10 FF      STA   $FF10
02A39: 00            BRK 
02A3A: 0B            ??? 
02A3B: 07 9B         RMB0  $9B
02A3D: 9C 9D 9E      STZ   $9E9D
02A40: 9F A0 A1      BBS1  $A0, $29E4
02A43: A2 9F         LDX   #$9F
02A45: A3 FF 00      TST   $FF, $00
02A48: 0B            ??? 
02A49: 08            PHP 
02A4A: A4 A5         LDY   $A5
02A4C: A6 A7         LDX   $A7
02A4E: A8            TAY 
02A4F: A9 AA         LDA   #$AA
02A51: AB            ??? 
02A52: A8            TAY 
02A53: AC FF FF      LDY   $FFFF
02A56: 00            BRK 
02A57: 08            PHP 
02A58: 05 80         ORA   $80
02A5A: 81 82         STA   ($82,X)
02A5C: 83 84 85      TST   $84, $85
02A5F: 86 87         STX   $87
02A61: 88            DEY 
02A62: 89 88         BIT   #$88
02A64: 8A            TXA 
02A65: 8C 8B 8C      STY   $8C8B
02A68: FF 00 08      BBS7  $00, $2A73
02A6B: 06 8E         ASL   $8E
02A6D: 8F 90 91      BBS0  $90, $2A01
02A70: 92 93         STA   ($93)
02A72: 94 95         STY   $95,X
02A74: 96 97         STX   $97,Y
02A76: 98            TYA 
02A77: 99 6E 6F      STA   $6F6E,Y
02A7A: 7E 7F FF      ROR   $FF7F,X
02A7D: 00            BRK 
02A7E: 11 07         ORA   ($07),Y
02A80: 8D 10 FF      STA   $FF10
02A83: FF 10 08      BBS7  $10, $2A8E
02A86: 12 50         ORA   ($50)
02A88: 55 53         EOR   $53,X
02A8A: 48            PHA 
02A8B: 20 52 55      JSR   $5552
02A8E: 4E 20 42      LSR   $4220
02A91: 55 54         EOR   $54,X
02A93: 54            ??? 
02A94: 4F 4E 21      BBR4  $4E, $2AB8
02A97: FF FF 00      BBS7  $FF, $2A9A
02A9A: 07 14         RMB0  $14
02A9C: 20 20 20      JSR   $2020
02A9F: 20 20 20      JSR   $2020
02AA2: 20 20 20      JSR   $2020
02AA5: 20 20 20      JSR   $2020
02AA8: 20 20 20      JSR   $2020
02AAB: 20 20 20      JSR   $2020
02AAE: 20 FF FF      JSR   $FFFF
02AB1: 10 08         BPL   $2ABB
02AB3: 12 4A         ORA   ($4A)
02AB5: 55 53         EOR   $53,X
02AB7: 54            ??? 
02AB8: 20 41 20      JSR   $2041
02ABB: 4D 4F 4D      EOR   $4D4F
02ABE: 45 4E         EOR   $4E
02AC0: 54            ??? 
02AC1: 2E 2E 2E      ROL   $2E2E
02AC4: FF FF 20      BBS7  $FF, $2AE7
02AC7: 08            PHP 
02AC8: 14 50         TRB   $50
02ACA: 4C 45 41      JMP   $4145
02ACD: 53 45         TAM   #$45
02ACF: 20 53 45      JSR   $4553
02AD2: 54            ??? 
02AD3: 20 44 49      JSR   $4944
02AD6: 53 43         TAM   #$43
02AD8: 21 FF         AND   ($FF,X)
02ADA: FF 20 07      BBS7  $20, $2AE4
02ADD: 14 50         TRB   $50
02ADF: 4C 45 41      JMP   $4145
02AE2: 53 45         TAM   #$45
02AE4: 20 43 4C      JSR   $4C43
02AE7: 4F 53 45      BBR4  $53, $2B2F
02AEA: 20 43 4F      JSR   $4F43
02AED: 56 45         LSR   $45,X
02AEF: 52 21         EOR   ($21)
02AF1: FF FF 20      BBS7  $FF, $2B14
02AF4: 0A            ASL 
02AF5: 14 4C         TRB   $4C
02AF7: 4F 41 44      BBR4  $41, $2B3E
02AFA: 20 45 52      JSR   $5245
02AFD: 52 4F         EOR   ($4F)
02AFF: 52 21         EOR   ($21)
02B01: FF FF A9      BBS7  $FF, $2AAD
02B04: F3 85 F8 A9 CA 85 F9  TAI   $F885, $CAA9, $F985
02B0B: 20 50 C9      JSR   $C950
02B0E: 60            RTS 


02B0F: 64 00         STZ   $00
02B11: 73 00 20 01 20 FF 00  TII   $2000, $2001, $00FF
02B18: 9C 00 22      STZ   $2200
02B1B: 73 00 22 01 22 FF 1D  TII   $2200, $2201, $1DFF
02B22: 44 0C         BSR   $2B30
02B24: 44 2E         BSR   $2B54
02B26: 58            CLI 
02B27: 44 3B         BSR   $2B64
02B29: 20 CF E3      JSR   $E3CF
02B2C: 20 C3 CB      JSR   $CBC3
02B2F: 60            RTS 


02B30: A9 00         LDA   #$00
02B32: 8D 84 22      STA   $2284
02B35: A9 E0         LDA   #$E0
02B37: 8D 85 22      STA   $2285
02B3A: A9 80         LDA   #$80
02B3C: 85 E7         STA   $E7
02B3E: 64 E6         STZ   $E6
02B40: A9 E2         LDA   #$E2
02B42: 8D 00 22      STA   $2200
02B45: A9 E8         LDA   #$E8
02B47: 8D 01 22      STA   $2201
02B4A: F3 00 22 02 22 0A 00  TAI   $2200, $2202, $000A
02B51: 64 F5         STZ   $F5
02B53: 60            RTS 


02B54: 20 E3 E8      JSR   $E8E3
02B57: 9C 02 18      STZ   $1802
02B5A: 9C 0F 18      STZ   $180F
02B5D: 20 7F F3      JSR   $F37F
02B60: 20 54 F3      JSR   $F354
02B63: 60            RTS 


02B64: 64 F7         STZ   $F7
02B66: 9C 00 08      STZ   $0800
02B69: 9C 01 08      STZ   $0801
02B6C: 9C 00 0C      STZ   $0C00
02B6F: 9C 01 0C      STZ   $0C01
02B72: 9C 03 14      STZ   $1403
02B75: 9C 00 10      STZ   $1000
02B78: 9C 02 14      STZ   $1402
02B7B: 64 F5         STZ   $F5
02B7D: 9C 1F 22      STZ   $221F
02B80: A9 10         LDA   #$10
02B82: 8D 42 22      STA   $2242
02B85: 64 F3         STZ   $F3
02B87: 64 F4         STZ   $F4
02B89: 20 A4 E3      JSR   $E3A4
02B8C: 20 D3 E3      JSR   $E3D3
02B8F: 62            CLA 
02B90: A2 20         LDX   #$20
02B92: A0 1E         LDY   #$1E
02B94: 20 9D E2      JSR   $E29D
02B97: A9 00         LDA   #$00
02B99: 20 67 E2      JSR   $E267
02B9C: A9 00         LDA   #$00
02B9E: 20 F8 E3      JSR   $E3F8
02BA1: A9 00         LDA   #$00
02BA3: 8D 14 22      STA   $2214
02BA6: A9 10         LDA   #$10
02BA8: 8D 15 22      STA   $2215
02BAB: 9C 26 22      STZ   $2226
02BAE: 9C 27 22      STZ   $2227
02BB1: 20 9A E4      JSR   $E49A
02BB4: 20 9A E4      JSR   $E49A
02BB7: A9 1F         LDA   #$1F
02BB9: 8D 27 22      STA   $2227
02BBC: 20 DA E5      JSR   $E5DA
02BBF: 20 0B E4      JSR   $E40B
02BC2: 60            RTS 
02BC3: 44 2B         BSR   $2BF0
02BC5: A9 00         LDA   #$00
02BC7: 8D 20 22      STA   $2220
02BCA: A9 C8         LDA   #$C8
02BCC: 8D 21 22      STA   $2221
02BCF: A9 00         LDA   #$00
02BD1: 8D 23 22      STA   $2223
02BD4: A9 C8         LDA   #$C8
02BD6: 8D 24 22      STA   $2224
02BD9: A9 04         LDA   #$04
02BDB: 8D 22 22      STA   $2222
02BDE: 8D 25 22      STA   $2225
02BE1: A9 02         LDA   #$02
02BE3: 8D 1F 22      STA   $221F
02BE6: 20 B5 E3      JSR   $E3B5
02BE9: 20 9E CC      JSR   $CC9E
02BEC: 20 E2 E3      JSR   $E3E2
02BEF: 60            RTS 
02BF0: A9 00         LDA   #$00
02BF2: 85 F7         STA   $F7
02BF4: 8D 00 00      STA   $0000
02BF7: 13 00         ST1   #$00
02BF9: 23 00         ST2   #$00
02BFB: A9 02         LDA   #$02
02BFD: 85 F7         STA   $F7
02BFF: 8D 00 00      STA   $0000
02C02: A0 40         LDY   #$40
02C04: A2 40         LDX   #$40
02C06: A9 00         LDA   #$00
02C08: 8D 02 00      STA   $0002
02C0B: A9 02         LDA   #$02
02C0D: 8D 03 00      STA   $0003
02C10: CA            DEX 
02C11: D0 F3         BNE   $2C06
02C13: 88            DEY 
02C14: D0 EE         BNE   $2C04
02C16: 60            RTS 
02C17: AD 56 22      LDA   $2256
02C1A: 20 00 E6      JSR   $E600
02C1D: 8D 56 22      STA   $2256
02C20: AD 57 22      LDA   $2257
02C23: 20 00 E6      JSR   $E600
02C26: 8D 57 22      STA   $2257
02C29: AD 58 22      LDA   $2258
02C2C: 20 00 E6      JSR   $E600
02C2F: 8D 58 22      STA   $2258
02C32: 64 F8         STZ   $F8
02C34: 64 F9         STZ   $F9
02C36: 64 FA         STZ   $FA
02C38: AD 56 22      LDA   $2256
02C3B: 44 5A         BSR   $2C97
02C3D: 44 3B         BSR   $2C7A
02C3F: 44 40         BSR   $2C81
02C41: 44 3E         BSR   $2C81
02C43: 44 3C         BSR   $2C81
02C45: 44 3A         BSR   $2C81
02C47: AD 57 22      LDA   $2257
02C4A: 44 4B         BSR   $2C97
02C4C: 44 35         BSR   $2C83
02C4E: A5 F8         LDA   $F8
02C50: 85 EC         STA   $EC
02C52: A5 F9         LDA   $F9
02C54: 85 ED         STA   $ED
02C56: A5 FA         LDA   $FA
02C58: 85 EE         STA   $EE
02C5A: 44 25         BSR   $2C81
02C5C: 44 1C         BSR   $2C7A
02C5E: 44 21         BSR   $2C81
02C60: 44 18         BSR   $2C7A
02C62: 44 16         BSR   $2C7A
02C64: 44 1B         BSR   $2C81
02C66: AD 58 22      LDA   $2258
02C69: 38            SEC 
02C6A: E9 96         SBC   #$96
02C6C: 85 EE         STA   $EE
02C6E: 62            CLA 
02C6F: E9 00         SBC   #$00
02C71: 85 ED         STA   $ED
02C73: 62            CLA 
02C74: E9 00         SBC   #$00
02C76: 85 EC         STA   $EC
02C78: 80 09         BRA   $2C83
02C7A: 06 EE         ASL   $EE
02C7C: 26 ED         ROL   $ED
02C7E: 26 EC         ROL   $EC
02C80: 60            RTS 
02C81: 44 F7         BSR   $2C7A
02C83: A5 FA         LDA   $FA
02C85: 18            CLC 
02C86: 65 EE         ADC   $EE
02C88: 85 FA         STA   $FA
02C8A: A5 F9         LDA   $F9
02C8C: 65 ED         ADC   $ED
02C8E: 85 F9         STA   $F9
02C90: A5 F8         LDA   $F8
02C92: 65 EC         ADC   $EC
02C94: 85 F8         STA   $F8
02C96: 60            RTS 
02C97: 85 EE         STA   $EE
02C99: 64 ED         STZ   $ED
02C9B: 64 EC         STZ   $EC
02C9D: 60            RTS 
02C9E: A9 00         LDA   #$00
02CA0: 85 F7         STA   $F7
02CA2: 8D 00 00      STA   $0000
02CA5: 13 00         ST1   #$00
02CA7: 23 20         ST2   #$20
02CA9: A9 02         LDA   #$02
02CAB: 85 F7         STA   $F7
02CAD: 8D 00 00      STA   $0000
02CB0: A9 00         LDA   #$00
02CB2: 85 EC         STA   $EC
02CB4: A9 C0         LDA   #$C0
02CB6: 85 ED         STA   $ED
02CB8: 64 EE         STZ   $EE
02CBA: A2 02         LDX   #$02
02CBC: C2            CLY 
02CBD: B1 EC         LDA   ($EC),Y
02CBF: 8D 02 00      STA   $0002
02CC2: 8D 03 00      STA   $0003
02CC5: C8            INY 
02CC6: C0 08         CPY   #$08
02CC8: 90 F3         BCC   $2CBD
02CCA: CA            DEX 
02CCB: D0 EF         BNE   $2CBC
02CCD: 18            CLC 
02CCE: A5 EC         LDA   $EC
02CD0: 69 08         ADC   #$08
02CD2: 85 EC         STA   $EC
02CD4: A5 ED         LDA   $ED
02CD6: 69 00         ADC   #$00
02CD8: 85 ED         STA   $ED
02CDA: C6 EE         DEC   $EE
02CDC: D0 DC         BNE   $2CBA
02CDE: 43 10         TMA   #$10
02CE0: 48            PHA 
02CE1: 43 20         TMA   #$20
02CE3: 48            PHA 
02CE4: A9 16         LDA   #$16
02CE6: 53 10         TAM   #$10
02CE8: 1A            INC 
02CE9: 53 20         TAM   #$20
02CEB: E3 00 80 02 00 00 20  TIA   $8000, $0002, $2000
02CF2: 68            PLA 
02CF3: 53 20         TAM   #$20
02CF5: 68            PLA 
02CF6: 53 10         TAM   #$10
02CF8: 60            RTS 
02CF9: FF FF FF      BBS7  $FF, $2CFB
02CFC: FF FF FF      BBS7  $FF, $2CFE
02CFF: FF FF FF      BBS7  $FF, $2D01
02D02: FF FF FF      BBS7  $FF, $2D04
02D05: FF FF FF      BBS7  $FF, $2D07
02D08: FF FF FF      BBS7  $FF, $2D0A
02D0B: FF FF FF      BBS7  $FF, $2D0D
02D0E: FF FF FF      BBS7  $FF, $2D10
02D11: FF FF FF      BBS7  $FF, $2D13
02D14: FF FF FF      BBS7  $FF, $2D16
02D17: FF FF FF      BBS7  $FF, $2D19
02D1A: FF FF FF      BBS7  $FF, $2D1C
02D1D: FF FF FF      BBS7  $FF, $2D1F
02D20: FF FF FF      BBS7  $FF, $2D22
02D23: FF FF FF      BBS7  $FF, $2D25
02D26: FF FF FF      BBS7  $FF, $2D28
02D29: FF FF FF      BBS7  $FF, $2D2B
02D2C: FF FF FF      BBS7  $FF, $2D2E
02D2F: FF FF FF      BBS7  $FF, $2D31
02D32: FF FF FF      BBS7  $FF, $2D34
02D35: FF FF FF      BBS7  $FF, $2D37
02D38: FF FF FF      BBS7  $FF, $2D3A
02D3B: FF FF FF      BBS7  $FF, $2D3D
02D3E: FF FF FF      BBS7  $FF, $2D40
02D41: FF FF FF      BBS7  $FF, $2D43
02D44: FF FF FF      BBS7  $FF, $2D46
02D47: FF FF FF      BBS7  $FF, $2D49
02D4A: FF FF FF      BBS7  $FF, $2D4C
02D4D: FF FF FF      BBS7  $FF, $2D4F
02D50: FF FF FF      BBS7  $FF, $2D52
02D53: FF FF FF      BBS7  $FF, $2D55
02D56: FF FF FF      BBS7  $FF, $2D58
02D59: FF FF FF      BBS7  $FF, $2D5B
02D5C: FF FF FF      BBS7  $FF, $2D5E
02D5F: FF FF FF      BBS7  $FF, $2D61
02D62: FF FF FF      BBS7  $FF, $2D64
02D65: FF FF FF      BBS7  $FF, $2D67
02D68: FF FF FF      BBS7  $FF, $2D6A
02D6B: FF FF FF      BBS7  $FF, $2D6D
02D6E: FF FF FF      BBS7  $FF, $2D70
02D71: FF FF FF      BBS7  $FF, $2D73
02D74: FF FF FF      BBS7  $FF, $2D76
02D77: FF FF FF      BBS7  $FF, $2D79
02D7A: FF FF FF      BBS7  $FF, $2D7C
02D7D: FF FF FF      BBS7  $FF, $2D7F
02D80: FF FF FF      BBS7  $FF, $2D82
02D83: FF FF FF      BBS7  $FF, $2D85
02D86: FF FF FF      BBS7  $FF, $2D88
02D89: FF FF FF      BBS7  $FF, $2D8B
02D8C: FF FF FF      BBS7  $FF, $2D8E
02D8F: FF FF FF      BBS7  $FF, $2D91
02D92: FF FF FF      BBS7  $FF, $2D94
02D95: FF FF FF      BBS7  $FF, $2D97
02D98: FF FF FF      BBS7  $FF, $2D9A
02D9B: FF FF FF      BBS7  $FF, $2D9D
02D9E: FF FF FF      BBS7  $FF, $2DA0
02DA1: FF FF FF      BBS7  $FF, $2DA3
02DA4: FF FF FF      BBS7  $FF, $2DA6
02DA7: FF FF FF      BBS7  $FF, $2DA9
02DAA: FF FF FF      BBS7  $FF, $2DAC
02DAD: FF FF FF      BBS7  $FF, $2DAF
02DB0: FF FF FF      BBS7  $FF, $2DB2
02DB3: FF FF FF      BBS7  $FF, $2DB5
02DB6: FF FF FF      BBS7  $FF, $2DB8
02DB9: FF FF FF      BBS7  $FF, $2DBB
02DBC: FF FF FF      BBS7  $FF, $2DBE
02DBF: FF FF FF      BBS7  $FF, $2DC1
02DC2: FF FF FF      BBS7  $FF, $2DC4
02DC5: FF FF FF      BBS7  $FF, $2DC7
02DC8: FF FF FF      BBS7  $FF, $2DCA
02DCB: FF FF FF      BBS7  $FF, $2DCD
02DCE: FF FF FF      BBS7  $FF, $2DD0
02DD1: FF FF FF      BBS7  $FF, $2DD3
02DD4: FF FF FF      BBS7  $FF, $2DD6
02DD7: FF FF FF      BBS7  $FF, $2DD9
02DDA: FF FF FF      BBS7  $FF, $2DDC
02DDD: FF FF FF      BBS7  $FF, $2DDF
02DE0: FF FF FF      BBS7  $FF, $2DE2
02DE3: FF FF FF      BBS7  $FF, $2DE5
02DE6: FF FF FF      BBS7  $FF, $2DE8
02DE9: FF FF FF      BBS7  $FF, $2DEB
02DEC: FF FF FF      BBS7  $FF, $2DEE
02DEF: FF FF FF      BBS7  $FF, $2DF1
02DF2: FF FF FF      BBS7  $FF, $2DF4
02DF5: FF FF FF      BBS7  $FF, $2DF7
02DF8: FF FF FF      BBS7  $FF, $2DFA
02DFB: FF FF FF      BBS7  $FF, $2DFD
02DFE: FF FF FF      BBS7  $FF, $2E00
02E01: FF FF FF      BBS7  $FF, $2E03
02E04: FF FF FF      BBS7  $FF, $2E06
02E07: FF FF FF      BBS7  $FF, $2E09
02E0A: FF FF FF      BBS7  $FF, $2E0C
02E0D: FF FF FF      BBS7  $FF, $2E0F
02E10: FF FF FF      BBS7  $FF, $2E12
02E13: FF FF FF      BBS7  $FF, $2E15
02E16: FF FF FF      BBS7  $FF, $2E18
02E19: FF FF FF      BBS7  $FF, $2E1B
02E1C: FF FF FF      BBS7  $FF, $2E1E
02E1F: FF FF FF      BBS7  $FF, $2E21
02E22: FF FF FF      BBS7  $FF, $2E24
02E25: FF FF FF      BBS7  $FF, $2E27
02E28: FF FF FF      BBS7  $FF, $2E2A
02E2B: FF FF FF      BBS7  $FF, $2E2D
02E2E: FF FF FF      BBS7  $FF, $2E30
02E31: FF FF FF      BBS7  $FF, $2E33
02E34: FF FF FF      BBS7  $FF, $2E36
02E37: FF FF FF      BBS7  $FF, $2E39
02E3A: FF FF FF      BBS7  $FF, $2E3C
02E3D: FF FF FF      BBS7  $FF, $2E3F
02E40: FF FF FF      BBS7  $FF, $2E42
02E43: FF FF FF      BBS7  $FF, $2E45
02E46: FF FF FF      BBS7  $FF, $2E48
02E49: FF FF FF      BBS7  $FF, $2E4B
02E4C: FF FF FF      BBS7  $FF, $2E4E
02E4F: FF FF FF      BBS7  $FF, $2E51
02E52: FF FF FF      BBS7  $FF, $2E54
02E55: FF FF FF      BBS7  $FF, $2E57
02E58: FF FF FF      BBS7  $FF, $2E5A
02E5B: FF FF FF      BBS7  $FF, $2E5D
02E5E: FF FF FF      BBS7  $FF, $2E60
02E61: FF FF FF      BBS7  $FF, $2E63
02E64: FF FF FF      BBS7  $FF, $2E66
02E67: FF FF FF      BBS7  $FF, $2E69
02E6A: FF FF FF      BBS7  $FF, $2E6C
02E6D: FF FF FF      BBS7  $FF, $2E6F
02E70: FF FF FF      BBS7  $FF, $2E72
02E73: FF FF FF      BBS7  $FF, $2E75
02E76: FF FF FF      BBS7  $FF, $2E78
02E79: FF FF FF      BBS7  $FF, $2E7B
02E7C: FF FF FF      BBS7  $FF, $2E7E
02E7F: FF FF FF      BBS7  $FF, $2E81
02E82: FF FF FF      BBS7  $FF, $2E84
02E85: FF FF FF      BBS7  $FF, $2E87
02E88: FF FF FF      BBS7  $FF, $2E8A
02E8B: FF FF FF      BBS7  $FF, $2E8D
02E8E: FF FF FF      BBS7  $FF, $2E90
02E91: FF FF FF      BBS7  $FF, $2E93
02E94: FF FF FF      BBS7  $FF, $2E96
02E97: FF FF FF      BBS7  $FF, $2E99
02E9A: FF FF FF      BBS7  $FF, $2E9C
02E9D: FF FF FF      BBS7  $FF, $2E9F
02EA0: FF FF FF      BBS7  $FF, $2EA2
02EA3: FF FF FF      BBS7  $FF, $2EA5
02EA6: FF FF FF      BBS7  $FF, $2EA8
02EA9: FF FF FF      BBS7  $FF, $2EAB
02EAC: FF FF FF      BBS7  $FF, $2EAE
02EAF: FF FF FF      BBS7  $FF, $2EB1
02EB2: FF FF FF      BBS7  $FF, $2EB4
02EB5: FF FF FF      BBS7  $FF, $2EB7
02EB8: FF FF FF      BBS7  $FF, $2EBA
02EBB: FF FF FF      BBS7  $FF, $2EBD
02EBE: FF FF FF      BBS7  $FF, $2EC0
02EC1: FF FF FF      BBS7  $FF, $2EC3
02EC4: FF FF FF      BBS7  $FF, $2EC6
02EC7: FF FF FF      BBS7  $FF, $2EC9
02ECA: FF FF FF      BBS7  $FF, $2ECC
02ECD: FF FF FF      BBS7  $FF, $2ECF
02ED0: FF FF FF      BBS7  $FF, $2ED2
02ED3: FF FF FF      BBS7  $FF, $2ED5
02ED6: FF FF FF      BBS7  $FF, $2ED8
02ED9: FF FF FF      BBS7  $FF, $2EDB
02EDC: FF FF FF      BBS7  $FF, $2EDE
02EDF: FF FF FF      BBS7  $FF, $2EE1
02EE2: FF FF FF      BBS7  $FF, $2EE4
02EE5: FF FF FF      BBS7  $FF, $2EE7
02EE8: FF FF FF      BBS7  $FF, $2EEA
02EEB: FF FF FF      BBS7  $FF, $2EED
02EEE: FF FF FF      BBS7  $FF, $2EF0
02EF1: FF FF FF      BBS7  $FF, $2EF3
02EF4: FF FF FF      BBS7  $FF, $2EF6
02EF7: FF FF FF      BBS7  $FF, $2EF9
02EFA: FF FF FF      BBS7  $FF, $2EFC
02EFD: FF FF FF      BBS7  $FF, $2EFF
02F00: FF FF FF      BBS7  $FF, $2F02
02F03: FF FF FF      BBS7  $FF, $2F05
02F06: FF FF FF      BBS7  $FF, $2F08
02F09: FF FF FF      BBS7  $FF, $2F0B
02F0C: FF FF FF      BBS7  $FF, $2F0E
02F0F: FF FF FF      BBS7  $FF, $2F11
02F12: FF FF FF      BBS7  $FF, $2F14
02F15: FF FF FF      BBS7  $FF, $2F17
02F18: FF FF FF      BBS7  $FF, $2F1A
02F1B: FF FF FF      BBS7  $FF, $2F1D
02F1E: FF FF FF      BBS7  $FF, $2F20
02F21: FF FF FF      BBS7  $FF, $2F23
02F24: FF FF FF      BBS7  $FF, $2F26
02F27: FF FF FF      BBS7  $FF, $2F29
02F2A: FF FF FF      BBS7  $FF, $2F2C
02F2D: FF FF FF      BBS7  $FF, $2F2F
02F30: FF FF FF      BBS7  $FF, $2F32
02F33: FF FF FF      BBS7  $FF, $2F35
02F36: FF FF FF      BBS7  $FF, $2F38
02F39: FF FF FF      BBS7  $FF, $2F3B
02F3C: FF FF FF      BBS7  $FF, $2F3E
02F3F: FF FF FF      BBS7  $FF, $2F41
02F42: FF FF FF      BBS7  $FF, $2F44
02F45: FF FF FF      BBS7  $FF, $2F47
02F48: FF FF FF      BBS7  $FF, $2F4A
02F4B: FF FF FF      BBS7  $FF, $2F4D
02F4E: FF FF FF      BBS7  $FF, $2F50
02F51: FF FF FF      BBS7  $FF, $2F53
02F54: FF FF FF      BBS7  $FF, $2F56
02F57: FF FF FF      BBS7  $FF, $2F59
02F5A: FF FF FF      BBS7  $FF, $2F5C
02F5D: FF FF FF      BBS7  $FF, $2F5F
02F60: FF FF FF      BBS7  $FF, $2F62
02F63: FF FF FF      BBS7  $FF, $2F65
02F66: FF FF FF      BBS7  $FF, $2F68
02F69: FF FF FF      BBS7  $FF, $2F6B
02F6C: FF FF FF      BBS7  $FF, $2F6E
02F6F: FF FF FF      BBS7  $FF, $2F71
02F72: FF FF FF      BBS7  $FF, $2F74
02F75: FF FF FF      BBS7  $FF, $2F77
02F78: FF FF FF      BBS7  $FF, $2F7A
02F7B: FF FF FF      BBS7  $FF, $2F7D
02F7E: FF FF FF      BBS7  $FF, $2F80
02F81: FF FF FF      BBS7  $FF, $2F83
02F84: FF FF FF      BBS7  $FF, $2F86
02F87: FF FF FF      BBS7  $FF, $2F89
02F8A: FF FF FF      BBS7  $FF, $2F8C
02F8D: FF FF FF      BBS7  $FF, $2F8F
02F90: FF FF FF      BBS7  $FF, $2F92
02F93: FF FF FF      BBS7  $FF, $2F95
02F96: FF FF FF      BBS7  $FF, $2F98
02F99: FF FF FF      BBS7  $FF, $2F9B
02F9C: FF FF FF      BBS7  $FF, $2F9E
02F9F: FF FF FF      BBS7  $FF, $2FA1
02FA2: FF FF FF      BBS7  $FF, $2FA4
02FA5: FF FF FF      BBS7  $FF, $2FA7
02FA8: FF FF FF      BBS7  $FF, $2FAA
02FAB: FF FF FF      BBS7  $FF, $2FAD
02FAE: FF FF FF      BBS7  $FF, $2FB0
02FB1: FF FF FF      BBS7  $FF, $2FB3
02FB4: FF FF FF      BBS7  $FF, $2FB6
02FB7: FF FF FF      BBS7  $FF, $2FB9
02FBA: FF FF FF      BBS7  $FF, $2FBC
02FBD: FF FF FF      BBS7  $FF, $2FBF
02FC0: FF FF FF      BBS7  $FF, $2FC2
02FC3: FF FF FF      BBS7  $FF, $2FC5
02FC6: FF FF FF      BBS7  $FF, $2FC8
02FC9: FF FF FF      BBS7  $FF, $2FCB
02FCC: FF FF FF      BBS7  $FF, $2FCE
02FCF: FF FF FF      BBS7  $FF, $2FD1
02FD2: FF FF FF      BBS7  $FF, $2FD4
02FD5: FF FF FF      BBS7  $FF, $2FD7
02FD8: FF FF FF      BBS7  $FF, $2FDA
02FDB: FF FF FF      BBS7  $FF, $2FDD
02FDE: FF FF FF      BBS7  $FF, $2FE0
02FE1: FF FF FF      BBS7  $FF, $2FE3
02FE4: FF FF FF      BBS7  $FF, $2FE6
02FE7: FF FF FF      BBS7  $FF, $2FE9
02FEA: FF FF FF      BBS7  $FF, $2FEC
02FED: FF FF FF      BBS7  $FF, $2FEF
02FF0: FF FF FF      BBS7  $FF, $2FF2
02FF3: FF FF FF      BBS7  $FF, $2FF5
02FF6: FF FF FF      BBS7  $FF, $2FF8
02FF9: FF FF FF      BBS7  $FF, $2FFB
02FFC: FF FF FF      BBS7  $FF, $2FFE
02FFF: FF FF FF      BBS7  $FF, $3001
03002: FF FF FF      BBS7  $FF, $3004
03005: FF FF FF      BBS7  $FF, $3007
03008: FF FF FF      BBS7  $FF, $300A
0300B: FF FF FF      BBS7  $FF, $300D
0300E: FF FF FF      BBS7  $FF, $3010
03011: FF FF FF      BBS7  $FF, $3013
03014: FF FF FF      BBS7  $FF, $3016
03017: FF FF FF      BBS7  $FF, $3019
0301A: FF FF FF      BBS7  $FF, $301C
0301D: FF FF FF      BBS7  $FF, $301F
03020: FF FF FF      BBS7  $FF, $3022
03023: FF FF FF      BBS7  $FF, $3025
03026: FF FF FF      BBS7  $FF, $3028
03029: FF FF FF      BBS7  $FF, $302B
0302C: FF FF FF      BBS7  $FF, $302E
0302F: FF FF FF      BBS7  $FF, $3031
03032: FF FF FF      BBS7  $FF, $3034
03035: FF FF FF      BBS7  $FF, $3037
03038: FF FF FF      BBS7  $FF, $303A
0303B: FF FF FF      BBS7  $FF, $303D
0303E: FF FF FF      BBS7  $FF, $3040
03041: FF FF FF      BBS7  $FF, $3043
03044: FF FF FF      BBS7  $FF, $3046
03047: FF FF FF      BBS7  $FF, $3049
0304A: FF FF FF      BBS7  $FF, $304C
0304D: FF FF FF      BBS7  $FF, $304F
03050: FF FF FF      BBS7  $FF, $3052
03053: FF FF FF      BBS7  $FF, $3055
03056: FF FF FF      BBS7  $FF, $3058
03059: FF FF FF      BBS7  $FF, $305B
0305C: FF FF FF      BBS7  $FF, $305E
0305F: FF FF FF      BBS7  $FF, $3061
03062: FF FF FF      BBS7  $FF, $3064
03065: FF FF FF      BBS7  $FF, $3067
03068: FF FF FF      BBS7  $FF, $306A
0306B: FF FF FF      BBS7  $FF, $306D
0306E: FF FF FF      BBS7  $FF, $3070
03071: FF FF FF      BBS7  $FF, $3073
03074: FF FF FF      BBS7  $FF, $3076
03077: FF FF FF      BBS7  $FF, $3079
0307A: FF FF FF      BBS7  $FF, $307C
0307D: FF FF FF      BBS7  $FF, $307F
03080: FF FF FF      BBS7  $FF, $3082
03083: FF FF FF      BBS7  $FF, $3085
03086: FF FF FF      BBS7  $FF, $3088
03089: FF FF FF      BBS7  $FF, $308B
0308C: FF FF FF      BBS7  $FF, $308E
0308F: FF FF FF      BBS7  $FF, $3091
03092: FF FF FF      BBS7  $FF, $3094
03095: FF FF FF      BBS7  $FF, $3097
03098: FF FF FF      BBS7  $FF, $309A
0309B: FF FF FF      BBS7  $FF, $309D
0309E: FF FF FF      BBS7  $FF, $30A0
030A1: FF FF FF      BBS7  $FF, $30A3
030A4: FF FF FF      BBS7  $FF, $30A6
030A7: FF FF FF      BBS7  $FF, $30A9
030AA: FF FF FF      BBS7  $FF, $30AC
030AD: FF FF FF      BBS7  $FF, $30AF
030B0: FF FF FF      BBS7  $FF, $30B2
030B3: FF FF FF      BBS7  $FF, $30B5
030B6: FF FF FF      BBS7  $FF, $30B8
030B9: FF FF FF      BBS7  $FF, $30BB
030BC: FF FF FF      BBS7  $FF, $30BE
030BF: FF FF FF      BBS7  $FF, $30C1
030C2: FF FF FF      BBS7  $FF, $30C4
030C5: FF FF FF      BBS7  $FF, $30C7
030C8: FF FF FF      BBS7  $FF, $30CA
030CB: FF FF FF      BBS7  $FF, $30CD
030CE: FF FF FF      BBS7  $FF, $30D0
030D1: FF FF FF      BBS7  $FF, $30D3
030D4: FF FF FF      BBS7  $FF, $30D6
030D7: FF FF FF      BBS7  $FF, $30D9
030DA: FF FF FF      BBS7  $FF, $30DC
030DD: FF FF FF      BBS7  $FF, $30DF
030E0: FF FF FF      BBS7  $FF, $30E2
030E3: FF FF FF      BBS7  $FF, $30E5
030E6: FF FF FF      BBS7  $FF, $30E8
030E9: FF FF FF      BBS7  $FF, $30EB
030EC: FF FF FF      BBS7  $FF, $30EE
030EF: FF FF FF      BBS7  $FF, $30F1
030F2: FF FF FF      BBS7  $FF, $30F4
030F5: FF FF FF      BBS7  $FF, $30F7
030F8: FF FF FF      BBS7  $FF, $30FA
030FB: FF FF FF      BBS7  $FF, $30FD
030FE: FF FF FF      BBS7  $FF, $3100
03101: FF FF FF      BBS7  $FF, $3103
03104: FF FF FF      BBS7  $FF, $3106
03107: FF FF FF      BBS7  $FF, $3109
0310A: FF FF FF      BBS7  $FF, $310C
0310D: FF FF FF      BBS7  $FF, $310F
03110: FF FF FF      BBS7  $FF, $3112
03113: FF FF FF      BBS7  $FF, $3115
03116: FF FF FF      BBS7  $FF, $3118
03119: FF FF FF      BBS7  $FF, $311B
0311C: FF FF FF      BBS7  $FF, $311E
0311F: FF FF FF      BBS7  $FF, $3121
03122: FF FF FF      BBS7  $FF, $3124
03125: FF FF FF      BBS7  $FF, $3127
03128: FF FF FF      BBS7  $FF, $312A
0312B: FF FF FF      BBS7  $FF, $312D
0312E: FF FF FF      BBS7  $FF, $3130
03131: FF FF FF      BBS7  $FF, $3133
03134: FF FF FF      BBS7  $FF, $3136
03137: FF FF FF      BBS7  $FF, $3139
0313A: FF FF FF      BBS7  $FF, $313C
0313D: FF FF FF      BBS7  $FF, $313F
03140: FF FF FF      BBS7  $FF, $3142
03143: FF FF FF      BBS7  $FF, $3145
03146: FF FF FF      BBS7  $FF, $3148
03149: FF FF FF      BBS7  $FF, $314B
0314C: FF FF FF      BBS7  $FF, $314E
0314F: FF FF FF      BBS7  $FF, $3151
03152: FF FF FF      BBS7  $FF, $3154
03155: FF FF FF      BBS7  $FF, $3157
03158: FF FF FF      BBS7  $FF, $315A
0315B: FF FF FF      BBS7  $FF, $315D
0315E: FF FF FF      BBS7  $FF, $3160
03161: FF FF FF      BBS7  $FF, $3163
03164: FF FF FF      BBS7  $FF, $3166
03167: FF FF FF      BBS7  $FF, $3169
0316A: FF FF FF      BBS7  $FF, $316C
0316D: FF FF FF      BBS7  $FF, $316F
03170: FF FF FF      BBS7  $FF, $3172
03173: FF FF FF      BBS7  $FF, $3175
03176: FF FF FF      BBS7  $FF, $3178
03179: FF FF FF      BBS7  $FF, $317B
0317C: FF FF FF      BBS7  $FF, $317E
0317F: FF FF FF      BBS7  $FF, $3181
03182: FF FF FF      BBS7  $FF, $3184
03185: FF FF FF      BBS7  $FF, $3187
03188: FF FF FF      BBS7  $FF, $318A
0318B: FF FF FF      BBS7  $FF, $318D
0318E: FF FF FF      BBS7  $FF, $3190
03191: FF FF FF      BBS7  $FF, $3193
03194: FF FF FF      BBS7  $FF, $3196
03197: FF FF FF      BBS7  $FF, $3199
0319A: FF FF FF      BBS7  $FF, $319C
0319D: FF FF FF      BBS7  $FF, $319F
031A0: FF FF FF      BBS7  $FF, $31A2
031A3: FF FF FF      BBS7  $FF, $31A5
031A6: FF FF FF      BBS7  $FF, $31A8
031A9: FF FF FF      BBS7  $FF, $31AB
031AC: FF FF FF      BBS7  $FF, $31AE
031AF: FF FF FF      BBS7  $FF, $31B1
031B2: FF FF FF      BBS7  $FF, $31B4
031B5: FF FF FF      BBS7  $FF, $31B7
031B8: FF FF FF      BBS7  $FF, $31BA
031BB: FF FF FF      BBS7  $FF, $31BD
031BE: FF FF FF      BBS7  $FF, $31C0
031C1: FF FF FF      BBS7  $FF, $31C3
031C4: FF FF FF      BBS7  $FF, $31C6
031C7: FF FF FF      BBS7  $FF, $31C9
031CA: FF FF FF      BBS7  $FF, $31CC
031CD: FF FF FF      BBS7  $FF, $31CF
031D0: FF FF FF      BBS7  $FF, $31D2
031D3: FF FF FF      BBS7  $FF, $31D5
031D6: FF FF FF      BBS7  $FF, $31D8
031D9: FF FF FF      BBS7  $FF, $31DB
031DC: FF FF FF      BBS7  $FF, $31DE
031DF: FF FF FF      BBS7  $FF, $31E1
031E2: FF FF FF      BBS7  $FF, $31E4
031E5: FF FF FF      BBS7  $FF, $31E7
031E8: FF FF FF      BBS7  $FF, $31EA
031EB: FF FF FF      BBS7  $FF, $31ED
031EE: FF FF FF      BBS7  $FF, $31F0
031F1: FF FF FF      BBS7  $FF, $31F3
031F4: FF FF FF      BBS7  $FF, $31F6
031F7: FF FF FF      BBS7  $FF, $31F9
031FA: FF FF FF      BBS7  $FF, $31FC
031FD: FF FF FF      BBS7  $FF, $31FF
03200: FF FF FF      BBS7  $FF, $3202
03203: FF FF FF      BBS7  $FF, $3205
03206: FF FF FF      BBS7  $FF, $3208
03209: FF FF FF      BBS7  $FF, $320B
0320C: FF FF FF      BBS7  $FF, $320E
0320F: FF FF FF      BBS7  $FF, $3211
03212: FF FF FF      BBS7  $FF, $3214
03215: FF FF FF      BBS7  $FF, $3217
03218: FF FF FF      BBS7  $FF, $321A
0321B: FF FF FF      BBS7  $FF, $321D
0321E: FF FF FF      BBS7  $FF, $3220
03221: FF FF FF      BBS7  $FF, $3223
03224: FF FF FF      BBS7  $FF, $3226
03227: FF FF FF      BBS7  $FF, $3229
0322A: FF FF FF      BBS7  $FF, $322C
0322D: FF FF FF      BBS7  $FF, $322F
03230: FF FF FF      BBS7  $FF, $3232
03233: FF FF FF      BBS7  $FF, $3235
03236: FF FF FF      BBS7  $FF, $3238
03239: FF FF FF      BBS7  $FF, $323B
0323C: FF FF FF      BBS7  $FF, $323E
0323F: FF FF FF      BBS7  $FF, $3241
03242: FF FF FF      BBS7  $FF, $3244
03245: FF FF FF      BBS7  $FF, $3247
03248: FF FF FF      BBS7  $FF, $324A
0324B: FF FF FF      BBS7  $FF, $324D
0324E: FF FF FF      BBS7  $FF, $3250
03251: FF FF FF      BBS7  $FF, $3253
03254: FF FF FF      BBS7  $FF, $3256
03257: FF FF FF      BBS7  $FF, $3259
0325A: FF FF FF      BBS7  $FF, $325C
0325D: FF FF FF      BBS7  $FF, $325F
03260: FF FF FF      BBS7  $FF, $3262
03263: FF FF FF      BBS7  $FF, $3265
03266: FF FF FF      BBS7  $FF, $3268
03269: FF FF FF      BBS7  $FF, $326B
0326C: FF FF FF      BBS7  $FF, $326E
0326F: FF FF FF      BBS7  $FF, $3271
03272: FF FF FF      BBS7  $FF, $3274
03275: FF FF FF      BBS7  $FF, $3277
03278: FF FF FF      BBS7  $FF, $327A
0327B: FF FF FF      BBS7  $FF, $327D
0327E: FF FF FF      BBS7  $FF, $3280
03281: FF FF FF      BBS7  $FF, $3283
03284: FF FF FF      BBS7  $FF, $3286
03287: FF FF FF      BBS7  $FF, $3289
0328A: FF FF FF      BBS7  $FF, $328C
0328D: FF FF FF      BBS7  $FF, $328F
03290: FF FF FF      BBS7  $FF, $3292
03293: FF FF FF      BBS7  $FF, $3295
03296: FF FF FF      BBS7  $FF, $3298
03299: FF FF FF      BBS7  $FF, $329B
0329C: FF FF FF      BBS7  $FF, $329E
0329F: FF FF FF      BBS7  $FF, $32A1
032A2: FF FF FF      BBS7  $FF, $32A4
032A5: FF FF FF      BBS7  $FF, $32A7
032A8: FF FF FF      BBS7  $FF, $32AA
032AB: FF FF FF      BBS7  $FF, $32AD
032AE: FF FF FF      BBS7  $FF, $32B0
032B1: FF FF FF      BBS7  $FF, $32B3
032B4: FF FF FF      BBS7  $FF, $32B6
032B7: FF FF FF      BBS7  $FF, $32B9
032BA: FF FF FF      BBS7  $FF, $32BC
032BD: FF FF FF      BBS7  $FF, $32BF
032C0: FF FF FF      BBS7  $FF, $32C2
032C3: FF FF FF      BBS7  $FF, $32C5
032C6: FF FF FF      BBS7  $FF, $32C8
032C9: FF FF FF      BBS7  $FF, $32CB
032CC: FF FF FF      BBS7  $FF, $32CE
032CF: FF FF FF      BBS7  $FF, $32D1
032D2: FF FF FF      BBS7  $FF, $32D4
032D5: FF FF FF      BBS7  $FF, $32D7
032D8: FF FF FF      BBS7  $FF, $32DA
032DB: FF FF FF      BBS7  $FF, $32DD
032DE: FF FF FF      BBS7  $FF, $32E0
032E1: FF FF FF      BBS7  $FF, $32E3
032E4: FF FF FF      BBS7  $FF, $32E6
032E7: FF FF FF      BBS7  $FF, $32E9
032EA: FF FF FF      BBS7  $FF, $32EC
032ED: FF FF FF      BBS7  $FF, $32EF
032F0: FF FF FF      BBS7  $FF, $32F2
032F3: FF FF FF      BBS7  $FF, $32F5
032F6: FF FF FF      BBS7  $FF, $32F8
032F9: FF FF FF      BBS7  $FF, $32FB
032FC: FF FF FF      BBS7  $FF, $32FE
032FF: FF FF FF      BBS7  $FF, $3301
03302: FF FF FF      BBS7  $FF, $3304
03305: FF FF FF      BBS7  $FF, $3307
03308: FF FF FF      BBS7  $FF, $330A
0330B: FF FF FF      BBS7  $FF, $330D
0330E: FF FF FF      BBS7  $FF, $3310
03311: FF FF FF      BBS7  $FF, $3313
03314: FF FF FF      BBS7  $FF, $3316
03317: FF FF FF      BBS7  $FF, $3319
0331A: FF FF FF      BBS7  $FF, $331C
0331D: FF FF FF      BBS7  $FF, $331F
03320: FF FF FF      BBS7  $FF, $3322
03323: FF FF FF      BBS7  $FF, $3325
03326: FF FF FF      BBS7  $FF, $3328
03329: FF FF FF      BBS7  $FF, $332B
0332C: FF FF FF      BBS7  $FF, $332E
0332F: FF FF FF      BBS7  $FF, $3331
03332: FF FF FF      BBS7  $FF, $3334
03335: FF FF FF      BBS7  $FF, $3337
03338: FF FF FF      BBS7  $FF, $333A
0333B: FF FF FF      BBS7  $FF, $333D
0333E: FF FF FF      BBS7  $FF, $3340
03341: FF FF FF      BBS7  $FF, $3343
03344: FF FF FF      BBS7  $FF, $3346
03347: FF FF FF      BBS7  $FF, $3349
0334A: FF FF FF      BBS7  $FF, $334C
0334D: FF FF FF      BBS7  $FF, $334F
03350: FF FF FF      BBS7  $FF, $3352
03353: FF FF FF      BBS7  $FF, $3355
03356: FF FF FF      BBS7  $FF, $3358
03359: FF FF FF      BBS7  $FF, $335B
0335C: FF FF FF      BBS7  $FF, $335E
0335F: FF FF FF      BBS7  $FF, $3361
03362: FF FF FF      BBS7  $FF, $3364
03365: FF FF FF      BBS7  $FF, $3367
03368: FF FF FF      BBS7  $FF, $336A
0336B: FF FF FF      BBS7  $FF, $336D
0336E: FF FF FF      BBS7  $FF, $3370
03371: FF FF FF      BBS7  $FF, $3373
03374: FF FF FF      BBS7  $FF, $3376
03377: FF FF FF      BBS7  $FF, $3379
0337A: FF FF FF      BBS7  $FF, $337C
0337D: FF FF FF      BBS7  $FF, $337F
03380: FF FF FF      BBS7  $FF, $3382
03383: FF FF FF      BBS7  $FF, $3385
03386: FF FF FF      BBS7  $FF, $3388
03389: FF FF FF      BBS7  $FF, $338B
0338C: FF FF FF      BBS7  $FF, $338E
0338F: FF FF FF      BBS7  $FF, $3391
03392: FF FF FF      BBS7  $FF, $3394
03395: FF FF FF      BBS7  $FF, $3397
03398: FF FF FF      BBS7  $FF, $339A
0339B: FF FF FF      BBS7  $FF, $339D
0339E: FF FF FF      BBS7  $FF, $33A0
033A1: FF FF FF      BBS7  $FF, $33A3
033A4: FF FF FF      BBS7  $FF, $33A6
033A7: FF FF FF      BBS7  $FF, $33A9
033AA: FF FF FF      BBS7  $FF, $33AC
033AD: FF FF FF      BBS7  $FF, $33AF
033B0: FF FF FF      BBS7  $FF, $33B2
033B3: FF FF FF      BBS7  $FF, $33B5
033B6: FF FF FF      BBS7  $FF, $33B8
033B9: FF FF FF      BBS7  $FF, $33BB
033BC: FF FF FF      BBS7  $FF, $33BE
033BF: FF FF FF      BBS7  $FF, $33C1
033C2: FF FF FF      BBS7  $FF, $33C4
033C5: FF FF FF      BBS7  $FF, $33C7
033C8: FF FF FF      BBS7  $FF, $33CA
033CB: FF FF FF      BBS7  $FF, $33CD
033CE: FF FF FF      BBS7  $FF, $33D0
033D1: FF FF FF      BBS7  $FF, $33D3
033D4: FF FF FF      BBS7  $FF, $33D6
033D7: FF FF FF      BBS7  $FF, $33D9
033DA: FF FF FF      BBS7  $FF, $33DC
033DD: FF FF FF      BBS7  $FF, $33DF
033E0: FF FF FF      BBS7  $FF, $33E2
033E3: FF FF FF      BBS7  $FF, $33E5
033E6: FF FF FF      BBS7  $FF, $33E8
033E9: FF FF FF      BBS7  $FF, $33EB
033EC: FF FF FF      BBS7  $FF, $33EE
033EF: FF FF FF      BBS7  $FF, $33F1
033F2: FF FF FF      BBS7  $FF, $33F4
033F5: FF FF FF      BBS7  $FF, $33F7
033F8: FF FF FF      BBS7  $FF, $33FA
033FB: FF FF FF      BBS7  $FF, $33FD
033FE: FF FF FF      BBS7  $FF, $3400
03401: FF FF FF      BBS7  $FF, $3403
03404: FF FF FF      BBS7  $FF, $3406
03407: FF FF FF      BBS7  $FF, $3409
0340A: FF FF FF      BBS7  $FF, $340C
0340D: FF FF FF      BBS7  $FF, $340F
03410: FF FF FF      BBS7  $FF, $3412
03413: FF FF FF      BBS7  $FF, $3415
03416: FF FF FF      BBS7  $FF, $3418
03419: FF FF FF      BBS7  $FF, $341B
0341C: FF FF FF      BBS7  $FF, $341E
0341F: FF FF FF      BBS7  $FF, $3421
03422: FF FF FF      BBS7  $FF, $3424
03425: FF FF FF      BBS7  $FF, $3427
03428: FF FF FF      BBS7  $FF, $342A
0342B: FF FF FF      BBS7  $FF, $342D
0342E: FF FF FF      BBS7  $FF, $3430
03431: FF FF FF      BBS7  $FF, $3433
03434: FF FF FF      BBS7  $FF, $3436
03437: FF FF FF      BBS7  $FF, $3439
0343A: FF FF FF      BBS7  $FF, $343C
0343D: FF FF FF      BBS7  $FF, $343F
03440: FF FF FF      BBS7  $FF, $3442
03443: FF FF FF      BBS7  $FF, $3445
03446: FF FF FF      BBS7  $FF, $3448
03449: FF FF FF      BBS7  $FF, $344B
0344C: FF FF FF      BBS7  $FF, $344E
0344F: FF FF FF      BBS7  $FF, $3451
03452: FF FF FF      BBS7  $FF, $3454
03455: FF FF FF      BBS7  $FF, $3457
03458: FF FF FF      BBS7  $FF, $345A
0345B: FF FF FF      BBS7  $FF, $345D
0345E: FF FF FF      BBS7  $FF, $3460
03461: FF FF FF      BBS7  $FF, $3463
03464: FF FF FF      BBS7  $FF, $3466
03467: FF FF FF      BBS7  $FF, $3469
0346A: FF FF FF      BBS7  $FF, $346C
0346D: FF FF FF      BBS7  $FF, $346F
03470: FF FF FF      BBS7  $FF, $3472
03473: FF FF FF      BBS7  $FF, $3475
03476: FF FF FF      BBS7  $FF, $3478
03479: FF FF FF      BBS7  $FF, $347B
0347C: FF FF FF      BBS7  $FF, $347E
0347F: FF FF FF      BBS7  $FF, $3481
03482: FF FF FF      BBS7  $FF, $3484
03485: FF FF FF      BBS7  $FF, $3487
03488: FF FF FF      BBS7  $FF, $348A
0348B: FF FF FF      BBS7  $FF, $348D
0348E: FF FF FF      BBS7  $FF, $3490
03491: FF FF FF      BBS7  $FF, $3493
03494: FF FF FF      BBS7  $FF, $3496
03497: FF FF FF      BBS7  $FF, $3499
0349A: FF FF FF      BBS7  $FF, $349C
0349D: FF FF FF      BBS7  $FF, $349F
034A0: FF FF FF      BBS7  $FF, $34A2
034A3: FF FF FF      BBS7  $FF, $34A5
034A6: FF FF FF      BBS7  $FF, $34A8
034A9: FF FF FF      BBS7  $FF, $34AB
034AC: FF FF FF      BBS7  $FF, $34AE
034AF: FF FF FF      BBS7  $FF, $34B1
034B2: FF FF FF      BBS7  $FF, $34B4
034B5: FF FF FF      BBS7  $FF, $34B7
034B8: FF FF FF      BBS7  $FF, $34BA
034BB: FF FF FF      BBS7  $FF, $34BD
034BE: FF FF FF      BBS7  $FF, $34C0
034C1: FF FF FF      BBS7  $FF, $34C3
034C4: FF FF FF      BBS7  $FF, $34C6
034C7: FF FF FF      BBS7  $FF, $34C9
034CA: FF FF FF      BBS7  $FF, $34CC
034CD: FF FF FF      BBS7  $FF, $34CF
034D0: FF FF FF      BBS7  $FF, $34D2
034D3: FF FF FF      BBS7  $FF, $34D5
034D6: FF FF FF      BBS7  $FF, $34D8
034D9: FF FF FF      BBS7  $FF, $34DB
034DC: FF FF FF      BBS7  $FF, $34DE
034DF: FF FF FF      BBS7  $FF, $34E1
034E2: FF FF FF      BBS7  $FF, $34E4
034E5: FF FF FF      BBS7  $FF, $34E7
034E8: FF FF FF      BBS7  $FF, $34EA
034EB: FF FF FF      BBS7  $FF, $34ED
034EE: FF FF FF      BBS7  $FF, $34F0
034F1: FF FF FF      BBS7  $FF, $34F3
034F4: FF FF FF      BBS7  $FF, $34F6
034F7: FF FF FF      BBS7  $FF, $34F9
034FA: FF FF FF      BBS7  $FF, $34FC
034FD: FF FF FF      BBS7  $FF, $34FF
03500: FF FF FF      BBS7  $FF, $3502
03503: FF FF FF      BBS7  $FF, $3505
03506: FF FF FF      BBS7  $FF, $3508
03509: FF FF FF      BBS7  $FF, $350B
0350C: FF FF FF      BBS7  $FF, $350E
0350F: FF FF FF      BBS7  $FF, $3511
03512: FF FF FF      BBS7  $FF, $3514
03515: FF FF FF      BBS7  $FF, $3517
03518: FF FF FF      BBS7  $FF, $351A
0351B: FF FF FF      BBS7  $FF, $351D
0351E: FF FF FF      BBS7  $FF, $3520
03521: FF FF FF      BBS7  $FF, $3523
03524: FF FF FF      BBS7  $FF, $3526
03527: FF FF FF      BBS7  $FF, $3529
0352A: FF FF FF      BBS7  $FF, $352C
0352D: FF FF FF      BBS7  $FF, $352F
03530: FF FF FF      BBS7  $FF, $3532
03533: FF FF FF      BBS7  $FF, $3535
03536: FF FF FF      BBS7  $FF, $3538
03539: FF FF FF      BBS7  $FF, $353B
0353C: FF FF FF      BBS7  $FF, $353E
0353F: FF FF FF      BBS7  $FF, $3541
03542: FF FF FF      BBS7  $FF, $3544
03545: FF FF FF      BBS7  $FF, $3547
03548: FF FF FF      BBS7  $FF, $354A
0354B: FF FF FF      BBS7  $FF, $354D
0354E: FF FF FF      BBS7  $FF, $3550
03551: FF FF FF      BBS7  $FF, $3553
03554: FF FF FF      BBS7  $FF, $3556
03557: FF FF FF      BBS7  $FF, $3559
0355A: FF FF FF      BBS7  $FF, $355C
0355D: FF FF FF      BBS7  $FF, $355F
03560: FF FF FF      BBS7  $FF, $3562
03563: FF FF FF      BBS7  $FF, $3565
03566: FF FF FF      BBS7  $FF, $3568
03569: FF FF FF      BBS7  $FF, $356B
0356C: FF FF FF      BBS7  $FF, $356E
0356F: FF FF FF      BBS7  $FF, $3571
03572: FF FF FF      BBS7  $FF, $3574
03575: FF FF FF      BBS7  $FF, $3577
03578: FF FF FF      BBS7  $FF, $357A
0357B: FF FF FF      BBS7  $FF, $357D
0357E: FF FF FF      BBS7  $FF, $3580
03581: FF FF FF      BBS7  $FF, $3583
03584: FF FF FF      BBS7  $FF, $3586
03587: FF FF FF      BBS7  $FF, $3589
0358A: FF FF FF      BBS7  $FF, $358C
0358D: FF FF FF      BBS7  $FF, $358F
03590: FF FF FF      BBS7  $FF, $3592
03593: FF FF FF      BBS7  $FF, $3595
03596: FF FF FF      BBS7  $FF, $3598
03599: FF FF FF      BBS7  $FF, $359B
0359C: FF FF FF      BBS7  $FF, $359E
0359F: FF FF FF      BBS7  $FF, $35A1
035A2: FF FF FF      BBS7  $FF, $35A4
035A5: FF FF FF      BBS7  $FF, $35A7
035A8: FF FF FF      BBS7  $FF, $35AA
035AB: FF FF FF      BBS7  $FF, $35AD
035AE: FF FF FF      BBS7  $FF, $35B0
035B1: FF FF FF      BBS7  $FF, $35B3
035B4: FF FF FF      BBS7  $FF, $35B6
035B7: FF FF FF      BBS7  $FF, $35B9
035BA: FF FF FF      BBS7  $FF, $35BC
035BD: FF FF FF      BBS7  $FF, $35BF
035C0: FF FF FF      BBS7  $FF, $35C2
035C3: FF FF FF      BBS7  $FF, $35C5
035C6: FF FF FF      BBS7  $FF, $35C8
035C9: FF FF FF      BBS7  $FF, $35CB
035CC: FF FF FF      BBS7  $FF, $35CE
035CF: FF FF FF      BBS7  $FF, $35D1
035D2: FF FF FF      BBS7  $FF, $35D4
035D5: FF FF FF      BBS7  $FF, $35D7
035D8: FF FF FF      BBS7  $FF, $35DA
035DB: FF FF FF      BBS7  $FF, $35DD
035DE: FF FF FF      BBS7  $FF, $35E0
035E1: FF FF FF      BBS7  $FF, $35E3
035E4: FF FF FF      BBS7  $FF, $35E6
035E7: FF FF FF      BBS7  $FF, $35E9
035EA: FF FF FF      BBS7  $FF, $35EC
035ED: FF FF FF      BBS7  $FF, $35EF
035F0: FF FF FF      BBS7  $FF, $35F2
035F3: FF FF FF      BBS7  $FF, $35F5
035F6: FF FF FF      BBS7  $FF, $35F8
035F9: FF FF FF      BBS7  $FF, $35FB
035FC: FF FF FF      BBS7  $FF, $35FE
035FF: FF FF FF      BBS7  $FF, $3601
03602: FF FF FF      BBS7  $FF, $3604
03605: FF FF FF      BBS7  $FF, $3607
03608: FF FF FF      BBS7  $FF, $360A
0360B: FF FF FF      BBS7  $FF, $360D
0360E: FF FF FF      BBS7  $FF, $3610
03611: FF FF FF      BBS7  $FF, $3613
03614: FF FF FF      BBS7  $FF, $3616
03617: FF FF FF      BBS7  $FF, $3619
0361A: FF FF FF      BBS7  $FF, $361C
0361D: FF FF FF      BBS7  $FF, $361F
03620: FF FF FF      BBS7  $FF, $3622
03623: FF FF FF      BBS7  $FF, $3625
03626: FF FF FF      BBS7  $FF, $3628
03629: FF FF FF      BBS7  $FF, $362B
0362C: FF FF FF      BBS7  $FF, $362E
0362F: FF FF FF      BBS7  $FF, $3631
03632: FF FF FF      BBS7  $FF, $3634
03635: FF FF FF      BBS7  $FF, $3637
03638: FF FF FF      BBS7  $FF, $363A
0363B: FF FF FF      BBS7  $FF, $363D
0363E: FF FF FF      BBS7  $FF, $3640
03641: FF FF FF      BBS7  $FF, $3643
03644: FF FF FF      BBS7  $FF, $3646
03647: FF FF FF      BBS7  $FF, $3649
0364A: FF FF FF      BBS7  $FF, $364C
0364D: FF FF FF      BBS7  $FF, $364F
03650: FF FF FF      BBS7  $FF, $3652
03653: FF FF FF      BBS7  $FF, $3655
03656: FF FF FF      BBS7  $FF, $3658
03659: FF FF FF      BBS7  $FF, $365B
0365C: FF FF FF      BBS7  $FF, $365E
0365F: FF FF FF      BBS7  $FF, $3661
03662: FF FF FF      BBS7  $FF, $3664
03665: FF FF FF      BBS7  $FF, $3667
03668: FF FF FF      BBS7  $FF, $366A
0366B: FF FF FF      BBS7  $FF, $366D
0366E: FF FF FF      BBS7  $FF, $3670
03671: FF FF FF      BBS7  $FF, $3673
03674: FF FF FF      BBS7  $FF, $3676
03677: FF FF FF      BBS7  $FF, $3679
0367A: FF FF FF      BBS7  $FF, $367C
0367D: FF FF FF      BBS7  $FF, $367F
03680: FF FF FF      BBS7  $FF, $3682
03683: FF FF FF      BBS7  $FF, $3685
03686: FF FF FF      BBS7  $FF, $3688
03689: FF FF FF      BBS7  $FF, $368B
0368C: FF FF FF      BBS7  $FF, $368E
0368F: FF FF FF      BBS7  $FF, $3691
03692: FF FF FF      BBS7  $FF, $3694
03695: FF FF FF      BBS7  $FF, $3697
03698: FF FF FF      BBS7  $FF, $369A
0369B: FF FF FF      BBS7  $FF, $369D
0369E: FF FF FF      BBS7  $FF, $36A0
036A1: FF FF FF      BBS7  $FF, $36A3
036A4: FF FF FF      BBS7  $FF, $36A6
036A7: FF FF FF      BBS7  $FF, $36A9
036AA: FF FF FF      BBS7  $FF, $36AC
036AD: FF FF FF      BBS7  $FF, $36AF
036B0: FF FF FF      BBS7  $FF, $36B2
036B3: FF FF FF      BBS7  $FF, $36B5
036B6: FF FF FF      BBS7  $FF, $36B8
036B9: FF FF FF      BBS7  $FF, $36BB
036BC: FF FF FF      BBS7  $FF, $36BE
036BF: FF FF FF      BBS7  $FF, $36C1
036C2: FF FF FF      BBS7  $FF, $36C4
036C5: FF FF FF      BBS7  $FF, $36C7
036C8: FF FF FF      BBS7  $FF, $36CA
036CB: FF FF FF      BBS7  $FF, $36CD
036CE: FF FF FF      BBS7  $FF, $36D0
036D1: FF FF FF      BBS7  $FF, $36D3
036D4: FF FF FF      BBS7  $FF, $36D6
036D7: FF FF FF      BBS7  $FF, $36D9
036DA: FF FF FF      BBS7  $FF, $36DC
036DD: FF FF FF      BBS7  $FF, $36DF
036E0: FF FF FF      BBS7  $FF, $36E2
036E3: FF FF FF      BBS7  $FF, $36E5
036E6: FF FF FF      BBS7  $FF, $36E8
036E9: FF FF FF      BBS7  $FF, $36EB
036EC: FF FF FF      BBS7  $FF, $36EE
036EF: FF FF FF      BBS7  $FF, $36F1
036F2: FF FF FF      BBS7  $FF, $36F4
036F5: FF FF FF      BBS7  $FF, $36F7
036F8: FF FF FF      BBS7  $FF, $36FA
036FB: FF FF FF      BBS7  $FF, $36FD
036FE: FF FF FF      BBS7  $FF, $3700
03701: FF FF FF      BBS7  $FF, $3703
03704: FF FF FF      BBS7  $FF, $3706
03707: FF FF FF      BBS7  $FF, $3709
0370A: FF FF FF      BBS7  $FF, $370C
0370D: FF FF FF      BBS7  $FF, $370F
03710: FF FF FF      BBS7  $FF, $3712
03713: FF FF FF      BBS7  $FF, $3715
03716: FF FF FF      BBS7  $FF, $3718
03719: FF FF FF      BBS7  $FF, $371B
0371C: FF FF FF      BBS7  $FF, $371E
0371F: FF FF FF      BBS7  $FF, $3721
03722: FF FF FF      BBS7  $FF, $3724
03725: FF FF FF      BBS7  $FF, $3727
03728: FF FF FF      BBS7  $FF, $372A
0372B: FF FF FF      BBS7  $FF, $372D
0372E: FF FF FF      BBS7  $FF, $3730
03731: FF FF FF      BBS7  $FF, $3733
03734: FF FF FF      BBS7  $FF, $3736
03737: FF FF FF      BBS7  $FF, $3739
0373A: FF FF FF      BBS7  $FF, $373C
0373D: FF FF FF      BBS7  $FF, $373F
03740: FF FF FF      BBS7  $FF, $3742
03743: FF FF FF      BBS7  $FF, $3745
03746: FF FF FF      BBS7  $FF, $3748
03749: FF FF FF      BBS7  $FF, $374B
0374C: FF FF FF      BBS7  $FF, $374E
0374F: FF FF FF      BBS7  $FF, $3751
03752: FF FF FF      BBS7  $FF, $3754
03755: FF FF FF      BBS7  $FF, $3757
03758: FF FF FF      BBS7  $FF, $375A
0375B: FF FF FF      BBS7  $FF, $375D
0375E: FF FF FF      BBS7  $FF, $3760
03761: FF FF FF      BBS7  $FF, $3763
03764: FF FF FF      BBS7  $FF, $3766
03767: FF FF FF      BBS7  $FF, $3769
0376A: FF FF FF      BBS7  $FF, $376C
0376D: FF FF FF      BBS7  $FF, $376F
03770: FF FF FF      BBS7  $FF, $3772
03773: FF FF FF      BBS7  $FF, $3775
03776: FF FF FF      BBS7  $FF, $3778
03779: FF FF FF      BBS7  $FF, $377B
0377C: FF FF FF      BBS7  $FF, $377E
0377F: FF FF FF      BBS7  $FF, $3781
03782: FF FF FF      BBS7  $FF, $3784
03785: FF FF FF      BBS7  $FF, $3787
03788: FF FF FF      BBS7  $FF, $378A
0378B: FF FF FF      BBS7  $FF, $378D
0378E: FF FF FF      BBS7  $FF, $3790
03791: FF FF FF      BBS7  $FF, $3793
03794: FF FF FF      BBS7  $FF, $3796
03797: FF FF FF      BBS7  $FF, $3799
0379A: FF FF FF      BBS7  $FF, $379C
0379D: FF FF FF      BBS7  $FF, $379F
037A0: FF FF FF      BBS7  $FF, $37A2
037A3: FF FF FF      BBS7  $FF, $37A5
037A6: FF FF FF      BBS7  $FF, $37A8
037A9: FF FF FF      BBS7  $FF, $37AB
037AC: FF FF FF      BBS7  $FF, $37AE
037AF: FF FF FF      BBS7  $FF, $37B1
037B2: FF FF FF      BBS7  $FF, $37B4
037B5: FF FF FF      BBS7  $FF, $37B7
037B8: FF FF FF      BBS7  $FF, $37BA
037BB: FF FF FF      BBS7  $FF, $37BD
037BE: FF FF FF      BBS7  $FF, $37C0
037C1: FF FF FF      BBS7  $FF, $37C3
037C4: FF FF FF      BBS7  $FF, $37C6
037C7: FF FF FF      BBS7  $FF, $37C9
037CA: FF FF FF      BBS7  $FF, $37CC
037CD: FF FF FF      BBS7  $FF, $37CF
037D0: FF FF FF      BBS7  $FF, $37D2
037D3: FF FF FF      BBS7  $FF, $37D5
037D6: FF FF FF      BBS7  $FF, $37D8
037D9: FF FF FF      BBS7  $FF, $37DB
037DC: FF FF FF      BBS7  $FF, $37DE
037DF: FF FF FF      BBS7  $FF, $37E1
037E2: FF FF FF      BBS7  $FF, $37E4
037E5: FF FF FF      BBS7  $FF, $37E7
037E8: FF FF FF      BBS7  $FF, $37EA
037EB: FF FF FF      BBS7  $FF, $37ED
037EE: FF FF FF      BBS7  $FF, $37F0
037F1: FF FF FF      BBS7  $FF, $37F3
037F4: FF FF FF      BBS7  $FF, $37F6
037F7: FF FF FF      BBS7  $FF, $37F9
037FA: FF FF FF      BBS7  $FF, $37FC
037FD: FF FF FF      BBS7  $FF, $37FF
03800: FF FF FF      BBS7  $FF, $3802
03803: FF FF FF      BBS7  $FF, $3805
03806: FF FF FF      BBS7  $FF, $3808
03809: FF FF FF      BBS7  $FF, $380B
0380C: FF FF FF      BBS7  $FF, $380E
0380F: FF FF FF      BBS7  $FF, $3811
03812: FF FF FF      BBS7  $FF, $3814
03815: FF FF FF      BBS7  $FF, $3817
03818: FF FF FF      BBS7  $FF, $381A
0381B: FF FF FF      BBS7  $FF, $381D
0381E: FF FF FF      BBS7  $FF, $3820
03821: FF FF FF      BBS7  $FF, $3823
03824: FF FF FF      BBS7  $FF, $3826
03827: FF FF FF      BBS7  $FF, $3829
0382A: FF FF FF      BBS7  $FF, $382C
0382D: FF FF FF      BBS7  $FF, $382F
03830: FF FF FF      BBS7  $FF, $3832
03833: FF FF FF      BBS7  $FF, $3835
03836: FF FF FF      BBS7  $FF, $3838
03839: FF FF FF      BBS7  $FF, $383B
0383C: FF FF FF      BBS7  $FF, $383E
0383F: FF FF FF      BBS7  $FF, $3841
03842: FF FF FF      BBS7  $FF, $3844
03845: FF FF FF      BBS7  $FF, $3847
03848: FF FF FF      BBS7  $FF, $384A
0384B: FF FF FF      BBS7  $FF, $384D
0384E: FF FF FF      BBS7  $FF, $3850
03851: FF FF FF      BBS7  $FF, $3853
03854: FF FF FF      BBS7  $FF, $3856
03857: FF FF FF      BBS7  $FF, $3859
0385A: FF FF FF      BBS7  $FF, $385C
0385D: FF FF FF      BBS7  $FF, $385F
03860: FF FF FF      BBS7  $FF, $3862
03863: FF FF FF      BBS7  $FF, $3865
03866: FF FF FF      BBS7  $FF, $3868
03869: FF FF FF      BBS7  $FF, $386B
0386C: FF FF FF      BBS7  $FF, $386E
0386F: FF FF FF      BBS7  $FF, $3871
03872: FF FF FF      BBS7  $FF, $3874
03875: FF FF FF      BBS7  $FF, $3877
03878: FF FF FF      BBS7  $FF, $387A
0387B: FF FF FF      BBS7  $FF, $387D
0387E: FF FF FF      BBS7  $FF, $3880
03881: FF FF FF      BBS7  $FF, $3883
03884: FF FF FF      BBS7  $FF, $3886
03887: FF FF FF      BBS7  $FF, $3889
0388A: FF FF FF      BBS7  $FF, $388C
0388D: FF FF FF      BBS7  $FF, $388F
03890: FF FF FF      BBS7  $FF, $3892
03893: FF FF FF      BBS7  $FF, $3895
03896: FF FF FF      BBS7  $FF, $3898
03899: FF FF FF      BBS7  $FF, $389B
0389C: FF FF FF      BBS7  $FF, $389E
0389F: FF FF FF      BBS7  $FF, $38A1
038A2: FF FF FF      BBS7  $FF, $38A4
038A5: FF FF FF      BBS7  $FF, $38A7
038A8: FF FF FF      BBS7  $FF, $38AA
038AB: FF FF FF      BBS7  $FF, $38AD
038AE: FF FF FF      BBS7  $FF, $38B0
038B1: FF FF FF      BBS7  $FF, $38B3
038B4: FF FF FF      BBS7  $FF, $38B6
038B7: FF FF FF      BBS7  $FF, $38B9
038BA: FF FF FF      BBS7  $FF, $38BC
038BD: FF FF FF      BBS7  $FF, $38BF
038C0: FF FF FF      BBS7  $FF, $38C2
038C3: FF FF FF      BBS7  $FF, $38C5
038C6: FF FF FF      BBS7  $FF, $38C8
038C9: FF FF FF      BBS7  $FF, $38CB
038CC: FF FF FF      BBS7  $FF, $38CE
038CF: FF FF FF      BBS7  $FF, $38D1
038D2: FF FF FF      BBS7  $FF, $38D4
038D5: FF FF FF      BBS7  $FF, $38D7
038D8: FF FF FF      BBS7  $FF, $38DA
038DB: FF FF FF      BBS7  $FF, $38DD
038DE: FF FF FF      BBS7  $FF, $38E0
038E1: FF FF FF      BBS7  $FF, $38E3
038E4: FF FF FF      BBS7  $FF, $38E6
038E7: FF FF FF      BBS7  $FF, $38E9
038EA: FF FF FF      BBS7  $FF, $38EC
038ED: FF FF FF      BBS7  $FF, $38EF
038F0: FF FF FF      BBS7  $FF, $38F2
038F3: FF FF FF      BBS7  $FF, $38F5
038F6: FF FF FF      BBS7  $FF, $38F8
038F9: FF FF FF      BBS7  $FF, $38FB
038FC: FF FF FF      BBS7  $FF, $38FE
038FF: FF FF FF      BBS7  $FF, $3901
03902: FF FF FF      BBS7  $FF, $3904
03905: FF FF FF      BBS7  $FF, $3907
03908: FF FF FF      BBS7  $FF, $390A
0390B: FF FF FF      BBS7  $FF, $390D
0390E: FF FF FF      BBS7  $FF, $3910
03911: FF FF FF      BBS7  $FF, $3913
03914: FF FF FF      BBS7  $FF, $3916
03917: FF FF FF      BBS7  $FF, $3919
0391A: FF FF FF      BBS7  $FF, $391C
0391D: FF FF FF      BBS7  $FF, $391F
03920: FF FF FF      BBS7  $FF, $3922
03923: FF FF FF      BBS7  $FF, $3925
03926: FF FF FF      BBS7  $FF, $3928
03929: FF FF FF      BBS7  $FF, $392B
0392C: FF FF FF      BBS7  $FF, $392E
0392F: FF FF FF      BBS7  $FF, $3931
03932: FF FF FF      BBS7  $FF, $3934
03935: FF FF FF      BBS7  $FF, $3937
03938: FF FF FF      BBS7  $FF, $393A
0393B: FF FF FF      BBS7  $FF, $393D
0393E: FF FF FF      BBS7  $FF, $3940
03941: FF FF FF      BBS7  $FF, $3943
03944: FF FF FF      BBS7  $FF, $3946
03947: FF FF FF      BBS7  $FF, $3949
0394A: FF FF FF      BBS7  $FF, $394C
0394D: FF FF FF      BBS7  $FF, $394F
03950: FF FF FF      BBS7  $FF, $3952
03953: FF FF FF      BBS7  $FF, $3955
03956: FF FF FF      BBS7  $FF, $3958
03959: FF FF FF      BBS7  $FF, $395B
0395C: FF FF FF      BBS7  $FF, $395E
0395F: FF FF FF      BBS7  $FF, $3961
03962: FF FF FF      BBS7  $FF, $3964
03965: FF FF FF      BBS7  $FF, $3967
03968: FF FF FF      BBS7  $FF, $396A
0396B: FF FF FF      BBS7  $FF, $396D
0396E: FF FF FF      BBS7  $FF, $3970
03971: FF FF FF      BBS7  $FF, $3973
03974: FF FF FF      BBS7  $FF, $3976
03977: FF FF FF      BBS7  $FF, $3979
0397A: FF FF FF      BBS7  $FF, $397C
0397D: FF FF FF      BBS7  $FF, $397F
03980: FF FF FF      BBS7  $FF, $3982
03983: FF FF FF      BBS7  $FF, $3985
03986: FF FF FF      BBS7  $FF, $3988
03989: FF FF FF      BBS7  $FF, $398B
0398C: FF FF FF      BBS7  $FF, $398E
0398F: FF FF FF      BBS7  $FF, $3991
03992: FF FF FF      BBS7  $FF, $3994
03995: FF FF FF      BBS7  $FF, $3997
03998: FF FF FF      BBS7  $FF, $399A
0399B: FF FF FF      BBS7  $FF, $399D
0399E: FF FF FF      BBS7  $FF, $39A0
039A1: FF FF FF      BBS7  $FF, $39A3
039A4: FF FF FF      BBS7  $FF, $39A6
039A7: FF FF FF      BBS7  $FF, $39A9
039AA: FF FF FF      BBS7  $FF, $39AC
039AD: FF FF FF      BBS7  $FF, $39AF
039B0: FF FF FF      BBS7  $FF, $39B2
039B3: FF FF FF      BBS7  $FF, $39B5
039B6: FF FF FF      BBS7  $FF, $39B8
039B9: FF FF FF      BBS7  $FF, $39BB
039BC: FF FF FF      BBS7  $FF, $39BE
039BF: FF FF FF      BBS7  $FF, $39C1
039C2: FF FF FF      BBS7  $FF, $39C4
039C5: FF FF FF      BBS7  $FF, $39C7
039C8: FF FF FF      BBS7  $FF, $39CA
039CB: FF FF FF      BBS7  $FF, $39CD
039CE: FF FF FF      BBS7  $FF, $39D0
039D1: FF FF FF      BBS7  $FF, $39D3
039D4: FF FF FF      BBS7  $FF, $39D6
039D7: FF FF FF      BBS7  $FF, $39D9
039DA: FF FF FF      BBS7  $FF, $39DC
039DD: FF FF FF      BBS7  $FF, $39DF
039E0: FF FF FF      BBS7  $FF, $39E2
039E3: FF FF FF      BBS7  $FF, $39E5
039E6: FF FF FF      BBS7  $FF, $39E8
039E9: FF FF FF      BBS7  $FF, $39EB
039EC: FF FF FF      BBS7  $FF, $39EE
039EF: FF FF FF      BBS7  $FF, $39F1
039F2: FF FF FF      BBS7  $FF, $39F4
039F5: FF FF FF      BBS7  $FF, $39F7
039F8: FF FF FF      BBS7  $FF, $39FA
039FB: FF FF FF      BBS7  $FF, $39FD
039FE: FF FF FF      BBS7  $FF, $3A00
03A01: FF FF FF      BBS7  $FF, $3A03
03A04: FF FF FF      BBS7  $FF, $3A06
03A07: FF FF FF      BBS7  $FF, $3A09
03A0A: FF FF FF      BBS7  $FF, $3A0C
03A0D: FF FF FF      BBS7  $FF, $3A0F
03A10: FF FF FF      BBS7  $FF, $3A12
03A13: FF FF FF      BBS7  $FF, $3A15
03A16: FF FF FF      BBS7  $FF, $3A18
03A19: FF FF FF      BBS7  $FF, $3A1B
03A1C: FF FF FF      BBS7  $FF, $3A1E
03A1F: FF FF FF      BBS7  $FF, $3A21
03A22: FF FF FF      BBS7  $FF, $3A24
03A25: FF FF FF      BBS7  $FF, $3A27
03A28: FF FF FF      BBS7  $FF, $3A2A
03A2B: FF FF FF      BBS7  $FF, $3A2D
03A2E: FF FF FF      BBS7  $FF, $3A30
03A31: FF FF FF      BBS7  $FF, $3A33
03A34: FF FF FF      BBS7  $FF, $3A36
03A37: FF FF FF      BBS7  $FF, $3A39
03A3A: FF FF FF      BBS7  $FF, $3A3C
03A3D: FF FF FF      BBS7  $FF, $3A3F
03A40: FF FF FF      BBS7  $FF, $3A42
03A43: FF FF FF      BBS7  $FF, $3A45
03A46: FF FF FF      BBS7  $FF, $3A48
03A49: FF FF FF      BBS7  $FF, $3A4B
03A4C: FF FF FF      BBS7  $FF, $3A4E
03A4F: FF FF FF      BBS7  $FF, $3A51
03A52: FF FF FF      BBS7  $FF, $3A54
03A55: FF FF FF      BBS7  $FF, $3A57
03A58: FF FF FF      BBS7  $FF, $3A5A
03A5B: FF FF FF      BBS7  $FF, $3A5D
03A5E: FF FF FF      BBS7  $FF, $3A60
03A61: FF FF FF      BBS7  $FF, $3A63
03A64: FF FF FF      BBS7  $FF, $3A66
03A67: FF FF FF      BBS7  $FF, $3A69
03A6A: FF FF FF      BBS7  $FF, $3A6C
03A6D: FF FF FF      BBS7  $FF, $3A6F
03A70: FF FF FF      BBS7  $FF, $3A72
03A73: FF FF FF      BBS7  $FF, $3A75
03A76: FF FF FF      BBS7  $FF, $3A78
03A79: FF FF FF      BBS7  $FF, $3A7B
03A7C: FF FF FF      BBS7  $FF, $3A7E
03A7F: FF FF FF      BBS7  $FF, $3A81
03A82: FF FF FF      BBS7  $FF, $3A84
03A85: FF FF FF      BBS7  $FF, $3A87
03A88: FF FF FF      BBS7  $FF, $3A8A
03A8B: FF FF FF      BBS7  $FF, $3A8D
03A8E: FF FF FF      BBS7  $FF, $3A90
03A91: FF FF FF      BBS7  $FF, $3A93
03A94: FF FF FF      BBS7  $FF, $3A96
03A97: FF FF FF      BBS7  $FF, $3A99
03A9A: FF FF FF      BBS7  $FF, $3A9C
03A9D: FF FF FF      BBS7  $FF, $3A9F
03AA0: FF FF FF      BBS7  $FF, $3AA2
03AA3: FF FF FF      BBS7  $FF, $3AA5
03AA6: FF FF FF      BBS7  $FF, $3AA8
03AA9: FF FF FF      BBS7  $FF, $3AAB
03AAC: FF FF FF      BBS7  $FF, $3AAE
03AAF: FF FF FF      BBS7  $FF, $3AB1
03AB2: FF FF FF      BBS7  $FF, $3AB4
03AB5: FF FF FF      BBS7  $FF, $3AB7
03AB8: FF FF FF      BBS7  $FF, $3ABA
03ABB: FF FF FF      BBS7  $FF, $3ABD
03ABE: FF FF FF      BBS7  $FF, $3AC0
03AC1: FF FF FF      BBS7  $FF, $3AC3
03AC4: FF FF FF      BBS7  $FF, $3AC6
03AC7: FF FF FF      BBS7  $FF, $3AC9
03ACA: FF FF FF      BBS7  $FF, $3ACC
03ACD: FF FF FF      BBS7  $FF, $3ACF
03AD0: FF FF FF      BBS7  $FF, $3AD2
03AD3: FF FF FF      BBS7  $FF, $3AD5
03AD6: FF FF FF      BBS7  $FF, $3AD8
03AD9: FF FF FF      BBS7  $FF, $3ADB
03ADC: FF FF FF      BBS7  $FF, $3ADE
03ADF: FF FF FF      BBS7  $FF, $3AE1
03AE2: FF FF FF      BBS7  $FF, $3AE4
03AE5: FF FF FF      BBS7  $FF, $3AE7
03AE8: FF FF FF      BBS7  $FF, $3AEA
03AEB: FF FF FF      BBS7  $FF, $3AED
03AEE: FF FF FF      BBS7  $FF, $3AF0
03AF1: FF FF FF      BBS7  $FF, $3AF3
03AF4: FF FF FF      BBS7  $FF, $3AF6
03AF7: FF FF FF      BBS7  $FF, $3AF9
03AFA: FF FF FF      BBS7  $FF, $3AFC
03AFD: FF FF FF      BBS7  $FF, $3AFF
03B00: FF FF FF      BBS7  $FF, $3B02
03B03: FF FF FF      BBS7  $FF, $3B05
03B06: FF FF FF      BBS7  $FF, $3B08
03B09: FF FF FF      BBS7  $FF, $3B0B
03B0C: FF FF FF      BBS7  $FF, $3B0E
03B0F: FF FF FF      BBS7  $FF, $3B11
03B12: FF FF FF      BBS7  $FF, $3B14
03B15: FF FF FF      BBS7  $FF, $3B17
03B18: FF FF FF      BBS7  $FF, $3B1A
03B1B: FF FF FF      BBS7  $FF, $3B1D
03B1E: FF FF FF      BBS7  $FF, $3B20
03B21: FF FF FF      BBS7  $FF, $3B23
03B24: FF FF FF      BBS7  $FF, $3B26
03B27: FF FF FF      BBS7  $FF, $3B29
03B2A: FF FF FF      BBS7  $FF, $3B2C
03B2D: FF FF FF      BBS7  $FF, $3B2F
03B30: FF FF FF      BBS7  $FF, $3B32
03B33: FF FF FF      BBS7  $FF, $3B35
03B36: FF FF FF      BBS7  $FF, $3B38
03B39: FF FF FF      BBS7  $FF, $3B3B
03B3C: FF FF FF      BBS7  $FF, $3B3E
03B3F: FF FF FF      BBS7  $FF, $3B41
03B42: FF FF FF      BBS7  $FF, $3B44
03B45: FF FF FF      BBS7  $FF, $3B47
03B48: FF FF FF      BBS7  $FF, $3B4A
03B4B: FF FF FF      BBS7  $FF, $3B4D
03B4E: FF FF FF      BBS7  $FF, $3B50
03B51: FF FF FF      BBS7  $FF, $3B53
03B54: FF FF FF      BBS7  $FF, $3B56
03B57: FF FF FF      BBS7  $FF, $3B59
03B5A: FF FF FF      BBS7  $FF, $3B5C
03B5D: FF FF FF      BBS7  $FF, $3B5F
03B60: FF FF FF      BBS7  $FF, $3B62
03B63: FF FF FF      BBS7  $FF, $3B65
03B66: FF FF FF      BBS7  $FF, $3B68
03B69: FF FF FF      BBS7  $FF, $3B6B
03B6C: FF FF FF      BBS7  $FF, $3B6E
03B6F: FF FF FF      BBS7  $FF, $3B71
03B72: FF FF FF      BBS7  $FF, $3B74
03B75: FF FF FF      BBS7  $FF, $3B77
03B78: FF FF FF      BBS7  $FF, $3B7A
03B7B: FF FF FF      BBS7  $FF, $3B7D
03B7E: FF FF FF      BBS7  $FF, $3B80
03B81: FF FF FF      BBS7  $FF, $3B83
03B84: FF FF FF      BBS7  $FF, $3B86
03B87: FF FF FF      BBS7  $FF, $3B89
03B8A: FF FF FF      BBS7  $FF, $3B8C
03B8D: FF FF FF      BBS7  $FF, $3B8F
03B90: FF FF FF      BBS7  $FF, $3B92
03B93: FF FF FF      BBS7  $FF, $3B95
03B96: FF FF FF      BBS7  $FF, $3B98
03B99: FF FF FF      BBS7  $FF, $3B9B
03B9C: FF FF FF      BBS7  $FF, $3B9E
03B9F: FF FF FF      BBS7  $FF, $3BA1
03BA2: FF FF FF      BBS7  $FF, $3BA4
03BA5: FF FF FF      BBS7  $FF, $3BA7
03BA8: FF FF FF      BBS7  $FF, $3BAA
03BAB: FF FF FF      BBS7  $FF, $3BAD
03BAE: FF FF FF      BBS7  $FF, $3BB0
03BB1: FF FF FF      BBS7  $FF, $3BB3
03BB4: FF FF FF      BBS7  $FF, $3BB6
03BB7: FF FF FF      BBS7  $FF, $3BB9
03BBA: FF FF FF      BBS7  $FF, $3BBC
03BBD: FF FF FF      BBS7  $FF, $3BBF
03BC0: FF FF FF      BBS7  $FF, $3BC2
03BC3: FF FF FF      BBS7  $FF, $3BC5
03BC6: FF FF FF      BBS7  $FF, $3BC8
03BC9: FF FF FF      BBS7  $FF, $3BCB
03BCC: FF FF FF      BBS7  $FF, $3BCE
03BCF: FF FF FF      BBS7  $FF, $3BD1
03BD2: FF FF FF      BBS7  $FF, $3BD4
03BD5: FF FF FF      BBS7  $FF, $3BD7
03BD8: FF FF FF      BBS7  $FF, $3BDA
03BDB: FF FF FF      BBS7  $FF, $3BDD
03BDE: FF FF FF      BBS7  $FF, $3BE0
03BE1: FF FF FF      BBS7  $FF, $3BE3
03BE4: FF FF FF      BBS7  $FF, $3BE6
03BE7: FF FF FF      BBS7  $FF, $3BE9
03BEA: FF FF FF      BBS7  $FF, $3BEC
03BED: FF FF FF      BBS7  $FF, $3BEF
03BF0: FF FF FF      BBS7  $FF, $3BF2
03BF3: FF FF FF      BBS7  $FF, $3BF5
03BF6: FF FF FF      BBS7  $FF, $3BF8
03BF9: FF FF FF      BBS7  $FF, $3BFB
03BFC: FF FF FF      BBS7  $FF, $3BFE
03BFF: FF FF FF      BBS7  $FF, $3C01
03C02: FF FF FF      BBS7  $FF, $3C04
03C05: FF FF FF      BBS7  $FF, $3C07
03C08: FF FF FF      BBS7  $FF, $3C0A
03C0B: FF FF FF      BBS7  $FF, $3C0D
03C0E: FF FF FF      BBS7  $FF, $3C10
03C11: FF FF FF      BBS7  $FF, $3C13
03C14: FF FF FF      BBS7  $FF, $3C16
03C17: FF FF FF      BBS7  $FF, $3C19
03C1A: FF FF FF      BBS7  $FF, $3C1C
03C1D: FF FF FF      BBS7  $FF, $3C1F
03C20: FF FF FF      BBS7  $FF, $3C22
03C23: FF FF FF      BBS7  $FF, $3C25
03C26: FF FF FF      BBS7  $FF, $3C28
03C29: FF FF FF      BBS7  $FF, $3C2B
03C2C: FF FF FF      BBS7  $FF, $3C2E
03C2F: FF FF FF      BBS7  $FF, $3C31
03C32: FF FF FF      BBS7  $FF, $3C34
03C35: FF FF FF      BBS7  $FF, $3C37
03C38: FF FF FF      BBS7  $FF, $3C3A
03C3B: FF FF FF      BBS7  $FF, $3C3D
03C3E: FF FF FF      BBS7  $FF, $3C40
03C41: FF FF FF      BBS7  $FF, $3C43
03C44: FF FF FF      BBS7  $FF, $3C46
03C47: FF FF FF      BBS7  $FF, $3C49
03C4A: FF FF FF      BBS7  $FF, $3C4C
03C4D: FF FF FF      BBS7  $FF, $3C4F
03C50: FF FF FF      BBS7  $FF, $3C52
03C53: FF FF FF      BBS7  $FF, $3C55
03C56: FF FF FF      BBS7  $FF, $3C58
03C59: FF FF FF      BBS7  $FF, $3C5B
03C5C: FF FF FF      BBS7  $FF, $3C5E
03C5F: FF FF FF      BBS7  $FF, $3C61
03C62: FF FF FF      BBS7  $FF, $3C64
03C65: FF FF FF      BBS7  $FF, $3C67
03C68: FF FF FF      BBS7  $FF, $3C6A
03C6B: FF FF FF      BBS7  $FF, $3C6D
03C6E: FF FF FF      BBS7  $FF, $3C70
03C71: FF FF FF      BBS7  $FF, $3C73
03C74: FF FF FF      BBS7  $FF, $3C76
03C77: 4C 9E CC      JMP   $CC9E
03C7A: FF FF FF      BBS7  $FF, $3C7C
03C7D: FF FF FF      BBS7  $FF, $3C7F
03C80: FF FF FF      BBS7  $FF, $3C82
03C83: FF FF FF      BBS7  $FF, $3C85
03C86: FF FF FF      BBS7  $FF, $3C88
03C89: FF FF FF      BBS7  $FF, $3C8B
03C8C: FF FF FF      BBS7  $FF, $3C8E
03C8F: FF FF FF      BBS7  $FF, $3C91
03C92: FF FF FF      BBS7  $FF, $3C94
03C95: FF FF FF      BBS7  $FF, $3C97
03C98: FF FF FF      BBS7  $FF, $3C9A
03C9B: FF FF FF      BBS7  $FF, $3C9D
03C9E: FF FF FF      BBS7  $FF, $3CA0
03CA1: FF FF FF      BBS7  $FF, $3CA3
03CA4: FF FF FF      BBS7  $FF, $3CA6
03CA7: FF FF FF      BBS7  $FF, $3CA9
03CAA: FF FF FF      BBS7  $FF, $3CAC
03CAD: FF FF FF      BBS7  $FF, $3CAF
03CB0: FF FF FF      BBS7  $FF, $3CB2
03CB3: FF FF FF      BBS7  $FF, $3CB5
03CB6: FF FF FF      BBS7  $FF, $3CB8
03CB9: FF FF FF      BBS7  $FF, $3CBB
03CBC: FF FF FF      BBS7  $FF, $3CBE
03CBF: FF FF FF      BBS7  $FF, $3CC1
03CC2: FF FF FF      BBS7  $FF, $3CC4
03CC5: FF FF FF      BBS7  $FF, $3CC7
03CC8: FF FF FF      BBS7  $FF, $3CCA
03CCB: FF FF FF      BBS7  $FF, $3CCD
03CCE: FF FF FF      BBS7  $FF, $3CD0
03CD1: FF FF FF      BBS7  $FF, $3CD3
03CD4: FF FF FF      BBS7  $FF, $3CD6
03CD7: FF FF FF      BBS7  $FF, $3CD9
03CDA: FF FF FF      BBS7  $FF, $3CDC
03CDD: FF FF FF      BBS7  $FF, $3CDF
03CE0: FF FF FF      BBS7  $FF, $3CE2
03CE3: FF FF FF      BBS7  $FF, $3CE5
03CE6: FF FF FF      BBS7  $FF, $3CE8
03CE9: FF FF FF      BBS7  $FF, $3CEB
03CEC: FF FF FF      BBS7  $FF, $3CEE
03CEF: FF FF FF      BBS7  $FF, $3CF1
03CF2: FF FF FF      BBS7  $FF, $3CF4
03CF5: FF FF FF      BBS7  $FF, $3CF7
03CF8: FF FF FF      BBS7  $FF, $3CFA
03CFB: FF FF FF      BBS7  $FF, $3CFD
03CFE: FF FF FF      BBS7  $FF, $3D00
03D01: FF FF FF      BBS7  $FF, $3D03
03D04: FF FF FF      BBS7  $FF, $3D06
03D07: FF FF FF      BBS7  $FF, $3D09
03D0A: FF FF FF      BBS7  $FF, $3D0C
03D0D: FF FF FF      BBS7  $FF, $3D0F
03D10: FF FF FF      BBS7  $FF, $3D12
03D13: FF FF FF      BBS7  $FF, $3D15
03D16: FF FF FF      BBS7  $FF, $3D18
03D19: FF FF FF      BBS7  $FF, $3D1B
03D1C: FF FF FF      BBS7  $FF, $3D1E
03D1F: FF FF FF      BBS7  $FF, $3D21
03D22: FF FF FF      BBS7  $FF, $3D24
03D25: FF FF FF      BBS7  $FF, $3D27
03D28: FF FF FF      BBS7  $FF, $3D2A
03D2B: FF FF FF      BBS7  $FF, $3D2D
03D2E: FF FF FF      BBS7  $FF, $3D30
03D31: FF FF FF      BBS7  $FF, $3D33
03D34: FF FF FF      BBS7  $FF, $3D36
03D37: FF FF FF      BBS7  $FF, $3D39
03D3A: FF FF FF      BBS7  $FF, $3D3C
03D3D: FF FF FF      BBS7  $FF, $3D3F
03D40: FF FF FF      BBS7  $FF, $3D42
03D43: FF FF FF      BBS7  $FF, $3D45
03D46: FF FF FF      BBS7  $FF, $3D48
03D49: FF FF FF      BBS7  $FF, $3D4B
03D4C: FF FF FF      BBS7  $FF, $3D4E
03D4F: FF FF FF      BBS7  $FF, $3D51
03D52: FF FF FF      BBS7  $FF, $3D54
03D55: FF FF FF      BBS7  $FF, $3D57
03D58: FF FF FF      BBS7  $FF, $3D5A
03D5B: FF FF FF      BBS7  $FF, $3D5D
03D5E: FF FF FF      BBS7  $FF, $3D60
03D61: FF FF FF      BBS7  $FF, $3D63
03D64: FF FF FF      BBS7  $FF, $3D66
03D67: FF FF FF      BBS7  $FF, $3D69
03D6A: FF FF FF      BBS7  $FF, $3D6C
03D6D: FF FF FF      BBS7  $FF, $3D6F
03D70: FF FF FF      BBS7  $FF, $3D72
03D73: FF FF FF      BBS7  $FF, $3D75
03D76: FF FF FF      BBS7  $FF, $3D78
03D79: FF FF FF      BBS7  $FF, $3D7B
03D7C: FF FF FF      BBS7  $FF, $3D7E
03D7F: FF FF FF      BBS7  $FF, $3D81
03D82: FF FF FF      BBS7  $FF, $3D84
03D85: FF FF FF      BBS7  $FF, $3D87
03D88: FF FF FF      BBS7  $FF, $3D8A
03D8B: FF FF FF      BBS7  $FF, $3D8D
03D8E: FF FF FF      BBS7  $FF, $3D90
03D91: FF FF FF      BBS7  $FF, $3D93
03D94: FF FF FF      BBS7  $FF, $3D96
03D97: FF FF FF      BBS7  $FF, $3D99
03D9A: FF FF FF      BBS7  $FF, $3D9C
03D9D: FF FF FF      BBS7  $FF, $3D9F
03DA0: FF FF FF      BBS7  $FF, $3DA2
03DA3: FF FF FF      BBS7  $FF, $3DA5
03DA6: FF FF FF      BBS7  $FF, $3DA8
03DA9: FF FF FF      BBS7  $FF, $3DAB
03DAC: FF FF FF      BBS7  $FF, $3DAE
03DAF: FF FF FF      BBS7  $FF, $3DB1
03DB2: FF FF FF      BBS7  $FF, $3DB4
03DB5: FF FF FF      BBS7  $FF, $3DB7
03DB8: FF FF FF      BBS7  $FF, $3DBA
03DBB: FF FF FF      BBS7  $FF, $3DBD
03DBE: FF FF FF      BBS7  $FF, $3DC0
03DC1: FF FF FF      BBS7  $FF, $3DC3
03DC4: FF FF FF      BBS7  $FF, $3DC6
03DC7: FF FF FF      BBS7  $FF, $3DC9
03DCA: FF FF FF      BBS7  $FF, $3DCC
03DCD: FF FF FF      BBS7  $FF, $3DCF
03DD0: FF FF FF      BBS7  $FF, $3DD2
03DD3: FF FF FF      BBS7  $FF, $3DD5
03DD6: FF FF FF      BBS7  $FF, $3DD8
03DD9: FF FF FF      BBS7  $FF, $3DDB
03DDC: FF FF FF      BBS7  $FF, $3DDE
03DDF: FF FF FF      BBS7  $FF, $3DE1
03DE2: FF FF FF      BBS7  $FF, $3DE4
03DE5: FF FF FF      BBS7  $FF, $3DE7
03DE8: FF FF FF      BBS7  $FF, $3DEA
03DEB: FF FF FF      BBS7  $FF, $3DED
03DEE: FF FF FF      BBS7  $FF, $3DF0
03DF1: FF FF FF      BBS7  $FF, $3DF3
03DF4: FF FF FF      BBS7  $FF, $3DF6
03DF7: FF FF FF      BBS7  $FF, $3DF9
03DFA: FF FF FF      BBS7  $FF, $3DFC
03DFD: FF FF FF      BBS7  $FF, $3DFF
03E00: FF FF FF      BBS7  $FF, $3E02
03E03: FF FF FF      BBS7  $FF, $3E05
03E06: FF FF FF      BBS7  $FF, $3E08
03E09: FF FF FF      BBS7  $FF, $3E0B
03E0C: FF FF FF      BBS7  $FF, $3E0E
03E0F: FF FF FF      BBS7  $FF, $3E11
03E12: FF FF FF      BBS7  $FF, $3E14
03E15: FF FF FF      BBS7  $FF, $3E17
03E18: FF FF FF      BBS7  $FF, $3E1A
03E1B: FF FF FF      BBS7  $FF, $3E1D
03E1E: FF FF FF      BBS7  $FF, $3E20
03E21: FF FF FF      BBS7  $FF, $3E23
03E24: FF FF FF      BBS7  $FF, $3E26
03E27: FF FF FF      BBS7  $FF, $3E29
03E2A: FF FF FF      BBS7  $FF, $3E2C
03E2D: FF FF FF      BBS7  $FF, $3E2F
03E30: FF FF FF      BBS7  $FF, $3E32
03E33: FF FF FF      BBS7  $FF, $3E35
03E36: FF FF FF      BBS7  $FF, $3E38
03E39: FF FF FF      BBS7  $FF, $3E3B
03E3C: FF FF FF      BBS7  $FF, $3E3E
03E3F: FF FF FF      BBS7  $FF, $3E41
03E42: FF FF FF      BBS7  $FF, $3E44
03E45: FF FF FF      BBS7  $FF, $3E47
03E48: FF FF FF      BBS7  $FF, $3E4A
03E4B: FF FF FF      BBS7  $FF, $3E4D
03E4E: FF FF FF      BBS7  $FF, $3E50
03E51: FF FF FF      BBS7  $FF, $3E53
03E54: FF FF FF      BBS7  $FF, $3E56
03E57: FF FF FF      BBS7  $FF, $3E59
03E5A: FF FF FF      BBS7  $FF, $3E5C
03E5D: FF FF FF      BBS7  $FF, $3E5F
03E60: FF FF FF      BBS7  $FF, $3E62
03E63: FF FF FF      BBS7  $FF, $3E65
03E66: FF FF FF      BBS7  $FF, $3E68
03E69: FF FF FF      BBS7  $FF, $3E6B
03E6C: FF FF FF      BBS7  $FF, $3E6E
03E6F: FF FF FF      BBS7  $FF, $3E71
03E72: FF FF FF      BBS7  $FF, $3E74
03E75: FF FF FF      BBS7  $FF, $3E77
03E78: FF FF FF      BBS7  $FF, $3E7A
03E7B: FF FF FF      BBS7  $FF, $3E7D
03E7E: FF FF FF      BBS7  $FF, $3E80
03E81: FF FF FF      BBS7  $FF, $3E83
03E84: FF FF FF      BBS7  $FF, $3E86
03E87: FF FF FF      BBS7  $FF, $3E89
03E8A: FF FF FF      BBS7  $FF, $3E8C
03E8D: FF FF FF      BBS7  $FF, $3E8F
03E90: FF FF FF      BBS7  $FF, $3E92
03E93: FF FF FF      BBS7  $FF, $3E95
03E96: FF FF FF      BBS7  $FF, $3E98
03E99: FF FF FF      BBS7  $FF, $3E9B
03E9C: FF FF FF      BBS7  $FF, $3E9E
03E9F: FF FF FF      BBS7  $FF, $3EA1
03EA2: FF FF FF      BBS7  $FF, $3EA4
03EA5: FF FF FF      BBS7  $FF, $3EA7
03EA8: FF FF FF      BBS7  $FF, $3EAA
03EAB: FF FF FF      BBS7  $FF, $3EAD
03EAE: FF FF FF      BBS7  $FF, $3EB0
03EB1: FF FF FF      BBS7  $FF, $3EB3
03EB4: FF FF FF      BBS7  $FF, $3EB6
03EB7: FF FF FF      BBS7  $FF, $3EB9
03EBA: FF FF FF      BBS7  $FF, $3EBC
03EBD: FF FF FF      BBS7  $FF, $3EBF
03EC0: FF FF FF      BBS7  $FF, $3EC2
03EC3: FF FF FF      BBS7  $FF, $3EC5
03EC6: FF FF FF      BBS7  $FF, $3EC8
03EC9: FF FF FF      BBS7  $FF, $3ECB
03ECC: FF FF FF      BBS7  $FF, $3ECE
03ECF: FF FF FF      BBS7  $FF, $3ED1
03ED2: FF FF FF      BBS7  $FF, $3ED4
03ED5: FF FF FF      BBS7  $FF, $3ED7
03ED8: FF FF FF      BBS7  $FF, $3EDA
03EDB: FF FF FF      BBS7  $FF, $3EDD
03EDE: FF FF FF      BBS7  $FF, $3EE0
03EE1: FF FF FF      BBS7  $FF, $3EE3
03EE4: FF FF FF      BBS7  $FF, $3EE6
03EE7: FF FF FF      BBS7  $FF, $3EE9
03EEA: FF FF FF      BBS7  $FF, $3EEC
03EED: FF FF FF      BBS7  $FF, $3EEF
03EF0: FF FF FF      BBS7  $FF, $3EF2
03EF3: FF FF FF      BBS7  $FF, $3EF5
03EF6: FF FF FF      BBS7  $FF, $3EF8
03EF9: FF FF FF      BBS7  $FF, $3EFB
03EFC: FF FF FF      BBS7  $FF, $3EFE
03EFF: FF FF FF      BBS7  $FF, $3F01
03F02: FF FF FF      BBS7  $FF, $3F04
03F05: FF FF FF      BBS7  $FF, $3F07
03F08: FF FF FF      BBS7  $FF, $3F0A
03F0B: FF FF FF      BBS7  $FF, $3F0D
03F0E: FF FF FF      BBS7  $FF, $3F10
03F11: FF FF FF      BBS7  $FF, $3F13
03F14: FF FF FF      BBS7  $FF, $3F16
03F17: FF FF FF      BBS7  $FF, $3F19
03F1A: FF FF FF      BBS7  $FF, $3F1C
03F1D: FF FF FF      BBS7  $FF, $3F1F
03F20: FF FF FF      BBS7  $FF, $3F22
03F23: FF FF FF      BBS7  $FF, $3F25
03F26: FF FF FF      BBS7  $FF, $3F28
03F29: FF FF FF      BBS7  $FF, $3F2B
03F2C: FF FF FF      BBS7  $FF, $3F2E
03F2F: FF FF FF      BBS7  $FF, $3F31
03F32: FF FF FF      BBS7  $FF, $3F34
03F35: FF FF FF      BBS7  $FF, $3F37
03F38: FF FF FF      BBS7  $FF, $3F3A
03F3B: FF FF FF      BBS7  $FF, $3F3D
03F3E: FF FF FF      BBS7  $FF, $3F40
03F41: FF FF FF      BBS7  $FF, $3F43
03F44: FF FF FF      BBS7  $FF, $3F46
03F47: FF FF FF      BBS7  $FF, $3F49
03F4A: FF FF FF      BBS7  $FF, $3F4C
03F4D: FF FF FF      BBS7  $FF, $3F4F
03F50: FF FF FF      BBS7  $FF, $3F52
03F53: FF FF FF      BBS7  $FF, $3F55
03F56: FF FF FF      BBS7  $FF, $3F58
03F59: FF FF FF      BBS7  $FF, $3F5B
03F5C: FF FF FF      BBS7  $FF, $3F5E
03F5F: FF FF FF      BBS7  $FF, $3F61
03F62: FF FF FF      BBS7  $FF, $3F64
03F65: FF FF FF      BBS7  $FF, $3F67
03F68: FF FF FF      BBS7  $FF, $3F6A
03F6B: FF FF FF      BBS7  $FF, $3F6D
03F6E: FF FF FF      BBS7  $FF, $3F70
03F71: FF FF FF      BBS7  $FF, $3F73
03F74: FF FF FF      BBS7  $FF, $3F76
03F77: FF FF FF      BBS7  $FF, $3F79
03F7A: FF FF FF      BBS7  $FF, $3F7C
03F7D: FF FF FF      BBS7  $FF, $3F7F
03F80: FF FF FF      BBS7  $FF, $3F82
03F83: FF FF FF      BBS7  $FF, $3F85
03F86: FF FF FF      BBS7  $FF, $3F88
03F89: FF FF FF      BBS7  $FF, $3F8B
03F8C: FF FF FF      BBS7  $FF, $3F8E
03F8F: FF FF FF      BBS7  $FF, $3F91
03F92: FF FF FF      BBS7  $FF, $3F94
03F95: FF FF FF      BBS7  $FF, $3F97
03F98: FF FF FF      BBS7  $FF, $3F9A
03F9B: FF FF FF      BBS7  $FF, $3F9D
03F9E: FF FF FF      BBS7  $FF, $3FA0
03FA1: FF FF FF      BBS7  $FF, $3FA3
03FA4: FF FF FF      BBS7  $FF, $3FA6
03FA7: FF FF FF      BBS7  $FF, $3FA9
03FAA: FF FF FF      BBS7  $FF, $3FAC
03FAD: FF FF FF      BBS7  $FF, $3FAF
03FB0: FF FF FF      BBS7  $FF, $3FB2
03FB3: FF FF FF      BBS7  $FF, $3FB5
03FB6: FF FF FF      BBS7  $FF, $3FB8
03FB9: FF FF FF      BBS7  $FF, $3FBB
03FBC: FF FF FF      BBS7  $FF, $3FBE
03FBF: FF FF FF      BBS7  $FF, $3FC1
03FC2: FF FF FF      BBS7  $FF, $3FC4
03FC5: FF FF FF      BBS7  $FF, $3FC7
03FC8: FF FF FF      BBS7  $FF, $3FCA
03FCB: FF FF FF      BBS7  $FF, $3FCD
03FCE: FF FF FF      BBS7  $FF, $3FD0
03FD1: FF FF FF      BBS7  $FF, $3FD3
03FD4: FF FF FF      BBS7  $FF, $3FD6
03FD7: FF FF FF      BBS7  $FF, $3FD9
03FDA: FF FF FF      BBS7  $FF, $3FDC
03FDD: FF FF FF      BBS7  $FF, $3FDF
03FE0: FF FF FF      BBS7  $FF, $3FE2
03FE3: FF FF FF      BBS7  $FF, $3FE5
03FE6: FF FF FF      BBS7  $FF, $3FE8
03FE9: FF FF FF      BBS7  $FF, $3FEB
03FEC: FF FF FF      BBS7  $FF, $3FEE
03FEF: FF FF FF      BBS7  $FF, $3FF1
03FF2: FF FF FF      BBS7  $FF, $3FF4
03FF5: FF FF FF      BBS7  $FF, $3FF7
03FF8: FF FF FF      BBS7  $FF, $3FFA
03FFB: FF FF FF      BBS7  $FF, $3FFD
03FFE: FF FF
