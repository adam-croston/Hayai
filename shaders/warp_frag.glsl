#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

//uniform float timeS;
//uniform vec2 mouseScreenPos0To1;
uniform vec2 screenRes;
uniform vec2 warpVertAScreenPos0To1;
uniform vec2 warpVertBScreenPos0To1;
uniform vec2 warpVertDScreenPos0To1;
uniform vec2 warpVertCScreenPos0To1;
uniform vec2 warpPerspXY;

uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

//----------------------------------------------------------------------------

bool isClose(float a, float b, float tolerance)
{
    return (a == b) ||
			(	(a <= (b + tolerance)) &&
				(a >= (b - tolerance)));
}
bool OnRangeInclusive(float val, float range_min, float range_max, float tol)
{
    return ((val+tol) >= range_min) && ((val-tol) <= range_max);
}

// Easy cross product.
float cross( in vec2 a, in vec2 b ) { return a.x*b.y - a.y*b.x; }

// Get the distance to a line from a point.
float DistToLine(in vec2 vA, in vec2 vB, in vec2 pt){
	vec2 pa = pt - vA;
	vec2 ba = vB - vA;
	float h = clamp(dot(pa,ba) / dot(ba,ba), 0.0, 1.0);
	return length(pa - ba*h);
}

// Determine the side of the line of a point.
// Leftward is positive and rightward is negative.
float Side(in vec2 vA, in vec2 vB, in vec2 pt){
    return (pt.x - vB.x) * (vA.y - vB.y) - (vA.x - vB.x) * (pt.y - vB.y);
}

// Determine if a point is inside a triangle.
// The triangle should be defined in anti-clockwise order.
bool PointInTriangle (in vec2 vA, in vec2 vB, in vec2 vC, in vec2 pt){
    bool b1 = (Side(vA, vB, pt) > 0.0);
    bool b2 = (Side(vB, vC, pt) > 0.0);
    bool b3 = (Side(vC, vA, pt) > 0.0);

    return ((b1 == b2) && (b2 == b3));
}

//----------------------------------------------------------------------------
// Returns number of solutions found.  If there is one valid solution, it will
// be put in s and t
int inverseBilerp(
	in vec2 p,
	in vec2 a,
	in vec2 b,
	in vec2 d,
	in vec2 c,
	out vec2 outA,
	out vec2 outB)
{
    bool solutionAValid = true;
	bool solutionBValid = true;
	
	vec2 pa = a - p;
	vec2 ca = a - c;
	vec2 pb = b - p;
	vec2 db = b - d;
	
    float A  = cross(pa, ca);
    float B1 = cross(pa, db);
    float B2 = cross(pb, ca);
    float C  = cross(pb, db);
    float B  = 0.5 * (B1 + B2);

    float s, s2, t, t2;

    float am2bpc = A-2*B+C;
    
    int num_valid_s = 0; // this is how many valid s values we have

    if(isClose(am2bpc, 0, 1e-10))
    {
    	if(isClose(A-C, 0, 1e-10))
    	{
    		// Looks like the input is A line
    		// You could set s=0.5 and solve for t if you wanted to
    		return 0;
    	}
    	s = A / (A-C);
    	if(OnRangeInclusive(s, 0, 1, 1e-10))
		{
    		num_valid_s = 1;
		}
    }
    else
    {
    	float sqrtbsqmac = sqrt(B*B - A*C);
    	s  = ((A-B) - sqrtbsqmac) / am2bpc;
    	s2 = ((A-B) + sqrtbsqmac) / am2bpc;
    	num_valid_s = 0;
    	if(OnRangeInclusive(s, 0, 1, 1e-10))
    	{
    		num_valid_s++;
    		if(OnRangeInclusive(s2, 0, 1, 1e-10))
			{
    			num_valid_s++;
			}
    	}
    	else
    	{
    		if(OnRangeInclusive(s2, 0, 1, 1e-10))
    		{
    			num_valid_s++;
    			s = s2;
    		}
    	}
    }

    if(num_valid_s == 0)
	{
    	return 0;
	}

    if(num_valid_s >= 1)
    {
    	float tdenom_x = (1-s)*(a.x-c.x) + s*(b.x-d.x);
    	float tdenom_y = (1-s)*(a.y-c.y) + s*(b.y-d.y);
    	solutionAValid = true;
    	if(isClose(tdenom_x, 0, 1e-10) && isClose(tdenom_y, 0, 1e-10))
    	{
    		solutionAValid = false;
    	}
    	else
    	{
    		// Choose the more robust denominator
    		if(abs(tdenom_x) > abs(tdenom_y))
    		{
    			t = ((1-s)*(a.x-p.x) + s*(b.x-p.x)) / (tdenom_x);
    		}
    		else
    		{
    			t = ((1-s)*(a.y-p.y) + s*(b.y-p.y)) / (tdenom_y);
    		}
    		if(!OnRangeInclusive(t, 0, 1, 1e-10))
			{
    			solutionAValid = false;
			}
    	}
    }

    // Same thing for s2 and t2
    if(num_valid_s == 2)
    {
    	float tdenom_x = (1-s2)*(a.x-c.x) + s2*(b.x-d.x);
    	float tdenom_y = (1-s2)*(a.y-c.y) + s2*(b.y-d.y);
    	solutionBValid = true;
    	if(isClose(tdenom_x, 0, 1e-10) && isClose(tdenom_y, 0, 1e-10))
    	{
    		solutionBValid = false;
    	}
    	else
    	{
    		// Choose the more robust denominator
    		if(abs(tdenom_x) > abs(tdenom_y))
    		{
    			t2 = ((1-s2)*(a.x-p.x) + s2*(b.x-p.x)) / (tdenom_x);
    		}
    		else
    		{
    			t2 = ((1-s2)*(a.y-p.y) + s2*(b.y-p.y)) / (tdenom_y);
    		}
    		if(!OnRangeInclusive(t2, 0, 1, 1e-10))
			{
    			solutionBValid = false;
			}
    	}
    }

    // Final clean up
    if(solutionBValid && !solutionAValid)
    {
    	s = s2;
    	t = t2;
    	solutionAValid = true;
    	solutionBValid = false;
    }

    // Output
    if(solutionAValid)
    {
    	outA.x = s;
    	outA.y = t;
    }

    if(solutionBValid)
    {
    	outB.x = s2;
    	outB.y = t2;
    }

    return ((solutionAValid?1:0) + (solutionBValid?1:0));
}
vec2 invBilinear(in vec2 p, in vec2 a, in vec2 b, in vec2 c, in vec2 d){

	vec2 outA;
	vec2 outB;
	int retVal = inverseBilerp(p, a, b, c, d, outA, outB);
	if(retVal > 0)
	{
		return outA;
	}
	else
	{
		return vec2(0.0,0.0);
	}
}

//----------------------------------------------------------------------------
void main(){
    // Set up our quad in Neg1To1 space.
    vec2 warpVertAScreenPosNeg1To1 = ((warpVertAScreenPos0To1 * 2.0) - 1.0);
    vec2 warpVertBScreenPosNeg1To1 = ((warpVertBScreenPos0To1 * 2.0) - 1.0);
    vec2 warpVertCScreenPosNeg1To1 = ((warpVertCScreenPos0To1 * 2.0) - 1.0);	
    vec2 warpVertDScreenPosNeg1To1 = ((warpVertDScreenPos0To1 * 2.0) - 1.0);
	
	// Determine the fragment position in Neg1To1 space. 
	vec2 screenPos0To1 = clamp((gl_FragCoord.xy / screenRes), 0.0, 1.0);  
	screenPos0To1.y = 1.0 - screenPos0To1.y;
	vec2 screenPosNeg1To1 = clamp(((screenPos0To1 * 2.0) - 1.0), -1.0, 1.0);
	
	// Determine the color to use for this fragment.
    
    // Start with a simple radial falloff.
	vec3 col =
		clamp(
			vec3(0.5,0.85,0.9)*(1.0-0.4*length(screenPosNeg1To1)),
			0.0,
			1.0);
    
    // If inside either triangle use the texture color.
    bool inTri1 =
		PointInTriangle(
			warpVertAScreenPosNeg1To1,
			warpVertCScreenPosNeg1To1,
			warpVertBScreenPosNeg1To1,
			screenPosNeg1To1);
    bool inTri2 = 
		PointInTriangle(
			warpVertAScreenPosNeg1To1,
			warpVertCScreenPosNeg1To1,
			warpVertDScreenPosNeg1To1,
			screenPosNeg1To1);
    if(inTri1 || inTri2){
        // Determine the fragment position in UV space of the quad. 
        vec2 posQUV = 
			invBilinear(
				screenPosNeg1To1,
				warpVertAScreenPosNeg1To1,
				warpVertBScreenPosNeg1To1,
				warpVertCScreenPosNeg1To1,
				warpVertDScreenPosNeg1To1);
        //posQUV.y = 1.0 - posQUV.y; // Flip for video?
		
        // Perspective correct equation.
        // From http://en.wikipedia.org/wiki/Texture_mapping#Perspective_correctness
        // The equation is identical for U and V, so we only show the U one below.
        //ualpha = (((1-alpha)*(u0/z0)) + ((alpha)*(u1/z1))) /;
        //         (((1-alpha)*(1.0/z0)) + ((alpha)*(1.0/z1)));
        
        // Abuse the equation above to apply as a simple user
        // controllable warping amount.
        // We do this by pretending the z value at u0 is just one and
        // giving the user control of the z value at u1.
        // We use vector ops to do this on U and V at the same timeS.
        vec2 zWarpUV = warpPerspXY;//vec2(0.5, 0.5);
        vec2 posQUVWarped = (((posQUV)*(1.0/zWarpUV))) / (((vec2(1.0, 1.0)-posQUV)) + ((posQUV)*(1.0/zWarpUV)));        
        
		vec3 texel = texture2D(texture, posQUVWarped).rgb;
		//vec3 texel = texture2D(texture, posQUV).rgb;
        col = texel;		
    }
	else
	{
		// If close to any edge draw it in a solid color.
		float minDistToEdge = 1e20;	
		minDistToEdge =
			min(minDistToEdge,
				DistToLine(
					warpVertAScreenPosNeg1To1,
					warpVertBScreenPosNeg1To1,
					screenPosNeg1To1));
		minDistToEdge = 
			min(minDistToEdge,
				DistToLine(
					warpVertBScreenPosNeg1To1,
					warpVertCScreenPosNeg1To1,
					screenPosNeg1To1));
		minDistToEdge = 
			min(minDistToEdge,
				DistToLine(
					warpVertCScreenPosNeg1To1,
					warpVertDScreenPosNeg1To1,
					screenPosNeg1To1));
		minDistToEdge = 
			min(minDistToEdge,
				DistToLine(
					warpVertDScreenPosNeg1To1,
					warpVertAScreenPosNeg1To1,
					screenPosNeg1To1));    
		if(minDistToEdge < 0.005)
		{
			col = vec3(0.0,0.0,0.0);// black
		} 
		else if(minDistToEdge < 0.015)
		{
			col = vec3(1.0,0.6,0.0);// orange
		}
	}
	
    // Set the output color.
	gl_FragColor = vec4(col, 1.0);	
}


//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// NON WORKING SOLUTIONS!!!
// Suffer from numerical errors with parallel lines.
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
/*
// From:
// http://stackoverflow.com/questions/808441/inverse-bilinear-interpolation
// First answer.
// Seems to work-ish, except in cases with parallel lines!
vec2 invBilinear( in vec2 p, in vec2 a, in vec2 b, in vec2 c, in vec2 d)
{
	vec2 da = a-d;
	vec2 pa = a-p;
	vec2 cb = b-c;
	vec2 pb = b-p;
		
	float A = cross(pa, da);
	float B = (cross(pa, cb) + cross(pb, da)) / 2.0;
	float C = cross(pb, cb);

	float denom = (A - (2.0*B) + C);
	if(abs(denom)<0.0001){
		float s = A / (A-C);
		float t =
			( (1.0-s)*(a.x-p.x) + s*(b.x-p.x) ) /
			( (1.0-s)*(a.x-d.x) + s*(b.x-c.x) );

		return vec2(s, t);
	}else{
		float s0 = ((A-B) + sqrt(B*B - A*C)) / denom;	
		float s1 = ((A-B) - sqrt(B*B - A*C)) / denom;

		float s = (s0>=0.0 && s0<=1.0)?s0:s1;
		float t =
			( (1.0-s)*(a.x-p.x) + s*(b.x-p.x) ) /
			( (1.0-s)*(a.x-d.x) + s*(b.x-c.x) );

		return vec2(s, t);
	}
} 
*/

/*
// Doesn't seem to work at all
vec2 invBilinear(in vec2 p, in vec2 a, in vec2 b, in vec2 c, in vec2 d){
// substition 1 (see. derivation)
vec2 ab = b-a;
vec2 dc = c-a;

// substitution 2 (see. derivation)
vec2 pa = a - p;
vec2 ad = d - a;
vec2 abdc = dc - ab; 

// solution of quadratic equations
float C = cross(pa, ad);
float B = cross(ab, ad) + cross(abdc, pa);
float A = cross(ab, abdc);
float D2 = B*B - 4*A*C;
float D  = sqrt(D2);

float u = (-B - D)/(2*A);

// backsubstitution of "u" to obtain "v"
float v;
float denom_x = ad.x + u*abdc.x;
float denom_y = ad.y + u*abdc.y;
if(abs(denom_x)>abs(denom_y))
{
	v = -(pa.x + u*ab.x)/denom_x;
}
else
{
	v = -(pa.y + u*ab.y)/denom_y;
}

// // do you really need second solution ? 
// u = (-B + D)/(2*A);
// denom_x = ad.x + u*abdc.x;
// denom_y = ad.y + u*abdc.y;
// if(abs(denom_x)>abs(denom_y))
//{
//	v = -(pa.x + u*ab.x)/denom_x;
//}
//else
//{
//	vB = -(pa.y + u*ab.y)/denom_y;
//}

return vec2(u, C);
}
*/

/*
// http://www.iquilezles.org/www/articles/ibilinear/ibilinear.htm
// Seems to work except in cases with parallel vertical lines!
vec2 invBilinear(in vec2 p, in vec2 a, in vec2 b, in vec2 c, in vec2 d)
{
    vec2 e = b-a;
    vec2 f = d-a;
    vec2 g = a-b+c-d;
    vec2 h = p-a;

    float k2 = cross(g, f);
    float k1 = cross(e, f) + cross(h, g);
    float k0 = cross(h, e);

    float w = k1*k1 - 4.0*k0*k2;
    if(w<0.0) return vec2(-1.0);
    w = sqrt(w);
	
    float vA = (-k1 - w)/(2.0*k2);
    float u1 = (h.x - f.x*vA)/(e.x + g.x*vA);
	
    float vB = (-k1 + w)/(2.0*k2);
    float u2 = (h.x - f.x*vB)/(e.x + g.x*vB);

    float u = u1;
    float v = vA;

    if(v<0.0 || v>1.0 || u<0.0 || u>1.0) { u=u2;   v=vB;   }
    if(v<0.0 || v>1.0 || u<0.0 || u>1.0) { u=-1.0; v=-1.0; }

    return vec2(u, v);
}
vec2 invBilinear(in vec2 p, in vec2 a, in vec2 b, in vec2 c, in vec2 d)
{
    vec2 e = b-a;
    vec2 f = d-a;
    vec2 g = a-b+c-d;
    vec2 h = p-a;
        
    float k2 = cross(g, f);
	if(abs(k2)<0.001){return vec3(1,0,0);}
    float k1 = cross(e, f) + cross(h, g);
	if(abs(k1)<0.001){return vec3(0,1,0);}
    float k0 = cross(h, e);
    if(abs(k0)<0.001){return vec3(0,0,1);}
	
    float w = k1*k1 - 4.0*k0*k2;
    if(w<0.0) return vec2(-1.0);
    w = sqrt(w);
    
	//if(abs(-k1 - w)<0.001){return vec3(1,1,0);}
	//if(abs(h.x - f.x*vA)<0.001){return vec3(1,1,0);}
	
	float u1 = (h.x - f.x*vA)/(e.x + g.x*vA);
    float vA = (-k1 - w)/(2.0*k2);
	
	float u2 = (h.x - f.x*vB)/(e.x + g.x*vB);
    float vB = (-k1 + w)/(2.0*k2);
    
    
    bool  b1 = vA>=0.0 && vA<=1.0 && u1>=0.0 && u1<=1.0;
    bool  b2 = vB>=0.0 && vB<=1.0 && u2>=0.0 && u2<=1.0;
    
    vec2 res = vec2(-1.0);

    if(b1 && !b2) res = vec2(u1, vA);
    if(!b1 &&  b2) res = vec2(u2, vB);
    
    return res;
}
*/