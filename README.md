# DebuggingSessionAnalysis

Starting from a new Pharo 11 image, and then the visualization tool itself:

```
Metacello new
    baseline: 'DebuggingSessionAnalysis';
    repository: 'github://bergel/DebuggingSessionAnalysis:main';
    load.
```

You then need a trace to be visualized. Unfortunately, no traces are publicly shared at this moment. 
Once you have a trace, you can open the visualization using the following incantation:

```
DSA new 
	fromFileName: '/Users/alexandrebergel/Downloads/internal-tests/User-V.ston'.
```

You should get a visualization like this:
<img width="1176" alt="image" src="https://github.com/bergel/DebuggingSessionAnalysis/assets/393742/d74ffc73-528d-43c8-bf96-0660b19152ae">
