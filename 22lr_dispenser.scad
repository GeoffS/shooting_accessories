include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

brassOD = 5.75 + 0.3;
brassRimOD = 6.9 + 0.25 ;
brassRimThickness = 1.1;
cartridgeLen = 26;

makeDispenser = false;
makeFunnel = false;

dispenserTroughWall = 3;
dispenserTroughCornerDia = 2*dispenserTroughWall;
dispenserTroughX = brassRimOD + 2*dispenserTroughWall + 2;
dispenserTroughY = 40;
dispenserTroughZ = cartridgeLen + 2;

dispenserBaseX = dispenserTroughX + 6;
dispenserBaseY = dispenserTroughY;
dispenserBaseOffsetY = 10;
dispenserBaseZ = 2;
dispenserBaseCornerDia = 10;

dispenserTotalZ = dispenserBaseZ + dispenserTroughZ;

dispenserFrontZ = 4;

funnelVRimXY = 7;
funnelVDia = 3;

funnelBaseX = 70;
funnelBaseY = 80;
funnelBaseZ = 25;

underFunnelBaseZ = cartridgeLen + 5;

funnelBaseOD = 2 * funnelVRimXY;
funnelBaseCZ = 1;

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

funnelDispenserDropZ = 5;
funnelDispenserStartY = funnelBackWallY-brassOD/2;
funnelDispenserY = 5 * brassRimOD;

module funnelCornersXform()
{
    translate([0, funnelBaseTotalY/2, 0])
        doubleX() doubleY() 
            translate([funnelCornerCtrX, funnelBaseTotalY/2-funnelBaseOD/2, 0]) 
                children();
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
            translate([0, funnelDispenserStartY, -underFunnelBaseZ]) hull()
            {
                z = underFunnelBaseZ + funnelVBottomFrontZ + 0.83;
                startDZ = 9.36;
                translate([0,0,-startDZ])
                    simpleChamferedCylinderDoubleEnded(d=funnelBaseOD, h=z+startDZ, cz=funnelBaseCZ);
                endDZ = 25;
                translate([0, funnelDispenserY, endDZ])
                    simpleChamferedCylinderDoubleEnded(d=funnelBaseOD, h=z-funnelDispenserDropZ-endDZ, cz=funnelBaseCZ);
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
        slotZ = cartridgeLen + 3;
        brassSlotY = brassOD+0.2;
        // Slot in funnel:
        hull()
        {
            tcy([0, funnelDispenserStartY, -slotZ], d=brassSlotY, h=100);
            tcy([0, funnelBackWallY-cartridgeLen-1, -slotZ], d=brassSlotY, h=100);
        }

        // Brass opening through front:
        translate([0,0, -underFunnelBaseZ+2]) hull()
        {
            z = slotZ + 3.8;
            tcy([0, funnelBackWallY-brassSlotY/2, 0], d=brassSlotY, h=z);
            tcy([0, funnelBackWallY+70, 0], d=brassSlotY, h=z);
        }

        // Rim opening through front:
        z = brassRimThickness + 0.6;
        d = brassRimOD + 0.3;
        endY = funnelDispenserStartY + funnelDispenserY;
        magicDY = 1.8;
        magicDZ = -0.5;
        hull()
        {
            
            tcy([0, funnelDispenserStartY, funnelVBottomFrontZ], d=d, h=z);
            tcy([0, endY, funnelVBottomFrontZ-funnelDispenserDropZ], d=d, h=z);
            
            translate([0, magicDY, magicDZ])
                tcy([0, endY, funnelVBottomFrontZ-funnelDispenserDropZ], d=d, h=z);
        }

        // Peak the roof of the rim opening for printability:
        translate([0,0,1.73]) hull()
        {
            rotate([0,0,0]) translate([0, funnelDispenserStartY, funnelVBottomFrontZ]) rotate([90,0,0]) cylinder(d=d, h=0.1, $fn=4);
            rotate([0,0,0]) translate([0, endY, funnelVBottomFrontZ-funnelDispenserDropZ]) rotate([90,0,0]) cylinder(d=d, h=0.1, $fn=4);
        }
    }
}


module funnelVCylinder(x, y, z, isFront, isTop)
{
    fvd2 = funnelVDia/2;
    dy = isFront? 0: 1;
    dx = -fvd2; //isFront? 0: -fvd2;
    dz = isTop? 0: fvd2;
    translate([x+dx, y+dy, z+dz]) rotate([90,0,0]) cylinder(d=funnelVDia, h=1);
}

module dispenser()
{
	difference()
    {
        union()
        {
            // Trough exterior:
            hull()
            {
                dy = dispenserTroughZ - dispenserFrontZ + 6;
                doubleX() tcy([dispenserTroughX/2-dispenserTroughCornerDia/2, dispenserTroughCornerDia/2, dispenserTotalZ-dispenserFrontZ], d=dispenserTroughCornerDia, h=dispenserFrontZ);
                doubleX() tcy([dispenserTroughX/2-dispenserTroughCornerDia/2, dy-dispenserTroughCornerDia/2, 0], d=dispenserTroughCornerDia, h=dispenserTotalZ);
                doubleX() tcy([dispenserTroughX/2-dispenserTroughCornerDia/2, dispenserTroughY-dispenserTroughCornerDia/2, 0], d=dispenserTroughCornerDia, h=dispenserTotalZ);
            }
        
            // Base:
            translate([0, dispenserTroughY/2, 0]) 
                hull() 
                    doubleX() doubleY() 
                        translate([dispenserBaseX/2-dispenserBaseCornerDia/2, dispenserBaseY/2-dispenserBaseCornerDia/2, 0]) 
                            cylinder(d=dispenserBaseCornerDia, h=dispenserBaseZ);
        }

        recessBackDY = 5;
        // Cartridge slot:
        translate([0,0,dispenserBaseZ]) hull()
        {
            tcy([0, -10, 0], d=brassOD, h=100);
            tcy([0, dispenserTroughY-recessBackDY, 0], d=brassOD, h=100);
        }

        // Rim recess:
        translate([0,0,dispenserTotalZ-2]) hull() 
        {
            tcy([0,3,0], d=brassRimOD, h=10);
            tcy([0,dispenserTroughY-recessBackDY,0], d=brassRimOD, h=10);
        }
    }
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
    // tcu([-200, dispenserBaseY/2-400+d, -200], 400);
    // tcu([-d, -200, -200], 400);
}

if(developmentRender)
{
	// display() dispenser();
    display() funnel();
    display() translate([-70,0,0]) dispenser();
}
else
{
	if(makeDispenser) dispenser();
    if(makeFunnel) rotate([90,0,0]) funnel();
}
