include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

mm = 25.4;

// Reference [1] = 12972670 RECEIVER, UPPER0001
//    [Y] Front lug hole center is 0.250"
//    [X] Base of lugs (= Z direction in design)

// Reference [2] = 12972670 RECEIVER, UPPER0002

// Reference [3] = 8448608 RECEIVER, LOWER0001

// Reference [4] = 8448641 LOWER RECEIVER FORGING0001

rearLugX = 0.496 * mm; // [1]
rearLugY = 0.450 * mm; // [1]
rearLugZ = 0.468 * mm; // [1]

rearLugCtrX = 0; // TBD
rearLugHoleCtrY = 6.375 * mm; // [1]
rearLugHoleCtrZ = 0.250 * mm; // [1]
rearLugFrontY = 6.151 * mm; // [1]
rearLugHoleDia = 0.25 * mm; // [1]
rearReceiverRadius = 0.750 * mm; // [2]

echo(str("rearLugHoleCtrY = ", rearLugHoleCtrY));

frontLugX = 0.496 * mm; // [1]
frontLugY = 0.431 * mm; // [1]

frontLugCtrX = 0; // TBD
frontLubHoleCtrY = 0; // [definition of 1]
frontLugFrontY = -0.219 * mm; // [1]
frontLugHoleCtrZ = 0.250 * mm; // [1]
frontLugHoleDia = 0.25 * mm; // TBD

rearOfUpperReceiverY = 6.999 * mm; // [2]

// X & Y need to come from additional drawings.
coverX = 1.0 * mm; // [2]
coverY = 8.0 * mm; // [TBD]
coverZ = 6.5; // Local dimension

coverOffsetY = -0.75 * mm; // TBD

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
            difference()
            {
                hull() translate([0, coverY/2+coverOffsetY, 0]) doubleX() doubleY() translate([coverX/2-coverCornerDia/2, coverY/2-coverCornerDia/2, -coverZ])
                {
                    simpleChamferedCylinderDoubleEnded(d=coverCornerDia, h=coverZ, cz=coverCZ);
                }

                // Upward curve of cover into the buffer-tube support at rear:
                translate([0, rearOfUpperReceiverY-rearReceiverRadius, -rearReceiverRadius]) difference() 
                {
                    {
                        tcu([-100,0,-100], 200);
                        rotate([0,90,0]) tcy([0,0,-150], d=2*rearReceiverRadius, h=300);
                    }
                }

                // Trim the sharp tail end 9mm behind rear of the lug:
                trimY = 9; // rearLugY/2
                tcu([-100, rearLugHoleCtrY+trimY, -100], 200);
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
                        translate([20,frontLugY/2,-frontLugX/2]) simpleChamferedCylinderDoubleEnded(d=frontLugY, h=frontLugX, cz=lugsCZ);
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

            // Rear Lug:
            difference()
            {
                rearLugHoleCtrXform()
                {
                    // The rear lug is defined by the position of its center (rearLugHoleCtrY) and its width (rearLugY).
                    translate([0,0,-rearLugHoleCtrZ+rearLugZ]) hull() rotate([0,90,0]) 
                    {
                        d = 2*lugsCZ + nothing;
                        doubleY() translate([0, rearLugY/2-d/2, -rearLugX/2]) simpleChamferedCylinderDoubleEnded(d=d, h=rearLugX, cz=lugsCZ);
                        translate([20,          0,     -rearLugX/2]) simpleChamferedCylinderDoubleEnded(d=rearLugY, h=rearLugX, cz=lugsCZ);
                    }
                }
                // Trim just below the base:
                tcu([-200, -200, -400-coverZ], 400);

                // The hole for the pin:
                rearLugHoleCtrXform() rotate([0,90,0]) 
                {
                    tcy([0,0,-100], d=rearLugHoleDia, h=200);
                    doubleZ() translate([0,0,rearLugX/2-rearLugHoleDia/2-0.5]) cylinder(d2=20, d1=0, h=10);
                }
            }
        }
    }
}

$fn=180;

module frontLugHoleCtrXform()
{
    translate([frontLugCtrX, frontLubHoleCtrY, frontLugHoleCtrZ]) children();
}

module rearLugHoleCtrXform()
{
    translate([rearLugCtrX, rearLugHoleCtrY, rearLugHoleCtrZ]) children();
}

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
    // tcu([-400+d, -20, -50], 400);
    // tcu([-200, -20, 0.25*mm-d], 400);
}

if(developmentRender)
{
	display() itemModule();

    displayGhost() translate([0, frontLubHoleCtrY, 0.25*mm]) rotate([0,90,0]) tcy([0,0,-20], d=1, h=40);
    displayGhost() translate([0, rearLugHoleCtrY, 0.25*mm]) rotate([0,90,0]) tcy([0,0,-20], d=1, h=40);
}
else
{
	itemModule();
}
