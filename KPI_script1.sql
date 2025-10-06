with step1 as
(
SELECT 
*
FROM
    (
        SELECT f.Ma_ck, f.Ngay, f.Phan_loai, f.[Value_nghin_vnd]
        FROM fact_gtm f
    ) AS src
PIVOT
(
    SUM([Value_nghin_vnd])
    FOR Phan_loai IN ([Tổ chức nước ngoài], [Tổ chức trong nước], [Cá nhân nước ngoài], [Cá nhân trong nước])
) AS pvt
), 
step2 as 
(
SELECT 
*
FROM
    (
        SELECT ftd.Ma_ck, ftd.Gia_tri_mua_trieu_vnd, ftd.Ngay, ftd.Phan_loai
        FROM fact_tu_doanh ftd
    ) AS src
PIVOT
(
    SUM(Gia_tri_mua_trieu_vnd)
    FOR Phan_loai IN ([Tu doanh])
) AS pvt
),
step3 as
(
select step1.Ma_ck as [Mã chứng khoán], DATEFROMPARTS(YEAR(step1.Ngay), Month(step1.Ngay), Day(step1.Ngay)) as [Ngày],
step1.[Tổ chức nước ngoài], step1.[Tổ chức trong nước], step1.[Cá nhân nước ngoài], step1.[Cá nhân trong nước], step2.[Tu doanh] as [Tự doanh]
from step1 
left join step2 on step1.Ma_ck = step2.Ma_ck and step1.Ngay = step2.Ngay
where step2.Ma_ck is not null
)
select step3.[Ngày], step3.[Mã chứng khoán], step4.Price as [Giá], 
step3.[Cá nhân nước ngoài], step3.[Cá nhân trong nước], step3.[Tổ chức nước ngoài], step3.[Tổ chức trong nước], step3.[Tự doanh]
from step3
left join (select * from fact_gia) step4
on step3.[Ngày] = step4.Ngay and step3.[Mã chứng khoán] = step4.Ma_ck
order by step3.[Ngày]
