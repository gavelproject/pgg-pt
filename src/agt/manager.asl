current_round(0).
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
  !create_pool_artifacts;
  !wait_until_all_done.


+!list_players(L)
  <-
  .all_names(Ags);
  .my_name(Me);
  .delete(Me,Ags,L).


+!create_pool_artifacts
  <-
  ?players(L);
  ?group_size(GroupSize);
  NGroups = .length(L) / GroupSize;
  +ngroups(NGroups);
  cartago.new_array("java.lang.String[]",["contributions_received"],Array);
  cartago.new_obj("cartago.events.SignalFilter",[Array],Filter);
  for ( .range(I,1,NGroups) ) {
    .concat("pool",I,PoolName);
    makeArtifact(PoolName,"pgg.Pool",[],PoolId);
    focus(PoolId,Filter);
    ?focused(pgg,_,PoolId);
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
    !run_round;
    !wait_until_all_done;
    !kill_players_in_death_row;
    !clear_pools;
  }.


+!increment_round
  <-
  ?current_round(OldRound);
  NewRound = OldRound+1;
  -+current_round(NewRound);
  .puts("Round##{NewRound}:").


+!run_round
  <-
  ?current_round(Round);
  ?ngroups(NGroups);
  ?group_size(GroupSize);
  !shuffled_players(Players);
  .length(Players,NumPlayers);
  ?pools(Pools);
  for ( .range(I,0,NGroups-1) ) {
    .nth(I,Pools,pool(PoolName,_));
    .puts("  Pool #{PoolName}:");
    for ( .range(J,I*GroupSize,(I+1)*GroupSize-1) & J < NumPlayers ) {
      .nth(J,Players,Player);
      addMember(Player)[artifact_name(PoolName)];
      .puts("    #{Player}");
      .send(Player,achieve,focus_pool(PoolName));
    }
    run[artifact_name(PoolName)];
  }.


+!shuffled_players(S)
  <-
  ?players(L);
  .shuffle(L,S).


+!wait_until_all_done
  <-
  .wait(all_done);
  .abolish(done(_));
  -all_done.


+done(_)
  : players(L) & .count(done(_)) == .length(L)
  <-
  +all_done.


+!kill_players_in_death_row
  <-
  for ( in_death_row(Player) ) {
    .kill_agent(Player);
    .abolish(in_death_row(Player));
  }
  !list_players(UpdatedList);
  -+players(UpdatedList);
  .wait(not in_death_row(_)).


+!clear_pools
  <-
  ?pools(Pools);
  for ( .member(pool(_,PoolId),Pools)) {
  	clear[artifact_id(PoolId)];
  }.


+contributions_received[artifact_id(PoolId)]
  <-
  ?benefit_factor(F);
  multiplyContributions(F)[artifact_id(PoolId)];
  disclosePayoff[artifact_id(PoolId)];
  discloseContributions[artifact_id(PoolId)];
  finish[artifact_id(PoolId)].


{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }