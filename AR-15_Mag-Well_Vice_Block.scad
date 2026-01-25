include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;
magWidth = 22.2; // Slightly less that 7/8"
magLength = 60.5;
magRibLength = 64;
magStopHeight = 70;
magWellBottomAngle = 10;

magStopExtraXY = 8;

magBlockViceX = magWidth + 2*magStopExtraXY;
magBlockViceY = magLength + 2*magStopExtraXY;
magBlockViceZ = 40;
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
            tcu([-magWidth/2, magwellStopExtraY, 0], [magWidth, magLength, magBlockZ]);
            
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
    translate([0,0,magBlockViceZ-magBlockViceCZ]) angledStopXform() children();
}

module viceSection()
{
    difference()
    {
        mainViceSection();
        angledStopTrimXform() tcu([-200,-200,0], 400);
    }
}

module mainViceSection()
{
    vdx = magBlockViceX/2 - magBlockViceDia/2;
    vdy = magBlockViceY/2 - magBlockViceDia/2;
    hull() translate([0,magBlockViceY/2,0]) doubleX() doubleY() translate([vdx, vdy, 0]) simpleChamferedCylinderDoubleEnded(d=magBlockViceDia, h=magBlockViceZ, cz=magBlockViceCZ);
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

    vdx = magBlockViceX/2 - magBlockViceDia/2;
    vdy = (magwellStopY/2 - magBlockViceDia/2) * magwellStopFactorY;

    hull() translate([0, dy, 0]) angledStopXform() translate([0,magwellStopY/2,0]) doubleX() doubleY() 
    {
        translate([vdx, vdy, 0]) simpleChamferedCylinderDoubleEnded(d=magBlockViceDia, h=magBlockViceZ, cz=magBlockViceCZ);
    }
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	itemModule();
}
