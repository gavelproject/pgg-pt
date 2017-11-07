+!report(NormInstance)
<-norm(_,_,_,_,target(Target),_,_,_)[H|T] = NormInstance;
	if ( .member(violation_time(_),[H|T]) & Target \== Me ) {
		!evaluate(NormInstance);
	}.