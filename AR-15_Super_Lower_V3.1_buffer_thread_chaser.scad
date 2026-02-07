include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

tapThreadsZ = 30;

tapOffsetZ = 5;
echo(str("tapOffsetZ = ", tapOffsetZ));

guideOD = 28.75;
guideZ = tapThreadsZ + tapOffsetZ;
guideCZ = firstLayerHeight + 10*layerHeight;

echo(str("guideCZ = ", guideCZ));

tapOD = 10;
tapOffsetAdj = 0.8;
tapRecessCtr = guideOD/2 - tapOD/2 + tapOffsetAdj;

tapFlutesID = 5.1;

tapFlutesInnerDia = 3.6;
tapFlutesInnerOffset = tapFlutesID/2 + tapFlutesInnerDia/2;
tapFlutesOuterDia = tapFlutesInnerDia;
tapFlutesOuterOffset = tapFlutesInnerOffset + tapFlutesInnerDia/2;
tapFlutesOuterAngle = 0;

stopZ = 25;

$fn=180;

module tap()
{
    difference()
    {
        // Core:
        cylinder(d=tapOD, h=200);

        // Flutes:
        for (a = [45, -45, 135, -135]) rotate([0,0,a])
        {
            hull()
            {
                translate([tapFlutesInnerOffset,0,-20]) cylinder(d=tapFlutesInnerDia, h=300);
                rotate([0,0,tapFlutesOuterAngle]) translate([tapFlutesOuterOffset,0,-20]) cylinder(d=tapFlutesOuterDia, h=300);
            }
        }
    }
}

module itemModule()
{
    difference()
    {
        union()
        {
            // Guide inside the threads:
            translate([0,0,guideZ+1]) mirror([0,0,1]) simpleChamferedCylinder(d=guideOD, h=guideZ+1, cz=guideCZ);

            // Stop to prevent going past the threaded part of the tap:
            difference()
            {
                translate([0,0,guideZ]) simpleChamferedCylinderDoubleEnded(d=guideOD+8, h=stopZ, cz=guideCZ);
                tcu([guideOD/2-0.099, -200, -200], 400);
                translate([0,0,guideZ+1+5]) hull()
                {
                    y1 = 6.4;
                    tcu([tapRecessCtr, -y1/2, 0], [100, y1, 0.1]);
                    dy = 2;
                    y2 = y1 + dy;
                    tcu([tapRecessCtr, -y2/2, dy/2], [100, y2, 100]);
                }
            }
        }

        // Tap section:
        translate([tapRecessCtr,0,tapOffsetZ]) tap();

        // Top shaft section:
        translate([tapRecessCtr,0,0])
        {
            d = tapOD + 0.6;
            translate([0,0,guideZ+1]) simpleChamferedCylinderDoubleEnded(d=d, h=300, cz=5);
            // Chamfer:
            translate([0,0,guideZ+stopZ-d/2-guideCZ]) cylinder(d2=20, d1=0, h=10);
        }
    }
}

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
    // tcu([-200, -d, -50], 400);
}

if(developmentRender)
{
	display() itemModule();

    // displayGhost() tcy([tapRecessCtr,0,0], d=3/8*25.4, h=100);
    // displayGhost() tcy([tapRecessCtr,0,0], d=tapFlutesID, h=guideZ);
}
else
{
	mirror([0,0,1]) itemModule();
}
