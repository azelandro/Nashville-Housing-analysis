select * from PortfolioProject..NationalHousing

--This exercise is to perform Data cleaning with SQL

-- First, we create a new column to have the correct sale date format.
select saledate from PortfolioProject..NationalHousing

alter table PortfolioProject..NationalHousing
add Saledate_converted date

select saledate_converted from PortfolioProject..NationalHousing

update PortfolioProject..NationalHousing
set saledate_converted = convert(date,saledate)

--Populate property address data

select n.UniqueID,n.ParcelID, n.PropertyAddress, o.uniqueID,o.ParcelID, o.PropertyAddress, ISNULL(n.PropertyAddress, o.PropertyAddress) 
from PortfolioProject..NationalHousing n
join PortfolioProject..NationalHousing o on 
n.ParcelID = o.ParcelID
and n.uniqueID <> o.uniqueID
where n.PropertyAddress is NULL
--order by ParcelID

update n
set n.propertyAddress = ISNULL(n.PropertyAddress, o.PropertyAddress) 
from PortfolioProject..NationalHousing n
join PortfolioProject..NationalHousing o on 
n.ParcelID = o.ParcelID
and n.uniqueID <> o.uniqueID

----------------------------------------------------------------------
-- Breaking out Address into individual columns (Address, City, State)

select substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1),
substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(Propertyaddress))
as Address from
PortfolioProject..NationalHousing

Alter table PortfolioProject..NationalHousing
add PropertySplitAddress Nvarchar(255),
PropertySplitCity Nvarchar(255)

update PortfolioProject..NationalHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)
from PortfolioProject..NationalHousing

update PortfolioProject..NationalHousing
set PropertySplitCity = substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(Propertyaddress))
from PortfolioProject..NationalHousing

select PropertySplitCity from PortfolioProject..NationalHousing

-- To break owner address
--The parsename function also splits the data by a delimeter, but it only splits with '.',
-- so we have to first replace the ',' with a '.' 
select parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NationalHousing

-- Now to create new columns to put the addressses to put into.
Alter table PortfolioProject..NationalHousing
add OwnerSplitAddress Nvarchar(255),
OwnerSplitCity Nvarchar(255),
OwnerSplitState Nvarchar(255)

update PortfolioProject..NationalHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3),
OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2),
OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1) 


---------------------------------------------------------------------
-- Change all Y values to and N values to No
Select SoldAsVacant,
CASE when SoldASvacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject..NationalHousing

update PortfolioProject..NationalHousing 
set SoldAsVacant = CASE when SoldASvacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


--  Removing duplicates
WITH RowNumCTE as(
Select *, 
	Row_number() over(partition by ParcelID, PropertyAddress, SalePrice,SaleDate,LegalReference order by UniqueID) row_num 
	From PortfolioProject..NationalHousing
	
	)
Delete 
from RowNumCTE
where row_num > 1 
