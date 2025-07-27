include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

brassOD = 5.75 + 0.3;
brassRimOD = 6.9 + 0.25 ;
brassRimThickness = 1.1;
cartridgeLen = 26;

makeFunnel = false;


funnelVRimXY = 7;
funnelVDia = 3;

funnelBaseX = 70;
funnelBaseY = 80;
funnelBaseZ = 25;

underFunnelBaseZ = cartridgeLen + 5;
echo(str("underFunnelBaseZ = ", underFunnelBaseZ));

funnelBaseOD = 2 * funnelVRimXY;
funnelBaseCZ = 1;

echo(str("funnelBaseOD = ", funnelBaseOD));

funnelRimX = funnelBaseX - 2*funnelVRimXY;
funnelRimY = funnelBaseY - 2*funnelVRimXY;
funnelRimZ = 4;

funnelBackWallY = funnelBaseY - funnelVRimXY;

funnelVTopX = funnelRimX/2;
funnelVTopY = funnelBaseY - funnelVRimXY;

funnelVBottomFrontY = funnelBaseY - funnelVRimXY;
funnelVBottomBackY = funnelVRimXY;

funnelVBottomFrontZ = 4;
funnelVBottomBackZ = funnelBaseZ - funnelRimZ;

funnelFrontExtraY = 6; //funnelBaseZ - funnelVBottomFrontZ;

funnelVRimDia = funnelBaseOD - 4*funnelBaseCZ - 2;
echo(str("funnelVRimDia = ", funnelVRimDia));

funnelBaseTotalY = funnelBaseY + funnelFrontExtraY;

funnelCornerCtrX = funnelBaseX/2-funnelBaseOD/2;
funnelCornerCtrY = funnelBaseY/2-funnelBaseOD/2;

funnelDispenserAngle = 15;
funnelDispenserStartY = funnelBackWallY-brassOD/2;
funnelDispenserY = 5 * brassRimOD;

funnelDispenserOD = funnelBaseOD;

funnelCornerOffsetY = funnelBaseTotalY/2-funnelBaseOD/2;

brassSlotZ = cartridgeLen + 3;
brassSlotY = brassOD+0.2;
brassSlotTopDia = brassSlotY + 8;

brassRimSlotZ = brassRimThickness + 0.5;

module funnelCornersXform()
{
    translate([0, funnelBaseTotalY/2, 0])
        doubleX() doubleY() 
            translate([funnelCornerCtrX, funnelCornerOffsetY, 0]) 
                children();
}

module funnelBrassSlotXform()
{
    translate([0, funnelDispenserStartY, 0]) children(0);
    translate([0, funnelBaseOD/2+brassSlotTopDia/2, 0]) children(1);
}

module funnelBrassSlotTaper()
{
    h = 5; //brassRimSlotZ;
    cylinder(d2=brassSlotTopDia, d1=brassSlotY, h=h);
    tcy([0,0,h-nothing], d=brassSlotTopDia, h=100);
}

module trimFrontFunnelWall()
{
    translate([0, 70.65, 0]) rotate([-30.3,0,0]) tcu([-200, 0, 0], 400);
}

module funnel()
{
    difference()
    {
        union()
        {
            // Funnel exterior:
            hull()
            {
                funnelCornersXform() 
                    translate([0,0,-underFunnelBaseZ])
                        simpleChamferedCylinderDoubleEnded(d=funnelBaseOD, h=funnelBaseZ+underFunnelBaseZ, cz=funnelBaseCZ);
            }

            // Dispenser exterior:
            funnelDispenserXform() hull()
            {
                // MAGIC NUMBER!!! depends on funnelDispenserAngle
                // ------vvvv
                startH = 53.6; //57.6;
                translate([0,0,-startH])
                    simpleChamferedCylinderDoubleEnded(d=funnelDispenserOD, h=startH, cz=funnelBaseCZ);
                endH = 5;
                translate([0, funnelDispenserY, -endH])
                    simpleChamferedCylinderDoubleEnded(d=funnelDispenserOD, h=endH, cz=funnelBaseCZ);
            }
        }

        // Trim below -underFunnelBaseZ:
        tcu([-200, -200, -400-underFunnelBaseZ], 400);

        // Basic V:
        hull()
        {
            doubleX() funnelVCylinder(funnelVTopX, funnelVBottomBackY, funnelVBottomBackZ, isFront=false, isTop=true);
            doubleX() funnelVCylinder(funnelVTopX, funnelVBottomFrontY, funnelVBottomBackZ, isFront=true, isTop=true);

            doubleX() funnelVCylinder(0, funnelVBottomFrontY, funnelVBottomFrontZ, isFront=true, isTop=false);

            // Rim recess:
            funnelCornersXform() translate([0, 0, funnelBaseZ-funnelRimZ]) cylinder(d=funnelVRimDia, h=20);
        }

        // Inside chamfer:
        hull() funnelCornersXform() translate([0,0,funnelBaseZ-funnelVRimDia/2-funnelBaseCZ]) cylinder(d1=0, d2=12, h=6);

        // Front opening:
        // Slot in funnel:
        hull()
        {
            // MAGIC NUMBER!!! Depends on funnelDispenserAngle:
            // ------v
            extraZ = 3;
            funnelBrassSlotXform()
            {
                tcy([0, 0, -brassSlotZ+extraZ], d=brassSlotY, h=100);
                tcy([0, 0, -brassSlotZ+extraZ], d=brassSlotY, h=100);
            }
        }

        // Brass slot in funnel top chamfer:
        hull()
        {
            difference()
            {
                funnelBrassSlotXform()
                {
                    f = 0.252;
                    dyf = 3;
                    dzf =0.95 - f*dyf;
                    translate([0, dyf, -brassRimSlotZ+funnelVBottomFrontZ+dzf]) funnelBrassSlotTaper();

                    dyb = 0; //-0.6;
                    dzb = 0.0;
                    translate([0, dyb, -brassRimSlotZ+funnelVBottomBackZ-2*brassRimSlotZ-dzb]) funnelBrassSlotTaper();
                }

                // translate([0, 70.65, 0]) rotate([-30.3,0,0]) tcu([-200, 0, 0], 400);
                trimFrontFunnelWall();
            }
        }

        // Brass opening through front:
        funnelDispenserXform() hull()
        {
            tcy([0, 0, -brassSlotZ], d=brassSlotY, h=brassSlotZ+nothing);
            tcy([0, funnelBackWallY+70, -brassSlotZ], d=brassSlotY, h=brassSlotZ+nothing);
        }

        // Rim opening through front:
        brassRimSlotExtraZ = nothing;
        brassRimSlotDia = brassRimOD + 0.3;
        brassRimSlotDY = 3.0;
        difference()
        {
            funnelDispenserXform() 
            {
                // A bit of extra height inside the funnel:
                translate([0, brassRimSlotDY, -brassRimSlotZ]) hull()
                {
                    tcy([0, 0, 0], d=brassRimSlotDia, h=brassRimSlotZ+nothing);
                    // #tcy([0, brassRimSlotDia/2, 0], d=brassRimSlotDia, h=brassRimSlotZ+5);
                }
            }
            trimFrontFunnelWall();
        }

        // The main slot:
        funnelDispenserXform() hull()
        {
            tcy([0, brassRimSlotDY, -brassRimSlotZ], d=brassRimSlotDia, h=brassRimSlotZ+brassRimSlotExtraZ);
            tcy([0, funnelDispenserY+1.8, -brassRimSlotZ], d=brassRimSlotDia, h=brassRimSlotZ+brassRimSlotExtraZ);
        }

        // Peak the roof of the rim opening for printability:
        funnelDispenserXform() hull()
        {
            h = 20;
            rotate([90,0,0]) tcy([0, brassRimSlotExtraZ, -h], d=brassRimSlotDia, h=h, $fn=4);
        }
    }
}

module funnelDispenserXform()
{
    z = funnelVBottomFrontZ + 0.83;
    translate([0, funnelDispenserStartY, z]) rotate([-funnelDispenserAngle,0,0]) children();
}


module funnelVCylinder(x, y, z, isFront, isTop)
{
    fvd2 = funnelVDia/2;
    dy = isFront? 0: 1;
    dx = -fvd2; //isFront? 0: -fvd2;
    dz = isTop? 0: fvd2;
    translate([x+dx, y+dy, z+dz]) rotate([90,0,0]) cylinder(d=funnelVDia, h=1);
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
    // tcu([-d, -200, -200], 400);
}

if(developmentRender)
{
	display() funnel();
}
else
{
	if(makeFunnel) funnel();
}
