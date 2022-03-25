# Anycast Agility: Tangled Datasets and Tools   

Here you can find dataset and tools used in our experiments described on the paper [Anycast Agility: Network Playbooks to Fight DDoS](https://ant.isi.edu/bib/Rizvi22a.html). We provide tools and resources to reproduce the figures on the paper. 

We based our investigation on jupyter notebook. You can find the following notebooks:

- *BGP poisoning*: Experiments on Tangled testbed using BGP poisoning traffic engineering technicque [[playbook]](https://github.com/LMBertholdo/anygility-pynb-usenix/blob/main/ddos-poison-fig14/graph-poison-path.ipynb) 
- *Catchment Distribution*: Experiments on catchment distribution using different setups [[playbook]](https://github.com/LMBertholdo/anygility-pynb-usenix/blob/main/playbook_analysis/Playbook-Analysis-Tangled-Catchment-load-distribution.ipynb)
- [tangled-catchment-distribution-fig6](https://github.com/LMBertholdo/anygility-pynb-usenix/blob/main/tangled-catchment-distribution-fig6/Tangled-Catchment-load-distribution-usenix-fig6.ipynb): Catchment distribution analysis
- [tangled-catchment-prepend](https://github.com/LMBertholdo/anygility-pynb-usenix/blob/main/tangled-catchment-prepend/Tangled-Catchment-load-distribution.ipynb): Analysis of path prepend impact on the Tangled testbed

*** NEW ***
- [Anygility-Tangled-Catchment-load-distribution](https://github.com/LMBertholdo/anygility-pynb-usenix/blob/main/tangled-catchment-distribution-fig6/Anygility-Tangled-Catchment-load-distribution.ipynb): Catchment distribution analysis (for different dataset versions)
Same experiment can be run with one of several different datasets available. Select by uncommenting.

Each notebook have a dataset on directory as example. Those notebooks were used to create paper figures as indicated (fig6,fig14).

More information and datasets can be found at [Datasets About Anycast Agility Against DDoS in Tangled Testbed](https://ant.isi.edu/datasets/anycast/anycast_against_ddos/tangled/index.html)
