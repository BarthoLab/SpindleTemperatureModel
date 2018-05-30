TITLE simple AMPA receptors

COMMENT
-----------------------------------------------------------------------------

	Simple model for glutamate AMPA receptors
	=========================================

  - FIRST-ORDER KINETICS, FIT TO WHOLE-CELL RECORDINGS

    Whole-cell recorded postsynaptic currents mediated by AMPA/Kainate
    receptors (Xiang et al., J. Neurophysiol. 71: 2552-2556, 1994) were used
    to estimate the parameters of the present model; the fit was performed
    using a simplex algorithm (see Destexhe et al., J. Computational Neurosci.
    1: 195-230, 1994).

  - SHORT PULSES OF TRANSMITTER (0.3 ms, 0.5 mM)

    The simplified model was obtained from a detailed synaptic model that 
    included the release of transmitter in adjacent terminals, its lateral 
    diffusion and uptake, and its binding on postsynaptic receptors (Destexhe
    and Sejnowski, 1995).  Short pulses of transmitter with first-order
    kinetics were found to be the best fast alternative to represent the more
    detailed models.

  - ANALYTIC EXPRESSION

    The first-order model can be solved analytically, leading to a very fast
    mechanism for simulating synapses, since no differential equation must be
    solved (see references below).



References

   Destexhe, A., Mainen, Z.F. and Sejnowski, T.J.  An efficient method for
   computing synaptic conductances based on a kinetic model of receptor binding
   Neural Computation 6: 10-14, 1994.  

   Destexhe, A., Mainen, Z.F. and Sejnowski, T.J. Synthesis of models for
   excitable membranes, synaptic transmission and neuromodulation using a 
   common kinetic formalism, Journal of Computational Neuroscience 1: 
   195-230, 1994.

See also:

   http://cns.iaf.cnrs-gif.fr

Written by A. Destexhe, 1995
27-11-2002: the pulse is implemented using a counter, which is more
	stable numerically (thanks to Yann LeFranc)

-----------------------------------------------------------------------------
ENDCOMMENT



INDEPENDENT {t FROM 0 TO 1 WITH 1 (ms)}

NEURON {
	POINT_PROCESS AMPA_S
	RANGE C, R, R0, R1, g, gmax, lastrelease
	NONSPECIFIC_CURRENT i
	GLOBAL Cmax, Cdur, Alpha, Beta, Erev, Deadtime, Rinf, Rtau
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
	Alpha	= 0.94	(/ms mM)	: forward (binding) rate
	Beta	= 0.18	(/ms)		: backward (unbinding) rate
	Erev	= 0	(mV)		: reversal potential	
	Deadtime = 1	(ms)		: mimimum time between release events
	gmax		(umho)		: maximum conductance
    temperature = 36
    q10 = 2.4                   : q10 based on Postlethwaite et al 2007
    exptemp = 32    (degC)      : exptemp based on Hestrin et al 1990 - Referenced in Destexhe book
}


ASSIGNED {
	v		(mV)		: postsynaptic voltage
	i 		(nA)		: current = g*(v - Erev)
	g 		(umho)		: conductance
	C		(mM)		: transmitter concentration
	R				: fraction of open channels
	R0				: open channels at start of release
	R1				: open channels at end of release
	Rinf				: steady state channels open
	Rtau		(ms)		: time constant of channel binding
	lastrelease	(ms)		: time of last spike
    phi_h
}

INITIAL {
	R = 0
	C = 0
	Rinf = Cmax*Alpha / (Cmax*Alpha + Beta)
    phi_h = q10 ^ ((temperature - exptemp )/10 (degC) ) 	
    Rtau = 1 / (((Alpha * Cmax) + Beta) * phi_h )
	lastrelease = -9e9
	R1=0
}

BREAKPOINT {
	SOLVE release
	g = gmax * R
	i = g*(v - Erev)
}

NET_RECEIVE (weight, on) {
	: flag is an implicit argument of NET_RECEIVE, normally 0
	if (flag == 0) {
	: a spike arrived, start onset state if not already on
		if (!on) {



			C = Cmax			: start new release
			R0 = R
			lastrelease = t
			on = 1
			: come again in Cdur with flag = 1
			net_send(Cdur, 1)
			net_send(Cdur + Deadtime, 2)
		}
	}
	if (flag == 1) {
		if (C == Cmax) {			: in dead time after release
			R1 = R
			C = 0.
		}	
	}
	if (flag == 2) {
		: "turn off after dead time"
		on = 0
	}
}

PROCEDURE release() { 
	if (C > 0) {				: transmitter being released?

	   R = Rinf + (R0 - Rinf) * exptable (- (t - lastrelease) / Rtau)
				
	} else {				: no release occuring

  	   R = R1 * exptable (- Beta * phi_h * (t - (lastrelease + Cdur)))
	}

	VERBATIM
	return 0;
	ENDVERBATIM
}

FUNCTION exptable(x) { 
	TABLE  FROM -10 TO 10 WITH 2000

	if ((x > -10) && (x < 10)) {
		exptable = exp(x)
	} else {
		exptable = 0.
	}
}
