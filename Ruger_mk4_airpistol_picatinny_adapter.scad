include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

makeBarrelTest = false;
makePicTest = false;
makeMountTop = false;
makeMountBottom = false;

barrelOD = 21.6;
fluteDia = 11.8;
fluteDepth = 2.1;
fluteAngles = [0, 60, -60, 120, -120];

ringWallThickness = 5.54;
ringOD = barrelOD + 2*ringWallThickness;
mountZ = 40; //10;
ringAngle = 140;
ringCZ = 2;

ringPinRecessZ = 23.5;
ringPinRecessDia = 2;
ringPinRecessDepth = 3;
ringPinRecessAngle = 125;

picMainRectX = 12.82; //(0.617 - 0.005) * 25.4;
picMainRectY = 9.0; //(0.367 + 0.010) * 25.4;

echo(str("picMainRectX = ", picMainRectX));
echo(str("picMainRectY = ", picMainRectY));

picTopRectX = 20.8; //(0.835 - 0.003) * 25.4;
picTopRectY = 5.5; //(0.164 - 0.010) * 25.4;

echo(str("picTopRectX = ", picTopRectX));
echo(str("picTopRectY = ", picTopRectY));

picMountOffsetX = ringOD/2 - 1.42; //1.8;

module mount()
{
	barrelMount();

	translate([picMainRectY+picMountOffsetX, 0, 0]) rotate([0,0,-90]) picatinnyMount(mountZ); //-2*ringCZ);
}

module picatinnyMount(z)
{
	// Main/Central rectangle:
	mainY = picMainRectY + 2.5;
	tcu([-picMainRectX/2, -mainY, 0], [picMainRectX, mainY, z]);

	// Mount top:
	difference()
	{
		// Rectangle:
		union()
		{
			topY = 7;
			tcu([-picTopRectX/2, -topY, 0], [picTopRectX, topY, z]);
			// tcu([-picTopRectX/2, -y, 0], [picTopRectX/2, y, mountZ]);
		}

		// Trim corners:
		cornerChamferY = picTopRectY*0.707/2 - 0.2;
		translate([0, -picTopRectY/2, 0]) doubleY() doubleX() translate([picTopRectX/2, -picTopRectY/2, 0]) rotate([0,0,45]) tcu([-50,-100 + cornerChamferY,-10], 100);
	}
}

screwHeadRecessDia = 6.1;
screwHeadRecessZ = 3.5;
screwHoleDia = 3.55;
nutXY = 5.7;
nutZ = 2.5;
screwZ = 16;

screwBumpOD = screwHeadRecessDia + 7;
screwBumpY = 20;
screwBumpCZ = 1;

screwBumpOffsetY = barrelOD/2 + 1 + screwHoleDia/2; // ringOD/2 - 3;
screwBumpCtrsZ = mountZ - screwBumpOD - 2*ringCZ - 1;

module barrelOutside()
{
	difference() 
	{
		union()
		{
			// Basic exterior:
			simpleChamferedCylinderDoubleEnded(d = ringOD, h = mountZ, cz = ringCZ);

			// Screw bumps:
			difference()
			{
				screwBumpCtrsXform() hull()
				{
					simpleChamferedCylinderDoubleEnded(d=screwBumpOD, h=screwBumpY, cz=screwBumpCZ, $fn=4);
					translate([0,-10,0]) simpleChamferedCylinderDoubleEnded(d=screwBumpOD, h=screwBumpY, cz=screwBumpCZ, $fn=8);
				}

				// Clip the outside points off:
				doubleY() tcu([-200, screwBumpOffsetY+screwBumpOD/2-1.8, -200], 400);
			}
		}

		// Flat-top on ring:
		tcu([picMountOffsetX, -200, -10], 400);

		// Screw holes:
		screwBumpCtrsXform() 
		{
			// Hole:
			tcy([0,0,-15], d=screwHoleDia, h=100);
			// Head recess:
			tcy([0,0,-100+screwHeadRecessZ], d=screwHeadRecessDia, h=100);
			// Nut recess:
			tcy([0,0,screwHeadRecessZ+screwZ-nutZ], d=1.4*nutXY, h=100, $fn=4);
		}
	}
}

module screwBumpCtrsXform()
{
	doubleY() 
		translate([0, screwBumpOffsetY, mountZ/2]) 
			doubleZ() translate([0, 0, -screwBumpCtrsZ/2]) 
				rotate([0,-90,0]) 
					translate([0,0,-screwBumpY/2]) 
						children();
}

module barrelMount()
{
	difference()
	{
		union()
		{
			difference()
			{
				union()
				{
					// Basic mount ring:
					difference() 
					{
						barrelOutside();

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
						
						barrelOutside();
					}
				}

				// Trim ends:
				doubleY() difference() 
				{
					rotate([0 ,0, ringAngle-90]) tcu([-400, 0, -200], 400);
					tcu([-400,-400,0], 400);
				}
			}

			// Add rounded ends for better printing:
			// doubleY() tcy([0,barrelOD/2+ringWallThickness/2,0], d=ringWallThickness, h=mountZ);
			doubleY() intersection() 
			{
				rotate([0 ,0, ringAngle-90])  tcy([0,barrelOD/2+ringWallThickness/2,0], d=ringWallThickness, h=mountZ);
				barrelOutside();
			}
		}

		// Make recess slot for pin:
		rotate([0,0,-90+ringPinRecessAngle]) hull()
		{
			translate([0, 0, ringPinRecessZ]) rotate([-90,0,0]) hull()
			{
				cylinder(d=ringPinRecessDia, h=barrelOD/2);
				rotate([0,-30,0]) cylinder(d=ringPinRecessDia*2, h=ringOD/2);
			}
		}
	}
}

split = 0.1;

module mountTop()
{
	difference()
	{
		mount();
		tcu([-400+split/2, -200, -200], 400);
	}
}

module mountBottom()
{
	difference()
	{
		mount();
		tcu([-split/2, -200, -200], 400);
	}
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
	// tcu([-200, -200, ringCZ+1+screwBumpOD/2-400], 400);
}

if(developmentRender)
{
	// display() barrelMount();
	// display() picatinnyMount();
	// display() mount();
	display() mountTop();
	display() mountBottom();
}
else
{
	if(makeBarrelTest) barrelMount();
	if(makePicTest) picatinnyMount();
	if(makeMountTop) mountTop();
	if(makeMountBottom) mountBottom();
}
