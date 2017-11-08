+!play_move
: move_strategy(cooperator) |
	move_strategy(nice) |
	(move_strategy(mean) & not too_many_freeriders)
<--+move(contribute);
	contribute(1).

+!play_move
: move_strategy(freerider) |
	(move_strategy(mean) & too_many_freeriders)
<--+move(defect);
	contribute(0).

+!assess_pool_members_image
<-?min_img_cooperator(MinCoop);
	.count(
		pool_member(Player) &
			overall_img(Player,ImgValue) &
			ImgValue < MinCoop,
		NumFrs
	);

	// GroupSize-1 = group size without me
	.count(pool_member(_),GroupSize);
	FrPercent =	NumFrs/(GroupSize-1);

	?max_percentage_freeriders(MaxFrPercent);
	if (FrPercent > MaxFrPercent) {
		+too_many_freeriders;
	} else {
		+~too_many_freeriders;
	}.
