// random_choice strategy
+!decide_sanctions(NormInstance,SanctionDecisions)
  : sanction_strategy(S) & (S == random_choice | S == random_threshold)
  <-
  !active_sanctions_for(NormInstance,Options);
  if ( .empty(Options) ) {
  	SanctionDecisions = [];
    !increase_sanctions_in_round;
  } else {
    if ( .length(Options) == 1 ) {
      .nth(0,Options,Sanction);
    } else {
      !apply_strategy(Options,Sanction);
    }
    SanctionDecisions = [Sanction];
  }.


// random_choice sanction strategy
+!apply_strategy(Options,Sanction)
  : sanction_strategy(random_choice)
  <-
  .random(X);
  if (X < 0.5) {
    .nth(0,Options,Sanction);
  } else {
    .nth(1,Options,Sanction);
  }.
