include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

makeBlock = false;
makeTest = false;

firstLayerHeight = 0.2;
layerHeight = 0.2;
magWidth = 22.2; // Slightly less that 7/8"
magLength = 60.5;
magRibLength = 64;
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

magwellStopFactorY = 1/cos(magWellBottomAngle);
// magwellStopFactorZ = tan(magWellBottomAngle);

echo(str("magwellStopFactorY = ", magwellStopFactorY));
// echo(str("magwellStopFactorZ = ", magwellStopFactorZ));

magwellStopY = magwellStopFactorY * magBlockViceY;
magwellStopExtraY = magwellStopFactorY * magStopExtraXY;

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
            mwdx = magWidth/2 - magBlockDia/2;
            mwdy = magLength/2 - magBlockDia/2;
            // %tcu([-magWidth/2, magwellStopExtraY, 0], [magWidth, magLength, magBlockZ]);
            translate([0, magLength/2+magwellStopExtraY, 0]) 
                hull() doubleX() doubleY() 
                    translate([mwdx, mwdy, 0])
                        simpleChamferedCylinderDoubleEnded(d=magBlockDia, h=magBlockZ, cz=magBlockCZ);
            
            // Angled piece that goes into the vice:
            hull()
            {
                viceSection();
                magWellAngledStop();
            }
        }
    }
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
    //   vvvvvv
    fy = 0.16459; //0.1645; //0.15299;
    dy = magBlockViceZ * fy;
    echo(str("mainMagWellAngledStop() dy = ", dy));

    // vdx = magBlockViceX/2 - magBlockViceDia/2;
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
        tcy([0,0,-400+50], d=400, h=400);
        tcy([0,0,95], d=400, h=400);
    }
}
