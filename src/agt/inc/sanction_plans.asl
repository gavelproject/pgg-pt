+!punish_myself
<-?cost_being_punished(Cost);
	?tokens(OldAmount);
	-+tokens(OldAmount-Cost).

+!gossip(Target,ImgValue)
<-!players_from_other_groups(ReceiverOptions);
	.shuffle(ReceiverOptions,Shuffled);
	.nth(0,Shuffled,Receiver);
	.send(Receiver,tell,gossip(Target,ImgValue));
	!add_applied_sanction(Target,gossip);
	!decrement_pending_sanctions.

+!punish(Target)
<-?cost_to_punish(Cost);
	?tokens(OldAmount);
	-+tokens(OldAmount-Cost);
	.all_names(Ags);
	if ( .member(Target,Ags) ) {
		.send(Target,achieve,punish_myself);
	}
	!add_applied_sanction(Target,punishment);
	!decrement_pending_sanctions.

+!add_applied_sanction(Target,Sanction)
<-?current_round(Round);
	+applied_sanction(Target,Sanction,Round).