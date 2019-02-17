/*Import BradyStats.csv from */

/* Two-Way ANOVA */
proc anova data=work.import;                                                                                                                                   
class AgeBin WonLost;
model Rate = AgeBin WonLost;
run;

proc glm data=work.import plots=all;
class AgeBin WonLost;
model Rate = AgeBin WonLost / clm;
run;



/* One-Way ANOVA*/
proc anova data=work.import;                                                                                                                                   
class AgeBin WonLost;
model Rate = AgeBin WonLost;
run;

proc glm data=work.import plots=all;
class AgeBin WonLost;
model Rate = AgeBin WonLost / clm;
run;
