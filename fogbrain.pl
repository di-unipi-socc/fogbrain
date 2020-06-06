:-qcompile('infra.pl').
:-qcompile('app.pl').
:-qcompile('./src/placer.pl').
:-qcompile('./src/reasoning.pl').
:-use_module(library(lists)).
:-dynamic deployment/4.

%%%% Thresholds to identify overloaded nodes and saturated e2e links%%%%
hwTh(0.5).
bwTh(0.2). 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fogBrain(App, NewPlacement) :-
	deployment(App, Placement, AllocHW, AllocBW),
	reasoningStep(App, Placement, AllocHW, AllocBW, NewPlacement).
fogBrain(App, Placement) :-
	\+deployment(App,_,_,_),
	time(placement(App, Placement)).