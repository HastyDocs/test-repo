## 2.3.6. Filtering
There are several ways to filter the objects shown in the 3D view. Filtering can be performed with clipping planes that are associated with floors or through filter buttons that can quickly show/hide categories of objects.

To use clipping, the user must first define floors for the model as discussed in Section 8.5. Once the floors are defined, a floor can be selected by using the Floor Drop-down above the 3D or 2D view as shown in Figure 7.

![pyro-scrn-floor-show](https://user-images.githubusercontent.com/2109426/136003233-4ebb83ac-d145-40dc-9be5-98310067b72b.png)


pyro scrn floor show
Figure 7. Floors drop-down
Once a floor has been selected, its clipping planes will be applied to the entire scene to only show objects within the clipping region.

Filtering can also be performed using the filter toolbar buttons as shown in Figure 8. Selecting/deselecting these buttons will quickly show/hide all objects of a specific type, such as obstructions, holes, vents, etc.

## 2.9. Configuration Files
PyroSim stores data related to user preferences in a file called PyroSim.props. By default, this file can be found in one of the following locations.

%APPDATA%\PyroSim\PyroSim.props
%PROGRAMDATA%\PyroSim\PyroSim.props

If at least one of these files exists, PyroSim will use it to load the user preferences. If both files exist, PyroSim will load user preferences from both files, giving preference to the file located in the APPDATA folder. This way the preference file located in the PROGRAMDATA folder can be shared among multiple machines, and the file located in the APPDATA folder on each machine overrides the shared settings.

The PROPS file is stored in a plaintext format, and can be viewed or edited with any conventional text editor. While it is not recommended to edit the file directly, some troubleshooting techniques may involve deleting the PROPS file so that a new one can be created from scratch by PyroSim.

Configurations for hotkeys in PyroSim is stored in a separate file named keybindings.json located in the APPDATA folder.

## 2.3.1. Camera Views
The traditional orthographic views are pre-programmed into PyroSim and are valid in both the 3D and 2D views. It is also possible to save custom camera views, for more information, see Chapter 3.

To change the camera view, select the desired view in the drop-down menu, as shown in Figure 3 or press the appropriate hotkey from Table 1.

Table 1. Camera View Hotkeys
View	Hotkey
Front	CTRL+1
Back	CTRL+2
Left	CTRL+3
Right	CTRL+4
Top	CTRL+5
Bottom	CTRL+6
