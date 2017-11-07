+!punish_myself
<-?cost_being_punished(Cost);
	?tokens(OldAmount);
	-+tokens(OldAmount-Cost).

+!gossip(Target,Move)
<-!players_from_other_groups(ReceiverOptions);
	.shuffle(ReceiverOptions,Shuffled);
	.nth(0,Shuffled,Receiver);
	?overall_img(Target,ImgValue);
	.send(Receiver,tell,gossip(Target,ImgValue));
	!decrement_pending_sanctions.

+!punish(Target)
<-?cost_to_punish(Cost);
	?tokens(OldAmount);
	-+tokens(OldAmount-Cost);
	.all_names(Ags);
	if ( .member(Target,Ags) ) {
		.send(Target,achieve,punish_myself);
	}
	!decrement_pending_sanctions.
