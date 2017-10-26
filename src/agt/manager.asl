players([]).
ngroups(_).
pools([]).

!setup_then_start.


+!setup_then_start
  <-
  !setup;
  !start.


+!setup
  <-
  !list_players(L);
  +players(L);
  !create_pool_artifacts.


+!list_players(L)
  <-
  .all_names(Ags);
  .my_name(Me);
  .delete(Me,Ags,L).


+!create_pool_artifacts
  : players(L) & .length(L,NP) & (NP > 0)
  <-
  ?group_size(GroupSize);
  NGroups = NP / GroupSize;
  +ngroups(NGroups);
  for ( .range(I,1,NGroups) ) {
    .concat("pool",I,PoolName);
    makeArtifact(PoolName,"pgg.Pool",[],PoolId);
    focus(PoolId);
    !add_pool(PoolName,PoolId);
  }.


-!create_pool_artifacts
  <-
  .wait(100);
  !create_pool_artifacts.


+!add_pool(PoolName,PoolId)
  <-
  ?pools(CurrentList);
  .union(CurrentList,[pool(PoolName,PoolId)],NewList);
  -+pools(NewList).


+!start
  <- 
  ?max_rounds(Max);
  for ( .range(I,1,Max) ) {
    !increment_round;
    ?current_round(Round);
    ?pool_duration(Duration);
    !run_round(Round,Duration);
    !wait_everyone_is_done_with(Round);
    !clear_pools;
  }.


+!increment_round
  <-
  ?current_round(OldRound);
  NewRound = OldRound + 1;
  -+current_round(NewRound);
  .puts("Round##{NewRound}:");
  .broadcast(untell,current_round(_));
  .broadcast(tell,current_round(NewRound)).


+!run_round(Round,Duration)
  <-
  ?ngroups(NGroups);
  ?group_size(GroupSize);
  !shuffled_players(Players);
  ?pools(Pools);
  for ( .range(I,0,NGroups-1) ) {
    .nth(I,Pools,pool(PoolName,_));
    setRound(Round)[artifact_name(PoolName)];
    .puts("  Pool #{PoolName}:");
    for ( .range(J,I*GroupSize,(I+1)*GroupSize-1) ) {
      .nth(J,Players,Player);
      addMember(Player)[artifact_name(PoolName)];
      .puts("    #{Player}");
      .send(Player,achieve,focus_pool(PoolName));
    }
    run(Duration)[artifact_name(PoolName)];
  }.


+!shuffled_players(S)
  <-
  ?players(L);
  .shuffle(L,S).


+!wait_everyone_is_done_with(Round)
  <-
  .wait(everyone_done_with(Round));
  -everyone_is_done_with(Round).


+done_with(_, Round)
  : players(L)
    & .length(L,NPlayers)
    & .count(done_with(_,Round),C)
    & C == NPlayers
  <-
  +everyone_is_done_with(Round).


+!clear_pools
  <-
  ?pools(Pools);
  for ( .member(pool(_,PoolId),Pools)) {
  	clear[artifact_id(PoolId)];
  }.


+status("FINISHED")[artifact_id(PoolId)]
  <-
  ?benefit_factor(F);
  multiplyContributions(F)[artifact_id(PoolId)];
  disclosePayoff[artifact_id(PoolId)];
  discloseContributions[artifact_id(PoolId)].


{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }