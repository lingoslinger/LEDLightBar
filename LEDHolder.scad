// bracket that supports LED light strip

// true if you are making two part brackets, false otherwise
twopart = true;

// length of a single part bracket, or half of a two part bracket
length = 155;

// material where fasteners attach to the car
bracketheight = 13;

// length of base from car to LED support
baselength = 40;
// thickness of base attached to 
basethickness = 10;

// triangle that supports LED light strip
// hypotenuse of triangle
lightfacewidth = 13;   
  
// angle of LED support relative to base of bracket
lightangle = 15;

// channel for LED light strip
channelheight = 3;

// diameter of the cap head of your M5 fastener of choice (measure and add 1.5 - 2mm)
capheaddiameter = 10.5;

// rotate the design for 3D printing
setupforprinting = false;

// plug or socket for connecting pieces
plug = false;

// template for drilling holes for rivnuts
template = false;

// hole placement in mm from edge
holeplacement = 10;

// two fastener holes instead of 4 on two part brackets- currently unimplemented
twoholes = false;

// "hollow" bracket for less material - currently unimplemented
usehollowbracket = false;

module squarebracket(st, sh, bt, bh) {
    cube([length, bt, bh]);
    translate([0, bt - st, bh]) {
        cube([length, st, sh]);
    }
}

module curvedbracket() {
    translate([0, baselength, 0]){ 
        rotate([-90, 0, -90]){
            linear_extrude(height = length)
            difference() {
                resize([baselength * 2, bracketheight * 2])circle($fn=100); 
                translate([-baselength, 0, 0]) { 
                    square(baselength * 2);
                }
                translate([-40, -bracketheight, 0]) {
                    square(40);
                }
            }
        }
    }
}

module lightbase(l) {
    lightheight = (sin(lightangle) * lightfacewidth);
    lightwidth =  (cos(lightangle) * lightfacewidth);
    translate([0, lightwidth, 0]) {
        rotate([180, 0, 0]) {
        polyhedron(//pt 0        1        2        3        4        5
                    points=[[0,0,0], [l,0,0], [l,lightwidth,0], [0,lightwidth,0], [0,lightwidth,lightheight], [l,lightwidth,lightheight]],
                    faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
                    );
        }
    }
    ledtrack(lightheight);
}

module ledtrack(h) {
    // lots of math to put the track where it goes...
    yoffset = sin(lightangle) * channelheight;
    zoffset = cos(lightangle) * channelheight;

    translate([0, yoffset, -h - zoffset]) {
        rotate([lightangle, 0, 0]) {
            difference() {
                cube([length, lightfacewidth, channelheight]);
                translate([0, 1.5, 0.5]) {
                    cube([length, 10.2, 1.5]);
                }
                translate([0, 2.25, 0]) {
                    cube([length, 8.7, 1.5]);
                }


                translate([length, 0, 0]) {
                    cube([0, 13, 1.5]);
                }

            }
        }
    }
}

module mountingholes(inset) {
    holelength = length;
    if (plug == true) {
        holelength = length;
    }
    rotate([90, 0, 0]) {
        translate([inset, bracketheight / 2, -baselength]) {
            cylinder(h=baselength, r = 5.5 / 2, $fn=100); 
        }
        translate([inset, bracketheight / 2, -baselength + 10]) {
            cylinder(h=baselength, r = capheaddiameter / 2, $fn=100); 
        }
        translate([holelength - inset, bracketheight / 2, -baselength]) {
            cylinder(h=baselength, r = 5.5 / 2, $fn=100); 
        }
        translate([holelength - inset, bracketheight / 2, -baselength + 10]) {
            cylinder(h=baselength, r = capheaddiameter / 2, $fn=100); 
        }
    }
}

module plug() {
    test = plug ? 0 : length;
    baselengthcenter = baselength / 2;
    baselengthheight = basethickness / 2;

    translate([length, baselengthcenter / 2 + 2, baselengthheight / 2]) {
        cube([4, baselength/2, 4]);
    }
}

module socket() {
    baselengthcenter = baselength / 2;
    baselengthheight = basethickness / 2;

    translate([0, baselengthcenter / 2 + 2, baselengthheight / 2]) {
        cube([4, (baselength + 0.1)/2, 4.1]);
    }
}

module hollowbracket(inset) {
    // use this again to calculate where the hollow part goes
    lightwidth =  (cos(lightangle) * lightfacewidth);
    translate([inset, lightwidth + 3, 0]) {
        cube([length - 2 * inset, baselength - lightwidth + 3, bracketheight - 3]);
    }
    // get some angles in there to avoid supports
}

module completeBracket() {
    if (plug) {
        curvedbracket();
        plug();
        lightbase(length);
    } else {
        difference() {
            curvedbracket();
            socket();
        }
       lightbase(length);

    }
}

module drillingholes(inset) {
    holelength = length;
    if (plug == true) {
        holelength = length;
    }
    rotate([90, 0, 0]) {
        translate([inset, bracketheight / 2, -baselength]) {
            cylinder(h=baselength, r = 5.5 / 2, $fn=100); 
        }
        translate([inset, bracketheight / 2, -baselength + 10]) {
            cylinder(h=baselength, r = 10.0 / 2, $fn=100); 
        }
        translate([holelength - inset, bracketheight / 2, -baselength]) {
            cylinder(h=baselength, r = 5.5 / 2, $fn=100); 
        }
        translate([holelength - inset, bracketheight / 2, -baselength + 10]) {
            cylinder(h=baselength, r = 10.0 / 2, $fn=100); 
        }
    }
}

module drillingtemplate() {
    rotate([90, 0, 0]) {
        difference() {
            cube([length, 3, bracketheight]);
            drillingholes(10);
        }
    }
}

module mountablebracket() {
    difference() {
        completeBracket();
        mountingholes(holeplacement);
        // hollowbracket(20);
    }
    
}

if (template) {
    drillingtemplate();
} else {
    if (!setupforprinting) {
        mountablebracket();
    } else if (setupforprinting && plug) {
        rotate([0, 270, 0]) { 
        mountablebracket();
    }
    } else if (setupforprinting && !plug) {
        translate([0,0,length]) {
        rotate([0, 90, 0]) { 
            mountablebracket();
        }
    }
} 
}

