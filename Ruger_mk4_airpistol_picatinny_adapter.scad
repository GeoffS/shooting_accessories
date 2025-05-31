include <../OpenSCAD_Lib/MakeInclude.scad>

makeBarrelTest = false;
makePicTest = false;
makeMount = false;

barrelOD = 21.8;
fluteDia = 11.8;
fluteDepth = 2;
fluteAngles = [0, 60, -60, 120, -120];

ringWallThickness = 7;
ringOD = barrelOD + 2*ringWallThickness;
mountZ = 40; //10;
ringAngle = 140;

picMainRectX = 12.82; //(0.617 - 0.005) * 25.4;
picMainRectY = 9.0; //(0.367 + 0.010) * 25.4;

echo(str("picMainRectX = ", picMainRectX));
echo(str("picMainRectY = ", picMainRectY));

picTopRectX = (0.835 - 0.003) * 25.4;
picTopRectY = 5.5; //(0.164 - 0.010) * 25.4;

echo(str("picTopRectX = ", picTopRectX));
echo(str("picTopRectY = ", picTopRectY));

picMountOffsetX = ringOD/2 - 1.8;

module mount()
{
	barrelMount();

	translate([picMainRectY+picMountOffsetX,0,0]) rotate([0,0,-90]) picatinnyMount();
}

module picatinnyMount()
{
	// Main/Central rectangle:
	tcu([-picMainRectX/2, -picMainRectY, 0], [picMainRectX, picMainRectY, mountZ]);

	// Mount top:
	difference()
	{
		// Rectangle:
		
		union()
		{
			y = 7;
			tcu([-picTopRectX/2, -y, 0], [picTopRectX, y, mountZ]);
			// tcu([-picTopRectX/2, -y, 0], [picTopRectX/2, y, mountZ]);
		}

		// Trim corners:
		cornerChamferY = picTopRectY*0.707/2 - 0.1;
		translate([0, -picTopRectY/2, 0]) doubleY() doubleX() translate([picTopRectX/2, -picTopRectY/2, 0]) rotate([0,0,45]) tcu([-50,-100 + cornerChamferY,-10], 100);
	}

	// %tcu([-20, -5.5, -20], 40);

	// Temp. base:
	// translate([0,-4-picMainRectY,0]) hull() doubleY() doubleX() tcy([11, 0, 0], d=8, h=mountZ);
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
				// hull()
				// {
				// 	cylinder(d=ringOD, h=mountZ);
					
				// 	tcu([picMountOffsetX, -picMainRectX/2, 0], [0.1, picMainRectX, mountZ]);
				// }
				difference() 
				{
					cylinder(d=ringOD, h=mountZ);
					tcu([picMountOffsetX, -200, -10], 400);
				}

				tcy([0,0,-10], d=barrelOD, h=200);
			}

			// Flute:
			intersection() 
			{
				for (a = fluteAngles) 
				{
					echo(str("a = ", a));
					rotate([0,0,a]) tcy([(barrelOD+fluteDia)/2 - fluteDepth, 0, 0], d=fluteDia, h=mountZ);
				}
				tcy([0,0,-10], d=barrelOD, h=200);
			}
		}

		// Trim:
		// tcu([-400, -200, -200], 400);
		doubleY() difference() 
		{
			rotate([0 ,0, ringAngle-90]) tcu([-400, 0, -200], 400);
			tcu([-400,-400,0], 400);
		}
	}

	// Add rounded ends for better printing:
	// doubleY() tcy([0,barrelOD/2+ringWallThickness/2,0], d=ringWallThickness, h=mountZ);
	doubleY() difference() 
	{
		rotate([0 ,0, ringAngle-90])  tcy([0,barrelOD/2+ringWallThickness/2,0], d=ringWallThickness, h=mountZ);
	}
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	// display() barrelMount();
	// display() picatinnyMount();
	display() mount();
}
else
{
	if(makeBarrelTest) barrelMount();
	if(makePicTest) picatinnyMount();
	if(makeMount) mount();
}
