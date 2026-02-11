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
    }
}

module vericalHoleForThreadedRod(z)
{
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

module workbenchStand()
{
    baseOffsetY = -20;

    baseX = 100;
    baseY = 190 - baseOffsetY;
    baseZ = 10;

    // Approzimate height to clear a pistol grip:
    //   -------------------vv
    supportRiserZ = baseZ + 90;
    z = magStopHeight + supportRiserZ;

    difference()
    {
	    union()
        {
            workbenchBase(baseX, baseY, baseZ, baseOffsetY);
            workbenchCoreChamfer(baseZ);
            magCoreComplete(z=z);
            magwellSupportSection(magBlockViceZ=supportRiserZ);
        }

        vericalHoleForThreadedRod(z);
    }
}

module workbenchCoreChamfer(baseZ)
{
    cz = 10;
    // MAGIC!!
    // ------v
    z = cz + 5;
    d = 2*z;
    hull() translate([0 ,magBlockViceY/2, baseZ-1]) 
        doubleX() doubleY() 
            translate([viceDX, viceDY, 0]) 
                cylinder(d1=d, d2=0, h=z);
}

module workbenchBase(x, y, z, dy)
{
    baseCornerDia = 20;
    baseCZ = 2;

    // Base:
    workbenchBasePlate(x, y, z, dy, baseCornerDia, baseCZ);

    // Brims:
    difference()
    {
        brimDia = baseCornerDia + 15;
        workbenchBaseXform(baseCornerDia, x, y, dy) cylinder(d=brimDia, h=firstLayerHeight);

        // hull() workbenchBaseXform(baseCornerDia, x, y, dy) tcy([0,0,-1], d=baseCornerDia-2*baseCZ+0.42, h=z);
        minkowski()
        {
            hull() workbenchBaseXform(baseCornerDia, x, y, dy) simpleChamferedCylinderDoubleEnded(d=baseCornerDia, h=z, cz=baseCZ);
            tcy([], d=0.42, h=2*first)
        }
    }
}

module workbenchBasePlate(x, y, z, dy, baseCornerDia, baseCZ)
{
    hull() workbenchBaseXform(baseCornerDia, x, y, dy) simpleChamferedCylinderDoubleEnded(d=baseCornerDia, h=z, cz=baseCZ);
}

module workbenchBaseXform(dia, x, y, dy)
{
    mwdx = x/2 - dia/2;
    mwdy = y/2 - dia/2;
    translate([0, y/2+dy, 0]) 
        doubleX() doubleY() 
            translate([mwdx, mwdy, 0]) children();
}

module viceMount()
{
    z = magStopHeight + magBlockViceZ;
    difference()
    {
	    union()
        {
            magCoreComplete(z=z);
            magwellSupportSection(magBlockViceZ=magBlockViceZ);
        }

        vericalHoleForThreadedRod(z);

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

module magwellSupportSection(magBlockViceZ)
{
    difference()
    {
        mainMagwellSupportSection(magBlockViceZ);
        translate([0,0,magBlockViceZ]) rotate([-magWellBottomAngle,0,0]) tcu([-200,-200,0], 400);
    }
}

viceDX = magBlockViceX/2 - magBlockViceDia/2;
viceDY = magBlockViceY/2 - magBlockViceDia/2;

module mainMagwellSupportSection(magBlockViceZ)
{
    hull() translate([0,magBlockViceY/2,0]) 
        doubleX() doubleY() 
            translate([viceDX, viceDY, 0]) 
                simpleChamferedCylinderDoubleEnded(d=magBlockViceDia, h=magBlockViceZ+10, cz=magBlockViceCZ);
}

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
    tcu([0-d, -200, -200], 400);
}

if(developmentRender)
{
    // display() testModule();
    display() workbenchStand();
	// display() translate([100,0,0]) viceMount();
    // display() translate([-100,0,0]) top();
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
    x = 50;
    y = 70;
    z = 10;
    dy = 0;
    baseCornerDia = 20;
    baseCZ = 2;

    // Base:
    hull() workbenchBaseXform(baseCornerDia, x, y, dy) simpleChamferedCylinderDoubleEnded(d=baseCornerDia, h=z, cz=baseCZ);

    // difference()
    // {
    //     viceMount();
    //     tcy([0,0,-400+40], d=400, h=400);
    //     tcy([0,0,75], d=400, h=400);
    // }
}
