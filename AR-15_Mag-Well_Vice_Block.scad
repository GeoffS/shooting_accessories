include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

magWidth = 22.2; // Slightly less that 7/8"
magLength = 60.5;
magRibLength = 64;
magStopHeight = 70;

magStopExtraXY = 8;

magBlockViceX = magWidth + 2*magStopExtraXY;
magBlockViceY = magLength + 2*magStopExtraXY;
magBlockViceZ = 40;
magBlockZ = magStopHeight + magBlockViceZ;

magBlockDia = 4;
magBlockCZ = 1.5;

magBlockViceDia = 8;
magBlockViceCZ = 2.5;

module itemModule()
{
	difference()
    {
        union()
        {
            // Core that goes into the mag-wall:
            tcu([-magWidth/2, 0, 0], [magWidth, magLength, magBlockZ]);

            // Block for vice:
            // tcu([-magBlockViceX/2, -magStopExtraXY, 0], [magBlockViceX, magBlockViceY, magBlockViceZ]);
            vdx = magBlockViceX/2 - magBlockViceDia/2;
            vdy = magBlockViceY/2 - magBlockViceDia/2;
            hull() translate([0, vdy-magStopExtraXY+magBlockViceDia/2, 0]) doubleX() doubleY() translate([vdx, vdy, 0]) simpleChamferedCylinderDoubleEnded(d=magBlockViceDia, h=magBlockViceZ, cz=magBlockViceCZ);
        }
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
