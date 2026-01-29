include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

makeBlock = false;
makeTest = false;

firstLayerHeight = 0.2;
layerHeight = 0.2;

magWidth = 22.2; // Slightly less that 7/8"
magLength = 60.5;
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

        // Horiz holes to sit on vice jaws:
        translate([0,magBlockViceY/2,40]) doubleY() translate([0,20,0]) rotate([0,90,0]) 
        {
            tcy([0,0,-100], d=6.3, h=200);
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

module mainViceSection()
{
    vdy = magBlockViceY/2 - magBlockViceDia/2;
    hull() translate([0,magBlockViceY/2,0]) 
        doubleX() doubleY() 
            translate([viceDX, vdy, 0]) 
                simpleChamferedCylinderDoubleEnded(d=magBlockViceDia, h=magBlockViceZ+10, cz=magBlockViceCZ);
}

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
    tcu([0, -200, -200], 400);
}

if(developmentRender)
{
	display() translate([0,0,nothing]) itemModule();

    // display() translate([100,0,0]) testModule();
}
else
{
	if(makeBlock) itemModule();
    if(makeTest) testModule();
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
