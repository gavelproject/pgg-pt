manager(manager).
sanctions_in_round(0).


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
  for ( .member(C,L) ) {
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


+pool_status("FINISHED")[artifact_id(PoolId)]
  <-
  !update_imgs;
  ?current_round(Round);
  .wait(.count(contribution(_,_,Round)) == .count(pool_member(_,Round)) );
  !detect_normative_events;

  // Wait for all sanctions to be applied
  NFreeriders = .count(contribution(P,0,Round) & not .my_name(P));
  .wait(sanctions_in_round(NFreeriders));

  !get_done_with_round(Round,PoolId).


+sanction_application(_,_,_,_)
  <-
  ?sanctions_in_round(NSanctions);
  -+sanctions_in_round(NSanctions+1).


+!get_done_with_round(Round,PoolId)
  <-
  stopFocus(PoolId);
  .abolish(focused(_,_[artifact_id(PoolId)],_));
  .my_name(Me);
  ?manager(Manager)
  .send(Manager,tell,done_with(Me,Round));
  -+sanctions_in_round(0).


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