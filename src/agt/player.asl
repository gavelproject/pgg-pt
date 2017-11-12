//////////////////// BEGIN SIMULATION PARAMETERS ////////////////////
cost_to_punish(1).
cost_being_punished(5).
tokens(50).

/**
 * Consider efficacy of a sanction application as 'indeterminate' after the
 * given number of rounds has passed since its application.
 */
indeterminate_efficacy_after(2).

/** Minimal image value to consider an agent as cooperator. */
min_img_cooperator(0.6).

/** Maximum number of gossips an agent can make per round. */
max_gossips_per_round(10).

/**
 * If noticed percentage of freeriders in the pool is greater than the number
 * given below, mean and nice agents use their individual active strategies.
 */
max_percentage_freeriders(0.2).

/** [gossip|punishment|random_choice|random_threshold] */
sanction_decision_strategy(gossip).

/** The two weights below should sum up to 1. */
weight_interaction_img(0.8).
weight_gossip_img(0.2).
/////////////////// END SIMULATION PARAMETERS /////////////////////

/* INITIAL BELIEFS */
current_round(0).
manager(manager).
pending_sanctions(0).

/* PLANS */
!start.

+!start
<-!create_de_facto;
	!create_img_db;
	!acquire_capabilities;
	!ready_to_play.

+!create_de_facto
<-.my_name(Me);
	.concat(Me,".de_facto",DfName);
	makeArtifact(DfName,"gavel.jacamo.DeFacto",[],DfId);
	focus(DfId);
	?focused(pgg,_,DfId).

+!create_img_db
<-.my_name(Me);
	.concat(Me,".img_db",DbName);
	?weight_gossip_img(WG);
	?weight_interaction_img(WI);
	makeArtifact(DbName,"pgg.ImageDb",[WG,WI],DbId);
	focus(DbId);
	?focused(pgg,_,DbId).

+!acquire_capabilities
<-?focused(_,capability_board,_);
	?capabilities(L);
	for ( .member(C,L) ) {
		!acquire_capability(C);
		registerSelfAs(C);
	}. 

// Acquire plans for capability C
+!acquire_capability(C)
<-acquireCapability(C,Plan);
	// .rename_apart(Plan,RenamedPlan);
	.add_plan(Plan).

+!ready_to_play
<-.my_name(Me);
	?manager(Manager);
	.send(Manager,tell,done(Me)).

// goal sent by the manager
+!focus_pool(PoolName)
<-?current_round(OldRound);
	-+current_round(OldRound+1);
	?max_gossips_per_round(MaxGossip);
	-+gossips_credit(MaxGossip);
	lookupArtifact(PoolName,PoolId);
	focus(PoolId);
	?focused(pgg,_,PoolId).

+!decrement_gossips_credit
<-?gossips_credit(Credit);
	-+gossips_credit(Credit-1).

+!update_players_in_other_groups
<-.all_names(Ags);
	.delete(manager,Ags,Players);
	.findall(Player,.member(Player,Players) & not pool_member(Player),Result);
	-+players_in_other_groups(Result).

+pool_status("RUNNING")
<-!update_players_in_other_groups;
	!assess_pool_members_image;
	!play_move.

+!contribute(Contribution,PoolId)
<-?tokens(T);
	-+tokens(T-Contribution);
	contribute(Contribution)[artifact_id(PoolId)].

+payoff(Payoff)
<-?tokens(T);
	-+tokens(T+Payoff).

+pool_status("FINISHED")[artifact_id(PoolId)]
<-!update_imgs;
	!detect_normative_events;

	// Wait for all sanctions to be applied
	.wait(pending_sanctions(0));
	!log_data;
	!done(PoolId).

+!update_imgs
<-?current_round(Round);
	for ( contribution(Player,Value) & not .my_name(Player) ) {
		addInteraction(Player,Round,Value);
	}.

+!increment_pending_sanctions
<-?pending_sanctions(N);
	-+pending_sanctions(N+1).

+!decrement_pending_sanctions
<-?pending_sanctions(N);
	-+pending_sanctions(N-1).

+!done(PoolId)
<-stopFocus(PoolId);
	.abolish(focused(_,_,PoolId));
	.my_name(Me);
	?manager(Manager);
	if ( tokens(T) & T < 0 ) {
		!prepare_for_death;
		.send(Manager,tell,in_death_row(Me));
	}
	.send(Manager,tell,done(Me)).
	
+!log_data
<-?current_round(Round);
	.my_name(Me);
	?tokens(Wealth);
	?move(Move);
	?focused(_,PoolName[_],_);
	.count(pool_member(_),PoolSize);
	.findall(Defector,contribution(Defector,0),Defectors);
	.findall(Cooperator,contribution(Cooperator,1),Cooperators);
	.findall(
		[Target,SanctionId],
		applied_sanction(Target,SanctionId,Round),
		AppliedSanctions
	);
	.print(
		Round,",",
		Me,",",
		Wealth,",",
		Move,",",
		PoolName,",",
		PoolSize,",",
		"\"",Cooperators,"\"",",",
		"\"",Defectors,"\"",",",
		"\"",AppliedSanctions,"\""
	).

+!prepare_for_death
<-.my_name(Me);
	.concat(Me,".img_db",ImgDbName);
	lookupArtifact(ImgDbName,ImgDbId);
	disposeArtifact(ImgDbId);
	.concat(Me,".de_facto",DfName);
	lookupArtifact(DfName,DfId);
	disposeArtifact(DfId).

// (T)arget, (V)alue, (S)ender
+gossip(T,V)[source(S)] <- putGossip(T,S,V).

{ include("controller_strategy.asl") }
{ include("detector_strategy.asl") }
{ include("evaluator_strategy.asl") }
{ include("move_strategy.asl") }
{ include("sanction_plans.asl") }
{ include("$jacamoJar/templates/common-cartago.asl") }