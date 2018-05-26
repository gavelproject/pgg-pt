//////////////////// BEGIN SIMULATION PARAMETERS ////////////////////
benefit_factor(3).
cooperation_cost(1).
cost_to_punish(0.05).
cost_being_punished(0.5).
gain_loss_utility_coeff(1).
loss_aversion_coeff(2.25).
tokens(12.5).

/** Minimal image value to consider an agent as cooperator. */
min_img_cooperator(0.6).

/** Maximum percentage of mates that may be sanctioned per round. */
max_sanction_ratio(0.75).

/** [gossip|punishment|random|threshold] */
sanction_decision_strategy(threshold).

/////////////////// END SIMULATION PARAMETERS /////////////////////
/* INITIAL BELIEFS */
current_round(0).
manager(manager).
pending_sanctions(0).

/* PLANS */
!start.

+!start
<-!create_de_facto;
	!acquire_capabilities;
	!ready_to_play.

+!create_de_facto
<-.my_name(Me);
	.concat(Me,".de_facto",DfName);
	makeArtifact(DfName,"gavel.jacamo.DeFacto",[],DfId);
	focus(DfId);
	?focused(pgg,_,DfId).

+!acquire_capabilities
<-?focused(_,capability_board,_);
	for ( .member(C,["detector","evaluator","executor"]) ) {
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
	lookupArtifact(PoolName,PoolId);
	focus(PoolId);
	?focused(pgg,_,PoolId).

+!update_players_in_other_groups
<-.all_names(Ags);
	.delete(manager,Ags,Players);
	.findall(Player,.member(Player,Players) & not pool_member(Player),Result);
	-+players_in_other_groups(Result).

+pool_status("RUNNING")
<-!incorporate_transmissions;
	!identify_freerider_mates;
	!update_players_in_other_groups;
	.count(pool_member(_),NumPlayers);
	?max_sanction_ratio(MaxSanctionRatio);
	math.floor((NumPlayers-1)*MaxSanctionRatio,SanctionsCredit);
	-+sanctions_credit(SanctionsCredit);
	!play_move.

+!contribute(Contribution,PoolId)
<-?tokens(T);
	-+tokens(T-Contribution);
	contribute(Contribution)[artifact_id(PoolId)].

+payoff(Payoff)
<-?tokens(T);
	-+tokens(T+Payoff).

+pool_status("FINISHED")[artifact_id(PoolId)]
<-	.findall(contribution(P,V), contribution(P,V) & not .my_name(P), L);
	!update_images_history(L);
	!detect_normative_events;
	// Wait for all sanctions to be applied
	.wait(pending_sanctions(0));
	!done_playing(PoolId).

+!update_images_history([contribution(Player,Value)|T])
:	history(Player,Coops,Rounds)
<-	!update_images_history(T);
	.abolish(history(Player,Coops,Rounds));
	+history(Player,Coops+Value,Rounds+1);
	!save_image(Player,Coops+Value,Rounds+1).

+!update_images_history([contribution(Player,Value)|T])
<-	!update_images_history(T);
	+history(Player,Value,1);
	!save_image(Player,Value,1).

+!update_images_history([]).

+!incorporate_transmissions
<-	for ( gossip(Player) ) {
		P = history(Player,Coops,Rounds);
		if ( P ) {
			-+history(Player,Coops,Rounds+1);
		} else {
			+history(Player,0,1);
		}
		.abolish(gossip(Player));
	}.

+!identify_freerider_mates
<-	P = freerider_mates(Freeriders);
	if ( not P ) {
		?min_img_cooperator(MinImgCoop);
		.setof(	Player,
			pool_member(Player) &
				image(Player,ImgValue) &
				ImgValue < MinImgCoop,
			Freeriders
		);
		+P;
	}.

+!save_image(Player,Coops,Rounds)
<-Value = Coops/Rounds;
	-image(Player,_);
	+image(Player,Value).

+!increment_pending_sanctions
<-?pending_sanctions(N);
	-+pending_sanctions(N+1);
	?sanctions_credit(Credit);
	-+sanctions_credit(Credit-1).

+!decrement_pending_sanctions
<-?pending_sanctions(N);
	-+pending_sanctions(N-1).

+!done_playing(PoolId)
<-	.my_name(Me);
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
	?focused(_,PoolName[_],PoolId);
	?freerider_mates(Freeriders);
	.findall(
		Target,
		applied_sanction(Target,gossip,Round),
		GossipTargets
	);
	.findall(
		Target,
		applied_sanction(Target,punishment,Round),
		PunishmentTargets
	);
	
	.print(
		Round,",",
		Me,",",
		Wealth,",",
		Move,",",
		PoolName,",",
		"\"",Freeriders,"\",",
		"\"",GossipTargets,"\",",
		"\"",PunishmentTargets,"\""
	);
	!done_log(PoolId).

+!done_log(PoolId)
<-	stopFocus(PoolId);
	.abolish(focused(_,_,PoolId));
	-freerider_mates(_);
	.my_name(Me);
	?manager(Manager);
	.send(Manager,tell,done(Me)).

+!prepare_for_death
<-.my_name(Me);
	.concat(Me,".img_db",ImgDbName);
	lookupArtifact(ImgDbName,ImgDbId);
	disposeArtifact(ImgDbId);
	.concat(Me,".de_facto",DfName);
	lookupArtifact(DfName,DfId);
	disposeArtifact(DfId).

{ include("controller_strategy.asl") }
{ include("detector_strategy.asl") }
{ include("evaluator_strategy.asl") }
{ include("move_strategy.asl") }
{ include("sanction_plans.asl") }
{ include("$jacamoJar/templates/common-cartago.asl") }
