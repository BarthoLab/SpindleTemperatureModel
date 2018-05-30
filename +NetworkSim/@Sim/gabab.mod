TITLE simple GABAb receptors

COMMENT
-----------------------------------------------------------------------------

	Kinetic model of GABA-B receptors
	=================================

  MODEL OF SECOND-ORDER G-PROTEIN TRANSDUCTION AND FAST K+ OPENING
  WITH COOPERATIVITY OF G-PROTEIN BINDING TO K+ CHANNEL

  PULSE OF TRANSMITTER

  SIMPLE KINETICS WITH NO DESENSITIZATION

	Features:

  	  - peak at 100 ms; time course fit to Tom Otis' PSC
	  - SUMMATION (psc is much stronger with bursts)


	Approximations:

	  - single binding site on receptor	
	  - model of alpha G-protein activation (direct) of K+ channel
	  - G-protein dynamics is second-order; simplified as follows:
		- saturating receptor
		- no desensitization
		- Michaelis-Menten of receptor for G-protein production
		- "resting" G-protein is in excess
		- Quasi-stat of intermediate enzymatic forms
	  - binding on K+ channel is fast


	Kinetic Equations:

	  dR/dt = K1 * T * (1-R-D) - K2 * R

	  dG/dt = K3 * R - K4 * G

	  R : activated receptor
	  T : transmitter
	  G : activated G-protein
	  K1,K2,K3,K4 = kinetic rate cst

  n activated G-protein bind to a K+ channel:

	n G + C <-> O		(Alpha,Beta)

  If the binding is fast, the fraction of open channels is given by:

	O = G^n / ( G^n + KD )

  where KD = Beta / Alpha is the dissociation constant

-----------------------------------------------------------------------------

  Parameters estimated from patch clamp recordings of GABAB PSP's in
  rat hippocampal slices (Otis et al, J. Physiol. 463: 391-407, 1993).

-----------------------------------------------------------------------------

  PULSE MECHANISM

  Kinetic synapse with release mechanism as a pulse.  

  Warning: for this mechanism to be equivalent to the model with diffusion 
  of transmitter, small pulses must be used...

  see details at http://cns.iaf.cnrs-gif.fr

  Written by A. Destexhe, 1995
  27-11-2002: the pulse is implemented using a counter, which is more
	stable numerically (thanks to Yann LeFranc)

-----------------------------------------------------------------------------
ENDCOMMENT



INDEPENDENT {t FROM 0 TO 1 WITH 1 (ms)}

NEURON {
	POINT_PROCESS GABAb_S
	RANGE C, R, G, g, gmax, lastrelease
	NONSPECIFIC_CURRENT i
	GLOBAL Cmax, Cdur, Deadtime
	GLOBAL K1, K2, K3, K4, KD, Erev
}
UNITS {
	(nA) = (nanoamp)
	(mV) = (millivolt)
	(umho) = (micromho)
	(mM) = (milli/liter)
}

PARAMETER {
	dt		(ms)
	Cmax	= 0.5	(mM)		: max transmitter concentration
	Cdur	= 0.3	(ms)		: transmitter duration (rising phase)	
	Deadtime = 1	(ms)		: mimimum time between release events
:
:	From Kfit with long pulse (5ms 0.5mM)
:
	K1	= 0.52	(/ms mM)	: forward binding rate to receptor
	K2	= 0.0013 (/ms)		: backward (unbinding) rate of receptor
	K3	= 0.098 (/ms)		: rate of G-protein production
	K4	= 0.033 (/ms)		: rate of G-protein decay
	KD	= 100			: dissociation constant of K+ channel
	n	= 4			: nb of binding sites of G-protein on K+
	Erev	= -95	(mV)		: reversal potential (E_K)
	gmax		(umho)		: maximum conductance
    temperature = 36
    q10 = 2.065                 : q10 based on Otis et al 1993 (1.82-2.31) - Referenced in Destexhe book
    exptemp = 34    (degC)      : exptemp based on Otis et al 1993 (33-35 degC) - Referenced in Destexhe book
}


ASSIGNED {
	v		(mV)		: postsynaptic voltage
	i 		(nA)		: current = g*(v - Erev)
	g 		(umho)		: conductance
	C		(mM)		: transmitter concentration
	Gn
	lastrelease	(ms)		: time of last spike
    phi_h
}


STATE {
	R				: fraction of activated receptor
	G				: fraction of activated G-protein
}


INITIAL {
	C = 0
	lastrelease = -9e9
    phi_h = q10 ^ ((temperature - exptemp )/10 (degC) )
	R = 0
	G = 0
}

BREAKPOINT {
	SOLVE bindkin METHOD cnexp
	Gn = G^n
	g = gmax * Gn / (Gn+KD)
	i = g*(v - Erev)
}

NET_RECEIVE (weight, on) {
	: flag is an implicit argument of NET_RECEIVE, normally 0
	if (flag == 0) {
	: a spike arrived, start onset state if not already on
		if (!on) {
			C = Cmax			: start new release
			lastrelease = t
			on = 1
			: come again in Cdur with flag = 1
			net_send(Cdur + dt, 1)
			net_send(Cdur + Deadtime + dt, 2)
		}
	}
	if (flag == 1) {
		if (C == Cmax) {			: in dead time after release
			C = 0.
		}	
	}
	if (flag == 2) {
		: "turn off after dead time"
		on = 0
	}
}

DERIVATIVE bindkin {
	: release()		: evaluate the variable C

	R' = K1 * phi_h * C * (1-R) - K2 * phi_h * R
	G' = K3 * R - K4 * G

}
