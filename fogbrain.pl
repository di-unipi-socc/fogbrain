:-qcompile('infra.pl').
:-qcompile('app.pl').
:-qcompile('./src/placer.pl').
:-qcompile('./src/reasoning.pl').
:-use_module(library(lists)).
:-dynamic deployment/4.

%%%% Thresholds to identify overloaded nodes and saturated e2e links%%%%
bwTh(0.2). hwTh(0.5).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fogBrainT(A, NewP) :- time(fogBrain(A, NewP)).

fogBrain(App, NewPlacement) :-
	deployment(App, Placement, AllocHW, AllocBW),
	consult('infra'),
	time(reasoningStep(App, Placement, AllocHW, AllocBW, NewPlacement)).
fogBrain(App, Placement) :-
	\+deployment(App,_,_,_),
	consult('infra'),
	time(placement(App, Placement)).