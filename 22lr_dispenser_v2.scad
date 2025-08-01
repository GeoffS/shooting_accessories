include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

brassOD = 5.75 + 0.3;
brassRimOD = 6.9 + 0.25 ;
brassRimThickness = 1.1;
cartridgeLen = 26;

echo(str("brassRimOD = ", brassRimOD));

brassRimDiaDifference = brassRimOD - brassOD;
echo(str("brassRimDiaDifference = ", brassRimDiaDifference));

makeOrienter = false;


centerHoleDia = brassRimOD + 2;

orienterBaseCZ = 2;
orienterTopFlatWidth = 2;
orienterExteriorWallThickness = 2*orienterBaseCZ + orienterTopFlatWidth;
orienterBaseDia = centerHoleDia + 2*cartridgeLen + 2*orienterExteriorWallThickness;
orienterFunnelDia = orienterBaseDia - 2*orienterBaseCZ - 2*orienterTopFlatWidth;

orienterFunnelZ = 40;

orienterBaseZ = 3;

orienterZ = orienterBaseZ + cartridgeLen + orienterFunnelZ;

orienterLipZ = 1;

orienterSlotY = cartridgeLen + 2;

module orienter()
{
    difference() 
    {
        // Exterior:
        simpleChamferedCylinderDoubleEnded(d=orienterBaseDia, h=orienterZ, cz=orienterBaseCZ);

        // Center Hole:
        tcy([0,0,-100], d=centerHoleDia, h=200);
        rotate([5,0,0]) translate([0,0,-10+centerHoleDia/2+orienterLipZ]) cylinder(d2=0, d1=20, h=10);

        // Funnel:
        hull()
        {
            // Basic funnel shape:
            translate([0,0,orienterZ-orienterFunnelZ]) cylinder(d2=orienterFunnelDia, d1=0, h=orienterFunnelZ+nothing);

            // Slot funnel modifier:
            dia = brassOD + 2;
            offsetZctr = orienterZ - orienterFunnelZ;
            offsetZedge = offsetZctr + 14;
            offsetY = orienterSlotY - 1; // + 1.5;
            ctrY = offsetY - dia/2;

            echo(str("offsetZedge = ", offsetZedge));

            tsp([0,    0,  offsetZctr], d=dia);
            tsp([0, ctrY, offsetZedge], d=dia);
        }

        // Slot:
        hull()
        {
            dia = brassRimOD + 0.6;
            slotZ = 200;
            slotBottomZ = -slotZ/2;
            ctrY = orienterSlotY - brassOD/2;

            tsp([0,    0, slotBottomZ], d=brassOD);
            tsp([0, ctrY, slotBottomZ], d=brassOD);
            tsp([0,    0,       slotZ], d=brassOD);
            tsp([0, ctrY,       slotZ], d=brassOD);
        }
    }

    // Lip:
    tcu([-10, -20-brassRimOD/2+1.6, 0], [20, 20, orienterLipZ]);
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
    // tcu([-d, -200, -200], 400);
}

if(developmentRender)
{
	display() orienter();
}
else
{
	if(makeOrienter) orienter();
}
