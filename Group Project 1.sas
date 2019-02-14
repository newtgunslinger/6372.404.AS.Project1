PROC IMPORT OUT= WORK.pats
            DATAFILE= "/home/daveknockwin0/PatriotsYearlyStats.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
RUN;



/* Print original dataset */
proc print data=pats;
run;



/* Scatterplot matrices to determine predictors */
proc sgscatter data=pats;
matrix RegSeasonWins BradyPasserRating PointsFor PointsAgainst PointsDifferential MarginOfVictory StrenghOfSchedule 
SimpleRatingSystem OffSimpleRatingSys DefSimpleRatingSys 
/ diagonal=(histogram);
run;

proc sgscatter data=pats;
matrix RegSeasonWins Yards Plays YardsPerPlay Turnovers FumblesLost FirstDowns PassCompletions PassAttempts PassYards 
PassTouchdowns PassInterceptions NetYardsPerPass PassFirstDowns RushAttempts 
/ diagonal=(histogram);
run;

proc sgscatter data=pats;
matrix RegSeasonWins RushYards RushTouchdowns RushYardsPerAttempt RushFirstDowns Penalties PenaltyYards PenaltyFirstDowns 
NumberDrives DriveScorePercent DriveTurnoverPercent AvgStartingPosition 
/ diagonal=(histogram);
run;

proc sgscatter data=pats;
matrix RegSeasonWins AvgDriveTime AvgDrivePlays AvgDriveYards AvgDrivePoints OppPointsFor OppYards OppPlays OppYardsPerPlay 
OppTurnovers OppFumblesLost OppFirstDowns OppPassCompletions OppPassAttempts 
/ diagonal=(histogram);
run;

proc sgscatter data=pats;
matrix RegSeasonWins OppPassYards OppPassTouchdowns OppPassInterceptions OppNetYardsPerPass OppPassFirstDowns OppRushAttempts 
OppRushYards OppRushTouchdowns OppRushYardsPerAttempt OppRushFirstDowns 
/ diagonal=(histogram);
run;

proc sgscatter data=pats;
matrix RegSeasonWins OppPenalties OppPenaltyYards OppPenaltyFirstDowns OppNumberDrives OppDriveScorePercent OppDriveTurnoverPerent 
OppAvgStartingPosition OppAvgDriveTime OppAvgDrivePlays 
/ diagonal=(histogram);
run;

proc sgscatter data=pats;
matrix RegSeasonWins OppAvgDriveYards OppAvgDrivePoints/ diagonal=(histogram);
run;



/* Scatterplot matrix of the predictors */
proc sgscatter data=pats;
matrix RegSeasonWins BradyPasserRating PointsFor PointsAgainst PointsDifferential MarginOfVictory SimpleRatingSystem Turnovers FirstDowns 
PassTouchdowns PassInterceptions NetYardsPerPass DriveScorePercent DriveTurnoverPercent AvgDriveTime AvgDrivePoints / diagonal=(histogram);
run;



/* Checking assumptions including outliers and leverage points */
proc reg data=pats plots(labels) = (rstudentleverage cooksd);
model RegSeasonWins = BradyPasserRating PointsFor PointsAgainst PointsDifferential MarginOfVictory SimpleRatingSystem Turnovers FirstDowns 
PassTouchdowns PassInterceptions NetYardsPerPass DriveScorePercent DriveTurnoverPercent AvgDriveTime AvgDrivePoints;
run; quit;



/* New dataset without outliers */
data pats2;
set pats;
if _n_=1 then delete;
if _n_=3 then delete;
if _n_=5 then delete;
run;



/* Print new dataset */
proc print data=pats2; run;



/* Checking multicollinearity thru VIFs */
proc reg data=pats2 corr plots(label)=(rstudentleverage cooksd);
model RegSeasonWins = BradyPasserRating PointsFor PointsAgainst PointsDifferential MarginOfVictory SimpleRatingSystem Turnovers FirstDowns 
PassTouchdowns PassInterceptions NetYardsPerPass DriveScorePercent DriveTurnoverPercent AvgDriveTime AvgDrivePoints / VIF;
run; quit;



/* Scatterplot matrix of the predictors minus the multicollinear ones */
proc sgscatter data=pats2;
matrix RegSeasonWins BradyPasserRating PointsFor PointsDifferential 
PassTouchdowns PassInterceptions NetYardsPerPass / diagonal=(histogram);
run;



/* Models for LARS, LASSO, stepwise, partial with final two predictors, partial with final one predictor on original dataset*/
proc GLMSELECT data=pats;
model RegSeasonWins = BradyPasserRating PointsFor PointsDifferential PassTouchdowns PassInterceptions NetYardsPerPass / selection = LARS;
run; quit;

proc GLMSELECT data=pats;
model RegSeasonWins = BradyPasserRating PointsFor PointsDifferential PassTouchdowns PassInterceptions NetYardsPerPass / selection = LASSO;
run; quit;

proc GLMSELECT data=pats;
model RegSeasonWins = BradyPasserRating PointsFor PointsDifferential PassTouchdowns PassInterceptions NetYardsPerPass / selection = stepwise;
run; quit;

proc reg data=pats;
model RegSeasonWins = BradyPasserRating PointsDifferential /partial;
run;

proc reg data=pats;
model RegSeasonWins = PointsDifferential /partial;
run;



/* Model for K-fold cross validation (leave-one-out) on original dataset*/
proc GLMSELECT data=pats;
model RegSeasonWins = BradyPasserRating PointsFor PointsDifferential PassTouchdowns PassInterceptions NetYardsPerPass / selection=forward(STOP=Press);
run;



/* Models for LARS, LASSO, stepwise, partial with final two predictors, partial with final one predictor on new dataset*/
proc GLMSELECT data=pats2;
model RegSeasonWins = BradyPasserRating PointsFor PointsDifferential PassTouchdowns PassInterceptions NetYardsPerPass / selection = LARS;
run; quit;

proc GLMSELECT data=pats2;
model RegSeasonWins = BradyPasserRating PointsFor PointsDifferential PassTouchdowns PassInterceptions NetYardsPerPass / selection = LASSO;
run; quit;

proc GLMSELECT data=pats2;
model RegSeasonWins = BradyPasserRating PointsFor PointsDifferential PassTouchdowns PassInterceptions NetYardsPerPass / selection = stepwise;
run; quit;

proc reg data=pats2;
model RegSeasonWins = BradyPasserRating PointsDifferential /partial;
run;

proc reg data=pats2;
model RegSeasonWins = PointsDifferential /partial;
run;



/* Model for K-fold cross validation (leave-one-out) on new dataset*/
proc GLMSELECT data=pats2;
model RegSeasonWins = BradyPasserRating PointsFor PointsDifferential PassTouchdowns PassInterceptions NetYardsPerPass / selection=forward(STOP=Press);
run;



/* Confidence intervals for the final model */
proc reg data=pats2;
model RegSeasonWins = PointsDifferential / clb;
run;