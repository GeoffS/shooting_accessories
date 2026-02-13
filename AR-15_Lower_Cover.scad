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
rearLugHoleCtrY = 6.365 * mm; // [1]
rearLugHoleCtrZ = 0.2525 * mm; // [1]
rearLugFrontY = 6.151 * mm; // [1]
rearLugHoleDia = 0.25 * mm; // [1]
rearReceiverRadius = 0.750 * mm; // [2]

echo(str("rearLugHoleCtrY = ", rearLugHoleCtrY));

frontLugX = 0.496 * mm; // [1]
frontLugY = 0.431 * mm; // [1]

frontLugCtrX = 0; // TBD
frontLubHoleCtrY = 0; // [definition of 1]
frontLugFrontY = -0.219 * mm; // [1]
frontLugHoleCtrZ = 0.2525 * mm; // [1]
frontLugHoleDia = 0.25 * mm; // TBD

rearOfUpperReceiverY = 6.999 * mm; // [2]

frontLugHoleDiaPrinted = frontLugHoleDia + 0.2; // Printing a bit tight.
rearLugHoleDiaPrinted = rearLugHoleDia + 0.5; // Printing a bit tight.

// MAGIC!!
//   Match the top of the cover chamfer to the front of the lug
//   --------------------------vvvvvv
coverOffsetY = -(frontLugX/2 - 0.7358);

coverCornerDia = 12;
coverCZ = firstLayerHeight + 5*layerHeight;
echo(str("coverCZ = ", coverCZ));

coverZ = 8; // local dimension

coverTransitionDX = 0.5;

coverForwardX = 29; // local dimension (from measuring Mil-Spec and FDM lowers)
coverRearX = 22.5; // local dimension (from measuring Mil-Spec and FDM lowers)
coverForwardEndY = 88.5; // local dimension (from measuring Mil-Spec and FDM lowers)

ccd2 = coverCornerDia/2;
fwdX = coverForwardX/2 - ccd2;
fwdY1 = coverOffsetY + ccd2;
fwdY2  = coverForwardEndY - 1 - ccd2; // MAGIC!!

rearX = coverRearX/2 - ccd2;
rearY1 = coverForwardEndY - 6.5 + ccd2; // MAGIC!!
rearY2 = rearLugHoleCtrY + 4;
//  -----------------------^
//  Make a nice tail-section.
// MAGIC!!

lugsCZ = 0.8;

module coverCorner()
{
    z2 = coverZ/2;
    receiverSideCZ = firstLayerHeight + 5*layerHeight;
    outsideCZ = 12*layerHeight;

    translate([0,0,z2]) simpleChamferedCylinder(d=coverCornerDia, h=z2, cz=receiverSideCZ);
    translate([0,0,z2]) mirror([0,0,1]) simpleChamferedCylinder(d=coverCornerDia, h=z2+nothing, cz=outsideCZ);
}

module itemModule()
{
	difference()
    {
        union()
        {
            // Cover:
            difference()
            {
                union()
                {
                    // Forward cover:
                    translate([0,0,-coverZ]) hull() doubleX()
                    {
                        translate([fwdX, fwdY1, 0]) coverCorner();
                        translate([fwdX, fwdY2, 0]) coverCorner();
                    }
                    // Transition cover:
                    hull() doubleX()
                    {
                        translate([fwdX, fwdY2, -coverZ]) coverCorner();
                        translate([rearX, rearY1, -coverZ]) coverCorner();
                    }
                    // Rear cover:
                    translate([0,0,-coverZ]) hull() doubleX()
                    {
                        translate([rearX, rearY1, 0]) coverCorner();
                        translate([rearX, rearY2, 0]) coverCorner();
                    }
                }

                // Upward curve of cover into the buffer-tube support at rear:
                rearReceiverRadiusCorrYZ = 0.3; // Print a little forward.
                translate([0, rearOfUpperReceiverY-rearReceiverRadius-rearReceiverRadiusCorrYZ, -rearReceiverRadius]) difference() 
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
                tcu([-200, -200, -400-coverZ/2], 400);

                // The hole for the pin:
                frontLugHoleCtrXform() rotate([0,90,0]) 
                {
                    tcy([0,0,-100], d=frontLugHoleDiaPrinted, h=200);
                    doubleZ() translate([0,0,frontLugX/2-frontLugHoleDiaPrinted/2-0.5]) cylinder(d2=20, d1=0, h=10);
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
                    tcy([0,0,-100], d=rearLugHoleDiaPrinted, h=200);
                    doubleZ() translate([0,0,rearLugX/2-rearLugHoleDiaPrinted/2-0.5]) cylinder(d2=20, d1=0, h=10);
                }
            }
        }

        // Hole for pull-string:
        translate([0, rearLugHoleCtrY-13, -coverZ/2])
        {
            dCord = 4.2;
            tcy([0, 0, -30], d=dCord, h=100);
            doubleZ() translate([0,0,coverZ/2-dCord/2-2.8]) cylinder(d2=14, d1=0, h=7);
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
    tcu([-400+d, -20, -50], 400);
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
