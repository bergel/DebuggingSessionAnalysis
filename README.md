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
DSA new visualizeFromFileName: '/Users/alexandrebergel/Desktop/User-77cbb221-1daa-0d00-97e1-e4460f54a26b37993377739000'.
```

You should get a visualization like:

<img width="1373" alt="image" src="https://github.com/bergel/DebuggingSessionAnalysis/assets/393742/7d3869ab-9750-4d6a-935a-f42a95d9556f">
