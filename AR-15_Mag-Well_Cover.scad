include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

mm = 25.4;

firstLayerHeight = 0.2;
layerHeight = 0.2;

// [9] = 8448639 PLATE, MAGAZINE CATCH0001

magCatchProtrusionIntoMagWell = 0.050 * mm; // [9]

magWidth = 22.4; // Slightly less that 7/8"
magLength = 60.7;
magRibLength = 64;
magRibWidth = 11;

magStopExtraXY = 8;

magBlockZ = 50;

magBlockDia = 6;
magBlockCZ = 2.2;

magLockRecessOffsetY = 39.2; //37.8;
magLockRecessOffsetZ = 31.5;
magLockRecessX = 1.7;
magLockRecessY = 9.5; //8.5; //13.4;
magLockRecessZ = 6.6;

magStopX = 1.6;

module itemModule()
{
	difference()
    {
	    union()
        {
            magCore();
            magCoreRib();
			magStop();
        }
        
        maglockRecess();

		// Ramp for mag-lock:
		translate([0, magLockRecessOffsetY, magBlockZ]) hull()
		{
			dx = max(magBlockCZ, magCatchProtrusionIntoMagWell + 1); //4.5;
			dy = 2;
			dz = 9;

			echo(str("Mag-Lock dx = ", dx));

			dx2 = dx*2;
			dy2 = dy*2;

			tcu([magWidth/2-dx,   0, 0], [10,     magLockRecessY, 0.1]);
			tcu([magWidth/2,    -dy, 0], [10, magLockRecessY+dy2, 0.1]);

			tcu([magWidth/2, 0, -dz-0.01], [dx, magLockRecessY, 0.01]);
		}
		
		// M3 Removal screw (handle):
		translate([0,magLength/2,0])
		{
			d = 3.0;
			cz = firstLayerHeight + 2*layerHeight;
			translate([0,0,-1]) simpleChamferedCylinder(d=d, h=10, cz=d/2);
			translate([0,0,-5+d/2+cz]) cylinder(d1=10, d2=0, h=5);
		}
	}
}
module maglockRecess()
{
	maglockXform() hull()
	{
		x2 = magLockRecessX*2;
		dx = 0.8; // ca. 2X wall-thickness
		tcu([magWidth/2,                  0,   magLockRecessZ+dx], [10,    magLockRecessY,    0.1]);
		tcu([magWidth/2-dx, -magLockRecessX, magLockRecessZ-0.01], [dx,    magLockRecessY+x2, 0.01]);
	}

	maglockXform() hull()
	{
		x2 = magLockRecessX*2;

		tcu([magWidth/2-magLockRecessX,               0, magLockRecessZ-0.1], [10,    magLockRecessY, 0.1]);
		tcu([magWidth/2,                -magLockRecessX, magLockRecessZ-0.1], [10, magLockRecessY+x2, 0.1]);

		tcu([magWidth/2-magLockRecessX,               0, 0], [10,    magLockRecessY, 0.1]);
		tcu([               magWidth/2, -magLockRecessX, 0], [10, magLockRecessY+x2, 0.1]);
	}
}

module magStop()
{
	maglockXform() hull()
	{
		x2 = magStopX*2;
		tcu([0,        0, -0.1], [magWidth/2+magStopX, magLockRecessY,    0.1]);
		tcu([0,-magStopX, -0.1], [         magWidth/2, magLockRecessY+x2, 0.1]);

		tcu([0,         0,-3.0], [magWidth/2+magStopX, magLockRecessY,    0.1]);
		tcu([0,-magStopX, -3.0], [         magWidth/2, magLockRecessY+x2, 0.1]);

		tcu([0,0,-6.0], [magWidth/2, magLockRecessY, 0.1]);
	}
}

// Lower edge of the mag-lock recess:
module maglockXform()
{
	translate([0, magLockRecessOffsetY, magLockRecessOffsetZ]) children();
}

module magCore()
{
    frontDia = 12;

	mwdx = magWidth/2 - magBlockDia/2;
    mwdy = magLength - magBlockDia/2;

    hull() doubleX()
	{
		translate([3.5,frontDia/2,0]) simpleChamferedCylinderDoubleEnded(d=frontDia, h=magBlockZ, cz=magBlockCZ);

		translate([mwdx, 11, 0])
            simpleChamferedCylinderDoubleEnded(d=magBlockDia, h=magBlockZ, cz=magBlockCZ);
		translate([mwdx, mwdy, 0])
            simpleChamferedCylinderDoubleEnded(d=magBlockDia, h=magBlockZ, cz=magBlockCZ);
	}
}

module magCoreRib()
{
    mwdx = magRibWidth/2 - magBlockDia/2;
    mwdy = magRibLength - magBlockDia/2;

	hull() doubleX() 
	{
		translate([mwdx, 40, 0])
            simpleChamferedCylinderDoubleEnded(d=magBlockDia, h=magBlockZ, cz=magBlockCZ);
		translate([mwdx, mwdy, 0])
            simpleChamferedCylinderDoubleEnded(d=magBlockDia, h=magBlockZ, cz=magBlockCZ);
	}   
}

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
	// tcu([-200, magLength/2, -20], 400);
	tcu([-200, magLockRecessOffsetY+magLockRecessY/2, -200], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	itemModule();
}
