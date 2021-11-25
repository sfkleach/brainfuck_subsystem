compile_mode :pop11 +strict;

section;

lvars brainfuck_directory = sys_fname_path( popfilename );

extend_searchlist(
    brainfuck_directory dir_>< 'auto',
    popautolist
) -> popautolist;

extend_searchlist(
    brainfuck_directory dir_>< 'lib',
    popuseslist
) -> popuseslist;

extend_searchlist(
    brainfuck_directory dir_>< 'help',
    vedhelplist
) -> vedhelplist;

uses addlanguage
uses brainfuck_reset

include subsystem.ph;

[
    [ name       brainfuck ]
    [ compiler   ^(procedure(c); brainfuck_compiler(c) endprocedure) ] ;;; indirection to assist with development.
    [ file_ext   '.bf' ]
    [ prompt     '?! ' ]
    [ reset      ^brainfuck_reset ]
].addlanguage;


endsection;
