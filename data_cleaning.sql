--cleaning data in sql queries

--Standardize date format

select saledatecoverted,convert(date,saledate) from nashvillehousing

update nashvillehousing
set saledate=convert(date,saledate);

alter table nashvillehousing
add saledateconverted date;

update nashvillehousing
set saledatecoverted=convert(date,saledate)
----------------------------------------------------------------------------------------------------------
--populate property address data

select a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress,isnull(a.propertyaddress,b.PropertyAddress) 
from nashvillehousing a
join nashvillehousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress= isnull(a.propertyaddress,b.propertyaddress)
from nashvillehousing a
join nashvillehousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
----------------------------------------------------------------------------------------------------
--breaking out address into individual columns(address,city,state)

select propertyaddress 
from nashvillehousing

select 
SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) as address,
SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1,len(propertyaddress)) as address
from nashvillehousing

alter table nashvillehousing
add propertysplitaddress nvarchar(255)

update nashvillehousing
set Propertysplitaddress=SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1)

alter table nashvillehousing
add propertysplitcity nvarchar(255)

update nashvillehousing
set propertysplitcity=SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1, len(propertyaddress))

select * from nashvillehousing;

select owneraddress from nashvillehousing;

select
parsename(replace(owneraddress,',','.'),3)
,parsename(replace(owneraddress,',','.'),2)
,parsename(replace(owneraddress,',','.'),1)
from nashvillehousing;

alter table nashvillehousing
add ownersplitaddress nvarchar(255)

update nashvillehousing
set ownersplitaddress=parsename(replace(owneraddress,',','.'),3)

alter table nashvillehousing
add ownersplitcity nvarchar(255)

update nashvillehousing
set ownersplitcity=parsename(replace(owneraddress,',','.'),2)

alter table nashvillehousing
add ownersplitstate nvarchar(255)

update nashvillehousing
set ownersplitstate=parsename(replace(owneraddress,',','.'),1)

select * from nashvillehousing;
----------------------------------------------------------------------------------------------------------------
--change y and n to yes and no  in "sold as vacant" field

select distinct(soldasvacant),count(soldasvacant)
from nashvillehousing
group by SoldAsVacant
order by 2;
 

select soldasvacant
, case when SoldAsVacant='y' then 'yes'
  when soldasvacant='n' then 'no'
  else soldasvacant
  end
  from nashvillehousing;

  update nashvillehousing
  set soldasvacant= case when SoldAsVacant='y' then 'yes'
  when soldasvacant='n' then 'no'
  else soldasvacant
  end
------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

with rownumCTE as (
select *,
       row_number() over (
	   partition by parcelid,
	   propertyaddress,
	   saledate,
	   legalreference
	   order by 
	   uniqueid )
	   row_num
	   from nashvillehousing
	   --order by parcelid
	   )
select * from rownumcte
where row_num>1
--order by PropertyAddress;
----------------------------------------------------------------------------------------------
-- delete unused columns

alter table nashvillehousing
drop column owneraddress,taxdistrict,propertyaddress

alter table nashvillehousing
drop column saledate;

select * from nashvillehousing;