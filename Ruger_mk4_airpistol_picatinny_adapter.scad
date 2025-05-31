include <../OpenSCAD_Lib/MakeInclude.scad>

makeBarrelTest = false;
makePicTest = false;

barrelOD = 21.8;
fluteDia = 11.8;
fluteDepth = 2;
fluteAngles = [0, 60, -60, 120, -120];

ringWallThickness = 5;
ringOD = barrelOD + 2*ringWallThickness;
mountZ = 10;

picMainRectX = (0.617 - 0.005) * 25.4;
picMainRectY = (0.367 + 0.010) * 25.4;

picTopRectX = (0.835 - 0.003) * 25.4;
picTopRectY = (0.164 - 0.010) * 25.4;

module picatinnyMount()
{
	// Main/Central rectangle:
	tcu([-picMainRectX/2, -picMainRectY, 0], [picMainRectX, picMainRectY, mountZ]);

	// Mount top:
	difference()
	{
		// Rectangle:
		y = 6;
		tcu([-picTopRectX/2, -y, 0], [picTopRectX, y, mountZ]);

		// Trim corners:
		translate([0, -picTopRectY/2, 0]) doubleY() doubleX() translate([picTopRectX/2, -picTopRectY/2, 0]) rotate([0,0,45]) tcu([-50,-100 + 1,-10], 100);
	}

	// Temp. base:
	translate([0,-4-picMainRectY,0]) hull() doubleY() doubleX() tcy([16, 0, 0], d=8, h=mountZ);
}

module barrelMount()
{
	difference()
	{
		union()
		{
			// Basic mount ring:
			difference() 
			{
				cylinder(d=ringOD, h=mountZ);

				tcy([0,0,-10], d=barrelOD, h=200);
			}

			// Flute:
			intersection() 
			{
				for (a = fluteAngles) 
				{
					echo(str("a = ", a));
					#rotate([0,0,a]) tcy([(barrelOD+fluteDia)/2 - fluteDepth, 0, 0], d=fluteDia, h=mountZ);
				}
				tcy([0,0,-10], d=barrelOD, h=200);
			}
		}

		// Trim:
		tcu([-400, -200, -200], 400);
	}

	// Add rounded ends for better printing:
	doubleY() tcy([0,barrelOD/2+ringWallThickness/2,0], d=ringWallThickness, h=mountZ);
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	// display() barrelMount();
	display() picatinnyMount();
}
else
{
	if(makeBarrelTest) barrelMount();
	if(makePicTest) picatinnyMount();
}
