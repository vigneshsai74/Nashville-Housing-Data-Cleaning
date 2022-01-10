-- Nashville Housing data cleaning

--Changing Sales Date Format

alter table PortfolioProject..HousingData add SaleDateNew Date;

update PortfolioProject..HousingData set SaleDateNew = convert(Date,SaleDate);

select SaleDateNew from PortfolioProject..HousingData

--Property Addresses Update Nulls
select * from PortfolioProject..HousingData 

update a
set a.PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..HousingData a
join PortfolioProject..HousingData b
on a.ParcelID=b.ParcelID
and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null

-- Splitting Addresses to individual fields

--Property Address Split

alter table PortfolioProject..HousingData add PropertyStreet nvarchar(255);

update PortfolioProject..HousingData set PropertyStreet = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress));


alter table PortfolioProject..HousingData add PropertyCity nvarchar(255);

update PortfolioProject..HousingData set PropertyCity = substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

--Owner Address Split

alter table PortfolioProject..HousingData add OwnerStreet nvarchar(255);

update PortfolioProject..HousingData set OwnerStreet = Parsename(replace(OwnerAddress,',','.'),3)


alter table PortfolioProject..HousingData add OwnerCity nvarchar(255);

update PortfolioProject..HousingData set OwnerCity = Parsename(replace(OwnerAddress,',','.'),2)

alter table PortfolioProject..HousingData add OwnerState nvarchar(255);

update PortfolioProject..HousingData set OwnerState = Parsename(replace(OwnerAddress,',','.'),1)

-- Updating Y and N to Yes and No
select SoldAsVacant,Count(SoldAsVacant) from PortfolioProject..HousingData group by SoldAsVacant order by Count(SoldAsVacant)

update PortfolioProject..HousingData
set SoldAsVacant=
case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No' 
else SoldAsVacant 
end

-- Removing Duplicates
with RowNumCTE as
(
select *,
ROW_NUMBER() over (
partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueID) row_num
from PortfolioProject..HousingData
)
select * from RowNumCTE where row_num>1

--Deleting Unused Columns

alter table PortfolioProject..HousingData drop column OwnerAddress, SaleDate, TaxDistrict, PropertyAddress

select * from PortfolioProject..HousingData

--Deleting null values
delete from PortfolioProject..HousingData where UniqueID is null 
or ParcelID is null 
or LandUse is null
or SalePrice is null
or LegalReference is null
or SoldAsVacant is null
or OwnerName is null
or Acreage is null
or LandValue is null
or BuildingValue is null
or TotalValue is null
or YearBuilt is null
or Bedrooms is null
or FullBath is null
or HalfBath is null
or SaleDateNew is null
or PropertyStreet is null
or PropertyCity is null
or OwnerStreet is null
or OwnerCity is null
or OwnerState is null

