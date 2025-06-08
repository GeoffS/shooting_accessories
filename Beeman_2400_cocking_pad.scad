include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

gunTopX = 17.0;
gunTopFlatX = 6.5;
gunBottomX = 35.4;

gunY = 12.7;
gunTopToFlatY = 2.6; //3.0; //4.2;

gunPortDia = 8.5;
gunPortCtrY = gunY - 1.0 - gunPortDia/2;
gunPortCtrZ = 8 - gunPortDia/2;

totalY = gunY + gunTopToFlatY;

echo(str("gunPortCtrY = ", gunPortCtrY));

padTopDia = 35;
padBottomDia = 12;
padBottomX = gunBottomX + padBottomDia;
padExtraY = gunTopToFlatY;
padY = gunY + padExtraY;
padZ = 15;
padCZ = 2;

// padZ = 40;

echo(str("padBottomX = ", padBottomX));
echo(str("padY = ", padY));

module itemModule()
{
	difference()
    {
        exterior();
        interior();
    }

    // Piece to rest on the top of the gun:
    intersection()
    {
        tcu([-gunTopFlatX/2, totalY, 0], [gunTopFlatX, 100, padZ]);

        exterior();
    }

    // Piece to push against the "ejection port":
    difference()
    {
        translate([0, gunPortCtrY, gunPortCtrZ]) rotate([0,90,0])
        {
            hull()
            {
                h = 35;
                tcy([0,0,-h/2], d=gunPortDia, h=h);
                tcy([20,0,-h/2], d=gunPortDia, h=h);
            }
        }

        // Trim below Z=0:
        tcu([-200,-200,-400], 400);

        // Trim center:
        x = gunTopX + 2;
        tcu([-x/2, 0, -10], [x, 200, 200]);

        // Chamfer the corner:
        doubleX() translate([x/2, gunPortCtrY-gunPortDia/2, 0]) rotate([0,-45,45]) tcu([-10+1, -5, -5], 10);
    }
}

padBottomCylOffsetCtr = padBottomX/2-padBottomDia/2+padCZ;

module exterior()
{
    hull()
    {
        // Top of gun
        translate([0, padY, 0]) simpleChamferedCylinderDoubleEnded(d=padTopDia, h=padZ, cz=padCZ);
        // Bottom of gun:
        doubleX() translate([padBottomCylOffsetCtr,0,0]) simpleChamferedCylinderDoubleEnded(d=padBottomDia, h=padZ, cz=padCZ);
        }
}

module interior()
{
    // Slot at top:
    hull()
    {
        tcy([0, gunY, -1], d=gunTopX, h=padZ+2);
        tcy([0, padY, -1], d=gunTopX, h=padZ+2);
    }

    gunProfile();

    // Chamfer the bottom opening:
    // translate([padBottomX/2-padBottomDia/2+padCZ,0,0]) simpleChamferedCylinderDoubleEnded(d=padBottomDia, h=padZ, cz=padCZ);
    //preRotationOffsetX = -padBottomDia/2 + padCZ - 0.22;
    doubleX() translate([padBottomCylOffsetCtr,0,0]) 
    {
        xy = 10;
        rotate([0,0,45]) tcu([-xy-padBottomDia/2+padCZ-0.23,-xy/2,0], [xy, xy, 200]);
        //%cylinder(h = 200, d=0.4);
    }

}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();
    // displayGhost()gunProfile();
}
else
{
	itemModule();
}

module gunProfile()
{
    gunSidesY = 7 + 5;
    gunProfile =[
        [ gunBottomX/2, -gunSidesY], 
        [-gunBottomX/2, -gunSidesY], 
        [-gunBottomX/2, 0],
        [-gunTopX/2, gunY],
        [ gunTopX/2, gunY],
        [ gunBottomX/2, 0]
    ];

    translate([0,0,-10]) linear_extrude(height=padZ+20) polygon(points=gunProfile, convexity=4);
}