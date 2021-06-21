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
positions = [0, 25, 50, 75, 100, 125, 150, 175, 200]
labels = [0, 25, 50, 0, 25, 50, 0, 25, 50]
plt.xticks(positions, labels)

plt.xlabel('Laser shots', size=14)
plt.savefig('groups_shots_pause.png', dpi=1000, bbox_inches='tight')
