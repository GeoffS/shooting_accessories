include <../OpenSCAD_Lib/MakeInclude.scad>

barrelOD = 22.0;
fluteDia = 13.5;
fluteDepth = 2.5;
fluteAngles = [0, 60, -60, 120, -120];

ringWallThickness = 3;
ringOD = barrelOD + 2*ringWallThickness;
mountZ = 10;

module itemModule()
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
					rotate([0,0,a]) tcy([(barrelOD+fluteDia)/2 - fluteDepth, 0, 0], d=fluteDia, h=mountZ);
				}
				tcy([0,0,-10], d=barrelOD, h=200);
			}
		}

		// Trim:
		tcu([-400, -200, -200], 400);
	}

	doubleY() tcy([0,barrelOD/2+ringWallThickness/2,0], d=ringWallThickness, h=mountZ);
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	itemModule();
}
