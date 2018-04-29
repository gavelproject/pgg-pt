+!play_move
: move_strategy(prospector)
<-	!check_new_pool_mates;
	!estimate_incomes;
	?defect_utility(MuD);
	?cooperate_utility(MuC);
	jia.abs(MuD,MuDAbs);
	jia.abs(MuC,MuCAbs);

	// Normalisation
	MuDN = (MuD/(1+MuDAbs)+1)/2;
	MuCN = (MuC/(1+MuCAbs)+1)/2;

	ProbCoop = (MuCN+(1-MuDN))/2

	if ( .random(N) & N < ProbCoop ) {
		-+move(cooperate);
		contribute(1);
	} else {
		-+move(defect);
		contribute(0);
	}.

+?cooperate_utility(Mu)
<-	?current_round(T);
	?income_cooperation(T,Ic);
	?income_defect(T,Id);
	?cooperation_cost(C);
	?gain_loss_utility(Ic-Id,C,U);
	Mu = Ic + U.

+?defect_utility(Mu)
<-	?current_round(T);
	?income_cooperation(T,Ic);
	?income_defect(T,Id);
	?cooperation_cost(C);
	?gain_loss_utility(C,Ic-Id,U);
	Mu = Id + U.

+!check_new_pool_mates
<-	for ( pool_member(Player) &
			not .my_name(Player) &
			not punishments_received(Player,_) &
			not defections_towards(Player,_) ) {
		+punishments_received(Player,0);
		+defections_towards(Player,0);
	}.

+?gain_loss_utility(Gain,Loss,U)
<-	?gain_loss_utility_coeff(Eta);
	?loss_aversion_coeff(Lambda);
	U = Eta*Gain-Eta*Lambda*Loss.

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
	PBP = Sum/.length(PoolMates).

+!sum_prob_being_punished([H|T],Sum)
<-	!sum_prob_being_punished(T,PartialSum);
	?punishments_received(H,P);
	?defections_towards(H,D);
	if (D == 0) {
		.random(X);
		Sum = X + PartialSum;
	} else {
		Sum = P/D + PartialSum;
	}.

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

+move(defect)
: move_strategy(prospector)
<-	for ( pool_member(Player) & not .my_name(Player) ) {
		?defections_towards(Player,N);
		-defections_towards(Player,N);
		+defections_towards(Player,N+1);
	}.
