: -*- neuron-mod -*-
TITLE T3_Stuart4
: T current 
:
:
NEURON {
  SUFFIX T :
  RANGE  sgmax :
  USEION ca READ eca :
  NONSPECIFIC_CURRENT i:
  : GLOBAL minf, mtau, hinf, htau:
}

PARAMETER {
  sgmax = 0.0    (mho/cm2):

  base_temperature = 36 (degC):

  celsius  (degC):
  q10 (1):

}


UNITS {
  (mA) = (milliamp):
  (mV) = (millivolt):
  (pS) = (picosiemens):
  (um) = (micron):
} 

ASSIGNED {
  v (mV):
  eca  (mV): : 160 mV
  i    (mA/cm2):
  minf (1):
  hinf (1):
  mtau (ms):
  htau (ms):
}


STATE {
  m (1) <1e-6>:
  h (1) <1e-4>:
}

BREAKPOINT {
  SOLVE states METHOD cnexp :
  i = sgmax* (m*m*m) * (h*h) * (v - eca):
}

INITIAL {
  if (0){
    trates(v):
    m=minf:
    h=hinf:
  } else {
    m=0
    h=0
  }
}


FUNCTION m_tau( x (mV) ) (ms)
{
  LOCAL a,b,c,t0,tau:
  a = 1 (ms):
    : b0    = 0.02054 * 1.22 (ms):
    : b = -log(b0)/c
  b =  -37.464737964802431236 (mV):

  c    = -0.0984  (1/mV):
  t0   = 2.44  (ms):

  tau = ( t0 +  a*exp( c * (x-b) ) ):
  m_tau = tau:
}



FUNCTION m_inf(x (mV) ) (1)
{

  LOCAL b,c :

  b = -63.0 (mV):
  c = -7.8 (mV):

  m_inf = 1 / ( 1+exp( (x-b)/c ) ):



}
 
FUNCTION h_tau(x (mV) ) (ms)
{

  LOCAL a,b,c,t0,tau:

  a = 1(ms):
  :b = -25.00097495 (mV) :
  b = -25.000 (mV) :
  c  = -0.1054  (1/mV) :
  t0 =  19.154 (ms) :

  tau = ( t0 +  a*exp( c * (x - b) ) ):

  h_tau = tau :
}



FUNCTION h_inf( x(mV) ) (1)
{
  LOCAL b,c,inf:

  b = -74.5517 (mV): 
  c = 6.45644 (mV): 

  inf = 1 / ( 1+ exp( (x-b)/c ) ):
  h_inf = inf : 
}


DERIVATIVE states {   
  trates(v):
  m' = (minf-m)/mtau :
  h' = (hinf-h)/htau :
}

PROCEDURE trates(v(mV)) {  

  UNITSOFF:
  q10 = 3^((celsius-base_temperature)/10):
  UNITSON:

  mtau = m_tau(v)/q10:
  minf = m_inf(v):
  htau = h_tau(v)/q10:
  hinf = h_inf(v):
}


        

