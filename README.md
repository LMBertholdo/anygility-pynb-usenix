# Anycast Agility: Tangled Datasets and Tools   

Here you can find the dataset and tools used in our experiments described in the paper [Anycast Agility: Network Playbooks to Fight DDoS](https://ant.isi.edu/bib/Rizvi22a.html). We provide tools and resources to reproduce the figures on the paper. 

We based our investigation on Jupiter notebook. You can find the following notebooks:

- *BGP poisoning*: Experiments on Tangled testbed using BGP poisoning traffic engineering technique [[notebook]](https://github.com/LMBertholdo/anygility-pynb-usenix/blob/main/ddos-poison-fig14/graph-poison-path.ipynb) 
- *Catchment distribution*: Experiments on catchment distribution using different setups [[notebook]](https://github.com/LMBertholdo/anygility-pynb-usenix/blob/main/playbook_analysis/Playbook-Analysis-Tangled-Catchment-load-distribution.ipynb)
- *BGP AS-PATH prepending*: Experiments using BGP prepending [[notebook]](https://github.com/LMBertholdo/anygility-pynb-usenix/blob/main/tangled-catchment-prepend/Tangled-Catchment-load-distribution.ipynb)


###  NEW 

Due to the volume of data, the above-mentionated notebooks use catchment distribution files as datasets (such as [[this]](https://github.com/LMBertholdo/anygility-pynb-usenix/blob/main/ddos-poison-fig14/poison2/POISON_1149_1149_PINGER-us-mia_DRAIN-nodrain_poa-lnd-mia_2021-04-24-13-34.csv.stats)) instead of the raw files that are much bigger. However, for reproducibility purposes, we provide a new notebook that does the full process (from raw files). 

- [Anygility-Tangled](https://github.com/LMBertholdo/anygility-pynb-usenix/blob/main/tangled-catchment-distribution-fig6/Anygility-Tangled-Catchment-load-distribution.ipynb) 

# Datasets

More information and datasets can be found at [Datasets About Anycast Agility Against DDoS in Tangled Testbed](https://ant.isi.edu/datasets/anycast/anycast_against_ddos/tangled/index.html)
