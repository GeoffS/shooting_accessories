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
magStopHeight = 50;
magWellBottomAngle = 10;

magStopExtraXY = 8;

magBlockViceX = magWidth + 2*magStopExtraXY;
magBlockViceY = magLength + 2*magStopExtraXY;
magBlockViceZ = 60;
magBlockZ = magStopHeight + magBlockViceZ;

magBlockDia = 4;
magBlockCZ = 1.5;

magBlockViceDia = 8;
magBlockViceCZ = 2.5;

// MAGIC!!
//  ----------------vvvvvvv
magwellStopExtraY = 6.12344;

echo(str("magBlockViceY = ", magBlockViceY));

// $fn = 180;

threadableHoleDia = 6.3; // 1/4-20
threadClearanceHoleDia = 6.7;

module top()
{
    z = 10;
    difference()
    {
        union()
        {
            mwdx = magWidth/2 - magBlockDia/2;
            mwdy = magLength/2 - magBlockDia/2;
            translate([0, 0, 0]) 
                hull() doubleX() doubleY() 
                    translate([mwdx, mwdy, 0])
                        simpleChamferedCylinderDoubleEnded(d=magBlockDia, h=2*z, cz=magBlockCZ);

            dx = 34/2 - magBlockViceDia/2;
            dy = (magLength+magStopExtraXY)/2 - magBlockViceDia/2;
            translate([0, magStopExtraXY/2, 0]) hull() 
                doubleX() doubleY() 
                    translate([dx, dy, 0]) 
                        simpleChamferedCylinderDoubleEnded(d=magBlockViceDia, h=z, cz=magBlockCZ);
        }

        // Vertical hole for clamp:
        translate([0,0,-50])
        {
            tcy([0,0,0], d=threadClearanceHoleDia+0.2, h=100);
        }
        translate([0,0,2*z-threadableHoleDia/2-1])
        {
            cylinder(d2=20, d1=0, h=10);
        }
        translate([0,0,-10+threadableHoleDia/2+1])
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

        // Vertical hole for clamp:
        translate([0,magBlockViceY/2,magBlockZ-50])
        {
            tcy([0,0,0], d=threadableHoleDia, h=100);
            tcy([0,0,0], d=threadClearanceHoleDia+0.2, h=35);
        }
        translate([0,magBlockViceY/2,magBlockZ-threadableHoleDia/2-1])
        {
            cylinder(d2=20, d1=0, h=10);
        }

        // Horiz holes to sit on vice jaws:
        translate([0,magBlockViceY/2,40]) doubleY() translate([0,20,0]) rotate([0,90,0]) 
        {
            // Threads:
            tcy([0,0,-100], d=threadableHoleDia, h=200);

            // Chamfer:
            doubleZ() translate([0,0,magBlockViceX/2-threadableHoleDia/2-0.6]) cylinder(d2=20, d1=0, h=10);

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
    // tcu([0, -200, -200], 400);
}

if(developmentRender)
{
	display() translate([100,0,0]) itemModule();
    display() translate([0,0,0]) top();

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
