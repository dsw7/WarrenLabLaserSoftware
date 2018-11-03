function [] = internal_close_monochromator(object)
%{
Function for disconnecting from monochromator.

    Parameters:
        object : the monochromator object
    Returns:
        None
%}
fclose(object);
clear object;
