
 M I N I   S S S S S P R A W L S
 -------------------------------

 making things, open ended, never unfinished. then: pipe to world.


 -------------------------------------------------------------------
 Copyright (c) 2016 Christoph Haag
 -------------------------------------------------------------------
 If not stated otherwise permission is granted to copy, distribute
 and/or modify these documents under the  terms of the Creative 
 Commmons Attribution-ShareAlike 4.0 International License 

 -> http://creativecommons.org/licenses/by-sa/4.0/

 -------------------------------------------------------------------
 EXCEPT: *.sh
 -------------------------------------------------------------------
 Copyright (c) 2016 Christoph Haag
 -------------------------------------------------------------------
 These files are free software: you can redistribute it and/or
 modify it under the terms of the GNU General Public License as
 published by the Free Software Foundation, either version 3 of
 the License, or (at your option) any later version.

 They are distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty
 of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 See the GNU General Public License below for more details.

 -> http://www.gnu.org/licenses/gpl.txt

 -------------------------------------------------------------------


 H E L P F U L :

 for T in `find . -name "*.*" | grep ".*\.[0-9]\{10\}$"`; \
 do mv $T `echo $T | sed 's/\.[0-9]*$//'`.tweet  ; done


