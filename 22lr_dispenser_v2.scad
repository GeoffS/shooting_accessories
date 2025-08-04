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
makeOrienterTest = false;


orienterLipZ = 1;

centerHoleDia = brassRimOD + 2;

orienterBaseCZ = 2;
orienterTopFlatWidth = 2;
orienterExteriorWallThickness = 2*orienterBaseCZ + orienterTopFlatWidth;
orienterBaseDia = centerHoleDia + 2*cartridgeLen + 2*orienterExteriorWallThickness;
orienterFunnelDia = orienterBaseDia - 2*orienterBaseCZ - 2*orienterTopFlatWidth;

orienterFunnelZ = 40;

orienterBaseZ = 3;

orienterZ = orienterBaseZ + cartridgeLen + orienterFunnelZ;

orienterSlotY = cartridgeLen + 2;

basicFunnelBottomZ = orienterZ-orienterFunnelZ;

centerHoleBottomOffsetY = centerHoleDia; ///2 + 1.5;
centerHoleBottomOffsetZ = basicFunnelBottomZ - 5; //orienterLipZ + brassRimOD;

module orienter()
{
    difference() 
    {
        // Exterior:
        simpleChamferedCylinderDoubleEnded(d=orienterBaseDia, h=orienterZ, cz=orienterBaseCZ);

        // Center Hole:
        tcy([0,0,-100], d=centerHoleDia, h=200);

        // Shift in center hole to reorient the cartridge:
        translate([0, 0, centerHoleBottomOffsetZ]) hull()
        {
            h = centerHoleBottomOffsetZ+nothing;
            shiftY = centerHoleDia;
            translate([0, 0, 0]) hull() 
            {
                difference()
                {
                    //scale([1/shiftFactor,1,1]) 
                    {
                        #tcy([0,shiftY,-30], d=centerHoleDia, h=30);
                        #translate([0,0,-nothing]) cylinder(d1=centerHoleDia, d2=0, h=centerHoleDia/2);
                    }
                    tcu([-30, -60, -30], 60);
                }
                tcy([0, centerHoleDia, -30], d=centerHoleDia, h=30);
            }
        }

        // Funnel:
        hull()
        {
            // Basic funnel shape:
            translate([0,0,basicFunnelBottomZ]) cylinder(d2=orienterFunnelDia, d1=0, h=orienterFunnelZ+nothing);

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
            echo(str("dia =",dia));
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
    translate([0, -centerHoleDia/2, 0]) hull()
    {
        z = centerHoleBottomOffsetZ - brassRimOD - 1;
        tcu([-50, -100+centerHoleDia, 0], [100, 100, z]);
        tcu([-50, -100, 0], [100, 100, z+centerHoleDia]);
    }
}

module orienterTest()
{
    difference()
    {
        extraXY = 4;
        orienter();
        // Clip +/-X:
        doubleX() tcu([centerHoleDia/2+extraXY, -200, -200], 400);
        // Clip +Y:
        tcu([-200, orienterSlotY+extraXY, -200], 400);
        // Clip -Y:
        tcu([-200, -(centerHoleDia/2+extraXY)-400, -200], 400);
        // Clip +Z:
        tcu([-200, -200, cartridgeLen+5], 400);
    }
}

    module clip(d=0)
    {
        //tc([-200, -400-d, -10], 400);
        tcu([-d, -200, -200], 400);
    }

if(developmentRender)
{
	// display() orienter();
    
    display() orienterTest();
}
else
{
	if(makeOrienter) orienter();
    if(makeOrienterTest) orienterTest();
}
