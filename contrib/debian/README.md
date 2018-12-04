
Debian
====================
This directory contains files used to package MERGEd/MERGE-qt
for Debian-based Linux systems. If you compile MERGEd/MERGE-qt yourself, there are some useful files here.

## MERGE: URI support ##


MERGE-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install MERGE-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your MERGEqt binary to `/usr/bin`
and the `../../share/pixmaps/MERGE128.png` to `/usr/share/pixmaps`

MERGE-qt.protocol (KDE)

