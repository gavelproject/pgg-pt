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
  for ( .member(C,L) & (C == "detector" | C == "evaluator") ) {
  	!acquire_capability(C);
  	registerSelfAs(C);
  }. 


// Acquire plans for capability C
+!acquire_capability(C)
  <-
  acquireCapability(C,File);
  .rename_apart(File,RenFile);
  .add_plan(RenFile).


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
  !detect;
  stopFocus(Pool);
  .abolish(focused(_,_[artifact_type("pgg.Pool")],_));
  .my_name(Me);
  ?current_round(Round);
  .send(manager,tell,done_with(Me,Round)).


{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }