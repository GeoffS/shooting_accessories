include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

makeBlock = false;
makeTop = false;
makeTest = false;

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
// 20mm to get holes below the mag-well stop:
// Magic'ish for 10 deg -----------vv
magBlockViceZ = horizontalHolesZ + 20;

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
        // MAGIC!!
        magicDY = magStopExtraXY-magwellStopExtraY;
        echo(str("magicDY = ", magicDY));
        translate([0, magicDY, 0]) union()
        {
            mwdx = magWidth/2 - magBlockDia/2;
            mwdy = magLength/2 - magBlockDia/2 - 0.2;
            hull() doubleX() doubleY() 
                translate([mwdx, mwdy, 0])
                    simpleChamferedCylinderDoubleEnded(d=magBlockDia, h=insertZ+topZ, cz=CZ);

            dx = 34/2 - magBlockViceDia/2;
            dy = (magLength+magStopExtraXY)/2 - magBlockViceDia/2;
            translate([0, magStopExtraXY/2, 0]) hull() 
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

module itemModule()
{
    difference()
    {
	    union()
        {
            magCore();
            magCoreRib();
            viceSection();
        }
        
        // Mag-catch slot:
        mcDia = 4;
        translate([10+magWidth/2-magCatchX+mcDia/2, magBlockViceY/2-magCatchCtrY, magBlockZ-magCatchZ-mcDia/2]) 
            hull() doubleX() doubleY() translate([10, magCatchY/2-mcDia/2, 0])
                simpleChamferedCylinderDoubleEnded(d=mcDia, h=100, cz=mcDia/2-nothing);

        // Vertical hole for clamp:
        translate([0, magBlockViceY/2, 0])
        {
            threadableLengthZ = 20;
            // Threadable section at top:
            tcy([0,0,-10], d=threadableHoleDiaVert, h=200);

            // Clearance section in middle of mount:
            translate([0,0,threadableLengthZ]) simpleChamferedCylinderDoubleEnded(d=threadClearanceHoleDia, h=magBlockZ-2*threadableLengthZ, cz=2);
        
            // Top Chamfer:
            translate([0,0,magBlockZ-threadableHoleDiaVert/2-1]) cylinder(d2=20, d1=0, h=10);
        
            // Bottom Chamfer:
            translate([0,0,-10+threadableHoleDiaVert/2+1]) cylinder(d1=20, d2=0, h=10);
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

module magCore()
{
    magCoreParams(x=magWidth, y=magLength, dy=magwellStopExtraY);
}

module magCoreRib()
{
    dy = (magRibLength-magLength)/2 + magwellStopExtraY;
    magCoreParams(x=magRibWidth, y=magRibLength, dy=dy);
}

module magCoreParams(x, y, dy)
{
    mwdx = x/2 - magBlockDia/2;
    mwdy = y/2 - magBlockDia/2;
    translate([0, magLength/2+dy, 0]) 
        hull() doubleX() doubleY() 
            translate([mwdx, mwdy, 0])
                simpleChamferedCylinderDoubleEnded(d=magBlockDia, h=magBlockZ, cz=magBlockCZ);
}

module viceSection()
{
    difference()
    {
        mainViceSection();
        translate([0,0,magBlockViceZ]) rotate([-magWellBottomAngle,0,0]) tcu([-200,-200,0], 400);
    }
}

viceDX = magBlockViceX/2 - magBlockViceDia/2;
viceDY = magBlockViceY/2 - magBlockViceDia/2;

module mainViceSection()
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
    // display() rotate([0,0,180]) translate([0,-magBlockViceY/2,magBlockZ+20]) rotate([0,180,0]) itemModule();
    // display() translate([0,0,0]) top();
    // displayGhost() tcy([0,0,0], d=6.2, h=40);

    display() itemModule();

	// display() translate([100,0,0]) itemModule();
    // display() translate([0,0,0]) top();

    // display() translate([100,0,0]) testModule();
}
else
{
	if(makeBlock) itemModule();
    if(makeTest) testModule();
    if(makeTop) top();
}

module testModule()
{
    difference()
    {
        itemModule();
        tcy([0,0,-400+40], d=400, h=400);
        tcy([0,0,75], d=400, h=400);
    }
}
