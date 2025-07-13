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
        // Base:
        hull()
        {
            funnelCornersXform() simpleChamferedCylinder(d=funnelBaseOD, h=funnelBaseZ, cz=funnelBaseCZ);
        }

        // Top rim:
        // #tcu([-funnelRimX/2, funnelVRimXY, funnelBaseZ-funnelRimZ], [funnelRimX, funnelRimY, 20]);

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
            tcy([0, funnelBackWallY-brassOD/2, -10], d=brassOD, h=100);
            tcy([0, funnelBackWallY-cartridgeLen-1, -10], d=brassOD+0.2, h=100);
        }
        // Brass opening through front:
        hull()
        {
            tcy([0, funnelBackWallY-brassOD/2, funnelVBottomFrontZ-100+nothing], d=brassOD, h=100);
            tcy([0, funnelBackWallY+15, funnelVBottomFrontZ-100+nothing], d=brassOD, h=100);
        }
        // Rim opening through front:
        hull()
        {
            z = brassRimThickness + 0.3;
            d = brassRimOD + 0.3;
            tcy([0, funnelBackWallY-brassRimOD/2, funnelVBottomFrontZ], d=d, h=z);
            tcy([0, funnelBackWallY+15, funnelVBottomFrontZ], d=d, h=z);
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
