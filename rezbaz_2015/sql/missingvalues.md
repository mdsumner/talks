SQL - missing data
========================================================
author: Michael Sumner - Australian Antarctic Division, Hobart
date: 2015-02-18



Challenge 1 - sorting 
===============================================

Write a query that sorts the records in Visited by date, omitting entries for which the date is not known (i.e., is null).

Challenge 2 - testing against null
===============================================

What do you expect this query to produce? 

```{sql, eval=FALSE}
select * from Visited where dated in ('1927-02-08', null);
```

What does it actually produce?

Challenge 3 - pros and cons
============================================================

Databases may use a "special value" rather than **null** to mean "missing" or "nothing here". 

For example, the date "0000-00-00" for a missing date, or -99.0 for a missing salinity or radiation reading (since actual readings cannot be negative). 

What does this simplify? 

What burdens or risks does it introduce?
