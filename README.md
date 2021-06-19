# Brammer

Based on expression profiles, this Brammer applification could subtyping brain tumor patients with different immune infiltration signatures (i.e. C1/2 subtypes). The C1 subtype enriches for a constellation of protective markers for prognosis, such as high infiltration of CD8+ T cells and nature killer cells. The C2 subtype has an extensive infiltration of tumor-associated macrophages and microglia, and was enriched with immune suppressive, wound healing and angiogenic signatures.



# Install

To install the package, please execute the following command.

```bash
devtools::install_github("xilinshen/brammer")
```



# Usage

#### Data preprocessing

The gene expression should be normalized as CPM values. Please make sure each row of expression matrix represent a patient and each column represent a Hugo Symbol of human gene.



Here's an example :



```R
load(system.file("data/CGGA_toydata.rda",package = "brammer"))
head(data)
```

<table class="dataframe">
<caption>A data.frame: 6 × 23987</caption>
<thead>
	<tr><th></th><th scope=col>A1BG</th><th scope=col>A1BG.AS1</th><th scope=col>A2M</th><th scope=col>A2M.AS1</th><th scope=col>A2ML1</th><th scope=col>A2MP1</th><th scope=col>A3GALT2</th><th scope=col>A4GALT</th><th scope=col>AAAS</th><th scope=col>AACS</th><th scope=col>...</th><th scope=col>ZYX</th><th scope=col>ZZEF1</th><th scope=col>ZZZ3</th><th scope=col>hsa.mir.1199</th><th scope=col>hsa.mir.125a</th><th scope=col>hsa.mir.335</th><th scope=col>hsa.mir.6080</th><th scope=col>hsa.mir.6723</th><th scope=col>hsa.mir.7162</th><th scope=col>hsa.mir.8072</th></tr>
	<tr><th></th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>...</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
	<tr><th scope=row>CGGA_1002_B</th><td>68.65</td><td>3.85</td><td>107.13</td><td>0.22</td><td>0.76</td><td>0.25</td><td>0.05</td><td>4.18</td><td>34.94</td><td>33.29</td><td>...</td><td>100.92</td><td> 6.11</td><td>14.06</td><td>51.53</td><td>0.06</td><td>0.03</td><td>13.28</td><td>163.33</td><td>0.00</td><td>5.18</td></tr>
	<tr><th scope=row>CGGA_1003_B</th><td>14.06</td><td>1.52</td><td> 44.50</td><td>0.09</td><td>2.28</td><td>0.05</td><td>0.16</td><td>0.86</td><td>51.14</td><td> 4.62</td><td>...</td><td> 53.37</td><td>27.50</td><td> 4.25</td><td>15.61</td><td>0.26</td><td>0.08</td><td>12.16</td><td>402.29</td><td>0.05</td><td>3.59</td></tr>
	<tr><th scope=row>CGGA_1010_B</th><td> 5.28</td><td>1.08</td><td> 11.15</td><td>0.17</td><td>0.17</td><td>0.04</td><td>0.00</td><td>0.15</td><td> 9.99</td><td> 1.65</td><td>...</td><td>  4.91</td><td> 9.21</td><td> 4.92</td><td> 1.21</td><td>0.00</td><td>0.07</td><td> 0.61</td><td>  0.43</td><td>0.00</td><td>0.66</td></tr>
	<tr><th scope=row>CGGA_1014_B</th><td>93.44</td><td>4.86</td><td> 75.97</td><td>0.28</td><td>2.20</td><td>0.77</td><td>0.56</td><td>3.24</td><td>44.31</td><td>24.16</td><td>...</td><td>175.54</td><td> 6.63</td><td> 7.72</td><td>22.21</td><td>0.16</td><td>0.06</td><td>12.18</td><td>172.12</td><td>0.05</td><td>4.13</td></tr>
	<tr><th scope=row>CGGA_1017_B</th><td>18.85</td><td>3.37</td><td> 51.23</td><td>0.59</td><td>0.86</td><td>0.16</td><td>0.10</td><td>1.26</td><td>14.95</td><td>26.65</td><td>...</td><td> 28.76</td><td> 9.52</td><td>14.64</td><td>17.09</td><td>0.08</td><td>0.05</td><td> 5.73</td><td> 98.53</td><td>0.00</td><td>1.18</td></tr>
	<tr><th scope=row>CGGA_1018_B</th><td>27.46</td><td>2.80</td><td> 38.94</td><td>0.18</td><td>2.47</td><td>0.04</td><td>0.06</td><td>1.28</td><td>54.66</td><td>10.59</td><td>...</td><td> 63.36</td><td>12.81</td><td>17.60</td><td>14.39</td><td>0.33</td><td>0.10</td><td>12.74</td><td> 73.55</td><td>0.06</td><td>5.03</td></tr>
</tbody>
</table>





#### Brain tumor subtyping

Brammer could classifies patients into C1/2 subtypes through expression matrix of brain tumor. 



```R
subtyping_result = brammer::model_predict(data)
head(subtyping_result)
```

<table class="dataframe">
<caption>A data.frame: 6 × 3</caption>
<thead>
	<tr><th></th><th scope=col>C1 probability (%)</th><th scope=col>C2 probability (%)</th><th scope=col>subtype</th></tr>
	<tr><th></th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
	<tr><th scope=row>CGGA_1002_B</th><td>0.977</td><td>0.023</td><td>C1</td></tr>
	<tr><th scope=row>CGGA_1003_B</th><td>0.739</td><td>0.261</td><td>C1</td></tr>
	<tr><th scope=row>CGGA_1010_B</th><td>1.000</td><td>0.000</td><td>C1</td></tr>
	<tr><th scope=row>CGGA_1014_B</th><td>0.228</td><td>0.772</td><td>C2</td></tr>
	<tr><th scope=row>CGGA_1017_B</th><td>0.995</td><td>0.005</td><td>C1</td></tr>
	<tr><th scope=row>CGGA_1018_B</th><td>0.985</td><td>0.015</td><td>C1</td></tr>
</tbody>
</table>





The columns "C1 probability (%)" and "C2 probability (%)" represent the probability that the patients belongs to C1/2 subtypes, respectively. The column "subtype" represent  brain tumor subtypes of patients predict by brammer.



