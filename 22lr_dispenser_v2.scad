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
centerHoleBottomOffsetY = centerHoleDia; ///2 + 1.5;
centerHoleBottomOffsetZ = orienterLipZ + brassRimOD;

orienterBaseCZ = 2;
orienterTopFlatWidth = 2;
orienterExteriorWallThickness = 2*orienterBaseCZ + orienterTopFlatWidth;
orienterBaseDia = centerHoleDia + 2*cartridgeLen + 2*orienterExteriorWallThickness;
orienterFunnelDia = orienterBaseDia - 2*orienterBaseCZ - 2*orienterTopFlatWidth;

orienterFunnelZ = 40;

orienterBaseZ = 3;

orienterZ = orienterBaseZ + cartridgeLen + orienterFunnelZ;

orienterSlotY = cartridgeLen + 2;

module orienter()
{
    difference() 
    {
        // Exterior:
        simpleChamferedCylinderDoubleEnded(d=orienterBaseDia, h=orienterZ, cz=orienterBaseCZ);

        // Center Hole:
        tcy([0,0,-100], d=centerHoleDia, h=200);
        // #rotate([10,0,0]) translate([0,0,-10+centerHoleDia/2+orienterLipZ]) cylinder(d2=0, d1=20, h=10);
        translate([0, centerHoleDia, centerHoleBottomOffsetZ]) hull()
        {
            h = centerHoleBottomOffsetZ+nothing;
            d2 = 2*centerHoleDia;
            translate([0 ,-centerHoleDia, 0]) hull() 
            {
                difference()
                {
                    scale([0.5,1,1]) 
                    {
                        tcy([0,0,-30], d=d2, h=30); //sphere(d=d2);
                        translate([0,0,-nothing]) cylinder(d1=d2, d2=0, h=d2/2);
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
    tcu([-10, -20-centerHoleDia/2+centerHoleBottomOffsetY, 0], [20, 20, orienterLipZ]);
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
