# WarrenLabLaserSoftware  
Repository containing all Warren Lab MATLAB laser code written by DSW  
---
## Layout  
![aa](https://github.com/dsw7/WarrenLabLaserSoftware/blob/master/gui_3_10_withlabels.png)
## Description  
**A.** Here the user chooses between fluorescence and TA mode  
**B.** The user selects a timebase (i.e. time interval to sample starting from oscilloscope trigger)  
**C.** The number of blank and experimental laser flashes (see **Example for Laser Options parameters**)  
**D.** The number of groups of laser flashes (see **Example for Laser Options parameters**)  
**E.** The pause time between groups of shots (see **Example for Laser Options parameters**)  
**F.** The user selects the DK240 monochromator wavelength (sent as an SCPI command TO the DK240)  
**G.** The DK240 returns the ACTUAL wavelength back to the user  
**H.** The user selects the slit width at the entrance of the DK240  
**I.** The user selects the slit width at the exit of the DK240  
**J.** The user selects the Hamamatsu PMT voltage  
**K.** QC9514 Digital Delay Generator options. Note that these fields are filled automatically upon toggling **A**  
**L.** This checkbox fires up the laser. The laser will not fire until all parameters have been selected  
**M.** Convenience feature for programmatically controlling individual shutters  
**N.** Convenience feature for programmatically controlling all shutters  
**O.** Pressing the START button will begin an experiment  
**P.** Pressing the ABORT button will immediately stop an experiment. **Use in case of a major safety issue arising during an  
       an experiment** or perhaps to abort an experiment where parameters were incorrectly chosen  
**Q.** Exports signal averaged data as .csv to a directory of choosing  
**R.** The results pane  
### Example for Laser Options parameters  
Here the program will take 25 blank reads and then 25 experimental reads.  
This will then be repeated 3 times with a delay of 2 seconds between each group. 

![](https://github.com/dsw7/WarrenLabLaserSoftware/blob/master/groups_shots_pause.png) 

<!---
    # code for plotting the shots groups delay figure
    import matplotlib.pyplot as plt
    import matplotlib.patches as patches  
  
    scale = 4
    f = plt.figure(figsize=(scale * 2, scale))

    ax = f.add_subplot(111)

    ax = plt.gca()
    # kill top / right borders
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)

    # all six rectangles
    ax.add_patch(patches.Rectangle((0,   0), width=25, height=0.2, edgecolor='k'))
    ax.add_patch(patches.Rectangle((25,  0), width=25, height=0.4, edgecolor='k', facecolor='r'))
    ax.add_patch(patches.Rectangle((75,  0), width=25, height=0.2, edgecolor='k'))
    ax.add_patch(patches.Rectangle((100, 0), width=25, height=0.4, edgecolor='k', facecolor='r'))
    ax.add_patch(patches.Rectangle((150, 0), width=25, height=0.2, edgecolor='k'))
    ax.add_patch(patches.Rectangle((175, 0), width=25, height=0.4, edgecolor='k', facecolor='r'))

    # rectangle labels
    plt.text(12.5, 0.22, 'Blank', size=12, ha='center')
    plt.text(37.5, 0.42, 'Experimental', size=12, ha='center')
    plt.text(87.5, 0.22, 'Blank', size=12, ha='center')
    plt.text(112.5, 0.42, 'Experimental', size=12, ha='center')
    plt.text(162.5, 0.22, 'Blank', size=12, ha='center')
    plt.text(187.5, 0.42, 'Experimental', size=12, ha='center')

    # group labels
    plt.text(25,  0.5, 'Group 1', size=16, ha='center')
    plt.text(100, 0.5, 'Group 2', size=16, ha='center')
    plt.text(175, 0.5, 'Group 3', size=16, ha='center')

    # delay labels
    plt.text(62.5,  0.05, '2 second\n delay', ha='center', size=10)
    plt.text(137.5, 0.05, '2 second\n delay', ha='center', size=10)

    # customize x / y ticks
    plt.yticks([])
    pos    = [0, 25, 50, 75, 100, 125, 150, 175, 200]
    labels = [0, 25, 50, 0, 25, 50, 0, 25, 50]
    plt.xticks(pos, labels)
           
    plt.xlabel('Laser shots', size=14)    

    plt.savefig('figure.png', dpi=1000, bbox_inches='tight')      
           
    plt.show()
-->

---
## Description of all directories

    ~/WarrenLabLaserSoftware/LaserTableProgram.fig    // the GUI code
    ~/WarrenLabLaserSoftware/LaserTableProgram.m      // the "main" script
    ~/WarrenLabLaserSoftware/css.m                    // isolated .m CompuScope data acquisition script
    ~/WarrenLabLaserSoftware/l_ts.m                   // isolated .m long timescale data acquisition script
    ~/WarrenLabLaserSoftware/docs                     // contains all hardware data/spec sheets
    ~/WarrenLabLaserSoftware/_defunct                 // contains legacy code
    ~/WarrenLabLaserSoftware/icon.png                 // some throwaway icon for standalone shortcut
    ~/WarrenLabLaserSoftware/caliper.ico              // some throwaway icon for standalone shortcut
    ~/WarrenLabLaserSoftware/gui_3.6.0.png            // screenshot of v3.6 UI for documentation/thesis purposes
    ~/WarrenLabLaserSoftware/gui_3_10_withlabels.png  // screenshot of v3.10 UI for documentation purposes
    ~/WarrenLabLaserSoftware/general_instructions.m   // basic instructions imported into program upon user request
    ~/WarrenLabLaserSoftware/additional_features.m    // info for other features that can be requested by user
    ~/WarrenLabLaserSoftware/groups_shots_pause.m     // schematic representation of groups vs. shots vs. pause UI input
---  
## Other notes   
  
3 Nov 2018   
Note that all .m scripts placed in this repo are from v3.9.0.  
I have a working 3.10.0 version on the lab PC that I will have  
to merge into this repo when I'm done.  
   
---
## Some previous versions/notes from SFU Vault
  
    ~/LaserTable_msc_3_1_0   
    
    ========================================================   
      
    ~/LaserTable_msc_3_2_0  
    Very stable version, previously used in C7000 lab  
    
    ========================================================     
    
    ~/DSWLaserProgram_3_2_0
    ~/DSWLaserProgram_3_2_0.prj
    MATLAB deploytool generated binaries for LaserTable_msc_3_2_0 directory
    
    ========================================================   
         
    ~/DSWLaserTable_3_6_deploytoolbinaries  
    MATLAB deploytool generated binaries for {}_3_6_0 version  
    .exe located under ~/DSWLaserTable_3_6_deploytoolbinaries/for_testing  
    
    ========================================================   
             
    ~/LaserTable_msc_3_3_0 // May 29 2018
    * Removed Python scripts
    * Minimum number of shots N reduced from 10 to 1
    * Minimum groups of shots S reduced from 3 to 1
    * Reordered all QC9514 delay generator functions
    * Fixed probe shutter opening during fluorescence experiments bug
    * Gave shutters A, B and C more descriptive names in the GUI
    * Instructions fetched by making menu bar calls are obtained from text files, and not hard code
    * Removed other garbage
    * Refactored ~/LaserTable_msc_3_3_0/internal_run_experiment.m        
    ~/LaserTable_msc_3_3_0/internal_byte2number.m
        Updated code to standards. No further work needed.
    ~/LaserTable_msc_3_3_0/internal_number2byte.m
        Updated code to standards. No further work needed.
    ~/LaserTable_msc_3_3_0/internal_setup.m                                                               
        Updated code to standards but I didn't confirm the code. It was inherited from a CS dummy script.
    ~/LaserTable_msc_3_3_0/internal_run_experiment.m
        Fixed a shutter operation bug (see bug report) & cleaned up the code to standards.
    ~/LaserTable_msc_3_3_0/internal_save_function.m
        Updated code to standards. No further work needed.
    ~/LaserTable_msc_3_3_0/internal_createDK240object.m
        Updated code to standards. No further work needed.
    ~/LaserTable_msc_3_3_0/internal_close_monochromator.m
        No work was needed.
    ~/LaserTable_msc_3_3_0/internal_GETmonochromator_entrance_slit_width.m
        Updated code to standards. No further work needed.
    ~/LaserTable_msc_3_3_0/internal_GETmonochromator_exit_slit_width.m
        Updated code to standards. No further work needed.
    ~/LaserTable_msc_3_3_0/internal_SETmonochromator_entrance_slit_width.m
        Updated code to standards. No further work needed.
    ~/LaserTable_msc_3_3_0/internal_SETmonochromator_exit_slit_width.m
        Updated code to standards. No further work needed.
    ~/LaserTable_msc_3_3_0/internal_GETmonochromator_wavelength.m
        Updated code to standards. No further work needed.
    ~/LaserTable_msc_3_3_0/internal_SETmonochromator_wavelength.m
        Updated code to standards. No further work needed.
    ~/LaserTable_msc_3_3_0/internal_NI_channels.m
        Updated code to standards. No further work needed.
    ~/LaserTable_msc_3_3_0/internal_createQC9514object.m
        Updated code to standards. Check if fprintf() is the best way to pass SCPI commands.              
    ~/LaserTable_msc_3_3_0/internal_close_DDG.m
        No work was needed.
    ~/LaserTable_msc_3_3_0/internal_QC9514_channel_manager.m
        Updated code to MATLAB standards but I did not check to make sure the code meets 
        SCPI formatting standards for the QC9514 device yet. Check if fprintf() is the 
        best way to pass SCPI commands.                                                                   
    ~/LaserTable_msc_3_3_0/internal_QC9514_pulsestate.m
        Updated code to standards. Check if fprintf() is the best way to pass SCPI commands.                   
    
    ========================================================         

    ~/LaserTable_msc_3_4_0 // July 17 2018
    * N = 1 for timebase > 1 ms
    * width = 2.0 s for timebase > 1 ms
    * Changed the following under ~/LaserTable_msc_3_4_0/internal_run_experiment.m:  
        86        pause(timeDecay); 
        87        
        88        shutter_1.outputSingleScan(1); 
        89        shutter_2.outputSingleScan(1);    % remove this
        90        
        91        if mode == 'T'
        92            shutter_3.outputSingleScan(1);
        93        end
        94    end

        To:

        86        pause(timeDecay); 
        87        
        88        shutter_1.outputSingleScan(1); 
        89
        90        if mode == 'T'
        91            shutter_3.outputSingleScan(1);
        92        end
        93    end

    * Added new function:
        ~/LaserTable_msc_3_4_0/internal_run_experiment_lt.m
            This function is for working with long timescales.
            Recall that N = 1 and S >= 1

        PSEUDOCODE:

        corrected = []
        for s = 1:S
            background = []
            experimental = []
            for session = 1:2
                if session == 1 % the background
                    open shutter 1 for 1 pulse
                    close shutter 1
                    delay for the entire timescale
                    data from scope -> background []
                else % the actual experiment
                    open shutter 1 for 1 pulse
                    close shutter 1
                    delay for the entire timescale
                    data from scope -> experimental []

            experimental [] - background [] -> corrected []
        export corrected [] for plot

    * Added a slider for programmatically controlling the PMT voltage     
    
    ========================================================   
            
    ~/LaserTable_msc_3_5_0 // July 18 2018
    * Did not remove global declarations - turns out they really are the best option in MATLAB
    * Changed handles._ referencing to hObject referencing in shutter radio button functions
    * Rewrote NI shutter / PMT voltage control code in line with NI documentation
    * Added CsMl_FreeSystem() to exit routine instead of relying on internals for exiting
    * Added removeChannel(...) to remove all NI channels in exit routine instead of relying on internals
    * Removed the following due to redundancy:
        ~/LaserTable_msc_3_5_0/internal_NI_channels.m
        ~/LaserTable_msc_3_5_0/internal_createDK240object.m
        ~/LaserTable_msc_3_5_0/internal_createQC9514object.m
        ~/LaserTable_msc_3_5_0/internal_close_DDG.m
        ~/LaserTable_msc_3_5_0/internal_close_monochromator.m
        ~/LaserTable_msc_3_5_0/internal_save_function.m
        ~/LaserTable_msc_3_5_0/QC9514_pulsestate.m
    * Capitalized all global variables somewhat like C++ macro definition syntax
    * Also gave many global variables more descriptive names
    * Removed experiment_mode -> experimentType conversion from the START EXPERIMENT section
    * Removed QC9514 global declarations from 'Digital Delay Generator' panel callbacks - no idea what this will do
    * Laser now shuts off at the end of an experiment for safety reasons
    
    ========================================================   
             
    ~/LaserTable_msc_3_6_0 // July 31 2018
    * Replaced {} with {}:
        ~/LaserTable_msc_3_6_0/internal_setup.m -> LaserTable_msc_3_6_0/css.m
    * Minimum groups of shots set back to 3. The signal averaging algorithm crashes for any number of groups < 3.
    * Removed the following due to redundancy:
        ~/LaserTable_msc_3_6_0/internal_run_experiment.m
      And rewrote the CompuScope capture algorithm in the main script. This bypasses costly function calls
      that slow down the program.
    * Redesigned GUI
    * Reworked ABORT routine. The experiment can be aborted any time
    * fopen() / fclose() pipeline confirmed for CompuScope hardware
    * fopen() / fclose() pipeline confirmed for NI hardware ->
        Replaced:
            removeChannel(INST_NI_DIGITAL, [1 2 3]);
            removeChannel(INST_NI_ANALOG, 1);
            release(INST_NI_DIGITAL);
            release(INST_NI_ANALOG);
        With:
            delete(INST_NI_DIGITAL);
            delete(INST_NI_ANALOG);
        Both processes do the same thing according DAQ toolbox documentation
    * Added LICENSE.md file
    * Cannot change MATLAB icon due to terms of service violation - I did however change icon on deploytool binary generation

    NOTE THAT THIS VERSION DOES NOT WORK WITH TIMESCALES ABOVE 400 us!
    This is due to the fact that ~/LaserTable_msc_3_6_0/internal_run_experiment_lt.m
    script was obliterated on setting up the CompuScope acquisition algorithm into the
    main script -> see (18) in TODO list.
    
    ========================================================   
                    
    ~/LaserTable_msc_3_7_0 // Aug 14 2018
    * Refactored DK240 monochromator code into main script
    * fopen() / fclose() pipeline confirmed for DK240 hardware
    * Removed the following due to redundancy (after refactoring):
        ~/LaserTable_msc_3_7_0/internal_SETmonochromator_entrance_slit_width.m
        ~/LaserTable_msc_3_7_0/internal_SETmonochromator_exit_slit_width.m
        ~/LaserTable_msc_3_7_0/internal_SETmonochromator_wavelength.m
        ~/LaserTable_msc_3_7_0/internal_GETmonochromator_entrance_slit_width.m
        ~/LaserTable_msc_3_7_0/internal_GETmonochromator_exit_slit_width.m
        ~/LaserTable_msc_3_7_0/internal_GETmonochromator_wavelength.m
        ~/LaserTable_msc_3_7_0/internal_byte2number.m
        ~/LaserTable_msc_3_7_0/internal_number2byte.m 
    
    ========================================================   
      
    ~/LaserTable_msc_3_8_0 // Aug 15 2018
    * Refactored QC9514 SCPI communication code into main script
    * fopen() / fclose() pipeline confirmed for QC9514 hardware
    * Removed the following due to redundancy (after refactoring):
        ~/LaserTable_msc_3_8_0/internal_QC9514_channel_manager.m class
    * Added a msgbox that notifies user when an experiment is over
    * Arc lamp pulser shuts off between TA experiments
    * Removed a redundant shutter control command from acquisition loop
    * Fixed issue with wrong figure title showing up in figure window
    * Replaced Continuum PSU pressure switch  
    
    ========================================================   
      
    ~/LaserTable_msc_3_9_0 // Aug 16 2018
    * Refactored lt routine into program by diverting into function l_ts.m
    * y-axis offset issue occurs only during TA experiments for some reason -> stray arc lamp light?
    * Added the voltage correction algorithm into the acquisition loop terminal to fix y-axis offset
    * Replaced crappy homemade Save As dialog box with a proper call to uiputfile()
    * Plot for long timescales seems off center -> it's fine - I forgot about trigger holdoff
    * Removed timebases 11-13 in timebase dropdown menu - see notes below:

    // --- FAST DIGITIZER --- //
    1 - CS12502  - GOOD  // 2 us
    2 - CS12502  - GOOD  // 20 us
    3 - CS12502  - GOOD  // 40 us
    4 - CS12502  - GOOD  // 100 us
    5 - CS12502  - GOOD  // 400 us
    6 - CS12502  - GOOD  // 800 us

    // --- SLOW DIGITIZER --- //  
    7 -  CS8422   -  Pump obscured? Shutter sequence might be too fast??
    8 -  CS8422   -  GOOD
    9 -  CS8422   -  GOOD
    10 - CS8422   -  GOOD sometimes?
    11 - CS8422   -  KNOWN TRIGGER ISSUES HERE - however I have removed this timebase  // 1 s
    12 - CS8422   -  KNOWN TRIGGER ISSUES HERE - however I have removed this timebase  // 10 s
    13 - CS8422   -  KNOWN TRIGGER ISSUES HERE - however I have removed this timebase  // 50 s

    ** Some other dev might have to deal with this if these timebases ever come to use
    ** I have left the code intact with timebases up to 13, however I removed:

        11 - 1 s [10 us/pt]                                 
        12 - 10 s [100 us/pt]                               
        13 - 50 s [500 us/pt]      

    From the Property Inspector -> String menu in timebase_CreateFcn through GUIDE.
    Another developer can easily undo my changes by adding the above to the String list
    through the GUIDE property inspector

    "! QC9514 channel not pulsing in lt_s.m" traceback:

    Step 1. User starts program, selects TA and then selects a long timescale alongside the other setup
            // this properly enables CHA
    Step 2. User hits START - program operates normally
    Step 3. Program will finish acquisition and CHA will be automatically disabled to stop arc lamp pulsing
    Step 4. User hits START a second time - program no longer re-enables CHA

    The problem? CHA disable was not properly reflected with a CHA enable in my diversion patch

    Bug:
    -------------------------------------------------------------
        ... do lt_s.m

        if EXPERIMENT_MODE == 3
            set(handles.channel_A_checkbox, 'Value', 0);
            fprintf(QC9514, strcat(CHANNELS('A'), STATE('OFF')));
        end   
    -------------------------------------------------------------

    Fix:
    -------------------------------------------------------------
        if EXPERIMENT_MODE == 3
            set(handles.channel_A_checkbox, 'Value', 1);
            fprintf(QC9514, strcat(CHANNELS('A'), STATE('ON')));
        end 

        ... do lt_s.m

        if EXPERIMENT_MODE == 3
            set(handles.channel_A_checkbox, 'Value', 0);
            fprintf(QC9514, strcat(CHANNELS('A'), STATE('OFF')));
        end   
    -------------------------------------------------------------
        
    ========================================================   
      
    ~/LaserTable_msc_3_10_0 // Nov 2 2018
    * Begin preparing for transition to GitHub -> /dsw7/WarrenLabLaserSoftware
    * Note that existing code in GH is from v3.9.0 -> update this with 3.10.0 code?
    * Control circuit -> ~/stircontrol_warrenlasertable/dsw_controlcircuit_pinout.pdf
      Work into lt_s.m?
    * Further isolate and clarify entry point into lt_s.m for other developers?
        

---
## TODO list:
1. PMT programmatic voltage control                                                                        % DONE
2. Arc lamp pulser off between experiments                                                                 % DONE
3. Set minimum number of cycles S to 1 ---> currently set at 3                                             % DONE
4. Set minimum number of shots N to 1 ---> currently set at 10                                             % DONE
5. DSW addition - clean up code a lot - it is far from publication worthy...                               % DONE
6. Clean up directory as well - no need for .py scripts and other crap in there                            % DONE
7. Fix shutter issue for transitioning between TA and Fluorescence experiments - shutter should close?     % DONE
8. Find a programmatic solution for quering NI Device Loader status and/or start it by default?
9. Throw in a warning box in OpeningFcn() should the monochromator be off                                  % DONE
   { Updated internal_createDK240object.m to return status = 0 if an error is thrown which then
     forces user to turn on monochromator and restart program. }
10. Remove STIR ON control and build a standalone stir control device                                      % DONE
11. Set up a workaround for NI-DAQ Error -200324
12. Rewrite NI control code in line with NI documentation                                                  % DONE
13. Write exit functions for gracefully disconnecting from NI, CompuScope instead of relying on internals  % DONE
14. Remove all global declarations                                                                         % PASSED
15. Confirm that all fopen() / fclose() pipelines follow literature/documentation recommendations          % DONE
16. Remove additional redundant functions ->  ~/internal_QC9514_pulsestate.m                               % DONE
17. Update shutter radio button states to match shutter states on start up
18. Update ~/LaserTable_msc_3_5_0/internal_run_experiment_lt.m NI routines                                 % DONE 
19. Attempt to make ABORT button abort experiment immediately using CsMl_AbortCapture()                    % DONE
20. Merge updated ~/LaserTable_msc_3_6_0/internal_run_experiment_lt.m into the main script
21. Reformat GUI - increase density, labelling and add version number                                      % DONE
22. Find a suitable icon for the standalone executable                                                     % DONE
23. Confirm that CsMl pipeline matches the pipeline presented in thesis script                             % DONE
24. Rewrite some parts of LICENSE.md to reflect work done by DSW
25. Remove ~/internal_byte2number.m & ~/internal_number2byte.m                                             % DONE
26. Add a msgbox that indicates when an experiment has finished [Daina suggestion]                         % DONE
27. Fix issue with figure title displaying wrong version                                                   % DONE
28. Take one last look at TA/flourescence shutter control scheme and confirm proper operation
29. Add drop down menu to manually select COM port for DK240/QC9514 (override default)
30. Update acquisition loop to work with long timescales (!! _lt.m function) <- < 10 s (JJW email)         % DONE
31. Update additional_features.txt & general_instructions.txt to reflect program changes
32. Program in the stir stop feature for long timescale experiments
33. REBUILD l_ts.m - 10 Hz laser pulse is being picked up by slow digitizer
34. Should probably make some slight adjustments to the laser manual in the near future
35. Throw in voltage error correction algorithm into acquisition loop terminus                             % DONE
36. Make abort feature work in l_ts.m
37. Isolate and clarify entry point into lt_s.m such that other developers (or myself) can pick up here
