include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

makeIntegralPicatinnyMountTop = false;
makeAttachedPicatinnyMountTop = false;
makeMountBottom = false;
makeFrontSightCoverTop = false;
makeFrontSightCoverBottom = false;

attachedPicatinnyMountWidth = 16;
attachedPicatinnyMountLength = 65.18;
attachedPicatinnyMountEndRadius = 20;

// M-Lok dims:
mLokScrewHoleDia = 5.8;
m5NutDia = 9.0;
m5NutThickness = 4.0;
mLokScrewsCtrs = 20.25;
mLokSlotWidth = 7.2;
mLokSlotLength = 32.8;
mLokSlotDepth = 1.6;
mLokSlotEndDia = 12.3;

barrelOD = 21.6;
fluteDia = 11.8;
fluteDepth = 2.1;
fluteAngles = [0, 60, -60, 120, -120];

ringWallThickness = 6.1;
ringOD = barrelOD + 2*ringWallThickness;
mountZ = attachedPicatinnyMountLength; //65; //40;
ringAngle = 140;
ringCZ = 2;

ringPinRecessZ = 23.5;
ringPinRecessDia = 2;
ringPinRecessDepth = 3;
ringPinRecessAngle = 125;

picMainRectX = 12.82;
picMainRectY = 9.0; 

echo(str("picMainRectX = ", picMainRectX));
echo(str("picMainRectY = ", picMainRectY));

picTopRectX = 20.8;
picTopRectY = 5.5;

echo(str("picTopRectX = ", picTopRectX));
echo(str("picTopRectY = ", picTopRectY));

picMountOffsetX = ringOD/2 - 1.42;
module frontSightCover()
{
	frontSightCoverZ = 36;
	frontSightCoverOD = 20;
	frontSightCoverOffsetX = 30;
	frontSightBaseY = 11;
	frontSightCoverScrewCtrs = 0;

	difference()
	{
		union()
		{
			barrelMount(z=frontSightCoverZ, screwCtrsZ=frontSightCoverScrewCtrs)
			{
				// Front sight exterior:
				difference() 
				{
					hull()
					{
						difference() 
						{
							basicExteriorCylinder(frontSightCoverZ);
							frontSightCoverTrim();
						}
						translate([frontSightCoverOffsetX-frontSightCoverOD/2,0,0]) basicExteriorCylinder(frontSightCoverZ, od=frontSightCoverOD);
					}
				}

				// Front sight cover interior:
				translate([0,0,-10]) hull()
				{
					tcy([0,0,0], d=frontSightBaseY, h=100);
					tcy([frontSightCoverOffsetX-frontSightBaseY/2-3,0,0], d=frontSightBaseY, h=100);
				}
			}
		}
	}
}

module frontSightCoverTrim()
{
	tcu([-400, -200, -10], 400);
}

module integralPicatinnyMount()
{
	barrelMount();

	translate([picMainRectY+picMountOffsetX, 0, 0]) rotate([0,0,-90]) picatinnyMount(mountZ);
}

module attachedPicatinnyMount()
{
	difference()
	{
		union()
		{
			barrelMount();

			// Flat top:
			difference()
			{
				tcu([ringOD/2-ringCZ-2.5, -attachedPicatinnyMountWidth/2, 0], [100, attachedPicatinnyMountWidth, mountZ]);

				translate([0, 0, mountZ/2]) doubleY() doubleZ() translate([0, attachedPicatinnyMountWidth/2, mountZ/2]) rotate([-45,0,0]) tcu([0, -100, -ringCZ*0.707], 200);
			}
		}

		// Flat-top trim:
		flatTopX = barrelOD/2 + 7.5;
		echo(str("flatTopX = ", flatTopX));
		tcu([flatTopX, -200, -10], 400);

		// M-Lok slot:
		difference()
		{
			translate([flatTopX-mLokSlotDepth, 0, mountZ/2]) hull() doubleZ() translate([0, 0, mLokSlotLength/2-mLokSlotEndDia/2]) rotate([0,90,0]) 
			{
				tcy([0,0,0], d=mLokSlotEndDia, h=20);
			}
			doubleY() tcu([-100, mLokSlotWidth/2, -10], 200);
		}

		// m5 Holes:
		translate([0,0,mountZ/2]) doubleZ() translate([0,0,mLokScrewsCtrs/2]) rotate([0,90,0]) 
		{
			// Hole:
			cylinder(d=mLokScrewHoleDia, h=100);
			// Nut recess:
			cylinder(d=m5NutDia, h=barrelOD/2 + m5NutThickness, $fn=6);
		}
	}
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

module basicExteriorCylinder(z, od=ringOD)
{
	simpleChamferedCylinderDoubleEnded(d = od, h = z, cz = ringCZ);
}

module barrelOutside(z, screwCtrsZ)
{
	echo(str("barrelOutside() $children = ", $children));
	difference() 
	{
		union()
		{
			// Basic exterior:
			basicExteriorCylinder(z);

			// Screw bumps:
			difference()
			{
				screwBumpCtrsXform(z, screwCtrsZ) hull()
				{
					simpleChamferedCylinderDoubleEnded(d=screwBumpOD, h=screwBumpY, cz=screwBumpCZ, $fn=4);
					translate([0,-10,0]) simpleChamferedCylinderDoubleEnded(d=screwBumpOD, h=screwBumpY, cz=screwBumpCZ, $fn=8);
				}

				// Clip the outside points off:
				doubleY() tcu([-200, screwBumpOffsetY+screwBumpOD/2-1.8, -200], 400);
			}

			if($children > 0) children(0);
		}

		// Screw holes:
		screwHoles(z, screwCtrsZ);

		// Any other things to subtract:
		if($children > 1) children(1);
	}
}

module screwHoles(z, screwCtrsZ)
{
	screwBumpCtrsXform(z, screwCtrsZ) 
		{
			// Hole:
			tcy([0,0,-15], d=screwHoleDia, h=100);
			// Head recess:
			tcy([0,0,-100+screwHeadRecessZ], d=screwHeadRecessDia, h=100);
			// Nut recess:
			tcy([0,0,screwHeadRecessZ+screwZ-nutZ], d=1.4*nutXY, h=100, $fn=4);
		}
}

module screwBumpCtrsXform(z=mountZ, screwCtrsZ)
{
	doubleY() 
		translate([0, screwBumpOffsetY, z/2]) 
			doubleZ() translate([0, 0, -screwCtrsZ/2]) 
				rotate([0,-90,0]) 
					translate([0,0,-screwBumpY/2]) 
						children();
}

module barrelMount(z=mountZ, screwCtrsZ=screwBumpCtrsZ)
{
	difference()
	{
		union()
		{
			difference()
			{
				union()
				{
					// Basic integralPicatinnyMount ring:
					difference() 
					{
						if($children > 1) barrelOutside(z, screwCtrsZ) { children(0); children(1); }
						else if($children > 0) barrelOutside(z, screwCtrsZ) { children(0); }
						else barrelOutside(z, screwCtrsZ) { }

						tcy([0,0,-10], d=barrelOD, h=200);
					}

					// Flute:
					intersection() 
					{
						for (a = fluteAngles) 
						{
							echo(str("a = ", a));
							rotate([0,0,a]) tcy([(barrelOD+fluteDia)/2 - fluteDepth, 0, 0], d=fluteDia, h=z);
						}
						
						if($children > 1) barrelOutside(z, screwCtrsZ) { children(0); children(1); }
						else if($children > 0) barrelOutside(z, screwCtrsZ) { children(0); }
						else barrelOutside(z, screwCtrsZ) { }
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
			doubleY() intersection() 
			{
				rotate([0 ,0, ringAngle-90])  tcy([0,barrelOD/2+ringWallThickness/2,0], d=ringWallThickness, h=z);
				if($children > 1) barrelOutside(z, screwCtrsZ) { children(0); children(1); }
				else if($children > 0) barrelOutside(z, screwCtrsZ) { children(0); }
				else barrelOutside(z, screwCtrsZ) { }
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

module integralPicatinnyMountTop()
{
	makeTop() integralPicatinnyMount();
}

module attachedPicatinnyMountTop()
{
	makeTop() attachedPicatinnyMount();
}

module mountBottom()
{
	makeBottom() integralPicatinnyMount();
}

module frontSightCoverTop()
{
	makeTop() frontSightCover();
}

module frontSightCoverBottom()
{
	makeBottom() frontSightCover();
}

module makeTop()
{
	difference()
	{
		children();
		tcu([-400+split/2, -200, -200], 400);
	}
}

module makeBottom()
{
	difference()
	{
		children();
		tcu([-split/2, -200, -200], 400);
	}
}

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
	// tcu([-200, -200, ringCZ+1+screwBumpOD/2-400], 400);
}

if(developmentRender)
{
	// display() integralPicatinnyMount();
	// display() attachedPicatinnyMountTop();
	// display() integralPicatinnyMountTop();
	// display() mountBottom();
	display() frontSightCoverTop();
	display() frontSightCoverBottom();

	display() translate([-60,0,0])
	{
		attachedPicatinnyMountTop();
		mountBottom();
	}
	display() translate([-120,0,0]) integralPicatinnyMountTop();
}
else
{
	if(makeIntegralPicatinnyMountTop) integralPicatinnyMountTop();
	if(makeAttachedPicatinnyMountTop) attachedPicatinnyMountTop();
	if(makeMountBottom) mountBottom();
	if(makeFrontSightCoverTop) frontSightCoverTop();
	if(makeFrontSightCoverBottom) frontSightCoverBottom();
}
