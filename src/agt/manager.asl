current_round(0).

!setup_then_start.

+!setup_then_start
<-!setup;
	!start.

+!setup
<-!update_players_list;
	!create_pool_artifacts;
	!wait_until_all_done.

+!update_players_list
<-.all_names(Ags);
	.my_name(Me);
	.delete(Me,Ags,Players);
	-+players(Players);
	-+num_players(.length(Players)).

+!create_pool_artifacts
<-?num_players(NumPlayers);
	?group_size(GroupSize);
	NGroups = NumPlayers/GroupSize;
	+ngroups(NGroups);
	cartago.new_array("java.lang.String[]",["contributions_received"],Array);
	cartago.new_obj("cartago.events.SignalFilter",[Array],Filter);
	for ( .range(I,1,NGroups) ) {
		.concat("pool",I,PoolName);
		makeArtifact(PoolName,"pgg.Pool",[],PoolId);
		focus(PoolId,Filter);
		?focused(pgg,_,PoolId);
	}
	!store_pools.

+!store_pools
<-.findall(
		PoolName,
		focused(pgg,PoolName[artifact_type("pgg.Pool")],_),
		PoolsList
	);
	+pools(PoolsList).

+!start
<-?max_rounds(Max);
	for ( .range(I,1,Max) ) {
		!increment_round;
		!run_round;
		!wait_until_all_done;
		!kill_players_in_death_row;
		!clear_pools;
	}
	.stopMAS.

+!increment_round
<-?current_round(OldRound);
	NewRound = OldRound+1;
	-+current_round(NewRound).

+!run_round
<-?current_round(Round);
	?ngroups(NGroups);
	?group_size(GroupSize);
	!shuffled_players(Players);
	?num_players(NumPlayers);
	?pools(Pools);
	for ( .range(I,0,NGroups-1) ) {
		.nth(I,Pools,PoolName);
		/*
		 * 1. Add the pool members to the pool.
		 * 2. Run the pool.
		 * 3. After the pool is running, tell the players they should focus on it.
		 * This ensures that players will be able to percept all the
		 * `pool_member(AgName)` observable properties when they focus on the
		 * artefact.
		 */
		for ( .range(J,I*GroupSize,(I+1)*GroupSize-1) & J < NumPlayers ) {
			.nth(J,Players,Player);
			addMember(Player)[artifact_name(PoolName)];
		}
		run[artifact_name(PoolName)];
		for ( .range(J,I*GroupSize,(I+1)*GroupSize-1) & J < NumPlayers ) {
			.nth(J,Players,Player);
			.send(Player,achieve,focus_pool(PoolName));
		}
	}.

+!shuffled_players(S)
<-?players(L);
	.shuffle(L,S).

+!wait_until_all_done
<-.wait(all_done);
	.abolish(done(_));
	-all_done.

+done(_)
: num_players(N) & .count(done(_)) == N
<-+all_done.

+!kill_players_in_death_row
: in_death_row(_)
<-for ( in_death_row(Player) ) {
		.kill_agent(Player);
		.abolish(in_death_row(Player));
	}
	!update_players_list;
	.wait(not in_death_row(_)).

+!kill_players_in_death_row.

+!clear_pools
<-?pools(Pools);
	for ( .member(PoolName,Pools) ) {
		clear[artifact_name(PoolName)];
	}.

+contributions_received[artifact_id(PoolId)]
<-?benefit_factor(F);
	multiplyContributions(F)[artifact_id(PoolId)];
	disclosePayoff[artifact_id(PoolId)];
	discloseContributions[artifact_id(PoolId)];
	finish[artifact_id(PoolId)].

{ include("$jacamoJar/templates/common-cartago.asl") }