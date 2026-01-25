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
magStopHeight = 70;
magWellBottomAngle = 10;

magCatchRampBottomZ = 60;
magCatchTopZ = 63.5;

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
// Probably...
//vvvvvvvvvvvvvvvv
magwellStopFactorY = 1/cos(magWellBottomAngle);

echo(str("magwellStopFactorY = ", magwellStopFactorY));

magwellStopY = magwellStopFactorY * magBlockViceY;
// MAGIC!!
//  ------------------------------------------------------v
magwellStopExtraY = magwellStopFactorY * magStopExtraXY - 2;

echo(str("magBlockViceY = ", magBlockViceY));
echo(str("magwellStopY = ", magwellStopY));

$fn = 180;

module itemModule()
{
	difference()
    {
        union()
        {
            // Core that goes into the mag-wall:
            magCore();
            magCoreRib();
            
            // Angled piece that goes into the vice:
            hull()
            {
                viceSection();
                magWellAngledStop();
            }
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

module angledStopXform()
{
    rotate([magWellBottomAngle,0,0]) children();
}

module angledStopTrimXform()
{
    // MAGIC!!
    // -----------------------------------------vvvvv
    translate([0,0,magBlockViceZ-magBlockViceCZ-0.573]) angledStopXform() children();
}

module viceSection()
{
    difference()
    {
        mainViceSection();
        angledStopTrimXform() tcu([-200,-200,0], 400);
    }
}

viceDX = magBlockViceX/2 - magBlockViceDia/2;

module mainViceSection()
{
    vdy = magBlockViceY/2 - magBlockViceDia/2;
    hull() translate([0,magBlockViceY/2,0]) 
        doubleX() doubleY() 
            translate([viceDX, vdy, 0]) 
                simpleChamferedCylinderDoubleEnded(d=magBlockViceDia, h=magBlockViceZ, cz=magBlockViceCZ);
}

module magWellAngledStop()
{
    difference()
    {
        mainMagWellAngledStop();
        angledStopTrimXform() tcu([-200,-200,-400], 400);
    }
}

module mainMagWellAngledStop()
{
    // MAGIC!!!!!!!
    //   vvvvvvv
    fy = 0.16459;
    dy = magBlockViceZ * fy;
    echo(str("mainMagWellAngledStop() dy = ", dy));

    vdy = (magwellStopY/2 - magBlockViceDia/2) * magwellStopFactorY;

    hull() translate([0, dy, 0]) angledStopXform() translate([0,magwellStopY/2,0]) 
        doubleX() doubleY() 
            translate([viceDX, vdy, 0]) 
                simpleChamferedCylinderDoubleEnded(d=magBlockViceDia, h=magBlockViceZ, cz=magBlockViceCZ);
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();

    display() translate([100,0,0]) testModule();
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
        tcy([0,0,-400+55], d=400, h=400);
        tcy([0,0,80], d=400, h=400);
    }
}
