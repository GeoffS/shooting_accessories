include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>
include <../OpenSCAD_Lib/threads.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

makePlate = false;
makeScrew = false;

plateZ = 3;

module screw()
{
    nutZ = 3;

    OD_inch = 1 + 3/16;
    TPI = 16;
    threadZ_inches = (20 + nutZ)/25.4;

    difference()
    {
        english_thread (diameter=OD_inch, threads_per_inch=TPI, length=threadZ_inches, leadin=1, leadfac=3);

        // Slightly reduce the OD to account for crap threads in upper:
        difference()
        {
            tcy([0,0,-5], d=100, h=100);
            tcy([0,0,-10], d=OD_inch*25.4 - 0.1, h=150);
        }
    }
    cylinder(d=50, h=nutZ, $fn=6);
}

module plate()
{
    // At origin.
    topOD = 60;

    topLeftOD = 44;
    topLeftX = -15;
    topLeftY = -(topOD - topLeftOD)/2;

    bottomOD = 50;
    bottomY = 23;

    bufferOD = 30.4;

    pinOD = 12.5;
    pinZ = 4;
    pinCZ = 1;
    pinY = 25.4;

	difference()
    {
        union()
        {
            hull()
            {
                #tcy([0,0,0], d=topOD, h=plateZ);
                #tcy([topLeftX, topLeftY, 0], d=topLeftOD, h=plateZ);
                #tcy([0,bottomY,0], d=bottomOD, h=plateZ);
            }

            // Pin:
            translate([0,pinY,0]) simpleChamferedCylinder(d=pinOD, h=pinZ+plateZ, cz=pinCZ);
        }

        // Hole foe the buffer:
        tcy([0,0,-10], d=bufferOD, h=100);
    }
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() plate();
    // display() screw();

    // display() translate([-70,0,0]) plate();
    display() translate([-70,0,0]) screw();
}
else
{
	if(makePlate) plate();
    if(makeScrew) screw();
}
