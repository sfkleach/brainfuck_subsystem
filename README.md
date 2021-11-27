# A Brainfuck Subsystem for Poplog

This library is intended to be a template that shows how to add
new language subsystems to Poplog. To use it, add the files into
your local library.

To use this subsystem, download the git repo 

    https://github.com/sfkleach/brainfuck_subsystem

and then load the brainfuck.p file. e.g.

    % git clone https://github.com/sfkleach/brainfuck_subsystem
    % pushd brainfuck_subsystem
    % poplog 
    : load brainfuck_subsystem/brainfuck.p

After that you can experiment by loading your brainfuck programs with
file extension .bf such as:

    : load brainfuck_subsystem/bf/hello.bf

Stephen Leach, 27 Nov 2021
