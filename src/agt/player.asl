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


// goal sent by the manager
+!focus_pool(PoolName)
  <-
  lookupArtifact(PoolName,PoolId);
  focus(PoolId).


+status("RUNNING")[artifact_id(PoolId)]
  : current_round(Round)
    & .my_name(Me)
    & pool_member(Me,Round)
    & .random(X) & X >= 0.5
  <-
  !contribute(PoolId).


+!contribute(PoolId)
  <-
  ?tokens(T);
  ?contribution_cost(Cost);
  -+tokens(T-Cost);
  contribute[artifact_id(PoolId)].


+payoff(Payoff)
  <-
  ?tokens(T);
  -+tokens(T+Payoff).


+status("FINISHED")[artifact_id(Pool)]
  <-
  !detect;
  stopFocus(Pool);
  .abolish(focused(_,_[artifact_type("pgg.Pool")],_));
  ?current_round(Round);
  .my_name(Me);
  .send(manager,tell,done_with(Me,Round)).


{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }