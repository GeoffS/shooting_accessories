include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

makeBlock = false;
makeTop = false;
makeTest = false;
makeWorkbenchStand = false;

firstLayerHeight = 0.2;
layerHeight = 0.2;

magWidth = 22.4; // Slightly less that 7/8"
magLength = 60.7;
magRibLength = 64;
magRibWidth = 11;
magWellBottomAngle = 10.3;
magStopHeight = 45;

threadableHoleDiaVert = 5.8; // A bit larger than the 5.16mm recommended 1/4-20 tap.
threadableHoleDiaHoriz = 6.25; // 1/4-20 just firm "self-tapping" thread dia.
threadClearanceHoleDia = 6.7;

// Original dimensions:
// magBlockViceZ = 60;
// horizontalHolesZ = 40;

// Small blue vice dimensions:
// 28mm from top of screw to top up jaws:
// ----------------vv
horizontalHolesZ = 28 + threadableHoleDiaHoriz/2;
echo(str("horizontalHolesZ = ", horizontalHolesZ));
// 20mm to get holes below the mag-well stop:
// Magic'ish for 10 deg -----------vv
magBlockViceZ = horizontalHolesZ + 20;
echo(str("magBlockViceZ = ", magBlockViceZ));

magCatchX = 4;
magCatchY1 = -6.6;
magCatchY2 = -18.6;
magCatchCtrY = (magCatchY1 + magCatchY2)/2;
magCatchY = -(magCatchY2 - magCatchY1) + 1;
magCatchZ = 19.5;

echo(str("magCatchCtrY = ", magCatchCtrY));
echo(str("magCatchY = ", magCatchY));

magStopExtraXY = 8;

magBlockViceX = magWidth + 2*magStopExtraXY;
magBlockViceY = magLength + 2*magStopExtraXY;
magBlockZ = magStopHeight + magBlockViceZ;
echo(str("magBlockZ = ", magBlockZ));

magBlockDia = 4;
magBlockCZ = 1.5;

magBlockViceDia = 8;
magBlockViceCZ = 2.5;

// MAGIC!!
//  ----------------vvvvvvv
magwellStopExtraY = 6.12344;

echo(str("magBlockViceY = ", magBlockViceY));

echo(str("magStopExtraXY-magwellStopExtraY = ", magStopExtraXY-magwellStopExtraY));

// $fn = 180;

module top()
{
    topZ = 10;
    insertZ = 6;
    CZ = firstLayerHeight + 2*layerHeight;

    difference()
    {
        topLipXY = (34 - magWidth)/2;
        topX = magWidth + 2*topLipXY;
        topY = magLength + topLipXY;

        echo(str("topLipXY = ", topLipXY));
        echo(str("topX = ", topX));
        echo(str("topY = ", topY));

        // MAGIC!!
        magicDY = topLipXY-magwellStopExtraY;
        /// ECHO: "magicDY = 1.87656"
        echo(str("magicDY = ", magicDY));

        translate([0, magicDY, 0]) union()
        {
            mwdx = magWidth/2 - magBlockDia/2;
            mwdy = magLength/2 - magBlockDia/2 - 0.2;
            hull() doubleX() doubleY() 
                translate([mwdx, mwdy, 0])
                    simpleChamferedCylinderDoubleEnded(d=magBlockDia, h=insertZ+topZ, cz=CZ);

            dx = topX/2 - magBlockViceDia/2;
            dy = (magLength+topLipXY)/2 - magBlockViceDia/2;
            translate([0, topLipXY/2, 0]) hull() 
                doubleX() doubleY() 
                    translate([dx, dy, 0]) 
                        simpleChamferedCylinderDoubleEnded(d=magBlockViceDia, h=topZ, cz=CZ);
        }

        // Vertical hole for clamp:
        topHoleDia = threadClearanceHoleDia+0.5;
        translate([0,0,-50])
        {
            tcy([0,0,0], d=topHoleDia, h=100);
        }
        translate([0,0,insertZ+topZ-topHoleDia/2-1])
        {
            cylinder(d2=20, d1=0, h=10);
        }
        translate([0,0,-10+topHoleDia/2+1])
        {
            cylinder(d1=20, d2=0, h=10);
        }
    }
}

module magCoreComplete(z)
{
    difference()
    {
        union()
        {
            magCore(z);
            magCoreRib(z);
        }

        // Mag-catch slot:
        mcDia = 4;
        translate([10+magWidth/2-magCatchX+mcDia/2, magBlockViceY/2-magCatchCtrY, z-magCatchZ-mcDia/2]) 
            hull() doubleX() doubleY() translate([10, magCatchY/2-mcDia/2, 0])
                simpleChamferedCylinderDoubleEnded(d=mcDia, h=100, cz=mcDia/2-nothing);

        // Vertical hole for clamp:
        translate([0, magBlockViceY/2, 0])
        {
            threadableLengthZ = 20;
            // Threadable section at top:
            tcy([0,0,-10], d=threadableHoleDiaVert, h=200);

            // Clearance section in middle of mount:
            translate([0,0,threadableLengthZ]) simpleChamferedCylinderDoubleEnded(d=threadClearanceHoleDia, h=z-2*threadableLengthZ, cz=2);
        
            // Top Chamfer:
            translate([0,0,z-threadableHoleDiaVert/2-1]) cylinder(d2=20, d1=0, h=10);
        
            // Bottom Chamfer:
            translate([0,0,-10+threadableHoleDiaVert/2+1]) cylinder(d1=20, d2=0, h=10);
        }
    }
}

module workbenchStand()
{
    difference()
    {
	    union()
        {
            magCoreComplete(z=magBlockZ);
            viceSection(magBlockViceZ=magBlockViceZ);
        }
    }
}

module viceMount()
{
    difference()
    {
	    union()
        {
            magCoreComplete(z=magBlockZ);
            viceSection(magBlockViceZ=magBlockViceZ);
        }

        // Horiz holes to sit on vice jaws:
        translate([0,magBlockViceY/2,horizontalHolesZ]) doubleY() translate([0,20,0]) rotate([0,90,0]) 
        {
            // Threads:
            tcy([0,0,-100], d=threadableHoleDiaHoriz, h=200);

            // Chamfer:
            doubleZ() translate([0,0,magBlockViceX/2-threadableHoleDiaHoriz/2-0.6]) cylinder(d2=20, d1=0, h=10);

            // Just larger than threaded rod OD:
            x = magBlockViceX-12;
            tcy([0,0,-x/2], d=6.7, h=x);
        }

    }
}

module magCore(z)
{
    magCoreParams(x=magWidth, y=magLength, z=z, dy=magwellStopExtraY);
}

module magCoreRib(z)
{
    dy = (magRibLength-magLength)/2 + magwellStopExtraY;
    magCoreParams(x=magRibWidth, y=magRibLength, z=z, dy=dy);
}

module magCoreParams(x, y, z, dy)
{
    mwdx = x/2 - magBlockDia/2;
    mwdy = y/2 - magBlockDia/2;
    translate([0, magLength/2+dy, 0]) 
        hull() doubleX() doubleY() 
            translate([mwdx, mwdy, 0])
                simpleChamferedCylinderDoubleEnded(d=magBlockDia, h=z, cz=magBlockCZ);
}

module viceSection(magBlockViceZ)
{
    difference()
    {
        mainViceSection(magBlockViceZ);
        translate([0,0,magBlockViceZ]) rotate([-magWellBottomAngle,0,0]) tcu([-200,-200,0], 400);
    }
}

viceDX = magBlockViceX/2 - magBlockViceDia/2;
viceDY = magBlockViceY/2 - magBlockViceDia/2;

module mainViceSection(magBlockViceZ)
{
    hull() translate([0,magBlockViceY/2,0]) 
        doubleX() doubleY() 
            translate([viceDX, viceDY, 0]) 
                simpleChamferedCylinderDoubleEnded(d=magBlockViceDia, h=magBlockViceZ+10, cz=magBlockViceCZ);
}

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
    // tcu([0-d, -200, -200], 400);
}

if(developmentRender)
{
    // display() rotate([0,0,180]) translate([0,-magBlockViceY/2,magBlockZ+20]) rotate([0,180,0]) viceMount();
    // display() translate([0,0,0]) top();
    // displayGhost() tcy([0,0,0], d=6.2, h=40);

    // display() viceMount();

    display() workbenchStand();
	display() translate([100,0,0]) viceMount();
    display() translate([-100,0,0]) top();

    // display() translate([100,0,0]) testModule();
}
else
{
	if(makeBlock) viceMount();
    if(makeTest) testModule();
    if(makeTop) top();
    if(makeWorkbenchStand) workbenchStand();
}

module testModule()
{
    difference()
    {
        viceMount();
        tcy([0,0,-400+40], d=400, h=400);
        tcy([0,0,75], d=400, h=400);
    }
}
