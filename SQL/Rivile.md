Get data from GL
```
SELECT * 
FROM dbo.I03_DKD d
left join dbo.I02_DKH h ON d.I03_KODAS_DH = h.I02_KODAS_DH
where (I03_KODAS_SSD = '2711' or I03_KODAS_SSC = '2711')
--and h.I02_OP_DATA >= '2025-11-07'
order by h.I02_OP_DATA
```
