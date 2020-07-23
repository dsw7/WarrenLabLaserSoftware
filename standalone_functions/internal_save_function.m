function [save_path] = internal_save_function(time_data, ...
                                              abs_fl_data, save_path)
%{
Function for saving data to some directory of the user's choosing
                                              
    Parameters:
        time_data : time data
        abs_fl_data : absorbance/fluorescence data
    Returns:
        None
%}

data_matrix = [time_data; abs_fl_data];
data_matrix = transpose(data_matrix);
csvwrite(save_path, data_matrix);


