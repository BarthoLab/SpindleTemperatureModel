/* Created by Language version: 6.2.0 */
/* NOT VECTORIZED */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "scoplib_ansi.h"
#undef PI
#define nil 0
#include "md1redef.h"
#include "section.h"
#include "nrniv_mf.h"
#include "md2redef.h"
 
#if METHOD3
extern int _method3;
#endif

#if !NRNGPU
#undef exp
#define exp hoc_Exp
extern double hoc_Exp(double);
#endif
 
#define _threadargscomma_ /**/
#define _threadargs_ /**/
 
#define _threadargsprotocomma_ /**/
#define _threadargsproto_ /**/
 	/*SUPPRESS 761*/
	/*SUPPRESS 762*/
	/*SUPPRESS 763*/
	/*SUPPRESS 765*/
	 extern double *getarg();
 static double *_p; static Datum *_ppvar;
 
#define t nrn_threads->_t
#define dt nrn_threads->_dt
#define gmax _p[0]
#define i _p[1]
#define g _p[2]
#define C _p[3]
#define R _p[4]
#define R0 _p[5]
#define R1 _p[6]
#define lastrelease _p[7]
#define phi_h _p[8]
#define _g _p[9]
#define _tsav _p[10]
#define _nd_area  *_ppvar[0]._pval
 
#if MAC
#if !defined(v)
#define v _mlhv
#endif
#if !defined(h)
#define h _mlhh
#endif
#endif
 
#if defined(__cplusplus)
extern "C" {
#endif
 static int hoc_nrnpointerindex =  -1;
 /* external NEURON variables */
 /* declaration of user functions */
 static double _hoc_exptable();
 static double _hoc_release();
 static int _mechtype;
extern void _nrn_cacheloop_reg(int, int);
extern void hoc_register_prop_size(int, int, int);
extern void hoc_register_limits(int, HocParmLimits*);
extern void hoc_register_units(int, HocParmUnits*);
extern void nrn_promote(Prop*, int, int);
extern Memb_func* memb_func;
 extern Prop* nrn_point_prop_;
 static int _pointtype;
 static void* _hoc_create_pnt(_ho) Object* _ho; { void* create_point_process();
 return create_point_process(_pointtype, _ho);
}
 static void _hoc_destroy_pnt();
 static double _hoc_loc_pnt(_vptr) void* _vptr; {double loc_point_process();
 return loc_point_process(_pointtype, _vptr);
}
 static double _hoc_has_loc(_vptr) void* _vptr; {double has_loc_point();
 return has_loc_point(_vptr);
}
 static double _hoc_get_loc_pnt(_vptr)void* _vptr; {
 double get_loc_point_process(); return (get_loc_point_process(_vptr));
}
 extern void _nrn_setdata_reg(int, void(*)(Prop*));
 static void _setdata(Prop* _prop) {
 _p = _prop->param; _ppvar = _prop->dparam;
 }
 static void _hoc_setdata(void* _vptr) { Prop* _prop;
 _prop = ((Point_process*)_vptr)->_prop;
   _setdata(_prop);
 }
 /* connect user functions to hoc names */
 static VoidFunc hoc_intfunc[] = {
 0,0
};
 static Member_func _member_func[] = {
 "loc", _hoc_loc_pnt,
 "has_loc", _hoc_has_loc,
 "get_loc", _hoc_get_loc_pnt,
 "exptable", _hoc_exptable,
 "release", _hoc_release,
 0, 0
};
#define _f_exptable _f_exptable_GABAa_S
#define exptable exptable_GABAa_S
 extern double _f_exptable( double );
 extern double exptable( double );
 /* declare global and static user variables */
#define Alpha Alpha_GABAa_S
 double Alpha = 10.5;
#define Beta Beta_GABAa_S
 double Beta = 0.166;
#define Cdur Cdur_GABAa_S
 double Cdur = 0.3;
#define Cmax Cmax_GABAa_S
 double Cmax = 0.5;
#define Deadtime Deadtime_GABAa_S
 double Deadtime = 1;
#define Erev Erev_GABAa_S
 double Erev = -80;
#define Rtau Rtau_GABAa_S
 double Rtau = 0;
#define Rinf Rinf_GABAa_S
 double Rinf = 0;
#define exptemp exptemp_GABAa_S
 double exptemp = 34;
#define q10 q10_GABAa_S
 double q10 = 2.1;
#define temperature temperature_GABAa_S
 double temperature = 36;
#define usetable usetable_GABAa_S
 double usetable = 1;
 /* some parameters have upper and lower limits */
 static HocParmLimits _hoc_parm_limits[] = {
 "usetable_GABAa_S", 0, 1,
 0,0,0
};
 static HocParmUnits _hoc_parm_units[] = {
 "Cmax_GABAa_S", "mM",
 "Cdur_GABAa_S", "ms",
 "Alpha_GABAa_S", "/ms",
 "Beta_GABAa_S", "/ms",
 "Erev_GABAa_S", "mV",
 "Deadtime_GABAa_S", "ms",
 "exptemp_GABAa_S", "degC",
 "Rtau_GABAa_S", "ms",
 "gmax", "umho",
 "i", "nA",
 "g", "umho",
 "C", "mM",
 "lastrelease", "ms",
 0,0
};
 static double delta_t = 1;
 static double v = 0;
 /* connect global user variables to hoc */
 static DoubScal hoc_scdoub[] = {
 "Cmax_GABAa_S", &Cmax_GABAa_S,
 "Cdur_GABAa_S", &Cdur_GABAa_S,
 "Alpha_GABAa_S", &Alpha_GABAa_S,
 "Beta_GABAa_S", &Beta_GABAa_S,
 "Erev_GABAa_S", &Erev_GABAa_S,
 "Deadtime_GABAa_S", &Deadtime_GABAa_S,
 "temperature_GABAa_S", &temperature_GABAa_S,
 "q10_GABAa_S", &q10_GABAa_S,
 "exptemp_GABAa_S", &exptemp_GABAa_S,
 "Rinf_GABAa_S", &Rinf_GABAa_S,
 "Rtau_GABAa_S", &Rtau_GABAa_S,
 "usetable_GABAa_S", &usetable_GABAa_S,
 0,0
};
 static DoubVec hoc_vdoub[] = {
 0,0,0
};
 static double _sav_indep;
 static void nrn_alloc(Prop*);
static void  nrn_init(_NrnThread*, _Memb_list*, int);
static void nrn_state(_NrnThread*, _Memb_list*, int);
 static void nrn_cur(_NrnThread*, _Memb_list*, int);
static void  nrn_jacob(_NrnThread*, _Memb_list*, int);
 static void _hoc_destroy_pnt(_vptr) void* _vptr; {
   destroy_point_process(_vptr);
}
 
static int _ode_count(int);
 /* connect range variables in _p that hoc is supposed to know about */
 static const char *_mechanism[] = {
 "6.2.0",
"GABAa_S",
 "gmax",
 0,
 "i",
 "g",
 "C",
 "R",
 "R0",
 "R1",
 "lastrelease",
 0,
 0,
 0};
 
extern Prop* need_memb(Symbol*);

static void nrn_alloc(Prop* _prop) {
	Prop *prop_ion;
	double *_p; Datum *_ppvar;
  if (nrn_point_prop_) {
	_prop->_alloc_seq = nrn_point_prop_->_alloc_seq;
	_p = nrn_point_prop_->param;
	_ppvar = nrn_point_prop_->dparam;
 }else{
 	_p = nrn_prop_data_alloc(_mechtype, 11, _prop);
 	/*initialize range parameters*/
 	gmax = 0;
  }
 	_prop->param = _p;
 	_prop->param_size = 11;
  if (!nrn_point_prop_) {
 	_ppvar = nrn_prop_datum_alloc(_mechtype, 3, _prop);
  }
 	_prop->dparam = _ppvar;
 	/*connect ionic variables to this model*/
 
}
 static void _initlists();
 
#define _tqitem &(_ppvar[2]._pvoid)
 static void _net_receive(Point_process*, double*, double);
 extern Symbol* hoc_lookup(const char*);
extern void _nrn_thread_reg(int, int, void(*f)(Datum*));
extern void _nrn_thread_table_reg(int, void(*)(double*, Datum*, Datum*, _NrnThread*, int));
extern void hoc_register_tolerance(int, HocStateTolerance*, Symbol***);
extern void _cvode_abstol( Symbol**, double*, int);

 void _gabaa_reg() {
	int _vectorized = 0;
  _initlists();
 	_pointtype = point_register_mech(_mechanism,
	 nrn_alloc,nrn_cur, nrn_jacob, nrn_state, nrn_init,
	 hoc_nrnpointerindex, 0,
	 _hoc_create_pnt, _hoc_destroy_pnt, _member_func);
 _mechtype = nrn_get_mechtype(_mechanism[1]);
     _nrn_setdata_reg(_mechtype, _setdata);
  hoc_register_dparam_size(_mechtype, 3);
 	hoc_register_cvode(_mechtype, _ode_count, 0, 0, 0);
 pnt_receive[_mechtype] = _net_receive;
 pnt_receive_size[_mechtype] = 2;
 	hoc_register_var(hoc_scdoub, hoc_vdoub, hoc_intfunc);
 	ivoc_help("help ?1 GABAa_S C:/Users/dburka/Dropbox/shared/matlab/dburka/+NetworkSim/@Sim/gabaa.mod\n");
 hoc_register_limits(_mechtype, _hoc_parm_limits);
 hoc_register_units(_mechtype, _hoc_parm_units);
 }
 static double *_t_exptable;
static int _reset;
static char *modelname = "simple GABAa receptors";

static int error;
static int _ninits = 0;
static int _match_recurse=1;
static void _modl_cleanup(){ _match_recurse=1;}
static int release();
 static double _n_exptable(double);
 
static void _net_receive (_pnt, _args, _lflag) Point_process* _pnt; double* _args; double _lflag; 
{    _p = _pnt->_prop->param; _ppvar = _pnt->_prop->dparam;
  if (_tsav > t){ extern char* hoc_object_name(); hoc_execerror(hoc_object_name(_pnt->ob), ":Event arrived out of order. Must call ParallelContext.set_maxstep AFTER assigning minimum NetCon.delay");}
 _tsav = t;   if (_lflag == 1. ) {*(_tqitem) = 0;}
 {
   if ( _lflag  == 0.0 ) {
     if (  ! _args[1] ) {
       C = Cmax ;
       R0 = R ;
       lastrelease = t ;
       _args[1] = 1.0 ;
       net_send ( _tqitem, _args, _pnt, t +  Cdur , 1.0 ) ;
       net_send ( _tqitem, _args, _pnt, t +  Cdur + Deadtime , 2.0 ) ;
       }
     }
   if ( _lflag  == 1.0 ) {
     if ( C  == Cmax ) {
       R1 = R ;
       C = 0. ;
       }
     }
   if ( _lflag  == 2.0 ) {
     _args[1] = 0.0 ;
     }
   } }
 
static int  release (  ) {
   if ( C > 0.0 ) {
     R = Rinf + ( R0 - Rinf ) * exptable ( _threadargscomma_ - ( t - lastrelease ) / Rtau ) ;
     }
   else {
     R = R1 * exptable ( _threadargscomma_ - Beta * phi_h * ( t - ( lastrelease + Cdur ) ) ) ;
     }
   
/*VERBATIM*/
	return 0;
  return 0; }
 
static double _hoc_release(void* _vptr) {
 double _r;
    _hoc_setdata(_vptr);
 _r = 1.;
 release (  );
 return(_r);
}
 static double _mfac_exptable, _tmin_exptable;
 static void _check_exptable();
 static void _check_exptable() {
  static int _maktable=1; int _i, _j, _ix = 0;
  double _xi, _tmax;
  if (!usetable) {return;}
  if (_maktable) { double _x, _dx; _maktable=0;
   _tmin_exptable =  - 10.0 ;
   _tmax =  10.0 ;
   _dx = (_tmax - _tmin_exptable)/2000.; _mfac_exptable = 1./_dx;
   for (_i=0, _x=_tmin_exptable; _i < 2001; _x += _dx, _i++) {
    _t_exptable[_i] = _f_exptable(_x);
   }
  }
 }

 double exptable(double _lx){ _check_exptable();
 return _n_exptable(_lx);
 }

 static double _n_exptable(double _lx){ int _i, _j;
 double _xi, _theta;
 if (!usetable) {
 return _f_exptable(_lx); 
}
 _xi = _mfac_exptable * (_lx - _tmin_exptable);
 _i = (int) _xi;
 if (_xi <= 0.) {
 return _t_exptable[0];
 }
 if (_i >= 2000) {
 return _t_exptable[2000];
 }
 return _t_exptable[_i] + (_xi - (double)_i)*(_t_exptable[_i+1] - _t_exptable[_i]);
 }

 
double _f_exptable (  double _lx ) {
   double _lexptable;
 if ( ( _lx > - 10.0 )  && ( _lx < 10.0 ) ) {
     _lexptable = exp ( _lx ) ;
     }
   else {
     _lexptable = 0. ;
     }
   
return _lexptable;
 }
 
static double _hoc_exptable(void* _vptr) {
 double _r;
    _hoc_setdata(_vptr);
  _r =  exptable (  *getarg(1) );
 return(_r);
}
 
static int _ode_count(int _type){ hoc_execerror("GABAa_S", "cannot be used with CVODE"); return 0;}

static void initmodel() {
  int _i; double _save;_ninits++;
 _save = t;
 t = 0.0;
{
 {
   R = 0.0 ;
   C = 0.0 ;
   Rinf = Cmax * Alpha / ( Cmax * Alpha + Beta ) ;
   phi_h = pow( q10 , ( ( temperature - exptemp ) / 10.0 ) ) ;
   Rtau = 1.0 / ( ( ( Alpha * Cmax ) + Beta ) * phi_h ) ;
   lastrelease = - 9e9 ;
   R1 = 0.0 ;
   }
  _sav_indep = t; t = _save;

}
}

static void nrn_init(_NrnThread* _nt, _Memb_list* _ml, int _type){
Node *_nd; double _v; int* _ni; int _iml, _cntml;
#if CACHEVEC
    _ni = _ml->_nodeindices;
#endif
_cntml = _ml->_nodecount;
for (_iml = 0; _iml < _cntml; ++_iml) {
 _p = _ml->_data[_iml]; _ppvar = _ml->_pdata[_iml];
 _tsav = -1e20;
#if CACHEVEC
  if (use_cachevec) {
    _v = VEC_V(_ni[_iml]);
  }else
#endif
  {
    _nd = _ml->_nodelist[_iml];
    _v = NODEV(_nd);
  }
 v = _v;
 initmodel();
}}

static double _nrn_current(double _v){double _current=0.;v=_v;{ {
   g = gmax * R ;
   i = g * ( v - Erev ) ;
   }
 _current += i;

} return _current;
}

static void nrn_cur(_NrnThread* _nt, _Memb_list* _ml, int _type){
Node *_nd; int* _ni; double _rhs, _v; int _iml, _cntml;
#if CACHEVEC
    _ni = _ml->_nodeindices;
#endif
_cntml = _ml->_nodecount;
for (_iml = 0; _iml < _cntml; ++_iml) {
 _p = _ml->_data[_iml]; _ppvar = _ml->_pdata[_iml];
#if CACHEVEC
  if (use_cachevec) {
    _v = VEC_V(_ni[_iml]);
  }else
#endif
  {
    _nd = _ml->_nodelist[_iml];
    _v = NODEV(_nd);
  }
 _g = _nrn_current(_v + .001);
 	{ _rhs = _nrn_current(_v);
 	}
 _g = (_g - _rhs)/.001;
 _g *=  1.e2/(_nd_area);
 _rhs *= 1.e2/(_nd_area);
#if CACHEVEC
  if (use_cachevec) {
	VEC_RHS(_ni[_iml]) -= _rhs;
  }else
#endif
  {
	NODERHS(_nd) -= _rhs;
  }
 
}}

static void nrn_jacob(_NrnThread* _nt, _Memb_list* _ml, int _type){
Node *_nd; int* _ni; int _iml, _cntml;
#if CACHEVEC
    _ni = _ml->_nodeindices;
#endif
_cntml = _ml->_nodecount;
for (_iml = 0; _iml < _cntml; ++_iml) {
 _p = _ml->_data[_iml];
#if CACHEVEC
  if (use_cachevec) {
	VEC_D(_ni[_iml]) += _g;
  }else
#endif
  {
     _nd = _ml->_nodelist[_iml];
	NODED(_nd) += _g;
  }
 
}}

static void nrn_state(_NrnThread* _nt, _Memb_list* _ml, int _type){
 double _break, _save;
Node *_nd; double _v; int* _ni; int _iml, _cntml;
#if CACHEVEC
    _ni = _ml->_nodeindices;
#endif
_cntml = _ml->_nodecount;
for (_iml = 0; _iml < _cntml; ++_iml) {
 _p = _ml->_data[_iml]; _ppvar = _ml->_pdata[_iml];
 _nd = _ml->_nodelist[_iml];
#if CACHEVEC
  if (use_cachevec) {
    _v = VEC_V(_ni[_iml]);
  }else
#endif
  {
    _nd = _ml->_nodelist[_iml];
    _v = NODEV(_nd);
  }
 _break = t + .5*dt; _save = t;
 v=_v;
{
 { {
 for (; t < _break; t += dt) {
 error =  release();
 if(error){fprintf(stderr,"at line 112 in file gabaa.mod:\n	SOLVE release\n"); nrn_complain(_p); abort_run(error);}
 
}}
 t = _save;
 }}}

}

static void terminal(){}

static void _initlists() {
 int _i; static int _first = 1;
  if (!_first) return;
   _t_exptable = makevector(2001*sizeof(double));
_first = 0;
}
