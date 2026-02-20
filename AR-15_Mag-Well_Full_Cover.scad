include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

mm = 25.4;

firstLayerHeight = 0.2;
layerHeight = 0.2;

makeNoHandle = false;
makeCordHandle = false;
makeBoltCatchNoRingTab = false;
makeBoltCatchWithRingTab = false;

// [9] = 8448639 PLATE, MAGAZINE CATCH0001

magCatchProtrusionIntoMagWell = 0.050 * mm; // [9]

magWidth = 22.4; // Slightly less that 7/8"
magLength = 60.7;
magRibLength = 64;
magRibWidth = 11;

magStopExtraXY = 8;

magWellBottomAngle = 10.3;

magBlockDia = 6;
magBlockCZ = 2.2;

topOfMagwellZ = 55;
magBlockFrontZ = topOfMagwellZ - 5;

magBlockCylindersZ = 100;
magBlockCylindersOffsetZ = magBlockFrontZ - magBlockCylindersZ;

echo(str("magBlockCylindersOffsetZ = ", magBlockCylindersOffsetZ));

magLockRecessOffsetY = 39.2;
magLockRecessOffsetZ = magBlockFrontZ - 18.5;
magLockRecessX = 1.9;
magLockRecessY = 11; //10.5;
magLockRecessZ = 6.6;

echo(str("magLockRecessOffsetZ = ", magLockRecessOffsetZ));

magStopX = 1.6;

module noHandle()
{
    echo("--- noHandle() --------------------------------------");
	magwellFiller(magBlockFrontZ=magBlockFrontZ, trimRib=false, addFrontRingTab=false);
}

module boltCatch(addFrontRingTab)
{
    boltCatchZ = 6;

    // Put the top of the straight part of the filler
    // boltCatchZ mm above the top of the lower, with 
    // the chamfer above that:
    magBlockFrontZ = topOfMagwellZ + boltCatchZ + magBlockCZ;

    echo(str("boltCatch() magBlockFrontZ = ", magBlockFrontZ));

    magwellFiller(magBlockFrontZ=magBlockFrontZ, trimRib=true, addFrontRingTab=addFrontRingTab);
}

module boltCatchNoRingTab()
{
    echo("--- boltCatchNoRingTab() --------------------------------------");
    boltCatch(addFrontRingTab=false);
}

module boltCatchWithRingTab()
{
    echo("--- boltCatchWithRingTab() --------------------------------------");
    boltCatch(addFrontRingTab=true);
}

module cordHandle()
{
    echo("--- cordHandle() --------------------------------------");
	difference()
	{
		magwellFiller(magBlockFrontZ=magBlockFrontZ, trimRib=false, addFrontRingTab=false);

		// Paracord handle:
        // MAGIC!!
        // See below.
        //  ---------------------vvv
		translate([0,magLength/2+2.7,0])
		{
			dCord = 5;
            // MAGIC!!
            // Should be relative to the bottom surface of the base at mid-length (Y):
            //   --------------------------------------------------------------vvv--------------------------------------vv
			rotate([-magWellBottomAngle,0,0]) doubleY() translate([0,dCord*0.7,-22]) simpleChamferedCylinder(d=dCord, h=25, cz=dCord/2);
		}
	}
}

module magwellFiller(magBlockFrontZ, trimRib, addFrontRingTab)
{
    magBlockCylindersOffsetZ = magBlockFrontZ - magBlockCylindersZ;

    echo(str("magwellFiller() topOfMagwellZ = ", topOfMagwellZ));
    echo(str("magwellFiller() magBlockFrontZ-magBlockCZ-2 = ", magBlockFrontZ-magBlockCZ-2, " (old)"));
    echo(str("magwellFiller() topOfMagwellZ+4 = ", topOfMagwellZ+4, " (new)"));

	difference()
    {
        topOfMagCatch = topOfMagwellZ+4;

	    union()
        {
            difference()
            {
                magCore(magBlockCylindersOffsetZ=magBlockCylindersOffsetZ);
            
                // Trim a bit of the magazine body away to avoid binding
                // on the front of the catch:
                if(trimRib) translate([0,magLength,0])
                {
                    d = magRibWidth;
                    tcy([0,0,topOfMagCatch], d=d, h=100);
                    translate([0,0,magBlockFrontZ-d/2-magBlockCZ]) cylinder(d1=0, d2=20, h=10);
                }
            }

            difference()
            {
                magCoreRib(magBlockCylindersOffsetZ=magBlockCylindersOffsetZ);
                if(trimRib) translate([0,0,topOfMagCatch])
                {
                    // Trim the top of the rib to be at the correct height to 
                    // engage the bolt hold-open catch:
                    tcu([-200,-20,0], 400);
                }
            }
			magStop();
        }

		// Trim the bottom angle:
		translate([0,0,0]) rotate([-magWellBottomAngle,0,0]) tcu([-200,-20,-400], 400);
        
        maglockRecess();

		// Ramp for mag-lock:
		translate([0, magLockRecessOffsetY, magBlockFrontZ]) hull()
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

		// Cartridge outline on top:
        translate([0,51.5,magBlockFrontZ-3*layerHeight]) rotate([0,0,180]) scale(0.23) translate([-34.8,0,0]) 
            linear_extrude(height = 10, convexity = 10) import(file = "5.56 Outline.svg");
	}

    // Add the base:
    rotate([-magWellBottomAngle,0,0])
    {
        extraXY = 7;

        baseX = magWidth + 2*extraXY;
        baseY = magRibLength/cos(magWellBottomAngle) + 2*extraXY;
        baseZ = 7;
        basseCZ = 2;
        baseCoiornerDia = 22;

        mwdx = baseX/2 - baseCoiornerDia/2;
        mwdy = baseY/2 - baseCoiornerDia/2;

        translate([0,baseY/2-extraXY,nothing])
        {
            %tcy([0,0,-30], d=1, h=50);
            hull() doubleY() doubleX() translate([mwdx, mwdy, -baseZ]) 
                simpleChamferedCylinderDoubleEnded(d=baseCoiornerDia, h=baseZ, cz=basseCZ);
        }
        
        // Front ring tab:
        // This whole thjing is MAGIC!!
        if(addFrontRingTab)
        {
            ringDX = 16;

            translate([mwdx, baseCoiornerDia/2-extraXY, -baseZ+nothing]) difference()
            {
                union()
                {
                    dX1 = -6;
                    dX2 = 0;
                    hull()
                    {
                        ringXform(dx=0) 
                        {
                            translate([0,0,baseZ/2]) simpleChamferedCylinder(d=21.2, h=baseZ/2, cz=1.6);
                            translate([0,0,baseZ/2]) mirror([0,0,1]) simpleChamferedCylinder(d=22.5, h=baseZ/2, cz=2.26);
                        }
                        ringXform(dx=ringDX) simpleChamferedCylinderDoubleEnded(d=10, h=2.5, cz=0.8);
                    }
                }

                ringXform(dx=ringDX)
                {
                    d = 3.5;
                    tcy([0,0,-10], d=d, h=20);
                    translate([0,0,baseZ/2-d/2-1]) rotate([0,13.5,0]) cylinder(d2=20, d1=0, h=10);
                    translate([0,0,-10+d/2+1.5]) cylinder(d2=0, d1=20, h=10);
                }
            }
        }
    }
}

module ringXform(dx)
{
    rotate([0,0,-45]) translate([dx,0,0]) children();
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
        // MAGIC!!
        //  Depends on recess depth.
        //  -vvv
        dy = 0.6;

		x2 = magStopX*2;
        y = magLockRecessY + dy;

        translate([0,-dy/2,0])
        {
            tcu([0,        0, -0.1], [magWidth/2+magStopX, y,    0.1]);
            tcu([0,-magStopX, -0.1], [         magWidth/2, y+x2, 0.1]);

            tcu([0,         0,-3.0], [magWidth/2+magStopX, y,    0.1]);
            tcu([0,-magStopX, -3.0], [         magWidth/2, y+x2, 0.1]);

            tcu([0,0,-6.0], [magWidth/2, magLockRecessY, 0.1]);
        }
	}
}

// Lower edge of the mag-lock recess:
module maglockXform()
{
	translate([0, magLockRecessOffsetY, magLockRecessOffsetZ]) children();
}

module magCore(magBlockCylindersOffsetZ)
{
    frontDia = 12;

	mwdx = magWidth/2 - magBlockDia/2;
    mwdy = magLength - magBlockDia/2;

    hull() doubleX()
	{
		// Nose:
		translate([2.6,frontDia/2,magBlockCylindersOffsetZ]) simpleChamferedCylinder(d=frontDia, h=magBlockCylindersZ, cz=magBlockCZ+0.6);

		translate([mwdx, 25, magBlockCylindersOffsetZ])
            simpleChamferedCylinder(d=magBlockDia, h=magBlockCylindersZ, cz=magBlockCZ);
		translate([mwdx, mwdy, magBlockCylindersOffsetZ])
            simpleChamferedCylinder(d=magBlockDia, h=magBlockCylindersZ, cz=magBlockCZ);
	}

    noseStrake(posZ=6);
    // MAGIC!!
    //  Match the nose-strake top to the top chamfer.
    //   --------------------------vvvv
    noseStrake(posZ=magBlockFrontZ-12.3);
}

module noseStrake(posZ)
{
    translate([0,0,posZ]) hull() doubleX()
	{
        flatZ = 3;
        dia = 6.5;
        cz = dia/2;
        Z = flatZ + 2*cz;

        mwdx = magWidth/2 - dia/2;
        mwdy = magLength - dia/2;

		translate([mwdx, dia/2, 0])
            simpleChamferedCylinderDoubleEnded(d=dia, h=Z, cz=cz);
		translate([mwdx, mwdy, 0])
            simpleChamferedCylinderDoubleEnded(d=dia, h=Z, cz=cz);
	}
}

module magCoreRib(magBlockCylindersOffsetZ)
{
    mwdx = magRibWidth/2 - magBlockDia/2;
    mwdy = magRibLength - magBlockDia/2;

	f = magRibLength/magLength;
	echo(str("magCoreRib() f = ", f));

	difference()
	{
		hull() doubleX() 
		{
			translate([mwdx, magBlockDia/2, magBlockCylindersOffsetZ])
				simpleChamferedCylinder(d=magBlockDia, h=magBlockCylindersZ, cz=magBlockCZ);
			translate([mwdx, mwdy, magBlockCylindersOffsetZ])
				simpleChamferedCylinder(d=magBlockDia, h=magBlockCylindersZ, cz=magBlockCZ);
		}    

		// Trim front:
		tcu([-200, -400+40, -50], 400);
	}
}

$fn=180;

module clip(d=0)
{
	// tcu([-200, -400-d, -10], 400);
	// tcu([-200, magLength/2, -20], 400);
	// tcu([-200, magLockRecessOffsetY+magLockRecessY/2, -200], 400);
    // tcu([0-d, -200, -200], 400);
}

if(developmentRender)
{
    
	// display() translate([-105,0,0]) cordHandle();
	// display() translate([-60,0,0]) noHandle();
    display() boltCatchNoRingTab();
    // display() translate([ 60,0,0]) boltCatchWithRingTab();

	// display() cordHandle();
	// display() translate([-60,0,0]) noHandle();
}
else
{
	if(makeNoHandle) noHandle();
	if(makeCordHandle) cordHandle();
    if(makeBoltCatchNoRingTab) boltCatchNoRingTab();
    if(makeBoltCatchWithRingTab) boltCatchWithRingTab();
}
