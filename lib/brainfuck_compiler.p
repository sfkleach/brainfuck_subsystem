compile_mode :pop11 +strict;

section $-brainfuck => brainfuck_compiler;

;;; The names used are arbitrary.
constant brainfuck_array_var = "Array";
constant brainfuck_index_var = "Index";

constant initial_position = 1 << 5;

define plant_initial_state();
    ;;; Brainfuck requires an integer array and an index as part of its runtime state.
    sysLVARS( brainfuck_array_var, 0 );
    sysPUSHQ( initintvec( initial_position << 1 ) );
    sysPOP( brainfuck_array_var );
    sysLVARS( brainfuck_index_var, 0 );
    sysPUSHQ( initial_position );
    sysPOP( brainfuck_index_var );
enddefine;

vars procedure plant_bf;

;;; This code-planting procedure starts at the character after the open brace and
;;; finishes after consuming the matching brace. It plants a loop in the conventional
;;; fashion:-
;;;
;;;         goto test:
;;;     start_body:
;;;         PLANT CODE FOR SEQUENCE OF INSTRUCTIONS
;;;         if Array[Index] != 0 goto start_body
;;;
;;; This style of code-planting eliminates a superfluous goto from the inner loop.
;;;
define plant_bf_loop();
    lvars start_loop = sysNEW_LABEL();
    lvars loop_test = sysNEW_LABEL();

    sysGOTO( loop_test );
    sysLABEL( start_loop );

    plant_bf( `]` );

    sysLABEL( loop_test );
    sysPUSH( brainfuck_index_var );
    sysPUSH( brainfuck_array_var );
    sysCALL( "subscrintvec" );
    sysPUSHQ( 0 );
    sysCALL( "==" );
    sysIFNOT( start_loop );
enddefine;


define signedunity( plus_or_minus );
    if plus_or_minus == `+` then
        1
    elseif plus_or_minus == `-` then
        -1
    else
        false
    endif
enddefine;

define direction( left_right );
    if left_right == `>` then
        1
    elseif left_right == `<` then
        -1
    else
        false
    endif
enddefine;

;;;
;;; Plants code for a sequence of BF instructions up to the stop-character.
;;; If there is no stop-character then -stop_char- should be -false-.
;;;
define plant_bf( stop_char );
    lvars n;
    until null( proglist ) do
        lvars inst = proglist.dest -> proglist;
        if inst == stop_char then
            quitloop
        elseif direction( inst ) ->> n then
            ;;; Read ahead to gather all the < and > characters into a single operation.
            while not(proglist.null) do
                lvars d = direction( proglist.hd );
                quitunless( d );
                n + d -> n;
                proglist.tl -> proglist;
            endwhile;
            sysPUSH( brainfuck_index_var );
            sysPUSHQ( n );
            sysCALL( "+" );
            sysPOP( brainfuck_index_var );
        elseif inst == `.` then
            sysPUSH( brainfuck_index_var );
            sysPUSH( brainfuck_array_var );
            sysCALL( "subscrintvec" );
            sysCALL( "cucharout" );
        elseif inst == `,` then
            sysCALL( "cucharin" );
            sysPUSH( brainfuck_index_var );
            sysPUSH( brainfuck_array_var );
            sysUCALL( "subscrintvec" );
        elseif inst == `[` then
            plant_bf_loop()
        else
            ;;; Read ahead to gather all the + and - characters into a single operation.
            lvars n = signedunity( inst );
            if n then
                while not(proglist.null) do
                    lvars d = signedunity( proglist.hd );
                    quitunless( d );
                    n + d -> n;
                    proglist.tl -> proglist;
                endwhile;
                sysPUSH( brainfuck_index_var );
                sysPUSH( brainfuck_array_var );
                sysCALL( "subscrintvec" );
                sysPUSHQ( n );
                sysCALL( "+" );
                sysPUSH( brainfuck_index_var );
                sysPUSH( brainfuck_array_var );
                sysUCALL( "subscrintvec" );
            endif
        endif
    enduntil;
    if stop_char and null(proglist) then
        mishap( 'Unexpected end of input', [% consstring(#| stop_char |#) %] )
    endif;
enddefine;

;;;
;;; Here we use -proglist_state- and -proglist_new_state-, even though it is
;;; overkill, to convert various kinds of source into a character repeater.
;;; We will actually override proglist so that it becomes a dynamic list of
;;; character codes.
;;;
define procedure brainfuck_compiler( source );
    dlocal proglist_state = proglist_new_state(source);
    procedure();
        dlocal proglist = cucharin.pdtolist;
        sysPROCEDURE(false, 0);
        plant_initial_state();
        plant_bf( false );
        sysCALLQ(sysENDPROCEDURE());
        sysEXECUTE();
    endprocedure.sysCOMPILE;
enddefine;

endsection;
