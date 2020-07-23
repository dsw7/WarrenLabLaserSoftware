function [] = internal_close_DDG(object)
%{
Closes the connection to the QC9514 digital delay generator

    Parameters:
        object : the monochromator object
    Returns:
        None

%}

delete(object);
clear object;
fclose('all');
