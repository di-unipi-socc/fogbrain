<p><img align="left"  src="http://pages.di.unipi.it/forti/fogbrain/img/logo.png" width="100"> <h1>FogBrain</h1></p>

_continuous reasoning for managing next-gen distributed applications_

<br></br>

FogBrain methodology is fully described in the following article:

> [Stefano Forti](http://pages.di.unipi.it/forti), [Antonio Brogi](http://pages.di.unipi.it/brogi)<br>
> [**Continuous Reasoning for Managing Next-Gen Distributed Applications**](https://doi.org/10.4204/EPTCS.325.22), <br>	
> ICLP 2020 (Technical Communications), EPTCS, vol. 325, pp. 164–177, 2020. 

If you wish to reuse source code in this repo, please consider citing it.

## Background & Prerequisites

FogBrain is written in Prolog. Prolog programs are finite sets of *clauses* of the form:

```prolog
a :- b1, ... , bn.
```

stating that `a` holds when `b1` and ... and `bn` holds, where `n =< 0` and `a`, `b1` ..., `bn` are atomic literals. Clauses with empty condition are also called *facts*. Prolog variables begin with upper-case letters, lists are denoted by square brackets, and negation by `\+`.

Before using **FogBrain** you need to install the latest stable release of [SWI-Prolog](https://www.swi-prolog.org/download/stable).

## QuickStart & Interactive Docs

All information on FogBrain can be found [here](http://pages.di.unipi.it/forti/fogbrain/index.html), along with a [quickstart example](http://pages.di.unipi.it/forti/fogbrain/quickstart.html) and [interactive documentation](http://pages.di.unipi.it/forti/fogbrain/docs.html) on the current release.

## Tutorial

To try **FogBrain**:

1. Download or clone this repository.

2. Open a terminal in the project folder and run `swipl fogbrain.pl`.

3. Inside the running program either run the query
   ```prolog
   :- fogBrain(vrApp, P).
   ``` 
   The output will be a first placement for the application described in `app.pl` onto the infrastructure described in `infra.pl`. 
   E.g.
   ```prolog
   %7,955 inferences, 0.000 CPU in 0.006 seconds (0% CPU, Infinite Lips)
   P = [on(vrDriver, accesspoint9), on(sceneSelector, cabinetserver0), on(videoStorage, cloud0)]
   ```

4. Open the file `infra.pl` and change some of the links or nodes involved in the placement output at step 3. 
   E.g.
   ```prolog
	node(cloud0,[ubuntu, mySQL, gcc, make], inf, []). --> node(cloud0,[], inf, []).
   ```

5. Repeat step 3. The output will only compute a new placement for suffering services (i.e. mapped onto overloaded nodes, or relying upon saturated end-to-end links for interacting with other services) and require many less inferences with respect to computing the initial placement. E.g.
	```prolog
	2 ?- fogBrain(vrApp,P).
	% 387 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)  
	P = [on(videoStorage, cloud1), on(vrDriver, accesspoint9), on(sceneSelector, cabinetserver0)] 
	```
In this example the new placement is computed by saving around 95% of inferences with respect to the first deployment.

