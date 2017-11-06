+!play_move
  : move_strategy(cooperator) |
    move_strategy(nice)
  <-
  contribute(1).


+!play_move
  : move_strategy(freerider)
  <-
  contribute(0).


+!play_move
  : move_strategy(mean)
  <-
  ?max_fr_percentage_in_group(MaxFrPercent);
  ?fr_percentage_in_group(FrPercent);
  if ( FrPercent > MaxFrPercent) {
    contribute(0);
  } else {
    contribute(1);
  }.


+?fr_percentage_in_group(Percentage)
  <-
  ?min_img_cooperator(MinCoop);
  .count(
    pool_member(Player) &
      overall_img(Player,ImgValue) &
      ImgValue < MinCoop,
    NumFrs
  );
  .count(pool_member(_),GroupSize);
  Percentage =  NumFrs/GroupSize.