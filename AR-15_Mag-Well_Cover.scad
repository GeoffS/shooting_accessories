include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;magWidth = 22.4; // Slightly less that 7/8"
magLength = 60.7;
magRibLength = 64;
magRibWidth = 11;

magCatchX = 4;
magCatchY1 = -6.6;
magCatchY2 = -18.6;
magCatchCtrY = (magCatchY1 + magCatchY2)/2;
magCatchY = -(magCatchY2 - magCatchY1) + 1;
magCatchZ = 19.5;

echo(str("magCatchCtrY = ", magCatchCtrY));
echo(str("magCatchY = ", magCatchY));

magStopExtraXY = 8;

magBlockViceX = magWidth + 2*magStopExtraXY;
magBlockViceY = magLength + 2*magStopExtraXY;
magBlockZ = 50;

magBlockDia = 4;
magBlockCZ = 1.5;

magLockRecessOffsetY = 37.8;
magLockRecessOffsetZ = 31.5;
magLockRecessX = 1.7;
magLockRecessY = 13.4;
magLockRecessZ = 6.6;

magStopX = 1.6;

// MAGIC!!
//  ----------------vvvvvvv
magwellStopExtraY = 0; //6.12344;

echo(str("magBlockViceY = ", magBlockViceY));

echo(str("magStopExtraXY-magwellStopExtraY = ", magStopExtraXY-magwellStopExtraY));

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
        
        // Mag-catch slot:
        // mcDia = 4;
        // translate([10+magWidth/2-magCatchX+mcDia/2, magBlockViceY/2-magCatchCtrY, magBlockZ-magCatchZ-mcDia/2]) 
        //     hull() doubleX() doubleY() translate([10, magCatchY/2-mcDia/2, 0])
        //         simpleChamferedCylinderDoubleEnded(d=mcDia, h=100, cz=mcDia/2-nothing);
		maglockRecess();
		
	}
}
module maglockRecess()
{
	maglockXform()
	{
		tcu([magWidth/2-magLockRecessX,0,0], [10, magLockRecessY, magLockRecessZ]);
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
    magCoreParams(x=magWidth, y=magLength, dy=magwellStopExtraY);
}

module magCoreRib()
{
    dy = (magRibLength-magLength)/2 + magwellStopExtraY;
    magCoreParams(x=magRibWidth, y=magRibLength, dy=dy);
}

module magCoreParams(x, y, dy)
{
    mwdx = x/2 - magBlockDia/2;
    mwdy = y/2 - magBlockDia/2;
    translate([0, magLength/2+dy, 0]) 
        hull() doubleX() doubleY() 
            translate([mwdx, mwdy, 0])
                simpleChamferedCylinderDoubleEnded(d=magBlockDia, h=magBlockZ, cz=magBlockCZ);
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
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
