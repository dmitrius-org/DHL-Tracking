--SQL CreateDB
if db_id('TrackTraceDB') is null
  create database TrackTraceDB;
go
--SQL useDB
use TrackTraceDB;
go

--SQL CreateDBSructure
--создание структуры базы данных TrackTraceDB
use TrackTraceDB;

--tShipments - номера доставки                
if OBJECT_ID('tShipments') is null  
begin              
    create table tShipments 
    (
     Number         nvarchar(510) 
    ,Status         nvarchar(60) 
    ,InDate         DateTime default GetDate()
    ,DateRefresh    datetime
    );
                    
    create unique index pk1 on tShipments(Number);
                    
    grant all on tShipments to public; 
end

-- tShipmentsTrack - статусы доставки
if OBJECT_ID('tShipmentsTrack') is null
begin
    create table tShipmentsTrack
    (
     Number         nvarchar(510) 
    ,Date           DateTime
    ,Status         nvarchar(60) 
    ,Description    nvarchar(500) 
    ,InDate         DateTime default GetDate()
    -- FOREIGN KEY (Number) REFERENCES tShipments (Number) ON DELETE CASCADE
    );
    create index ao1 on tShipmentsTrack(Number);
    grant all on tShipmentsTrack to public;  
end

-- tTaskLog - Таблица лога выполнения шедулера
if OBJECT_ID('tTaskLog') is null
begin
    create table tTaskLog
    (
     ID             Numeric(18, 0) identity  
    ,InDate         DateTime default GetDate()
    ,MessageType    nvarchar(60) 
    ,MessageText    nvarchar(1000)
    );
    --create index ao1 on tTaskLog(ID);
    grant all on tTaskLog to public;                          
end   

-- pShipmentsTrack - временная таблица статусы доставки
if OBJECT_ID('pShipmentsTrack') is null
begin
    create table pShipmentsTrack
    (
     Number         nvarchar(510) 
    ,Date           DateTime
    ,Status         nvarchar(60) 
    ,Description    nvarchar(500) 
    );
    create index ao1 on pShipmentsTrack(Number, Date, Status);
    grant all on pShipmentsTrack to public;                          
end  

-- tShippingMethod - Способы доставки
if OBJECT_ID('tShippingMethod') is null
begin
    create table tShippingMethod
    (
     Id             int
    ,Name           nvarchar(255) 
    ,isActive       bit 
    );
    create index ao1 on tShippingMethod(Id);
    grant all on tShippingMethod to public;
    
    -- добавление списка способов доставки
    Insert tShippingMethod (Id, Name, isActive)
    select t.kVersandArt, t.cname, 0
      from [eazybusiness].[dbo].[tversandart] t (nolock)
     where not exists (select 1 from tShippingMethod p with (nolock index=ao1) where p.id = t.kVersandArt)
end 


go
--SQL ShipmentsUpdate
-- Обновление списока номеров по которым нужно получить данные

insert [tShipments] (Number)
SELECT distinct
       v.[cIdentCode]
  FROM [eazybusiness].[dbo].[tVersand] as v (nolock)
 inner join tShippingMethod as sm (nolock) 
         on sm.id       = v.kVersandArt
        and sm.isActive = 1
 where isnull(cReference, '') <> ''
   and v.[dErstellt] >= convert(datetime, :BeginDate)
   and isnull(v.[cIdentCode], '') <> ''
   and not exists (select 1
                     from [tShipments] s with (nolock index=pk1)
                    where s.Number COLLATE Latin1_General_CI_AS = v.[cIdentCode])

   -- order by v.[dErstellt] desc

go

--SQL ShipmentInsert
declare @J as NVARCHAR(MAX)
select @J = :J

delete pShipmentsTrack from pShipmentsTrack (rowlock)
INSERT INTO pShipmentsTrack 
      ([Number], [Date], [Status], [Description])
SELECT id,
       timestamp,
       statusCode,
       description
  FROM OPENJSON(@J) WITH (
        id       NVARCHAR(255) '$.id'
       ,[events] NVARCHAR(MAX) '$.events' AS JSON)
   OUTER APPLY OPENJSON([events]) WITH (
         statusCode  NVARCHAR(255) '$.statusCode', 
         description NVARCHAR(255) '$.description',
         timestamp   NVARCHAR(255) '$.timestamp');

insert into tShipmentsTrack
       (Number
       ,Date
       ,Status
       ,Description)
select  p.Number
       ,p.Date
       ,p.Status
       ,p.Description
  from pShipmentsTrack p (nolock)
 where not exists(select 1
                    from tShipmentsTrack t (nolock)
                   where t.Number = p.Number
                     and t.Date   = p.Date
                     and t.Status = p.Status)
                               
   Update s
      set s.Status      = case
                            when st.Status = 'delivered'
                            then 'delivered'
                            else s.Status
                          end
         ,s.DateRefresh = getdate()
     from pShipmentsTrack st (nolock)
    inner join tShipments s (updlock)
            on s.Number = st.Number

go

