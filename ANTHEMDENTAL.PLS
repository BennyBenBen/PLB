* ************************************************************
* ANTHEMDENTAL.PLS
*
* Reads the Anthem Dental file
* Z:\data\3707\AnthemDental\ANTHDDS
*
* 2018/11/21 BML Setup
* ************************************************************
	Include	Z:\SOURCE\INCLUDES\COMMON.INC
	Include	Z:\SOURCE\INCLUDES\ANTHDENT.Inc

ANTHDEN 	IFILE    

FilNam  	Dim     255	// Input File

PROVNBR		Dim 	12	// Screen Prompt Input - 9 digit Provider number
PROOFFICE	Dim 	3	// Screen Prompt Input - 3 digit Provider number
PROVKEY		Dim	12	// Screen Prompt Input - 12 digit Provider Key
INPUTCODE	Dim	5	// Screen Prompt Input - Service Code Prompt

CHOPKEY		Dim	9	// 12 digit Provider Key chopped

CNT1		FORM 	4	// Overall loop counter to avoid enless loop
CNT2		FORM	"06"	// Verticle Start position of the First Column of List of Providers
CNT3		FORM	"06"	// Verticle Start position of the Second Column of List of Providers

CNT4		FORM	4	// Verticle Start position of Office Code Input


LOOPCNT		FORM	3	// Array Counter
SERVICECODE	Dim	5	// Array Value
SERVICECOST	Form	7.2	// Array Value
MAXLOOP		FORM	"600"	// Max array count

LENGPTR		FORM	03	// length of Provider Number Input

PROVIDERFOUND	FORM  	01	// Flag
OFFICEFOUND	FORM	01	// Flag
CODEFOUND	FORM	01	// Flag
SECONDCOLUMN	FORM	01	// FLAG
HEADER1		INIT	"Office Name"

	//Open the Input File
     	PACK	FilNam,"Z:\data\3707\AnthemDental\ANTHDDS"
	Open	ANTHDEN,FilNam,Read
	
	SETWTITLE "ANTHEM DENTAL LOOKUP"
        
	DISPLAY	*COLOR=23,*ES:
		*P02:01,"ANTHEM DENTAL LOOKUP"
	KEYIN	*P02:02,"PRESS ESC TO END THE PROGRAM"
       
	TRAP Program_End IF ESCAPE

	LOOP //This Loop allows the user to do more than one lookup
	
		MOVE 0 to PROVIDERFOUND
		MOVE 0 to SECONDCOLUMN
		INCR CNT1
		DISPLAY *P01:25,"25";
		DISPLAY *P80:25,"*";
		KEYIN	*P02:04,*EF, "Please Enter a 9 digit Provider Number:", PROVNBR 		//Prompt for a Provider Number
		//KEYIN	*P02:04, "Please Enter a 9 digit Provider Number:", PROVNBR 		//Prompt for a Provider Number

		MOVELPTR PROVNBR TO LENGPTR
		PACK 	PROVKEY, PROVNBR, "   "
		READ 	ANTHDEN,PROVKEY;ANTHDENTREC
		CHOP 	PROVKEY INTO CHOPKEY
		
		IF (LENGPTR<>9)
			KEYIN   *P02:04,*EF,"Provider not found, press enter to try again",REPLY;
		ELSE
			LOOP //This loop displays all the records for a given Dentist
				READKS 	ANTHDEN;ANTHDENTREC
				UNTIL OVER
				
				IF (CHOPKEY=ATDPROVNBR)
					IF (PROVIDERFOUND=0)
						DISPLAY *P02:CNT2, HEADER1
					ENDIF
					
					IF (CNT2>16)
						IF (SECONDCOLUMN=0)
							DISPLAY *P38:CNT3, HEADER1
							MOVE 1 to SECONDCOLUMN
						ENDIF
						INCR CNT3
						DISPLAY *P39:CNT3,ATDOFFICE
						DISPLAY *P45:CNT3,ATDNAME
					ELSE
						INCR CNT2
						DISPLAY *P03:CNT2,ATDOFFICE
						DISPLAY *P09:CNT2,ATDNAME		
					ENDIF
					MOVE 1 to PROVIDERFOUND	
					
				ELSE
					IF (PROVIDERFOUND=1) // we found the first record, but the next record did not match
						BREAK // proceed on to prompt for the Office #
					ELSE
						MOVE 0 to PROVIDERFOUND				
						KEYIN   *P02:04,*EF,"Provider not found, press enter to try again",REPLY;
						BREAK
					ENDIF
				ENDIF
			
			REPEAT
			
			IF (PROVIDERFOUND=1)
				IF (CNT3>CNT2)
					MOVE CNT3 to CNT4
				ELSE
					MOVE CNT2 to CNT4
				ENDIF
				
				INCR CNT4 
				
				LOOP
					KEYIN	*P02:CNT4,*EF,"Enter a Provider Office:", PROOFFICE	// Prompt for a Provider's Office #
					MOVE	"            " to PROVKEY
					PACK 	PROVKEY, PROVNBR, PROOFFICE
					READ 	ANTHDEN,PROVKEY;ANTHDENTREC
				
					IF OVER
						MOVE 0 TO OFFICEFOUND
						KEYIN *P02:CNT4,*EF,"Invalid office number Press Enter to try again:",REPLY
					ELSE
						MOVE 1 to OFFICEFOUND
						INCR CNT4
						
						LOOP
							MOVE 0 to LOOPCNT
							KEYIN	*P02:CNT4,*EF, "Enter a Service Code:", INPUTCODE // Prompt for a service code #	
							INCR LOOPCNT
							LOOP // Loop the curent record's Array to find the array value that matches the service code
								EXPLODE ATDARRAY(LOOPCNT),",",SERVICECODE,SERVICECOST
				
								IF (SERVICECODE = INPUTCODE)
									MOVE 1 to CODEFOUND
									BREAK
								ELSE
									MOVE 0 to CODEFOUND
								ENDIF
							
								INCR LOOPCNT
								IF (LOOPCNT>MAXLOOP)			
								   BREAK
								ENDIF
							REPEAT
							IF (CODEFOUND=1)
								CALC	SERVICECOST = (SERVICECOST/100)
								
								INCR CNT4
								DISPLAY *P02:CNT4,*EF, "Service Amount Cost",SERVICECOST
								
								INCR CNT4
								KEYIN *P02:CNT4,*EF,"Press Enter",REPLY
								BREAK
							ELSE
								
								INCR CNT4
								KEYIN *P02:CNT4,*EF,"Service Code Not Found, Press Enter to try again:",REPLY	
								MOVE CNT2 to CNT4				
							ENDIF
							
							MOVE 	"     " to SERVICECODE
							MOVE 	"     " to INPUTCODE
						REPEAT					
					ENDIF
					
					MOVE "   " to PROOFFICE
					MOVE CNT2 to CNT4
					
					IF (CODEFOUND=1)
						Break
					ENDIF
				
				REPEAT
			ELSE
				MOVE 	"            " 	to PROVNBR
			ENDIF

			IF (CNT1>1000)
				KEYIN   *ES,*P02:25,"To many tries, this program will stop:",REPLY
				BREAK
			ENDIF
		
		ENDIF
	
		MOVE "06" to CNT2
		MOVE CNT2 to CNT3
	REPEAT
	
	Call Program_End
	

Program_End		
	Close ANTHDEN
	STOP
