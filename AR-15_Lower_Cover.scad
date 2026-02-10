include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

mm = 25.4;

// Reference [1] = [Y] Front lug hole center is 0.250"
//               = [X] Base of lugs (= Z direction in design)

reaLugX = 0.5 * mm; // TBD
rearLugY = 0.450 * mm; // [1]
rearLugZ = 0.468 * mm; // [1]

rearLugCtrX = 0; // TBD
rearLugHoleCtrY = 6.375 * mm; // [1]
rearLubHoleCtrZ = 0.250 * mm; // [1]
rearLugFrontY = 6.151 * mm; // [1]
rearLugHoleDia = 0.25 * mm; // TBD

frontLugX = 0.5 * mm; // TBD
frontLugY = 0.431 * mm; // [1]

frontLugCtrX = 0; // TBD
frontLubHoleCtrY = 0; // [definition of 1]
frontLugFrontY = -0.219 * mm; // [1]
frontLugHoleCtrZ = 0.250 * mm; // [1]
frontLugHoleDia = 0.25 * mm; // TBD

// X & Y need to come from additional drawings.
coverX = 1.0 * mm;
coverY = 7.0 * mm;
coverZ = 4;

coverOffsetY = -1.0 * mm; // TBD

lugsCZ = 0.8;

coverCornerDia = 8;
coverCZ = firstLayerHeight + 5*layerHeight;
echo(str("coverCZ = ", coverCZ));

module itemModule()
{
	difference()
    {
        union()
        {
            // Cover:
            hull() translate([0, coverY/2+coverOffsetY, 0]) doubleX() doubleY() translate([coverX/2-coverCornerDia/2, coverY/2-coverCornerDia/2, -coverZ])
            {
                simpleChamferedCylinderDoubleEnded(d=coverCornerDia, h=coverZ, cz=coverCZ);
            }

            // Front Lug:
            difference()
            {
                frontLugHoleCtrXform()
                {
                    // The front lug is defined by the position of its front face relative to 
                    // the hole's center(frontLugFrontY) and the width of the lug (frontLugY).
                    translate([0,frontLugFrontY,0]) hull() rotate([0,90,0]) 
                    {
                        translate([0,frontLugY/2,-frontLugX/2]) simpleChamferedCylinderDoubleEnded(d=frontLugY, h=frontLugX, cz=lugsCZ);
                        translate([10,frontLugY/2,-frontLugX/2]) simpleChamferedCylinderDoubleEnded(d=frontLugY, h=frontLugX, cz=lugsCZ);
                    }
                }
                // Trim just below the base:
                tcu([-200, -200, -400-nothing], 400);

                // The hole for the pin:
                frontLugHoleCtrXform() rotate([0,90,0]) 
                {
                    tcy([0,0,-100], d=frontLugHoleDia, h=200);
                    doubleZ() translate([0,0,frontLugX/2-frontLugHoleDia/2-0.5]) cylinder(d2=20, d1=0, h=10);
                }
            }
        }
    }
}

module frontLugHoleCtrXform()
{
    translate([frontLugCtrX, frontLubHoleCtrY, frontLugHoleCtrZ]) children();
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
