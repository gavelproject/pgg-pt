/* INITIAL BELIEFS */

cost_to_punish(1).
cost_being_punished(5).
/**
 * Consider efficacy of a sanction application as
 * 'indeterminate' after the given number of rounds
 * has passed since its application.
 */
indeterminate_efficacy_after(2).
manager(manager).
/** gossip/punishment/random_choice/random_threshold */
sanction_strategy(punishment).
sanctions_in_round(0).
freeriders_threshold(0.2).
tokens(50).
weight_interaction_img(0.8).
weight_gossip_img(0.2).


/* PLANS */
!start.


+!start
  <-
  !create_de_facto;
  !create_img_db;
  !acquire_capabilities;
  !ready_to_play.


+!create_de_facto
  <-
  .my_name(Me);
   .concat(Me,".de_facto",DfName);
   makeArtifact(DfName,"gavel.jacamo.DeFacto",[],DfId);
   focus(DfId).


+!create_img_db
  <-
  .my_name(Me);
   .concat(Me,".img_db",DbName);
   ?weight_gossip_img(WG);
   ?weight_interaction_img(WI);
   makeArtifact(DbName,"pgg.ImageDb",[WG,WI],DbId);
   focus(DbId).


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


+!ready_to_play
  <-
  .my_name(Me);
  ?manager(Manager);
  .send(Manager,tell,done_with(Me,0)).


+current_round(Round) <- .abolish(current_round(Round-1)).


// goal sent by the manager
+!focus_pool(PoolName)
  <-
  lookupArtifact(PoolName,PoolId);
  focus(PoolId).


+!players_from_other_groups(Round,Result)
  <-
  .all_names(Ags);
  .delete(manager,Ags,Players);
  .findall(Player,.member(Player,Players) & not pool_member(Player,Round),Result).


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


+pool_status("FINISHED")[artifact_id(PoolId)]
  <-
  !update_imgs;
  ?current_round(Round);
  .wait(.count(contribution(_,_,Round)) == .count(pool_member(_,Round)) );
  !detect_normative_events;

  // Wait for all sanctions to be applied
  NFreeriders = .count(contribution(P,0,Round) & not .my_name(P));
  .wait(sanctions_in_round(NFreeriders));

  !done_with_round(Round,PoolId).


+!update_imgs
  <-
  ?current_round(Round);
  for ( contribution(Player,Value,Round) ) {
    addInteraction(Player,Round,Value);
  }.


+!increase_sanctions_in_round
  <-
  ?sanctions_in_round(NSanctions);
  -+sanctions_in_round(NSanctions+1).


+!done_with_round(Round,PoolId)
  <-
  stopFocus(PoolId);
  .abolish(focused(_,_[artifact_id(PoolId)],_));
  -+sanctions_in_round(0);
  .my_name(Me);
  ?manager(Manager);
  if ( tokens(T) & T < 0 ) {
    !prepare_for_death;
    .send(Manager,tell,in_death_row(Me));
  }
  .send(Manager,tell,done_with(Me,Round)).


+!prepare_for_death
  <-
  .my_name(Me);
  .concat(Me,".img_db",ImgDbName);
  lookupArtifact(ImgDbName,ImgDbId);
  disposeArtifact(ImgDbId);
  .concat(Me,".de_facto",DfName);
  lookupArtifact(DfName,DfId);
  disposeArtifact(DfId).


+!report(NormInstance)
  : .my_name(Me) &
    evaluators(Evaluators) &
    .member(Me,Evaluators)
  <-
  norm(_,_,_,_,target(Target),_,_,_)[H|T] = NormInstance;
  if ( .member(violation_time(_),[H|T]) & Target \== Me) {
    !evaluate(NormInstance);
  }.


+gossip(Target,ImgValue)[source(Sender)]
  <-
  putGossip(Target,Sender,ImgValue).


+!punish_myself(Round)
  <-
  ?cost_being_punished(Cost);
  ?tokens(OldAmount);
  -+tokens(OldAmount-Cost).


+!gossip(Target,Move,Round)
  <-
  !players_from_other_groups(Round,ReceiverOptions);
  .shuffle(ReceiverOptions,Shuffled);
  .nth(0,Shuffled,Receiver);
  ?overall_img(Target,ImgValue);
  .send(Receiver,tell,gossip(Target,ImgValue));
  !increase_sanctions_in_round.


+!punish(Target,Round)
  <-
  ?cost_to_punish(Cost);
  ?tokens(OldAmount);
  -+tokens(OldAmount-Cost);
  .all_names(Ags);
  if ( .member(Target,Ags) ) {
    .send(Target,achieve,punish_myself(Round));
  }
  !increase_sanctions_in_round.


{ include("sanction_strategies.asl") }
{ include("controller_strategy.asl") }
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }