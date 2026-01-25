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
magCatchX = 1.4;
magCatchY = 13.4;
magCatchZ = 6.5;

magStopExtraXY = 8;

magBlockViceX = magWidth + 2*magStopExtraXY;
magBlockViceY = magLength + 2*magStopExtraXY;
magBlockViceZ = 60;
magBlockZ = magStopHeight + magBlockViceZ;

magBlockDia = 4;
magBlockCZ = 1.5;

magBlockViceDia = 8;
magBlockViceCZ = 2.5;

// From pre-MAGIC conversion:
// ECHO: "magwellStopFactorY = 1.01543"
// ECHO: "magBlockViceY = 76.5"
// ECHO: "magwellStopY = 77.6804"
// ECHO: "magwellStopFactorY * magStopExtraXY = 8.12344"
// ECHO: "magwellStopExtraY = 6.12344"
// ECHO: "mainMagWellAngledStop() dy = 9.8754"
// ECHO: "mainMagWellAngledStop() dy = 9.8754"

// MAGIC!!
// Probably...
//vvvvvvvvvvvvvvvv
// magwellStopFactorY = 1/cos(magWellBottomAngle);
// magwellStopFactorY = 1.01543;
// echo(str("magwellStopFactorY = ", magwellStopFactorY));

// MAGIC!!
//  -----------vvvvvvv
magwellStopY = 77.6804; //magwellStopFactorY * magBlockViceY;

// MAGIC!!
//  ----------------vvvvvvv
magwellStopExtraY = 6.12344; //magwellStopFactorY * magStopExtraXY - 2;

echo(str("magBlockViceY = ", magBlockViceY));
echo(str("magwellStopY = ", magwellStopY));
// echo(str("magwellStopFactorY * magStopExtraXY = ", magwellStopFactorY * magStopExtraXY));
echo(str("magwellStopExtraY = ", magwellStopExtraY));

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
            magCatchRamp();
            
            // Angled piece that goes into the vice:
            hull()
            {
                viceSection();
                magWellAngledStop();
            }
        }

        magCatchRecess();
    }
}

module magCatchXform()
{
    children();
}

module magCatchRamp()
{

}

module magCatchRecess()
{

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
    // // MAGIC!!!!!!!
    // //   vvvvvvv
    // fy = 0.16459;

    // MAGIC!!!!!!!
    //   vvvvvvv
    dy =  9.8754; //magBlockViceZ * fy;
    echo(str("mainMagWellAngledStop() dy = ", dy));

    // MAGIC!!
    //  --vvvvvvv
    vdy = 35.3778; //(magwellStopY/2 - magBlockViceDia/2) * 1.01543; //magwellStopFactorY;
    echo(str("mainMagWellAngledStop() vdy = ", vdy));

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
	display() translate([0,0,nothing]) itemModule();

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
