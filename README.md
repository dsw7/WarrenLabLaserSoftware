# WarrenLabLaserSoftware
Repository containing all Warren Lab MATLAB laser code written by David Weber. See [Applications of numerical linear algebra to protein structural analysis: the case of methionine-aromatic motifs](https://summit.sfu.ca/item/18741) for more information.

## Disclaimer
- I am not a MATLAB expert. Actually I learned MATLAB on the fly simply to fulfill the requirements of this project. I acknowledge that this code is far from ideal and I would have done many things differently now that I am more experienced.
- Some of this code was automatically generated using the MATLAB GUI editor.
- This code can likely very easily be broken up into individual `*.m` files.

## Layout
<img src="https://github.com/dsw7/WarrenLabLaserSoftware/blob/master/pngs/gui_3_10_withlabels.png">

## Description
Label | Description
----- | -----------
**A** |  Here the user chooses between fluorescence and TA mode.
**B** |  The user selects a timebase (i.e. time interval to sample starting from oscilloscope trigger).
**C** |  The number of blank and experimental laser flashes (see **Example for Laser Options parameters**).
**D** |  The number of groups of laser flashes (see **Example for Laser Options parameters**).
**E** |  The pause time between groups of shots (see **Example for Laser Options parameters**).
**F** |  The user selects the DK240 monochromator wavelength (sent as an SCPI command TO the DK240).
**G** |  The DK240 returns the ACTUAL wavelength back to the user.
**H** |  The user selects the slit width at the entrance of the DK240.
**I** |  The user selects the slit width at the exit of the DK240.
**J** |  The user selects the Hamamatsu PMT voltage.
**K** |  QC9514 Digital Delay Generator options. Note that these fields are filled automatically upon toggling **A**.
**L** |  This checkbox fires up the laser. The laser will not fire until all parameters have been selected.
**M** |  Convenience feature for programmatically controlling individual shutters.
**N** |  Convenience feature for programmatically controlling all shutters.
**O** |  Pressing the START button will begin an experiment.
**P** |  Pressing the ABORT button will immediately stop an experiment. **Use in case of a major safety issue arising during an experiment** or perhaps to abort an experiment if parameters were incorrectly chosen.
**Q** |  Exports signal averaged data as .csv to a directory of choosing.
**R** |  The results pane displaying the oscilloscope output.

## Example for Laser Options parameters
Note that in the [Layout](#layout) example, the "user" has indicated they wish to collect 3 groups of 25 shots and have inputted a delay time of 2 seconds. What does this mean? An oscilloscope reading the output of the PMT will first collect 25 reads with a shutter blocking the Nd:YAG laser from striking the sample cuvette. This is the blank read. The shutter will then open and the Nd:YAG laser will reach (and excite) the sample 25 times. The sample will emit light which will be picked up by the PMT/oscilloscope. The blank data will then be subtracted from the experimental data to yield corrected data. Corrected data will then be signal averaged. Recall that the user specified 3 groups of shots. The aforementioned sequence of events will now be repeated three times, with a delay of 2 seconds between each group. The figure below very nicely depicts this sequence of events:
<img src="https://github.com/dsw7/WarrenLabLaserSoftware/blob/master/pngs/groups_shots_pause.png">

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

## Description of all directories
File / Directory | Description
---------------- | -----------
`LaserTableProgram3_10_0.fig` | Last grad school GUI update. This is a binary file generated by MATLAB
`LaserTableProgram3_10_0.m` | Last grad school "main" script update
`LaserTableProgram.fig` | The GUI code. This is a binary file generated by MATLAB
`LaserTableProgram.m` | The "main" script
`css.m` | Isolated `.m` CompuScope data acquisition script
`l_ts.m` | Isolated `.m` long timescale data acquisition script
`docs` | Contains all hardware data/spec sheets
`icon.png` | Some throwaway icon for standalone shortcut
`caliper.ico` | Some throwaway icon for standalone shortcut
`gui_3.6.0.png` | Screenshot of v3.6 UI for documentation/thesis purposes
`gui_3_10_withlabels.png` | Screenshot of v3.10 UI for documentation purposes
`general_instructions.txt` | Basic instructions imported into program upon user request
`additional_features.m` | Info for other features that can be requested by user
`groups_shots_pause.m` | Schematic representation of groups vs. shots vs. pause UI input

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
