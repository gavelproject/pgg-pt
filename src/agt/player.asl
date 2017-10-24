// Initial goal
!start.

+!start
   <- 
   .my_name(Me);
   .concat(Me,".de_facto",DfName);
   makeArtifact(DfName,"gavel.jacamo.DeFacto",[],DfId);
   focus(DfId);
   !acquire_capabilities.
   
// goal sent by the manager
+!focus_pool(PoolName)
  <-
  lookupArtifact(PoolName,PoolId);
  focus(PoolId).

// goal sent by the manager
+!leave_pool
  <-
  ?focused(_,_[artifact_type("pgg.Pool")],PoolId);
  stopFocus(PoolId);
  .abolish(focused(_,_[artifact_type("pgg.Pool")],_)).

+!acquire_capabilities
  <-
  ?focused(_,capability_board,_);
  ?capabilities(L);
  for ( .member(C,L) & C == "detector" | C == "evaluator" ) {
  	!acquire_capability(C);
  	registerSelfAs(C);
  }. 
  
// Acquire plans for capability C
-!acquire_capability(C)
  <-
  acquireCapability(C,File);
  .rename_apart(File,RenFile);
  .add_plan(RenFile).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }