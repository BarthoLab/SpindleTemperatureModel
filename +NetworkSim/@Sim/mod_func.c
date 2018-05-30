#include <stdio.h>
#include "hocdec.h"
#define IMPORT extern __declspec(dllimport)
IMPORT int nrnmpi_myid, nrn_nobanner_;

extern void _Gfluct2_reg();
extern void _HH2_reg();
extern void _IAHP_reg();
extern void _ICAN_reg();
extern void _IT_reg();
extern void _IT2_reg();
extern void _Ih_reg();
extern void _T_EZs_reg();
extern void _ampa_reg();
extern void _cadecay_reg();
extern void _capump_reg();
extern void _gabaa_reg();
extern void _gabab_reg();
extern void _kleak_reg();
extern void _sk_gp_reg();
extern void _vecevent_reg();

modl_reg(){
	//nrn_mswindll_stdio(stdin, stdout, stderr);
    if (!nrn_nobanner_) if (nrnmpi_myid < 1) {
	fprintf(stderr, "Additional mechanisms from files\n");

fprintf(stderr," Gfluct2.mod");
fprintf(stderr," HH2.mod");
fprintf(stderr," IAHP.mod");
fprintf(stderr," ICAN.mod");
fprintf(stderr," IT.mod");
fprintf(stderr," IT2.mod");
fprintf(stderr," Ih.mod");
fprintf(stderr," T_EZs.mod");
fprintf(stderr," ampa.mod");
fprintf(stderr," cadecay.mod");
fprintf(stderr," capump.mod");
fprintf(stderr," gabaa.mod");
fprintf(stderr," gabab.mod");
fprintf(stderr," kleak.mod");
fprintf(stderr," sk_gp.mod");
fprintf(stderr," vecevent.mod");
fprintf(stderr, "\n");
    }
_Gfluct2_reg();
_HH2_reg();
_IAHP_reg();
_ICAN_reg();
_IT_reg();
_IT2_reg();
_Ih_reg();
_T_EZs_reg();
_ampa_reg();
_cadecay_reg();
_capump_reg();
_gabaa_reg();
_gabab_reg();
_kleak_reg();
_sk_gp_reg();
_vecevent_reg();
}
