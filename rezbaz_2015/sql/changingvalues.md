SQL - changing values
========================================================
author: Michael Sumner - Australian Antarctic Division, Hobart
date: 2015-02-18



Challenge 1 - correcting values
===============================================

We realize that Valentina Roerich was reporting salinity as percentages, rather than proportions between 0 and 1. 

Write a query that returns all of her salinity measurements from the Survey table with the values divided by 100.


Challenge 2 - union
===============================================
The union operator combines the results of two queries:
```{sql,eval=FALSE}
select * from Person where ident='dyer' union 
  select * from Person where ident='roe';
```

ident | personal | family
------|----------|--------
dyer  | William  | Dyer
roe	| Valentina	| Roerich

Use union to create a table of all salinity measurements in which Roerich's values have been corrected from percentages to values between 0 and 1. 

Challenge 3 - string operations
===============================================
The site identifiers in the Visited table are letters and numerals separated by '-':

```{sql,eval=FALSE}
select distinct site from Visited;
```
<tiny>
|DR-1   
|DR-3   
|MSK-4   
</tiny>

The function instr(X, Y) returns the index of the first occurrence of string Y in string X. The function substr(X, I) returns the substring of X starting at index I. 

Use these two functions to produce a table of only the letters from Site. (i.e. "DR" and "MSK")
