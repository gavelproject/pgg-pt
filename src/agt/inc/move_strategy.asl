+!play_move
: move_strategy(prospector)
<-	!check_new_pool_mates;
	!estimate_incomes;
	?defect_utility(Mu);
	jia.abs(Mu,MuAbs);

	// Sigmoid function
	X = (Mu/(1+MuAbs)+1)/2;

	if ( .random(N) & N < X ) {
		-+move(defect);
		contribute(0);
	} else {
		-+move(cooperate);
		contribute(1);
	}.

+?defect_utility(Mu)
<-	?current_round(T);
	?income_cooperation(T,Ic);
	?income_defect(T,Id);
	?cooperation_cost(C);
	?gain_loss_utility(C,Ic-Id,Mu).

+!check_new_pool_mates
<-	for ( pool_member(Player) &
			not .my_name(Player) &
			not punishments_received(Player,_) &
			not defections_towards(Player,_) ) {
		+punishments_received(Player,0);
		+defections_towards(Player,0);
	}.

+?gain_loss_utility(Gain,Loss,Mu)
<-	?gain_loss_utility_coeff(Eta);
	?loss_aversion_coeff(Lambda);
	Mu = Eta*Gain-Eta*Lambda*Loss.

+!estimate_incomes
<-	?benefit_factor(Phi);
	?cooperation_cost(C);
	.count(pool_member(Player),GroupSize);
	?freerider_mates(NumFreeriders)
	?current_round(T);

	!income_cooperation(Phi,C,GroupSize,NumFreeriders,Ic);
	+income_cooperation(T,Ic);

	!income_defect(Phi,C,GroupSize,NumFreeriders,Id);
	+income_defect(T,Id).

+!income_cooperation(Phi,C,GroupSize,NumFreeriders,Ic)
<-	Ic = Phi*C*(GroupSize-NumFreeriders)/GroupSize.

+!income_defect(Phi,C,GroupSize,NumFreeriders,Id)
<-	?prob_being_punished(Rho);
	?cost_being_punished(Delta);
	Id = Phi*C*(GroupSize-1-NumFreeriders)/GroupSize-(GroupSize-1)*Rho*Delta.

+?freerider_mates(NFreeriders)
<-	?min_img_cooperator(MinImgCoop);
	.count(	pool_member(Player) &
			overall_img(Player,ImgValue) &
			ImgValue < MinImgCoop,
		NFreeriders
	).

+?prob_being_punished(PBP)
<-	.findall(P,pool_member(P) & not .my_name(P),PoolMates);
	!sum_prob_being_punished(PoolMates,Sum);
	PBP = 1*Sum/.length(PoolMates).

+!sum_prob_being_punished([H|T],Sum)
<-	!sum_prob_being_punished(T,PartialSum);
	?punishments_received(H,P);
	?defections_towards(H,D);
	Sum = (P+0**D)/(D+2*0**D) + PartialSum.

+!sum_prob_being_punished([],0).

+!play_move
: move_strategy(cooperator)
<-	-+move(cooperate);
	contribute(1).

+!play_move
: move_strategy(freerider)
<-	-+move(defect);
	contribute(0).

+?freeriders_ratio(FRRatio)
<-	?freerider_mates(NumFrs);
	// GroupSize-1 = group size without me
	.count(pool_member(_),GroupSize);
	FRRatio = NumFrs/(GroupSize-1).

+!assess_pool_members_image
<-	?freeriders_ratio(FRRatio);
	?max_percentage_freeriders(MaxFrPercent);
	if (FRRatio > MaxFrPercent) {
		+too_many_freeriders;
	} else {
		+~too_many_freeriders;
	}.

+!move(defect)
: move_strategy(prospector)
<-	for ( pool_member(Player) & not .my_name(Player) ) {
		?defections_towards(Player,N);
		-+defections_towards(Player,N+1);
	}.
