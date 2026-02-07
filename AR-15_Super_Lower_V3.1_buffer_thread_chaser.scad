include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

guideOD = 28.75;
guideZ = 15; //30;
guideCZ = firstLayerHeight + 5*layerHeight;

echo(str("guideCZ = ", guideCZ));

tapOD = 10;
tapOffsetAdj = 0.5;
tapRecessCtr = guideOD/2 - tapOD/2 + tapOffsetAdj;

tapFlutesID = 5.1;

tapFlutesInnerDia = 3.6;
tapFlutesInnerOffset = tapFlutesID/2 + tapFlutesInnerDia/2;
tapFlutesOuterDia = tapFlutesInnerDia;
tapFlutesOuterOffset = tapFlutesInnerOffset + tapFlutesInnerDia/2;
tapFlutesOuterAngle = 0;

module tap()
{
    translate([tapRecessCtr, 0, -10]) difference()
    {
        // Core:
        translate([0, 0, -10]) cylinder(d=tapOD, h=200);

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
        simpleChamferedCylinderDoubleEnded(d=guideOD, h=guideZ, cz=guideCZ);

        tap();
    }
}

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();

    // displayGhost() tcy([tapRecessCtr,0,0], d=3/8*25.4, h=100);
    displayGhost() tcy([tapRecessCtr,0,0], d=tapFlutesID, h=guideZ);
}
else
{
	itemModule();
}
