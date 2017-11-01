manager(manager).


!start.


+!start
  <-
  !create_de_facto;
  !acquire_capabilities.


+!create_de_facto
  <-
  .my_name(Me);
   .concat(Me,".de_facto",DfName);
   makeArtifact(DfName,"gavel.jacamo.DeFacto",[],DfId);
   focus(DfId).


+!acquire_capabilities
  <-
  ?focused(_,capability_board,_);
  ?capabilities(L);
  for ( .member(C,L) & (C == "detector" | C == "evaluator" | C == "executor") ) {
  	!acquire_capability(C);
  	registerSelfAs(C);
  }. 


// Acquire plans for capability C
+!acquire_capability(C)
  <-
  acquireCapability(C,Plan);
//  .rename_apart(Plan,RenamedPlan);
  .add_plan(Plan).


+current_round(Round) <- .abolish(current_round(Round-1)).


// goal sent by the manager
+!focus_pool(PoolName)
  <-
  lookupArtifact(PoolName,PoolId);
  focus(PoolId).


+pool_status("RUNNING")[artifact_id(PoolId)]
  <-
  if (.random(X) & X >= 0.5) {
    !contribute(1,PoolId);
  } else {
    !contribute(0,PoolId);
  }.


+!contribute(Contribution,PoolId)
  <-
  ?tokens(T);
  -+tokens(T-Contribution);
  contribute(Contribution)[artifact_id(PoolId)].


+payoff(Payoff,_)
  <-
  ?tokens(T);
  -+tokens(T+Payoff).


+pool_status("FINISHED")[artifact_id(Pool)]
  <-
  ?current_round(Round);
  .wait(.count(contribution(_,_,Round)) == .count(pool_member(_,Round)) );
  !detect_normative_events;
  stopFocus(Pool);
  .abolish(focused(_,_[artifact_type("pgg.Pool")],_));
  .my_name(Me);
  .send(manager,tell,done_with(Me,Round)).


+!report(NormInstance)
  : .my_name(Me) &
    evaluators(Evaluators) &
    .member(Me,Evaluators)
  <-
  norm(_,_,_,_,target(Target),_,_,_)[H|T] = NormInstance;
  if ( .member(violation_time(_),[H|T]) & Target \== Me) {
    !evaluate(NormInstance);
  }.


+!decide_sanctions(NormInstance,SanctionDecisions)
  <-
  !active_sanctions_for(NormInstance,Options);
  .random(X);
  if (X < 0.5) {
    .nth(0,Options,Sanction);
  } else {
    .nth(1,Options,Sanction);
  }
  SanctionDecisions = [Sanction].


+!gossip(Target,Move,Round)
  <-
  .puts("Gossip: #{Target}-#{Move}-#{Round}").


+!punish(Target,Round)
  <-
  .puts("Punishment: #{Target}-#{Round}").

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }