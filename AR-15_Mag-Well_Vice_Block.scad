include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

magWidth = 22.2; // Slightly less that 7/8"
magLength = 60.5;
magRibLength = 64;
magStopHeight = 70;
magWellBottomAngle = 10; //80 - 90;

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
magwellStopFactorZ = tan(magWellBottomAngle);

magwellStopY = magwellStopFactorY * magBlockViceY;
magwellStopExtraY = magwellStopFactorY * magStopExtraXY;

echo(str("magBlockViceY = ", magBlockViceY));
echo(str("magwellStopY = ", magwellStopY));

    

module itemModule()
{
	difference()
    {
        union()
        {
            // Core that goes into the mag-wall:
            translate([0, magwellStopExtraY, 0]) 
                tcu([-magWidth/2, 0, 0], [magWidth, magLength, magBlockZ]);

            // Block for vice:
            // tcu([-magBlockViceX/2, -magStopExtraXY, 0], [magBlockViceX, magBlockViceY, magBlockViceZ]);
            
            viceSection();
            // // Vice section perpendicular to the mag-well bottom:
            // magWellAngledStop();

            // // Vice section perpendicular to the mag-well-interior/rifle:
            // hull() translate([0, vdy-magStopExtraXY+magBlockViceDia/2, 0]) doubleX() doubleY() translate([vdx, vdy, 0]) simpleChamferedCylinderDoubleEnded(d=magBlockViceDia, h=magBlockViceZ, cz=magBlockViceCZ);
        }
    }
}

module viceSection()
{
    difference()
    {
        hull() translate([0, magLength/2, 0]) mainViceSection();
        #translate([0,0,magBlockViceZ-magBlockViceCZ]) angledStopXform() tcu([-200,-200,0], 400);
    }
    
    // magWellAngledStop();

}

module angledStopXform()
{
    rotate([magWellBottomAngle,0,0]) children();
}

module mainViceSection()
{
    vdx = magBlockViceX/2 - magBlockViceDia/2;
    vdy = magBlockViceY/2 - magBlockViceDia/2;
    translate([0,magwellStopExtraY,0]) doubleX() doubleY() translate([vdx, vdy, 0]) simpleChamferedCylinderDoubleEnded(d=magBlockViceDia, h=magBlockViceZ, cz=magBlockViceCZ);
}

module magWellAngledStop()
{
    vdx = magBlockViceX/2 - magBlockViceDia/2;
    vdy = magwellStopY/2 - magBlockViceDia/2;
    angledStopXform() doubleX() doubleY() 
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
