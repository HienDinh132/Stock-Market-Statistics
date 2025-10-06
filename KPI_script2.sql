with step1 as
(
select * from (  
select t.[Ngay] as Ngay, t.Ma_ck, t.Price, t.Price_previous_day,  
Round(((t.Price - t.Price_previous_day) / t.Price_previous_day),4) as [% tang_gia]  
from (  
select f.Ngay, f.[Ma_ck], f.Price,  
LAG (Price, 1, 0)   
OVER (PARTITION BY Ma_ck ORDER BY [Ngay]) AS Price_previous_day  
from fact_gia f ) t  
where t.Price_previous_day != 0 ) g
),
step2_1 as
(
select dn.Ma_ck, d1.ten_nganh as phan_nganh_lv1
from dim_phan_nganh dn
left join
(select * from dim_nganh_lv1) d1
on dn.id_phan_nganh = d1.id
where phan_loai like '%1'
),
step2_2 as
(
select dn.Ma_ck, d5.ten_nganh as phan_nganh_lv5
from dim_phan_nganh dn
left join
(select * from dim_nganh_lv5) d5
on dn.id_phan_nganh = d5.id
where phan_loai like '%5'
)
,
step2 as
(
select a.Ma_ck, a.phan_nganh_lv1, b.phan_nganh_lv5 
from step2_1 as a
left join step2_2 as b
on a.Ma_ck = b.Ma_ck
)
select DATEFROMPARTS(year(step1.Ngay), MONTH(step1.Ngay), Day(step1.Ngay)) as [Ngày],
step1.Ma_ck as [Mã chứng khoán], step2.[phan_nganh_lv1] as [Phân ngành cấp 1], step2.phan_nganh_lv5 as [Phân ngành cấp 5],
step1.Price as [Giá], step1.Price_previous_day as [Giá phiên trước], 
Cast((step1.[% tang_gia] * 100) as varchar) + ' %' as [% tăng giá]
from step1
left join step2 
on step1.Ma_ck = step2.Ma_ck
order by step1.Ngay desc, step2.[phan_nganh_lv1] desc, step2.[phan_nganh_lv5] desc
