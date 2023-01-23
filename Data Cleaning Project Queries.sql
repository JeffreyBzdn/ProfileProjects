/*

Cleaning data in SQL querries.

*/

Select *
From PortfolioProject..NashvilleHousing

Select SaleDateConverted, Convert(date, SaleDate)
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
Set SaleDateConverted = Convert(date, SaleDate)

--Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelId
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelId
	and a.[UniqueID] <> b.[UniqueID]


--Breaking out Address into different columns (Address,City,State)
Select PropertyAddress
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select 
Substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, Substring (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , Len(PropertyAddress)) AS Address
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress nvarchar(250);

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = Substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity nvarchar(250);

Update PortfolioProject..NashvilleHousing
Set PropertySplitCity = Substring (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , Len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

Select 
Parsename(Replace(OwnerAddress, ',', '.'), 3) as Address
,Parsename(Replace(OwnerAddress, ',', '.'), 2) as City 
,Parsename(Replace(OwnerAddress, ',', '.'), 1) as State
From PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
add OwnnerSplitAddres nvarchar(250);

Update PortfolioProject..NashvilleHousing
Set OwnnerSplitAddres = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(250);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter table PortfolioProject..NashvilleHousing
add OwnnerSplitState nvarchar(250);

Update PortfolioProject..NashvilleHousing
Set OwnnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" Field

Select distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END
From PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END

	   ----------------------------------------------------------------------------------------------------------

--Remove Duplicates

With ROWNUMCTE AS(
Select *,
	Row_Number () OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
--order by ParcelID
)
Delete 
From ROWNUMCTE
Where row_num > 1
--Order by PropertyAddress

With ROWNUMCTE AS(
Select *,
	Row_Number () OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
--order by ParcelID
)
select *
From ROWNUMCTE
Where row_num > 1

--------------------------------------------------------------------------------------------------
--Delete Unwanted Columns

select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, TaxDistrict

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate