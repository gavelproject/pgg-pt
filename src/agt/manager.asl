!setup.
!start.

+!setup
  <-
  .all_names(Ags);
  .my_name(Me);
  .delete(Me,Ags,Players);
  +players(Players).

+!start
  <- 
  ?max_timesteps(Max);
  for ( .range(I,1,Max) ) {
    !update_timestep;
    !run_round;
  }.
  
+!update_timestep
  <-
  ?timestep(OldT);
  NewT=OldT+1;
  -+timestep(NewT);
  .puts("Timestep##{NewT}:");
  .broadcast(untell,timestep(_));
  .broadcast(tell,timestep(NewT)).
  
+!run_round
  <-
  ?timestep(T);
  ?players(L);
  .shuffle(L,Shuffled);
  .length(Shuffled, NAgs);
  ?group_size(GroupSize);
  NGroups = NAgs / GroupSize;
  
  for ( .range(I,1,NGroups) ) {
    .puts("  Group##{I}:");
    .concat("g",I,"ts",T,"pool",PoolName);
    makeArtifact(PoolName,"pgg.Pool",[],PoolId);
    focus(PoolId);
    for ( .range(J,(I-1)*GroupSize,I*GroupSize-1) ) {
      .nth(J,Shuffled,Ag);
      addMember(Ag)[artifact_id(PoolId)];
      .puts("    #{Ag}");
      .send(Ag,achieve,focus_pool(PoolName));
    }
  }
  .wait(200);
  .broadcast(achieve,leave_pool);
  .wait(200);
  .findall(PoolId,focused(_,_[artifact_type("pgg.Pool")],PoolId),Pools);
  !dispose_pools(Pools).
  
+!dispose_pools([])
  <-
  .abolish(focused(_,_[artifact_type("pgg.Pool")],_)).
+!dispose_pools([H|T])
  <-
  stopFocus(H);
  disposeArtifact(H);
  !dispose_pools(T).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }